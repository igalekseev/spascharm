`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:   ITEP
// Engineer:   SvirLex
// 
// Create Date:    14:21:30 03/18/2022 
// Design Name:    timecnt
// Module Name:    clkgen 
// Project Name:   drift4spascharm
// Target Devices: xc3s400-4pq208
// Tool versions: 
// Description:    Take 24 MHz quartz input clock and produce 24, 48 and 160 MHz clock
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clkgen(
    input xclk,
    output clk24,
    output clk40,
    output clk160
    );
	
	wire locked;
	wire clka;
	
//		DCM
   // DCM: Digital Clock Manager Circuit
   //      Spartan-3
   // Xilinx HDL Language Template, version 14.7

   DCM #(
      .SIM_MODE("SAFE"),  // Simulation: "SAFE" vs. "FAST", see "Synthesis and Simulation Design Guide" for details
      .CLKDV_DIVIDE(2.0), // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                          //   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      .CLKFX_DIVIDE(3),   // Can be any integer from 1 to 32
      .CLKFX_MULTIPLY(20), // Can be any integer from 2 to 32
      .CLKIN_DIVIDE_BY_2("FALSE"), // TRUE/FALSE to enable CLKIN divide by two feature
      .CLKIN_PERIOD(40.0),  // Specify period of input clock
      .CLKOUT_PHASE_SHIFT("NONE"), // Specify phase shift of NONE, FIXED or VARIABLE
      .CLK_FEEDBACK("1X"),  // Specify clock feedback of NONE, 1X or 2X
      .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                            //   an integer from 0 to 15
      .DFS_FREQUENCY_MODE("LOW"),  // HIGH or LOW frequency mode for frequency synthesis
      .DLL_FREQUENCY_MODE("LOW"),  // HIGH or LOW frequency mode for DLL
      .DUTY_CYCLE_CORRECTION("TRUE"), // Duty cycle correction, TRUE or FALSE
      .FACTORY_JF(16'hC080),   // FACTORY JF values
      .PHASE_SHIFT(0),     // Amount of fixed phase shift from -255 to 255
      .STARTUP_WAIT("FALSE")   // Delay configuration DONE until DCM LOCK, TRUE/FALSE
   ) DCM_160 (
      .CLK0(clk24),     // 0 degree DCM CLK output
      .CLK180(), 		// 180 degree DCM CLK output
      .CLK270(), 		// 270 degree DCM CLK output
      .CLK2X(),         // 2X DCM CLK output
      .CLK2X180(), // 2X, 180 degree DCM CLK out
      .CLK90(),   // 90 degree DCM CLK output
      .CLKDV(),   // Divided DCM CLK out (CLKDV_DIVIDE)
      .CLKFX(clka),   // DCM CLK synthesis out (M/D)
      .CLKFX180(), // 180 degree CLK synthesis out
      .LOCKED(locked), // DCM LOCK status output
      .PSDONE(), // Dynamic phase adjust done output
      .STATUS(), // 8-bit DCM status bits output
      .CLKFB(clk24),   // DCM clock feedback
      .CLKIN(xclk),   // Clock input (from IBUFG, BUFG or DCM)
      .PSCLK(0),   // Dynamic phase adjust clock input
      .PSEN(0),     // Dynamic phase adjust enable input
      .PSINCDEC(0), // Dynamic phase adjust increment/decrement
      .RST(0)        // DCM asynchronous reset input
   );

   DCM #(
      .SIM_MODE("SAFE"),  // Simulation: "SAFE" vs. "FAST", see "Synthesis and Simulation Design Guide" for details
      .CLKDV_DIVIDE(4.0), // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                          //   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      .CLKFX_DIVIDE(1),   // Can be any integer from 1 to 32
      .CLKFX_MULTIPLY(2), // Can be any integer from 2 to 32
      .CLKIN_DIVIDE_BY_2("FALSE"), // TRUE/FALSE to enable CLKIN divide by two feature
      .CLKIN_PERIOD(40.0),  // Specify period of input clock
      .CLKOUT_PHASE_SHIFT("NONE"), // Specify phase shift of NONE, FIXED or VARIABLE
      .CLK_FEEDBACK("1X"),  // Specify clock feedback of NONE, 1X or 2X
      .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                            //   an integer from 0 to 15
      .DFS_FREQUENCY_MODE("LOW"),  // HIGH or LOW frequency mode for frequency synthesis
      .DLL_FREQUENCY_MODE("LOW"),  // HIGH or LOW frequency mode for DLL
      .DUTY_CYCLE_CORRECTION("TRUE"), // Duty cycle correction, TRUE or FALSE
      .FACTORY_JF(16'hC080),   // FACTORY JF values
      .PHASE_SHIFT(0),     // Amount of fixed phase shift from -255 to 255
      .STARTUP_WAIT("FALSE")   // Delay configuration DONE until DCM LOCK, TRUE/FALSE
   ) DCM_40 (
      .CLK0(clk160),          // 0 degree DCM CLK output
      .CLK180(), 		// 180 degree DCM CLK output
      .CLK270(), 		// 270 degree DCM CLK output
      .CLK2X(),         // 2X DCM CLK output
      .CLK2X180(), // 2X, 180 degree DCM CLK out
      .CLK90(),   // 90 degree DCM CLK output
      .CLKDV(clk40),   // Divided DCM CLK out (CLKDV_DIVIDE)
      .CLKFX(),   // DCM CLK synthesis out (M/D)
      .CLKFX180(), // 180 degree CLK synthesis out
      .LOCKED(), // DCM LOCK status output
      .PSDONE(), // Dynamic phase adjust done output
      .STATUS(), // 8-bit DCM status bits output
      .CLKFB(clk160),   // DCM clock feedback
      .CLKIN(clka),   // Clock input (from IBUFG, BUFG or DCM)
      .PSCLK(0),   // Dynamic phase adjust clock input
      .PSEN(0),     // Dynamic phase adjust enable input
      .PSINCDEC(0), // Dynamic phase adjust increment/decrement
      .RST(!locked)        // DCM asynchronous reset input
   );


endmodule
