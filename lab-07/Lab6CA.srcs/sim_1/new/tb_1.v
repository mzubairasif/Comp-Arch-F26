`timescale 1ns / 1ps

module tb_ALU_1bit;

    // 1. Declare variables to connect to the module
    reg [2:0] op_code;
    reg       a;
    reg       b;
    reg       carry_in;
    
    wire      carry_out;
    wire      result;

    // 2. Instantiate the Unit Under Test (UUT)
    ALU_1bit uut (
        .op_code(op_code),
        .a(a),
        .b(b),
        .carry_in(carry_in),
        .carry_out(carry_out),
        .result(result)
    );

    // 3. Apply test vectors
    initial begin
        // Monitor prints the variables to the console every time one of them changes
        $monitor("Time=%0t | op_code=%b | a=%b b=%b cin=%b | result=%b cout=%b", 
                 $time, op_code, a, b, carry_in, result, carry_out);

        // Initialize inputs
        a = 0; b = 0; carry_in = 0; op_code = 3'd0;
        #10; // Wait 10ns
        
        // --- Test OR (op_code = 0) ---
        op_code = 3'd0; a = 0; b = 0; #10; // Expected result = 0
        op_code = 3'd0; a = 0; b = 1; #10; // Expected result = 1
        
        // --- Test AND (op_code = 1) ---
        op_code = 3'd1; a = 1; b = 0; #10; // Expected result = 0
        op_code = 3'd1; a = 1; b = 1; #10; // Expected result = 1

        // --- Test ADD (op_code = 2) ---
        // A + B + Cin
        op_code = 3'd2; a = 1; b = 0; carry_in = 0; #10; // 1 + 0 + 0 = 1 (cout=0)
        op_code = 3'd2; a = 1; b = 1; carry_in = 0; #10; // 1 + 1 + 0 = 0 (cout=1)
        op_code = 3'd2; a = 1; b = 1; carry_in = 1; #10; // 1 + 1 + 1 = 1 (cout=1)

        // --- Test XOR (op_code = 3) ---
        op_code = 3'd3; a = 1; b = 0; #10; // Expected result = 1
        op_code = 3'd3; a = 1; b = 1; #10; // Expected result = 0

        // --- Test SUB (op_code = 4) ---
        // A - B uses 2's complement: A + (~B) + 1. 
        // b_mux handles ~B inside the module, but WE must supply the +1 via carry_in.
        op_code = 3'd4; a = 1; b = 0; carry_in = 1; #10; // 1 - 0 = 1 (cout=1)
        op_code = 3'd4; a = 1; b = 1; carry_in = 1; #10; // 1 - 1 = 0 (cout=1)
        
        // 0 - 1 evaluates as 0 + 0 + 1 = 1. The cout=0 indicates a borrow occurred.
        op_code = 3'd4; a = 0; b = 1; carry_in = 1; #10; 

        // End simulation
        $finish;
    end

endmodule