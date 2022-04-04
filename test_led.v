`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 	ITEP
// Engineer:	SvirLex
//
// Create Date:   01:05:44 03/21/2022
// Design Name:   led
// Module Name:   /home/igor/proj/spascharm-timecounter/test_led.v
// Project Name:  timecnt
// Target Device: xc3s400-4pq208
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: led
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_led;

	// Inputs
	reg clk;
	reg trig;

	// Outputs
	wire out;

	// Instantiate the Unit Under Test (UUT)
	led #(.COUNT(100)) uut (
		.clk(clk), 
		.trig(trig), 
		.out(out)
	);

     always begin
			#12.5 clk = ~clk;
	  end

	initial begin
		// Initialize Inputs
		clk = 0;
		trig = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		@(posedge clk);
		trig <= 1;
		@(posedge clk);
		trig <= 0;
		
		#1000;
		
		@(posedge clk);
		trig <= 1;
		@(posedge clk);
		trig <= 0;
		
		#10000
		
		@(posedge clk);
		trig <= 1;
		@(posedge clk);
		trig <= 0;

	end
      
endmodule

