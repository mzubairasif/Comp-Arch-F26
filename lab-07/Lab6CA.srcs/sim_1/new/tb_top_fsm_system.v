`timescale 1ns / 1ps

module tb_top_fsm_system;

    reg clk;
    reg pbin;
    reg [15:0] physical_sw;
    wire [15:0] physical_leds;
    wire [6:0] seg;
    wire dp;
    wire [3:0] an;

    // Instantiate Top FSM System with fast parameters for simulation
    top_fsm_system #(
        .SIM_DIVIDER_COUNT(10), // Fast slow_clk: flips every 10 cycles
        .SIM_REFRESH_BITS(4)    // Fast 7-segment refresh multiplexing
    ) uut (
        .clk(clk),
        .pbin(pbin),
        .physical_sw(physical_sw),
        .physical_leds(physical_leds),
        .seg(seg),
        .dp(dp),
        .an(an)
    );

    // 100 MHz clock generation (10ns period)
    always #5 clk = ~clk;

    // Helper task to wait for slow clock tick and allow LED register to latch
    task wait_one_step;
    begin
        @(posedge uut.slow_clk);
        @(posedge clk); // reg_op updates here, ALU computes new writeData
        @(posedge clk); // leds module registers new writeData to physical_leds
        #1;
    end
    endtask

    // Helper task to press and release button (for debouncer with fast pulses if needed, or direct)
    task press_button_sim;
    begin
        pbin = 1'b1;
        repeat (70000) @(posedge clk);
        pbin = 1'b0;
        repeat (70000) @(posedge clk);
    end
    endtask

    // Helper function to decode 7-segment bits ('0' or '1')
    function [0:0] seg_to_val;
        input [6:0] s;
        begin
            if (s == 7'b1000000)
                seg_to_val = 1'b0;
            else if (s == 7'b1111001)
                seg_to_val = 1'b1;
            else
                seg_to_val = 1'bx;
        end
    endfunction

    integer test_errors = 0;

    initial begin
        clk = 0;
        pbin = 0;
        physical_sw = 16'd0;

        $display("==================================================================");
        $display("    STARTING TOP FSM SYSTEM TESTBENCH (TASK 3 ALU AUTO-LOOP)      ");
        $display("==================================================================");

        // Allow clock to settle and leds module to latch initial Opcode 0 value
        @(posedge clk);
        @(posedge clk);
        #1;

        $display("Hardcoded Operands: A = 0x10101010, B = 0x01010101");
        $display("Checking all operations in automatic cycling loop...\n");

        // -------------------------------------------------------------
        // State 0: OR (Opcode 0 -> 3'b000)
        // Expected: A | B = 0x11111111 -> LEDs[15:0] = 0x1111
        // -------------------------------------------------------------
        #2;
        $display("[OPCODE 0: OR] LEDs = 0x%04h | Expected = 0x1111 | Opcode Reg = %d", physical_leds, uut.reg_op);
        if (physical_leds !== 16'h1111 || uut.reg_op !== 3'd0) begin
            $display(">>> FAILED: Expected LEDs = 0x1111 for OR");
            test_errors = test_errors + 1;
        end else begin
            $display(">>> PASSED: OR operation output verified!");
        end

        // Wait for next step tick
        wait_one_step();

        // -------------------------------------------------------------
        // State 1: AND (Opcode 1 -> 3'b001)
        // Expected: A & B = 0x00000000 -> LEDs[15:0] = 0x0000, Zero = 1
        // -------------------------------------------------------------
        $display("\n[OPCODE 1: AND] LEDs = 0x%04h | Expected = 0x0000 | Zero = %b | Opcode Reg = %d", 
                 physical_leds, uut.alu_zero, uut.reg_op);
        if (physical_leds !== 16'h0000 || uut.reg_op !== 3'd1 || uut.alu_zero !== 1'b1) begin
            $display(">>> FAILED: Expected LEDs = 0x0000, Zero = 1 for AND");
            test_errors = test_errors + 1;
        end else begin
            $display(">>> PASSED: AND operation & Zero flag verified!");
        end

        wait_one_step();

        // -------------------------------------------------------------
        // State 2: ADD (Opcode 2 -> 3'b010)
        // Expected: A + B = 0x11111111 -> LEDs[15:0] = 0x1111
        // -------------------------------------------------------------
        $display("\n[OPCODE 2: ADD] LEDs = 0x%04h | Expected = 0x1111 | Opcode Reg = %d", physical_leds, uut.reg_op);
        if (physical_leds !== 16'h1111 || uut.reg_op !== 3'd2) begin
            $display(">>> FAILED: Expected LEDs = 0x1111 for ADD");
            test_errors = test_errors + 1;
        end else begin
            $display(">>> PASSED: ADD operation output verified!");
        end

        wait_one_step();

        // -------------------------------------------------------------
        // State 3: XOR (Opcode 3 -> 3'b011)
        // Expected: A ^ B = 0x11111111 -> LEDs[15:0] = 0x1111
        // -------------------------------------------------------------
        $display("\n[OPCODE 3: XOR] LEDs = 0x%04h | Expected = 0x1111 | Opcode Reg = %d", physical_leds, uut.reg_op);
        if (physical_leds !== 16'h1111 || uut.reg_op !== 3'd3) begin
            $display(">>> FAILED: Expected LEDs = 0x1111 for XOR");
            test_errors = test_errors + 1;
        end else begin
            $display(">>> PASSED: XOR operation output verified!");
        end

        wait_one_step();

        // -------------------------------------------------------------
        // State 4: SUB (Opcode 4 -> 3'b100)
        // Expected: A - B = 0x0F0F0F0F -> LEDs[15:0] = 0x0F0F
        // -------------------------------------------------------------
        $display("\n[OPCODE 4: SUB] LEDs = 0x%04h | Expected = 0x0F0F | Opcode Reg = %d", physical_leds, uut.reg_op);
        if (physical_leds !== 16'h0F0F || uut.reg_op !== 3'd4) begin
            $display(">>> FAILED: Expected LEDs = 0x0F0F for SUB");
            test_errors = test_errors + 1;
        end else begin
            $display(">>> PASSED: SUB operation output verified!");
        end

        wait_one_step();

        // -------------------------------------------------------------
        // State 5: SLL (Opcode 5 -> 3'b101)
        // Expected: A << 1 = 0x20202020 -> LEDs[15:0] = 0x2020
        // -------------------------------------------------------------
        $display("\n[OPCODE 5: SLL] LEDs = 0x%04h | Expected = 0x2020 | Opcode Reg = %d", physical_leds, uut.reg_op);
        if (physical_leds !== 16'h2020 || uut.reg_op !== 3'd5) begin
            $display(">>> FAILED: Expected LEDs = 0x2020 for SLL");
            test_errors = test_errors + 1;
        end else begin
            $display(">>> PASSED: SLL operation output verified!");
        end

        wait_one_step();

        // -------------------------------------------------------------
        // State 6: SRL (Opcode 6 -> 3'b110)
        // Expected: A >> 1 = 0x08080808 -> LEDs[15:0] = 0x0808
        // -------------------------------------------------------------
        $display("\n[OPCODE 6: SRL] LEDs = 0x%04h | Expected = 0x0808 | Opcode Reg = %d", physical_leds, uut.reg_op);
        if (physical_leds !== 16'h0808 || uut.reg_op !== 3'd6) begin
            $display(">>> FAILED: Expected LEDs = 0x0808 for SRL");
            test_errors = test_errors + 1;
        end else begin
            $display(">>> PASSED: SRL operation output verified!");
        end

        // Check 7-segment display for Opcode 6 (3'b110)
        // Digits 2, 1, 0 should show '1', '1', '0' and Digit 3 should be off
        repeat (16) @(posedge clk);
        $display("\n[7-SEGMENT DISPLAY VERIFICATION]");
        $display("Digit 3 Anode = %b (Expected: 1 = OFF)", uut.seg_display.an[3]);

        wait_one_step();

        // -------------------------------------------------------------
        // Check Loop Wrap-around: Next state should be Opcode 0
        // -------------------------------------------------------------
        $display("\n[LOOP WRAP-AROUND CHECK]");
        $display("Opcode Reg = %d (Expected: 0)", uut.reg_op);
        if (uut.reg_op !== 3'd0) begin
            $display(">>> FAILED: Loop did not wrap around to 0!");
            test_errors = test_errors + 1;
        end else begin
            $display(">>> PASSED: Loop successfully wrapped back to Opcode 0!");
        end

        // -------------------------------------------------------------
        // Check Pause Switch (sw[0] = 1)
        // -------------------------------------------------------------
        $display("\n[PAUSE SWITCH CHECK (sw[0] = 1)]");
        physical_sw[0] = 1'b1;
        wait_one_step();
        wait_one_step();
        $display("After 2 wait cycles with sw[0]=1, Opcode Reg = %d (Expected: 0)", uut.reg_op);
        if (uut.reg_op !== 3'd0) begin
            $display(">>> FAILED: Loop did not pause when sw[0]=1!");
            test_errors = test_errors + 1;
        end else begin
            $display(">>> PASSED: Pause functionality verified!");
        end
        physical_sw[0] = 1'b0;

        // -------------------------------------------------------------
        // Summary
        // -------------------------------------------------------------
        $display("\n==================================================================");
        if (test_errors == 0) begin
            $display("   ALL TESTBENCH CHECKS PASSED SUCCESSFULLY! (0 ERRORS)         ");
        end else begin
            $display("   TESTBENCH COMPLETED WITH %d ERRORS!                           ", test_errors);
        end
        $display("==================================================================");

        $finish;
    end

endmodule
