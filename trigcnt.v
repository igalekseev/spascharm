`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	ITEP
// Engineer: 	SvirLex
// 
// Create Date:    16:25:31 03/18/2022 
// Design Name: 	timecnt
// Module Name:     trigcnt 
// Project Name: 	drift4spascharm
// Target Devices: 	xc3s400-4pq208
// Tool versions: 
// Description: 	Impelments 18 bit trigger counter and 36 bit time counter
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module trigcnt(
    input clk,					// 160 MHz clock
    input trigger,				// trigger pulse
    input cyclebegin,			// cycle begin pulse (reset time counter)
    input reset,				// reset trigger counter
    output reg ready,			// we have data
    output reg [17:0] trignum,	// trigger number to stream
    output reg [35:0] timenum,	// timecnt to stream
	input [7:0] addr,			// read register address
	input read,					// read pulse to store long registers
	output reg [7:0] rdata		// read data
    );

	reg [17:0] trigcnt = 0;
	reg [35:0] timecnt = 0;
	reg [15:0] trigcopy = 0;
	reg [31:0] timecopy = 0;
	reg read_del = 0;
	
	always @(posedge clk) begin
		if (cyclebegin) begin
			timecnt <= 0;
			trigcnt <= 0;
		end else begin
			timecnt <= timecnt + 1;
		end
		ready <= trigger;
		if (trigger) begin
			trignum <= trigcnt;
			timenum <= timecnt;
			trigcnt <= trigcnt + 1;
		end
		if (reset) begin
			trigcnt <= 0;
		end
		if (read & (!read_del)) begin
			if (addr == 14) begin
				trigcopy <= trigcnt[15:0];
			end else if (addr == 16) begin
				timecopy <= timecnt[31:0];
			end
		end
		read_del <= read;
		case (addr)
		14 : begin
				rdata <= trigcopy[7:0];
			 end
		15 : begin
				rdata <= trigcopy[15:8];
			 end
 		16: begin
				rdata <= timecopy[7:0];
			 end
 		17: begin
				rdata <= timecopy[15:8];
			 end
 		18: begin
				rdata <= timecopy[23:16];
			 end
 		19: begin
				rdata <= timecopy[31:24];
			 end
		endcase
	end

endmodule
