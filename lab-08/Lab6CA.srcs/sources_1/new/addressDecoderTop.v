`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2026 03:10:00 PM
// Design Name: 
// Module Name: addressDecoderTop
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

module addressDecoderTop (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] address,
    input  wire        readEnable,
    input  wire        writeEnable,
    input  wire [31:0] writeData,
    input  wire [15:0] switches,
    output wire [31:0] readData,
    output wire [15:0] leds
);

    // 1. Decoder Enable & Select Signals
    wire DataMemWrite;
    wire DataMemRead;
    wire LEDWrite;
    wire SwitchReadEnable;
    wire DataMemSelect;
    wire LEDSelect;
    wire SwitchSelect;

    AddressDecoder decoder_inst (
        .address(address),
        .readEnable(readEnable),
        .writeEnable(writeEnable),
        .DataMemWrite(DataMemWrite),
        .DataMemRead(DataMemRead),
        .LEDWrite(LEDWrite),
        .SwitchReadEnable(SwitchReadEnable),
        .DataMemSelect(DataMemSelect),
        .LEDSelect(LEDSelect),
        .SwitchSelect(SwitchSelect)
    );

    // 2. Data Memory Instantiation (512 locations x 32 bits)
    wire [31:0] data_mem_out;
    DataMemory #(
        .DEPTH(512),
        .DATA_WIDTH(32),
        .ADDR_WIDTH(9)
    ) data_mem_inst (
        .clk(clk),
        .rst(rst),
        .MemWrite(DataMemWrite),
        .MemRead(DataMemRead),
        .address(address[8:0]),
        .write_data(writeData),
        .read_data(data_mem_out)
    );

    // 3. Switch Interface Instantiation (Lab 5 switch module)
    wire [31:0] switch_data_out;
    switches switch_interface (
        .physical_sw(switches),
        .switch_data(switch_data_out)
    );

    // 4. LED Interface Instantiation (Lab 5 leds module)
    // To allow leds.v to retain its state when LEDWrite is not asserted,
    // feed back the current LED output unless a write occurs.
    wire [15:0] leds_internal;
    wire [31:0] led_write_bus = (LEDWrite) ? writeData : {16'd0, leds_internal};

    leds led_interface (
        .clk(clk),
        .rst(rst),
        .writeData(led_write_bus),
        .physical_leds(leds_internal)
    );

    assign leds = leds_internal;

    // 5. Read Data Multiplexer
    // Routes DataMemory or Switches to CPU readData, defaulting to 0 on inactive/invalid reads.
    assign readData = (DataMemSelect && DataMemRead)          ? data_mem_out :
                      (SwitchSelect  && SwitchReadEnable)     ? switch_data_out :
                      32'd0;

endmodule
