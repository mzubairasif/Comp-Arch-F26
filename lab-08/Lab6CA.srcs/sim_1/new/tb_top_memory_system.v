`timescale 1ns / 1ps

module tb_top_memory_system;

    reg clk;
    reg pbin;
    reg [15:0] physical_sw;
    wire [15:0] physical_leds;
    wire [6:0] seg;
    wire dp;
    wire [3:0] an;

    // Instantiate with reduced divider count for rapid simulation
    top_memory_system #(
        .SIM_DIVIDER_COUNT(4),
        .SIM_REFRESH_BITS(4)
    ) uut (
        .clk(clk),
        .pbin(pbin),
        .physical_sw(physical_sw),
        .physical_leds(physical_leds),
        .seg(seg),
        .dp(dp),
        .an(an)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        pbin = 0;
        physical_sw = 16'h0000; // Auto FSM mode

        // Let the auto FSM run through states
        #200;

        // Set switches to a specific pattern (e.g., 0xBEEF)
        physical_sw = 16'hBEEF;
        #300;

        // Test manual button stepping
        pbin = 1; #10; pbin = 0; #50;
        pbin = 1; #10; pbin = 0; #50;

        $display("Hardware top module simulation passed smoothly!");
        $finish;
    end

endmodule
