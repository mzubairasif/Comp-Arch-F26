`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2026 03:05:00 PM
// Design Name: 
// Module Name: AddressDecoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module AddressDecoder (
    input  wire [31:0] address,
    input  wire        readEnable,
    input  wire        writeEnable,
    output wire        DataMemWrite,
    output wire        DataMemRead,
    output wire        LEDWrite,
    output wire        SwitchReadEnable,
    output wire        DataMemSelect,
    output wire        LEDSelect,
    output wire        SwitchSelect
);

    // Device selection based on address[9:8] (Lab 8 Manual Table)
    assign DataMemSelect = (address[9:8] == 2'b00);
    assign LEDSelect     = (address[9:8] == 2'b01);
    assign SwitchSelect  = (address[9:8] == 2'b10);

    // Gated enables ensuring mutual exclusion and preventing bus contention
    // 1. Data Memory: supports both read and write
    assign DataMemWrite      = writeEnable && DataMemSelect;
    assign DataMemRead       = readEnable  && DataMemSelect;

    // 2. LEDs: write-only interface
    assign LEDWrite          = writeEnable && LEDSelect;

    // 3. Switches: read-only interface
    assign SwitchReadEnable  = readEnable  && SwitchSelect;

endmodule
