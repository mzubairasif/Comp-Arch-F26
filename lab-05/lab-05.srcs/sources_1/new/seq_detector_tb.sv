//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muddassir Ali

// Module Name: sequence_detector_tb
// Project Name: sequence_detector
// Target Devices: Baasys 3
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module sequence_detector_tb;

    logic clk;
    logic rst;
    logic din;
    logic detect;

    sequence_detector dut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .detect(detect)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        rst = 1;
        din = 0;

        // Reset
        #10;
        rst = 0;

        // Input = 10110
        din = 1;
        #10;

        din = 0;
        #10;

        din = 1;
        #10;

        din = 1;
        #10;

        din = 0;
        #10;

        // Input = 110110
        din = 1;
        #10;

        din = 1;
        #10;

        din = 0;
        #10;

        din = 1;
        #10;

        din = 1;
        #10;

        din = 0;
        #10;

        $finish;

    end

endmodule