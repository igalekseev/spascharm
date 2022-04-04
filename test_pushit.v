`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 	ITEP
// Engineer:	SvirLex
//
// Create Date:   01:37:27 03/20/2022
// Design Name:   pushit
// Module Name:   C:/projects/spascharm/timecnt/test_pushit.v
// Project Name:  timecnt
// Target Device: xc3s400-4pq208 
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: pushit
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_pushit;

	// Inputs
	reg clk;
	reg clkslow;
	reg trigready;
	reg cycleready;
	reg [17:0] trignum;
	reg [17:0] cyclenum;
	reg [35:0] timenum;
	reg busy;

	// Outputs
	wire [7:0] data;
	wire write;

	// Instantiate the Unit Under Test (UUT)
	pushit uut (
		.clk(clk), 
		.clkslow(clkslow), 
		.trigready(trigready), 
		.cycleready(cycleready), 
		.trignum(trignum), 
		.cyclenum(cyclenum), 
		.timenum(timenum), 
		.busy(busy), 
		.data(data), 
		.write(write)
	);

     always begin
			#3 clk = ~clk;
	  end

     always begin
			#12 clkslow = ~clkslow;
	  end

	initial begin
		// Initialize Inputs
		clk = 0;
		clkslow = 0;
		trigready = 0;
		cycleready = 0;
		trignum = 18'h12345;
		cyclenum = 18'h26789;
		timenum = 36'h123456789;
		busy = 0;

		// Wait 100 ns for global reset to finish
		#100;
      
		// Add stimulus here
		
		@(posedge clk);
		trigready = 1;
		@(posedge clk);
		trigready = 0;
		
		#500
		@(posedge clk);
		cycleready = 1;
		@(posedge clk);
		cycleready = 0;

	end
      
endmodule

