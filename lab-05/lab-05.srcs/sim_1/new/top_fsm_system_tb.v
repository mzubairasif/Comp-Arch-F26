`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muhammad Zubair Asif
// 
// Create Date: 09/24/2026 01:00:00 AM
// Design Name: 
// Module Name: top_fsm_system_tb
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

module top_fsm_system_tb;

    // Inputs to DUT
    reg clk;
    reg pbin;
    reg [15:0] physical_sw;

    // Outputs from DUT
    wire [15:0] physical_leds;

    // Instantiate Top-Level System
    skeleton_top_fsm uut (
        .clk(clk),
        .pbin(pbin),
        .physical_sw(physical_sw),
        .physical_leds(physical_leds)
    );

    // Fast clock generation: 100 MHz (Period = 10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Monitor countdown sequence on physical_leds
    always @(posedge uut.slow_clk) begin
        if (uut.counter_inst.current_state == 1'b1) begin
            $display("    [SlowClk Tick] state=%b | Counter=%0d | physical_leds=%0d", 
                     uut.counter_inst.current_state, uut.counter_inst.counter, physical_leds);
        end
    end

    // Test sequence
    initial begin
        $timeformat(-9, 0, " ns", 6);

        // Initialize
        pbin = 0;
        physical_sw = 16'd0;

        $display("Starting Top-Level FSM System Testbench...");

        // ------------------------------------------------------------
        // Test 1: Power-on Reset
        // ------------------------------------------------------------
        $display("[Time %0t] Test 1: Asserting reset (pbin)...", $time);
        #20;
        pbin = 1;
        #40;
        pbin = 0;
        #40;

        // ------------------------------------------------------------
        // Test 2: Idle State Check
        // ------------------------------------------------------------
        $display("[Time %0t] Test 2: Checking idle state with physical_sw = 0", $time);
        physical_sw = 16'd0;
        #100;

        // ------------------------------------------------------------
        // Test 3: Normal Countdown (Load 5)
        // ------------------------------------------------------------
        $display("[Time %0t] Test 3: Setting physical_sw = 5, triggering countdown", $time);
        @(negedge uut.slow_clk);
        physical_sw = 16'd5;
        @(posedge uut.slow_clk);
        #10;
        physical_sw = 16'd0;

        // Wait enough cycles for countdown (each slow clock period is 60ns)
        #480;

        // ------------------------------------------------------------
        // Test 4: Switch Immunity (Load 6, tamper with 15)
        // ------------------------------------------------------------
        $display("[Time %0t] Test 4: Testing switch immunity (load 6, tamper with 15)", $time);
        @(negedge uut.slow_clk);
        physical_sw = 16'd6;
        @(posedge uut.slow_clk);
        #10;
        physical_sw = 16'd15;
        #180;
        physical_sw = 16'd0;
        #300;

        // ------------------------------------------------------------
        // Test 5: Reset Mid-Countdown (Load 10, assert pbin halfway)
        // ------------------------------------------------------------
        $display("[Time %0t] Test 5: Testing reset mid-countdown", $time);
        @(negedge uut.slow_clk);
        physical_sw = 16'd10;
        @(posedge uut.slow_clk);
        #10;
        physical_sw = 16'd0;
        #180;
        $display("[Time %0t] Asserting reset (pbin) mid-countdown!", $time);
        pbin = 1;
        #60;
        pbin = 0;
        #120;

        $display("[Time %0t] All top-level tests completed successfully!", $time);
        $finish;
    end

endmodule
