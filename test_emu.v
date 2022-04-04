`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 	ITEP
// Engineer:	SvirLex
//
// Create Date:   00:39:21 03/29/2022
// Design Name:   emugen
// Module Name:   /home/igor/proj/spascharm-timecounter/test_emu.v
// Project Name:  timecnt
// Target Device: xc3s400-4pq208 
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: emugen
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_emu;

	// Inputs
	reg clk;
	reg enable;

	// Outputs
	wire trigger;

	// Instantiate the Unit Under Test (UUT)
	emugen #(
		.period(40),
		.cycleon(1000),
		.cycleoff(500)
	) uut (
		.clk(clk), 
		.enable(enable), 
		.trigger(trigger)
	);

	always begin
		#12.5 clk = ~clk;
	end

	initial begin
		// Initialize Inputs
		clk = 0;
		enable = 0;

		// Wait 100 ns for global reset to finish
		#1000;
        
		// Add stimulus here
		enable <= 1;

	end
      
endmodule

