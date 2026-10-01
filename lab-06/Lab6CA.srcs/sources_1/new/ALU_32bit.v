`timescale 1ns / 1ps

module ALU_32bit(
    input wire [2:0]  op_code,
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] result,
    output wire       carry_out
);

    wire [32:0] carry;
    
    // 1. Create internal wires to hold the separate answers
    wire [31:0] basic_alu_result;
    wire [31:0] sll_result;
    wire [31:0] srl_result;
    assign carry[0] = (op_code == 3'd4) ? 1'b1 : 1'b0;
    assign carry_out = carry[32];

    // 2. Redirect the 1-bit array output to 'basic_alu_result'
    ALU_1bit alu_inst [31:0] (
        .op_code( {32{op_code}} ),  
        .a(a),                      
        .b(b),                      
        .carry_in(carry[31:0]),     
        .carry_out(carry[32:1]),    
        .result(basic_alu_result)   // Catch the output here
    );

    // 3. Instantiate your new SLL module
    SLL sll_inst (
        .A(a),
        .Result(sll_result)         // Catch the shifted output here
    );
    SRL srl_inst (
        .A(a),
        .Result(srl_result)         // Catch the shifted output here
    );

    // 4. Multiplexer to select the final output based on op_code
    // If op_code is 5, output the shift. Otherwise, output the basic ALU result.    
    always @(*) begin
        if (op_code == 3'd5) begin
                    // OR
            result=sll_result;
            
        end else if (op_code == 3'd6) begin
            result = srl_result;          //AND
            
        end else begin
            result = basic_alu_result;             // Default to prevent latches
        end
    end

endmodule