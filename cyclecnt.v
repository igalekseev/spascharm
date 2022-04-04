`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	ITEP
// Engineer: 	SvirLex
// 
// Create Date:    02:10:25 03/19/2022 
// Design Name: 	 timecnt
// Module Name:    cyclecnt 
// Project Name: 	 drift4spascharm
// Target Devices: xc3s400-4pq208
// Tool versions: 
// Description:    Cycle counter.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module cyclecnt(
    input clk,
    input cycle,
    input reset,
    output reg ready,
    output reg [17:0] cyclenum,
    input [7:0] addr,
    input read,
    output reg [7:0] rdata
    );

	 reg [17:0] cyclecnt = 0;
	 reg [15:0] cyclecopy = 0;
	 reg read_del = 0;

	 always @(posedge clk) begin
		if (reset) begin
			cyclecnt <= 0;
		end
		ready <= cycle;
		if (cycle) begin
			cyclenum <= cyclecnt;
			cyclecnt <= cyclecnt + 1;
		end
		if (read & (!read_del)) begin
			if (addr == 12) begin
				cyclecopy <= cyclecnt[15:0];
			end
		end
		read_del <= read;
		case (addr)
		12 : begin
				rdata <= cyclecopy[7:0];
			 end
		13 : begin
				rdata <= cyclecopy[15:8];
			 end
		endcase

	 end

endmodule
