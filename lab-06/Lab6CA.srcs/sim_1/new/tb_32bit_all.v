`timescale 1ns / 1ps

module tb_32bit_all;

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
        // Monitor prints output in Hexadecimal format (%h) for easy reading
        $monitor("Time=%0t | op=%d | a=%h, b=%h | result=%h, cout=%b", 
                 $time, op_code, a, b, result, carry_out);

        // Initialize inputs
        a = 32'd0; b = 32'd0; op_code = 3'd0;
        #10;
        
        // --- Test 1: OR (op_code = 0) ---
        op_code = 3'd0; 
        a = 32'hAAAA_AAAA; b = 32'h5555_5555; 
        #10; // Expected result: FFFF_FFFF
        
        // --- Test 2: AND (op_code = 1) ---
        op_code = 3'd1; 
        a = 32'hFFFF_0000; b = 32'h00FF_FFFF; 
        #10; // Expected result: 00FF_0000

        // --- Test 3: ADD (op_code = 2) ---
        op_code = 3'd2; 
        a = 32'h0000_0005; b = 32'h0000_000A; 
        #10; // Expected result: 0000_000F (15)
        
        // Overflow test: FFFF_FFFF + 1
        a = 32'hFFFF_FFFF; b = 32'h0000_0001; 
        #10; // Expected result: 0000_0000, cout = 1

        // --- Test 4: XOR (op_code = 3) ---
        op_code = 3'd3; 
        a = 32'hF0F0_F0F0; b = 32'h1111_1111; 
        #10; // Expected result: E1E1_E1E1

        // --- Test 5: SUB (op_code = 4) ---
        op_code = 3'd4; 
        a = 32'h0000_0014; b = 32'h0000_000A; 
        #10; // Expected result: 0000_000A (20 - 10 = 10)

        // Borrow test: 3 - 5
        a = 32'h0000_0003; b = 32'h0000_0005; 
        #10; // Expected result: FFFF_FFFE (-2), cout = 0

        // --- Test 6: SLL (op_code = 5) ---
        // Shifts input A left by 1 bit
        op_code = 3'd5; 
        a = 32'h0000_0001; b = 32'h0000_0000; // 'b' is ignored for shifts
        #10; // Expected result: 0000_0002
        
        a = 32'hFFFF_FFFF; 
        #10; // Expected result: FFFF_FFFE

        // --- Test 7: SRL (op_code = 6) ---
        // Shifts input A right by 1 bit
        op_code = 3'd6; 
        a = 32'h0000_0002; 
        #10; // Expected result: 0000_0001
        
        a = 32'hFFFF_FFFF; 
        #10; // Expected result: 7FFF_FFFF

        $finish;
    end

endmodule