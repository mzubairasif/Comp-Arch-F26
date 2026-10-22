`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muddassir Ali

// Module Name: clock_divider
// Project Name: Counter
// Target Devices: Baasys 3
// 
//////////////////////////////////////////////////////////////////////////////////


module clock_divider #(
    parameter MAX_COUNT = 50_000_000 - 1
)(
    input wire clk_in,    // The 100MHz board clock
    input wire rst,       // Reset
    output reg clk_out = 0    // Slow 1Hz clock (period 1 sec)
);

    reg [31:0] count = 0;

    always @(posedge clk_in) begin
        if (rst) begin
            count <= 0;
            clk_out <= 0;
        end 
        else if (count == MAX_COUNT) begin
            count <= 0;
            clk_out <= ~clk_out; // Flip the slow clock opposite of what it was
        end 
        else begin
            count <= count + 1;
        end
    end

endmodule
