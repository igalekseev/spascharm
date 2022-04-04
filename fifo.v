`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	ITEP
// Engineer: 	SvirLex
// 
// Create Date:    02:09:08 03/20/2022 
// Design Name: 	 timecnt
// Module Name:    fifo 
// Project Name:   drift4spascharm
// Target Devices: xc3s400-4pq208
// Tool versions: 
// Description:    FIFO to store data before USB readout
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module fifo(
    input clk,				// 40 MHz FIFO clock
    input write,			// write to FIFO, active high
    input [7:0] data,	// data to FIFO
    output reg busy,		// FIFO is busy (nearly full)
    input flag,				// CPU flag indicating its FIFO full, active high
    output reg [7:0] xdata,	// data to CPU
    output reg xwrite,	// write to CPU
    output reg xpkte,	// PKTEND to USB, active high
	 input reset			// reset from RST register
    );

	 parameter FIFOBITS = 14;
	 parameter MINFREE = 10;
	 reg [7:0] fifo[2**FIFOBITS-1:0];
	 reg [FIFOBITS-1:0] wadr = 0;
	 reg [FIFOBITS-1:0] radr = 0;
	 reg [1:0] endcnt = 0;
	 
	 always @(posedge clk) begin
		busy <= 0;
		
		if (reset) begin
			wadr <= 0;
		end else begin
			if (((radr > wadr) && (radr - wadr < MINFREE)) || ((radr < wadr) && (2**FIFOBITS + radr - wadr < MINFREE))) begin
				busy <= 1;
			end
			if (write) begin
				fifo[wadr] <= data;
				wadr <= wadr + 1;
			end
		end
	 end

	 always @(negedge clk) begin
		xwrite <= 0;
		xpkte <= 0;
		
		if (reset) begin
			radr <= 0;
			xpkte <= 1;	// write packet whatever it was in it
		end else begin
			if ((radr != wadr) && (!flag)) begin	// flag - active=full high
				xdata <= fifo[radr];
				radr <= radr + 1;
				xwrite <= 1;	// active high
				if (xdata == 8'hBF) begin
					endcnt <= 1;
				end
				if (endcnt != 0) begin
					endcnt <= endcnt + 1;
				end 
				if (endcnt == 2) begin
					endcnt <= 0;
					xpkte <= 1;
				end
			end 
		end
	 end

endmodule
