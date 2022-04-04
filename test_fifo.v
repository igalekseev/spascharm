`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 	ITEP
// Engineer:	SvirLex
//
// Create Date:   23:53:26 03/20/2022
// Design Name:   fifo
// Module Name:   /home/igor/proj/spascharm-timecounter/test_fifo.v
// Project Name:  timecnt
// Target Device:  xc3s400-4pq208
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: fifo
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_fifo;

	// Inputs
	reg clk;
	reg write;
	reg [7:0] data;
	reg flag;
	reg reset;

	// Outputs
	wire busy;
	wire [7:0] xdata;
	wire xwrite;
	wire xpkte;

	// Instantiate the Unit Under Test (UUT)
	fifo uut (
		.clk(clk), 
		.write(write), 
		.data(data), 
		.busy(busy), 
		.flag(flag), 
		.xdata(xdata), 
		.xwrite(xwrite), 
		.xpkte(xpkte), 
		.reset(reset)
	);

     always begin
			#12.5 clk = ~clk;
	  end
	  
	  always @(posedge clk) begin
			data <= data + 1;
	  end 

	initial begin
		// Initialize Inputs
		clk = 0;
		write = 0;
		data = 0;
		flag = 0;
		reset = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		@(posedge clk);
		write <= 1;
		#10010
		flag <= 1;
		#990
		write <= 0;
	end
      
endmodule

