`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITEP
// Engineer: SvirLex
// 
// Create Date:    14:49:17 03/18/2022 
// Design Name:    timecnt
// Module Name:    trigger 
// Project Name:   drift4spascharm
// Target Devices: xc3s400-4pq208
// Tool versions: 
// Description:		Make trigger and cycle pulses. Block triggers for 300 ns
//					A long (> 1 us) trigger pulse is consdered as a cycle.
//					It will produce 3 short pulses: at the begin (trigpulse), 
//					1 us after its begin (cycleend)
//					and after its end (cyclebegin)
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module trigger(
    input clk,			// 160 MHz clock
    input trigin,		// main input trigger
    input trigcpu,	// trigger from CPU (debug)
	 input trigemu,	// trigger emulator
	 input [1:0] trigsel,		// trgigger selector from register
    output reg trigpulse = 0,	// 1 clk trigger pulse
    output reg cycleend = 0,	// end of cycle signal 1 clk
	 output reg cyclebegin = 0	// begin of cycle signal 1 clk
    );

	parameter BLKCOUNT = 5;

	reg trigmux = 0;
	reg trigblock = 0;
	reg [5:0] blkcnt = 0;
	reg [7:0] uscnt = 0;
	reg [1:0] cycle = 0;

	always @(posedge clk) begin
		// input multiplexer
		case (trigsel)
         2'b00: trigmux <= trigin;
         2'b01: trigmux <= trigcpu;
         2'b10: trigmux <= trigemu;
         2'b11: trigmux <= trigin;
      endcase
		// trigger block
		if (trigmux) begin
			trigblock <= 1;
			blkcnt <= BLKCOUNT;
		end else if (blkcnt == 0) begin
			trigblock <= 0;
		end else begin
			blkcnt <= blkcnt - 1;
		end
		// trigger pulse
		trigpulse <= trigmux & (!trigblock);
		// 1 us counter and cycle
		if (trigpulse) begin
			uscnt <= 160;
		end
		if (!trigmux) begin
			uscnt <= 0;
			cycle[0] <= 0;
		end else if (uscnt != 0) begin
			uscnt <= uscnt - 1;
		end 
		if (uscnt == 1) begin
			cycle[0] <= 1;
		end
		cycle[1] <= cycle[0];
		cycleend <= 0;
		cyclebegin <= 0;
		case (cycle)
		2'b01  : begin
				 cycleend <= 1;
                 end
        2'b10  : begin
				 cyclebegin <= 1;
                 end
        default: begin
                 end
        endcase
	end



endmodule
