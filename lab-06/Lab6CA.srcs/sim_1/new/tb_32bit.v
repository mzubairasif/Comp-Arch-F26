`timescale 1ns / 1ps

module tb_ALU_32bit;

    // 1. Declare inputs as registers and outputs as wires
    reg [2:0]  op_code;
    reg [31:0] a;
    reg [31:0] b;
    
    wire [31:0] result;
    wire        carry_out;

    // 2. Instantiate the 32-bit ALU
    ALU_32bit uut (
        .op_code(op_code),
        .a(a),
        .b(b),
        .result(result),
        .carry_out(carry_out)
    );

    // 3. Apply Test Vectors
    initial begin
        // Use %h for Hexadecimal formatting. Printing 32 individual bits is hard to read, 
        // so hex format organizes them nicely into 8 characters.
        $monitor("Time=%0t | op=%d | a=%h, b=%h | result=%h, cout=%b", 
                 $time, op_code, a, b, result, carry_out);

        // Initialize
        a = 32'd0; b = 32'd0; op_code = 3'd0;
        #10;
        
        // --- Test 1: OR (op_code = 0) ---
        // Alternating bits: 1010... OR 0101... = 1111... (FFFFFFFF)
        op_code = 3'd0; 
        a = 32'hAAAA_AAAA; b = 32'h5555_5555; 
        #10; 
        
        // --- Test 2: AND (op_code = 1) ---
        // Overlapping region should remain, rest turn to 0. 
        op_code = 3'd1; 
        a = 32'hFFFF_0000; b = 32'h00FF_FFFF; 
        #10; // Expected: 00FF0000

        // --- Test 3: ADD (op_code = 2) ---
        // Standard addition: 5 + 10 = 15 (Hex F)
        op_code = 3'd2; 
        a = 32'h0000_0005; b = 32'h0000_000A; 
        #10; 
        
        // Addition with Overflow
        // Max 32-bit number + 1 rolls over to 0 and triggers carry_out.
        a = 32'hFFFF_FFFF; b = 32'h0000_0001; 
        #10; 

        // --- Test 4: XOR (op_code = 3) ---
        op_code = 3'd3; 
        a = 32'hF0F0_F0F0; b = 32'h1111_1111; 
        #10; // Expected: E1E1E1E1

        // --- Test 5: SUB (op_code = 4) ---
        // Standard Subtraction: 20 - 10 = 10 (Hex A)
        op_code = 3'd4; 
        a = 32'h0000_0014; b = 32'h0000_000A; 
        #10; 

        // Subtraction with Negative Result (Borrow)
        // 3 - 5 = -2. 
        // Expected: FFFFFFFE (This is -2 in 32-bit 2's complement). carry_out=0 indicates a borrow.
        a = 32'h0000_0003; b = 32'h0000_0005; 
        #10; 

        $finish;
    end

endmodule