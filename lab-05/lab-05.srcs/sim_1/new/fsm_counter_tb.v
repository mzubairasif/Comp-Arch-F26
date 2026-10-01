`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muhammad Zubair Asif
// 
// Create Date: 09/23/2026 07:54:07 PM
// Design Name: 
// Module Name: fsm_counter_tb
// Project Name: CompArch F26 lab-05
// Target Devices: BASYS-3
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


module fsm_counter_tb;

    // Inputs to DUT
    reg clk;
    reg rst;
    reg [15:0] switches;

    // Outputs from DUT
    wire [15:0] leds;

    // Instantiate Device Under Test (DUT)
    fsm_counter uut (
        .clk(clk),
        .rst(rst),
        .switches(switches),
        .leds(leds)
    );

    // Clock generation: 100 MHz (Period = 10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Monitor countdown progress
    always @(posedge clk) begin
        if (uut.current_state == 1'b1) begin
            $display("    [State S_COUNT] LEDs = %0d | Counter = %0d", leds, uut.counter);
        end
    end

    // Test stimulus sequence
    initial begin
        $timeformat(-9, 0, " ns", 6);

        // Initialize inputs
        rst = 0;
        switches = 16'd0;

        $display("Starting FSM Counter Testbench...");

        // ------------------------------------------------------------
        // Test 1: Power-on Reset
        // ------------------------------------------------------------
        $display("[Time %0t] Test 1: Asserting reset...", $time);
        #10;
        rst = 1;
        #20;
        rst = 0;
        #20;

        // ------------------------------------------------------------
        // Test 2: Idle State Check (switches = 0)
        // ------------------------------------------------------------
        $display("[Time %0t] Test 2: Checking idle state with switches = 0", $time);
        switches = 16'd0;
        #40;

        // ------------------------------------------------------------
        // Test 3: Normal Countdown (Load 5)
        // ------------------------------------------------------------
        $display("[Time %0t] Test 3: Setting switches = 5, triggering countdown", $time);
        @(negedge clk);
        switches = 16'd5;

        // Once captured into S_COUNT, drop switches back to 0
        @(posedge clk);
        #1;
        switches = 16'd0;

        // Wait enough cycles for counter to count: 5 -> 4 -> 3 -> 2 -> 1 -> 0 -> S_WAIT
        #80;

        // ------------------------------------------------------------
        // Test 4: Switch Immunity (Load 6, change switches during countdown)
        // ------------------------------------------------------------
        $display("[Time %0t] Test 4: Testing switch immunity during countdown", $time);
        @(negedge clk);
        switches = 16'd6;
        @(posedge clk);
        #1;
        // Attempt to tamper with switches while counting down
        switches = 16'd15;
        #30;
        switches = 16'd0;
        #50;

        // ------------------------------------------------------------
        // Test 5: Reset Mid-Countdown (Load 10, assert reset halfway)
        // ------------------------------------------------------------
        $display("[Time %0t] Test 5: Testing reset mid-countdown", $time);
        @(negedge clk);
        switches = 16'd10;
        @(posedge clk);
        #1;
        switches = 16'd0;

        // Let it count down a few ticks (10 -> 9 -> 8 -> 7...)
        #30;
        $display("[Time %0t] Asserting reset mid-countdown!", $time);
        rst = 1;
        #15;
        rst = 0;
        #30;

        $display("[Time %0t] All tests completed successfully!", $time);
        $finish;
    end

endmodule

