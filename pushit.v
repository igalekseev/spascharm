`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	ITEP
// Engineer: 	SvirLex
// 
// Create Date:    00:49:15 03/20/2022 
// Design Name: 	 timecnt
// Module Name:    pushit 
// Project Name: 	 drift4spascharm
// Target Devices: xc3s400-4pq208
// Tool versions: 
// Description:    Takes data from trigcnt and cycle cnt and form blocks for FIFO
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module pushit(
    input clk,					// 160 MHz
    input clkslow,			// 40 MHz
    input trigready,			// trigger data is ready
    input cycleready,		// cycle data is ready
    input [17:0] trignum,	// trigger number
    input [17:0] cyclenum,	// cycle number
    input [35:0] timenum,	// trigger time
	 input busy,				// FIFO is full
    output reg [7:0] data = 0,		// Data to FIFO
    output reg write = 0	// strob accomplishing data
    );

	 reg [4:0] state = 0;
	 reg cycle = 0;
	 reg trigger = 0;
	 reg trig_save = 0;
	 reg [17:0] num_save = 0;
	 reg [35:0] time_save = 0;
	 
	 always @(posedge clk) begin
		 if (busy || (state != 0)) begin
			cycle <= 0;
			trigger <= 0;
			if (trigready) begin
				trig_save <= 1;
			end
		 end else if (trigready || trig_save) begin
			trigger <= 1;
			trig_save <= 0;
		 end else if (cycleready) begin
			cycle <= 1;
		 end
		 
	 end
	 
	 always @(posedge clkslow) begin
		write <= 0;
		case (state) 
		0 : begin
			if (trigger) begin
				data <= 8'hFF;
				write <= 1;
				state <= 1;
				num_save <= trignum;
				time_save <= timenum;
			end else if (cycle) begin
				data <= 8'hBF;
				write <= 1;
				state <= 10;		
			end
			end
		1 : begin
				data <= num_save[5:0];
				write <= 1;
				state <= 2;		
			end
		2 : begin
				data <= num_save[11:6];
				write <= 1;
				state <= 3;		
			end
		3 : begin
				data <= num_save[17:12];
				write <= 1;
				state <= 4;		
			end
		4 : begin
				data <= time_save[5:0];
				write <= 1;
				state <= 5;		
			end
		5 : begin
				data <= time_save[11:6];
				write <= 1;
				state <= 6;		
			end
		6 : begin
				data <= time_save[17:12];
				write <= 1;
				state <= 7;		
			end
		7 : begin
				data <= time_save[23:18];
				write <= 1;
				state <= 8;		
			end
		8 : begin
				data <= time_save[29:24];
				write <= 1;
				state <= 9;		
			end
		9 : begin
				data <= time_save[35:30];
				write <= 1;
				state <= 0;		
			end
   	10 : begin
				data <= cyclenum[5:0];
				write <= 1;
				state <= 11;		
			end
   	11 : begin
				data <= cyclenum[11:6];
				write <= 1;
				state <= 12;		
			end
   	12 : begin
				data <= cyclenum[17:12];
				write <= 1;
				state <= 0;		
			end
		default: begin
			state <= 0;
			end	
		endcase
	 end

endmodule
