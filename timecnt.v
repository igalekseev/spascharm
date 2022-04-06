`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		 ITEP
// Engineer: 		 SvirLex
// 
// Create Date:    17.03.2022 
// Design Name:    timecounter
// Module Name:    timecounter
// Project Name:   drift board
// Target Devices: xc3S400-PQ208 4C
//
// Revision 0.01 - File Created
// Additional Comments: 
// Set trigger marks for Spascharm @160 MHz
// Output data format:
// Byte Bits             Comment
// 0    11 111111         trigger word signature
// 1    00 trgnum[5:0]    LS bits of trigger number
// 2    00 trgnum[11:6]   next 6 bits of trigger number
// 3    00 trgnum[17:12]  MS bits of trigger number
// 4-9  00 trgtim[35:0]   36 bit 160 MHz time counter
// 10   ...               next trigger
// ..   10 111111         end of cycle signature
// ..   00 cynum[17:0]    18 bit cycle number
//      Each trigger info block is 10 bytes. cycle end block is 4 bytes.
// There is an empty trigger at the end of cycle. Time conuter is reset at cycle begin.
// Registers:
// Address   Name   Comment
//   3(RW)   CSR3   CSR3[1:0] - trigger source select 0 - external (normal), 1 - from CPU, 2 - from emulator, 3 - external trigger, but emulator is on
//                  CSR3[7] - Enable data stream
//   4(W)    RST    RST[0]  - reset all FIFOs, emulate EOC
//                  RST[1]  - reset trigger counter
//                  RST[2]  - reset cycle counter
//					All bits are autoclear
//   4(R)           RST[7] - cycle is on: 1 - beam is on, 0 - no beam
// 12-13(R)  CYNUM  CYNUM[15:0] - cycle counter
// 14-15(R)  TRNUM  TRNUM[15:0] - trigger counter
// 16-19(R)  TMNUM  TMNUM[31:0] - time counter
//     Registers CYNUM, TRNUM, TMNUM are latched on the LS byte readout.
//////////////////////////////////////////////////////////////////////////////////



module timecnt(
	output [1:0] LED,	// LEDs
	input XADR,		// CPU register address strob, active high
	input XCLK,		// 24 MHz main clock
	inout [7:0] XDATA,	// CPU register data
	output [1:0] XIFAD,	// Slave FIFO address - must be 0
	output XIFCLK,		// Slave FIFO output clock (24 MHz)
	output [7:0] XIFDATA,	// Slave FIFO data
	input XIFFULL,		// FIFO full, active (full) - high
	output XIFOE,		// Slave FIFO output enable = 0
	output XIFRD,		// Slave FIFO read = 0
	output XIFWR,		// write to slave FIFO, active HIGH
	input [23:0] XIN,	// signal inputs
	output XPKTE,		// USB PKTEND, active HIGH
	input XRSTR,		// CPU register read strob, active low
	input XTRIG_FX2,	// trigger from CPU
	input XTRIG_IN_N,	// Main trigger, LVDS
	input XTRIG_IN_P,	// Main trigger, LVDS
	output XTRIG_OUT_N,	// Output trigger, LVDS
	output XTRIG_OUT_P,	// Output trigger, LVDS
	input XWSTR,		// CPU register write strob, active low
	output XPWOUT,		// output for rising saw pulse
	input XPAN_P,		// comparator input
	input XPAN_N,		// comparator input
	input XCMP_P,		// comparator input
	input XCMP_N,		// comparator input
	input XINT_P,		// comparator input
	input XINT_N,		// comparator input
	input XNAN_P,		// comparator input
	input XNAN_N		// comparator input
);
//-------------------------------------------
//		Signals
//		Clocks
	wire CLK160;
	wire CLK40;
	wire CLK24;
//		Trigger & cycle
	wire trigin;
	wire trigemu;
	wire trigpulse;
	wire cyclebegin;
	wire cycleend;
	wire cycleon;
//		data to fifo
	wire trigready;
	wire cycleready;
	wire [17:0] trignum;
	wire [35:0] timenum;
	wire [17:0] cyclenum;
//		data to registers
	wire [7:0] fromtrigcnt;
	wire [7:0] fromcyclecnt;
//		data to FIFO
	wire fifobusy;
	wire [7:0] fifodata;
	wire fifowrite;
//
	reg cpuwr = 0;
	reg [7:0] cpuadr = 0;
	reg cpuwrdel = 1;
	reg [7:0] CSR3 = 0;
	reg [7:0] RST = 0;
	reg [7:0] cpurdata = 0;
//-------------------------------------------
//		Permanent output signals etc
	assign XIFAD = 0;
	assign XIFOE = 0;
	assign XIFRD = 0;
	assign XPWOUT = 0;

	IBUFDS #(.IOSTANDARD("DEFAULT")) XPAN_DS (.O(), .I(XPAN_P), .IB(XPAN_N));
	IBUFDS #(.IOSTANDARD("DEFAULT")) XCMP_DS (.O(), .I(XCMP_P), .IB(XCMP_N));
	IBUFDS #(.IOSTANDARD("DEFAULT")) XINT_DS (.O(), .I(XINT_P), .IB(XINT_N));
	IBUFDS #(.IOSTANDARD("DEFAULT")) XNAN_DS (.O(), .I(XNAN_P), .IB(XNAN_N));
	OBUFDS #(.IOSTANDARD("DEFAULT")) OTRIG_DS (.I(trigemu), .O(XTRIG_OUT_P), .OB(XTRIG_OUT_N));

//-------------------------------------------
	
//		DCM
    clkgen u_clk (.xclk(XCLK), .clk24(CLK24), .clk40(CLK40), .clk160(CLK160));
	assign XIFCLK = CLK40;

//	Make trigger pulse
	// IBUFDS: Differential Input Buffer
	//         Spartan-3
	// Xilinx HDL Language Template, version 14.7

	IBUFDS #(
      .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
	) IBUFDS_trig (
      .O(trigin),  // Buffer output
      .I(XTRIG_IN_P),  // Diff_p buffer input (connect directly to top-level port)
      .IB(XTRIG_IN_N) // Diff_n buffer input (connect directly to top-level port)
	);

	trigger u_trig (
		.clk(CLK160), 
		.trigin(trigin), 
		.trigcpu(XTRIG_FX2),
		.trigemu(trigemu),
		.trigsel(CSR3[1:0]),
		.trigpulse(trigpulse),
		.cycleend(cycleend),
		.cyclebegin(cyclebegin),
		.cycleon(cycleon)
	);
	
	emugen u_emu (
		.clk(CLK40), 
		.enable(CSR3[1]), 
		.trigger(trigemu)
	);
	
	trigcnt u_trigcnt (
		.clk(CLK160),
		.trigger(trigpulse),
		.cyclebegin(cyclebegin),
		.reset(RST[1]),
		.ready(trigready),
		.trignum(trignum),
		.timenum(timenum),
		.addr(cpuadr),
		.read(!XRSTR),
		.rdata(fromtrigcnt)
	);
	
	cyclecnt u_cycle (
		.clk(CLK160),
		.cycle(cycleend),
		.reset(RST[2]),
		.ready(cycleready),
		.cyclenum(cyclenum),
		.addr(cpuadr),
		.read(!XRSTR),
		.rdata(fromcyclecnt)
	);

	pushit u_push (
		.clk(CLK160), 
		.clkslow(CLK40), 
		.trigready(trigready), 
		.cycleready(cycleready), 
		.trignum(trignum), 
		.cyclenum(cyclenum), 
		.timenum(timenum), 
		.busy(fifobusy), 
		.data(fifodata), 
		.write(fifowrite)
	);
	
	fifo u_fifo (
		.clk(CLK40), 
		.write(fifowrite), 
		.data(fifodata), 
		.busy(fifobusy), 
		.flag(XIFFULL), 
		.xdata(XIFDATA), 
		.xwrite(XIFWR), 
		.xpkte(XPKTE), 
		.reset(RST[0])
	);
	
	led u_ledA (
		.clk(CLK40), 
		.trig(fifowrite), 
		.out(LED[0])
	);
	
	led u_ledB (
		.clk(CLK40), 
		.trig(!XIFWR), 
		.out(LED[1])
	);	
	
//	CPU registers	
	always @(posedge CLK40) begin
		cpuwrdel <= XWSTR;
		if (XADR & (!XWSTR) & cpuwrdel) begin	// write active low, address- high
			cpuadr <= XDATA;
		end
		RST <= 0;	// auto clear
		if ((!XADR) & (!XWSTR) & cpuwrdel) begin
			case (cpuadr)
			3 : begin
					CSR3 <= XDATA;
				end
			4 : begin
					RST <= XDATA;
				end
			default : begin
					end
			endcase
		end
		case (cpuadr) 
		3 : begin
				cpurdata <= CSR3;
			end
		4 : begin 
				cpurdata <= {cycleon,7'h00};
			end 
		12 :
			begin
				cpurdata <= fromcyclecnt;
			end
		13 :
			begin
				cpurdata <= fromcyclecnt;
			end
		14 :
			begin
				cpurdata <= fromtrigcnt;
			end
		15 :
			begin
				cpurdata <= fromtrigcnt;
			end
		16 :
			begin
				cpurdata <= fromtrigcnt;
			end
		17 :
			begin
				cpurdata <= fromtrigcnt;
			end
		18 :
			begin
				cpurdata <= fromtrigcnt;
			end
		19 :
			begin
				cpurdata <= fromtrigcnt;
			end
		default : begin
				cpurdata <= 0;
			end
		endcase
	end

	assign XDATA = (!XRSTR) ? cpurdata : 8'bzzzzzzzz;	// read - low!

endmodule
