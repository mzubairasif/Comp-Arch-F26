`timescale 1ns / 1ps

module RegisterFile_tb;
    reg clk;
    reg reset;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] write_data;
    reg reg_write;
    
    wire [31:0] read_1, read_2;

    // Instantiate the Register File
    reg_file uut (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .reg_write(reg_write),
        .read_1(read_1),
        .read_2(read_2)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test Sequence
    initial begin
        // Initialize Inputs
        reset = 1; reg_write = 0; rs1 = 0; rs2 = 0; rd = 0; write_data = 0;
        #15 reset = 0;

        // i. Write a value to x5 and read it
        $display("Test i: Write and Read x5");
        rd = 5'd5; write_data = 32'hDEADBEEF; reg_write = 1;
        #10 reg_write = 0; rs1 = 5'd5;
        #10 if (read_1 == 32'hDEADBEEF) $display("PASS: x5 = %h", read_1);
            else $display("FAIL: x5 = %h", read_1);

        // ii. Attempt to write to x0
        $display("Test ii: Attempt write to x0");
        rd = 5'd0; write_data = 32'hFFFFFFFF; reg_write = 1;
        #10 reg_write = 0; rs1 = 5'd0;
        #10 if (read_1 == 32'h00000000) $display("PASS: x0 = %h", read_1);
            else $display("FAIL: x0 = %h", read_1);

        // iii. Simultaneous two read ports
        $display("Test iii: Simultaneous reads (x5 and x6)");
        rd = 5'd6; write_data = 32'hAAAA5555; reg_write = 1; 
        #10 reg_write = 0; rs1 = 5'd5; rs2 = 5'd6;
        #10 if (read_1 == 32'hDEADBEEF && read_2 == 32'hAAAA5555) 
                $display("PASS: x5 = %h, x6 = %h", read_1, read_2);
            else $display("FAIL: Simultaneous read incorrect.");

        // iv. Overwrite a register
        $display("Test iv: Overwrite x5");
        rd = 5'd5; write_data = 32'h12345678; reg_write = 1; 
        #10 reg_write = 0; rs1 = 5'd5;
        #10 if (read_1 == 32'h12345678) $display("PASS: x5 overwritten = %h", read_1);
            else $display("FAIL: x5 overwrite failed.");

        // v. Reset behavior
        $display("Test v: Reset");
        reset = 1; 
        #10 reset = 0; rs1 = 5'd5; rs2 = 5'd6;
        #10 if (read_1 == 32'h0 && read_2 == 32'h0) $display("PASS: Registers cleared on reset.");
            else $display("FAIL: Registers not cleared.");

        $finish;
    end
endmodule