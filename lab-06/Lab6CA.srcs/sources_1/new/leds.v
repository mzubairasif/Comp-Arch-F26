`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muddassir Ali
// 
// Module Name: leds
// Project Name: Counter
// Target Devices: Baasys 3
// 
//////////////////////////////////////////////////////////////////////////////////

module leds(
    input clk,
    input rst,
    input [31:0] writeData,
    output reg [15:0] physical_leds
);
    always @(posedge clk) begin
        if (rst) 
            physical_leds <= 16'd0;
        else 
            physical_leds <= writeData[15:0];
    end
endmodule