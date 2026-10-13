`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: reg_file / RegisterFile
// Description: 32x32 Register File for RV32I RISC-V Processor.
//              - Register x0 is hardwired to 0 (reads 0, writes ignored).
//              - Two asynchronous (combinational) read ports.
//              - One synchronous write port triggered on posedge clk.
//              - Synchronous reset clears all registers to 0.
//////////////////////////////////////////////////////////////////////////////////

module reg_file (
    input  wire        clk,
    input  wire        reset,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [31:0] write_data,
    input  wire        reg_write,
    output wire [31:0] read_1,
    output wire [31:0] read_2
);

    // 32 registers of 32-bit width
    reg [31:0] registers [31:0];
    integer i;

    // Initialize all registers to 0 for simulation & FPGA bitstream initialization
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'd0;
        end
    end

    // Synchronous write and reset logic
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'd0;
            end
        end else if (reg_write && (rd != 5'd0)) begin
            // RV32I convention: Writes to x0 are ignored
            registers[rd] <= write_data;
        end
    end

    // Asynchronous (combinational) read ports
    // RV32I convention: Reading x0 always returns 0
    assign read_1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    assign read_2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];

endmodule
