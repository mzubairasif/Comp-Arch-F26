`timescale 1ns / 1ps

module tb_top_fsm_system;

    reg clk;
    reg pbin;
    reg [15:0] physical_sw;
    wire [15:0] physical_leds;

    // Instantiate Top FSM System
    top_fsm_system uut (
        .clk(clk),
        .pbin(pbin),
        .physical_sw(physical_sw),
        .physical_leds(physical_leds)
    );

    // 100 MHz clock generation (10ns period)
    always #5 clk = ~clk;

    // Task to press and release button (holding across debouncer duration 65536 cycles)
    task press_button;
    begin
        pbin = 1'b1;
        // Hold high for ~70,000 clock cycles (700us) to pass debouncer
        repeat (70000) @(posedge clk);
        pbin = 1'b0;
        // Hold low for ~70,000 clock cycles to allow debouncer to reset
        repeat (70000) @(posedge clk);
    end
    endtask

    initial begin
        clk = 0;
        pbin = 0;
        physical_sw = 16'd0;

        $display("=================================================");
        $display("   STARTING TOP FSM SYSTEM TESTBENCH SIMULATION   ");
        $display("=================================================");

        // Wait initial settling time
        repeat (100) @(posedge clk);

        // -----------------------------------------------------------------
        // TEST 1: 5 + 3 = 8 (Opcode 2)
        // -----------------------------------------------------------------
        $display("\n[TEST 1] Setting up A = 5, B = 3, Opcode = 2 (ADD)");

        // Step 0: Set A[15:0] = 5
        physical_sw = 16'd5;
        repeat (20) @(posedge clk);
        $display("State 0: Switch Data = %d, LEDs echoing = %d", physical_sw, physical_leds);
        press_button();

        // Step 1: Set A[31:16] = 0
        physical_sw = 16'd0;
        repeat (20) @(posedge clk);
        $display("State 1: Switch Data = %d, LEDs echoing = %d", physical_sw, physical_leds);
        press_button();

        // Step 2: Set B[15:0] = 3
        physical_sw = 16'd3;
        repeat (20) @(posedge clk);
        $display("State 2: Switch Data = %d, LEDs echoing = %d", physical_sw, physical_leds);
        press_button();

        // Step 3: Set B[31:16] = 0
        physical_sw = 16'd0;
        repeat (20) @(posedge clk);
        $display("State 3: Switch Data = %d, LEDs echoing = %d", physical_sw, physical_leds);
        press_button();

        // Step 4: Set Opcode = 2 (ADD)
        physical_sw = 16'd2;
        repeat (20) @(posedge clk);
        $display("State 4: Opcode = %d, LEDs echoing = %d", physical_sw[2:0], physical_leds);
        press_button();

        // Step 5: Read Lower 16-bits of Result
        repeat (20) @(posedge clk);
        $display("State 5 (Result Low): physical_leds = %d (Expected: 8)", physical_leds);
        if (physical_leds == 16'd8)
            $display(">>> TEST 1 RESULT LOW: PASSED! <<<");
        else
            $display(">>> TEST 1 RESULT LOW: FAILED! <<<");
        press_button();

        // Step 6: Read Upper 16-bits of Result
        repeat (20) @(posedge clk);
        $display("State 6 (Result High): physical_leds = %d (Expected: 0)", physical_leds);
        if (physical_leds == 16'd0)
            $display(">>> TEST 1 RESULT HIGH: PASSED! <<<");
        else
            $display(">>> TEST 1 RESULT HIGH: FAILED! <<<");
        press_button();

        // Step 7: Read Carry Out
        repeat (20) @(posedge clk);
        $display("State 7 (Carry Out): physical_leds = %b (Expected: 0)", physical_leds[0]);
        if (physical_leds[0] == 1'b0)
            $display(">>> TEST 1 CARRY OUT: PASSED! <<<");
        else
            $display(">>> TEST 1 CARRY OUT: FAILED! <<<");
        press_button();

        // -----------------------------------------------------------------
        // TEST 2: 20 - 10 = 10 (Opcode 4: SUB)
        // -----------------------------------------------------------------
        $display("\n[TEST 2] Setting up A = 20, B = 10, Opcode = 4 (SUB)");

        // Step 0: Set A[15:0] = 20
        physical_sw = 16'd20;
        repeat (20) @(posedge clk);
        press_button();

        // Step 1: Set A[31:16] = 0
        physical_sw = 16'd0;
        repeat (20) @(posedge clk);
        press_button();

        // Step 2: Set B[15:0] = 10
        physical_sw = 16'd10;
        repeat (20) @(posedge clk);
        press_button();

        // Step 3: Set B[31:16] = 0
        physical_sw = 16'd0;
        repeat (20) @(posedge clk);
        press_button();

        // Step 4: Set Opcode = 4 (SUB)
        physical_sw = 16'd4;
        repeat (20) @(posedge clk);
        press_button();

        // Step 5: Read Lower 16-bits of Result
        repeat (20) @(posedge clk);
        $display("State 5 (Result Low): physical_leds = %d (Expected: 10)", physical_leds);
        if (physical_leds == 16'd10)
            $display(">>> TEST 2 SUBTRACTION: PASSED! <<<");
        else
            $display(">>> TEST 2 SUBTRACTION: FAILED! <<<");

        $display("\n=================================================");
        $display("   TESTBENCH SIMULATION COMPLETED!              ");
        $display("=================================================");
        $finish;
    end

endmodule
