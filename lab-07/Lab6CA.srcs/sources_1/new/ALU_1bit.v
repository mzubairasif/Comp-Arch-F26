`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2026 12:39:13 PM
// Design Name: 
// Module Name: ALU_1bit
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

`timescale 1ns / 1ps

module ALU_1bit(
    input wire [2:0] op_code,
    input wire       a,
    input wire       b,
    input wire       carry_in,
    output wire      carry_out,
    output reg       result
);

    wire b_mux;
    wire temp,or_temp,and_temp,xor_temp;
    OR t1(a,b,or_temp); 
    XOR t2(a,b,xor_temp); 
    AND t3(a,b,and_temp); 
    // Conditionally invert b for subtraction
    assign b_mux = (op_code == 3'd4) ? ~b : b;
    
    // The adder must use b_mux, not b
    adder ad1(a, b_mux, carry_in, temp, carry_out);
    
    always @(*) begin
        if (op_code == 3'd0) begin
                    // OR
            result=or_temp;
            
        end else if (op_code == 3'd1) begin
            result = and_temp;          //AND
            
        end else if (op_code == 3'd2|| op_code == 3'd4) begin
            result = temp;          // subtraction or addition based b mux            
        end else if (op_code == 3'd3) begin
            result = xor_temp;          // XOR
            
        end else begin
            result = 1'b0;              // Default to prevent latches
        end
    end
endmodule
