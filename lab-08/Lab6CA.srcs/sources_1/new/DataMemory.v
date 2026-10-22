`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2026 03:00:00 PM
// Design Name: 
// Module Name: DataMemory
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

module DataMemory #(
    parameter DEPTH      = 512,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 9
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  MemWrite,
    input  wire                  MemRead,
    input  wire [ADDR_WIDTH-1:0] address,
    input  wire [DATA_WIDTH-1:0] write_data,
    output wire [DATA_WIDTH-1:0] read_data
);

    // 512 locations of 32-bit memory array
    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
    integer i;

    // Initialize all memory locations to 0
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            memory[i] = {DATA_WIDTH{1'b0}};
        end
    end

    // Synchronous write and synchronous reset
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                memory[i] <= {DATA_WIDTH{1'b0}};
            end
        end else if (MemWrite) begin
            memory[address] <= write_data;
        end
    end

    // Asynchronous read (single-cycle processor convention)
    // If MemRead is high, return data at address; otherwise output 0
    assign read_data = (MemRead) ? memory[address] : {DATA_WIDTH{1'b0}};

endmodule
