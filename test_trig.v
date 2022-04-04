`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:59:21 03/18/2022
// Design Name:   trigger
// Module Name:   /home/igor/proj/spascharm-timecounter/test_trig.v
// Project Name:  timecnt
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: trigger
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_trig;

	// Inputs
	reg clk;
	reg trigin;
	reg trigcpu;
	reg trigemu;
	reg [1:0] trigsel;

	// Outputs
	wire trigpulse;
	wire cycleend;
	wire cyclebegin;

	// Instantiate the Unit Under Test (UUT)
	trigger uut (
		.clk(clk), 
		.trigin(trigin), 
		.trigcpu(trigcpu), 
		.trigemu(trigemu),
		.trigsel(trigsel), 
		.trigpulse(trigpulse), 
		.cycleend(cycleend), 
		.cyclebegin(cyclebegin)
	);

      always begin
			#3 clk = ~clk;
	  end

	initial begin
		// Initialize Inputs
		clk = 0;
		trigin = 0;
		trigcpu = 0;
		trigsel = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	  
	  trigin = 1;
	  #20;
	  trigin = 0;
	  #2000;
	  trigin = 1;
	  #20;
	  trigin = 0;
	  #2000;
	  trigin = 1;
	  #2000;
	  trigin = 0;

	end
      
endmodule

