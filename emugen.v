`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	ITEP
// Engineer: 	SvirLex
// 
// Create Date:    00:17:19 03/29/2022 
// Design Name: 	timecnt
// Module Name:    emugen 
// Project Name: 	drift4spascharm
// Target Devices: xc3s400-4pq208
// Tool versions: 
// Description:   Emulates trigger signal and cycle
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module emugen(
    input clk,			// 40 MHz
    input enable,		// Emulation signal enable
    output reg trigger = 1	// resulting trigger signal
    );

	 parameter period = 40000;			// trigger period in 40 MHz clock = 1 ms
	 parameter cycleon = 40000000;	//	cycle ON time = 1 s
	 parameter cycleoff = 80000000;	// cycle OFF = 2 s
	 reg [29:0] cyclecnt;
	 reg cycle = 0;
	 reg [19:0] trigcnt;
	 
	 always @(posedge clk) begin
		if (!enable) begin
			cycle <= 0;		// off
			cyclecnt <= 0;
		end else begin
			if ((cycle == 0 && cyclecnt >= cycleoff) || (cycle == 1 && cyclecnt >= cycleon)) begin
				cycle <= !cycle;
				cyclecnt <= 0;
			end else begin
				cyclecnt <= cyclecnt + 1;
			end
		end
		if (cycle == 0) begin 
			trigger <= 1;
			trigcnt <= 0;
		end else begin
			if (trigcnt >= period) begin
				trigger <= 1;
				trigcnt <= 0;
			end else begin
				trigger <= 0;
				trigcnt <= trigcnt + 1;
			end
		end
	 end

endmodule
