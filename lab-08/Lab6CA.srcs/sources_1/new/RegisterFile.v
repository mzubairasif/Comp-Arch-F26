`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RegisterFile
// Description: Standard 32x32 Register File as specified in Lab 7 manual:
//              - Inputs: clk, rst, WriteEnable, rs1[4:0], rs2[4:0], rd[4:0], WriteData[31:0]
//              - Outputs: ReadData1[31:0], ReadData2[31:0]
//              - Connects to RV32I reg_file implementation
//////////////////////////////////////////////////////////////////////////////////

module RegisterFile (
    input  wire        clk,
    input  wire        rst,
    input  wire        WriteEnable,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [31:0] WriteData,
    output wire [31:0] ReadData1,
    output wire [31:0] ReadData2
);

    reg_file rf_inst (
        .clk(clk),
        .reset(rst),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(WriteData),
        .reg_write(WriteEnable),
        .read_1(ReadData1),
        .read_2(ReadData2)
    );

endmodule
