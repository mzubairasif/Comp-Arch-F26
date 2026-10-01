`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muddassir Ali
// 
// Module Name: switches
// Project Name: Counter
// Target Devices: Baasys 3
// 
//////////////////////////////////////////////////////////////////////////////////

module switches(
    input [15:0] physical_sw,
    output [31:0] switch_data
);
    assign switch_data = {16'd0, physical_sw};
endmodule