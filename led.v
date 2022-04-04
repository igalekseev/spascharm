`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	ITEP
// Engineer: 	SvirLex
// 
// Create Date:    00:40:05 03/21/2022 
// Design Name: 	 timecnt
// Module Name:    led 
// Project Name:   drift4spascharm
// Target Devices: xc3s400-4pq208
// Tool versions: 
// Description: 	Do a logn flash on the received pulse
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module led(
    input clk,
    input trig,
    output reg out = 1
    );

	parameter COUNT = 40000;
	reg [15:0] cnt = 0;

	always @(posedge clk) begin
		out <= 1;
		if (trig) begin
			cnt <= COUNT;
		end else if (cnt != 0) begin
			cnt <= cnt - 1;
			out <= 0;
		end
	end

endmodule
