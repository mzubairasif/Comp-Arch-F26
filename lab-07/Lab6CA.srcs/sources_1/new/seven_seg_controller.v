`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: seven_seg_controller
// Target Devices: Basys 3
// Description: Time-multiplexed controller for Basys 3 4-digit 7-segment display.
//              Displays a 3-bit opcode across 3 of the onboard seven-segment LEDs:
//              - an[2] displays bit 2 of opcode (MSB)
//              - an[1] displays bit 1 of opcode
//              - an[0] displays bit 0 of opcode (LSB)
//              - an[3] is turned OFF (unlit)
//              - dp (decimal point) lights up when zero_flag is asserted.
//////////////////////////////////////////////////////////////////////////////////

module seven_seg_controller #(
    parameter REFRESH_BITS = 18
)(
    input  wire       clk,        // 100 MHz system clock
    input  wire       rst,        // reset
    input  wire [2:0] opcode,     // 3-bit opcode to display
    input  wire       zero_flag,  // Zero flag indicator for decimal point
    output reg  [6:0] seg,        // 7-segment cathodes: {g, f, e, d, c, b, a} (active low)
    output wire       dp,         // Decimal point (active low)
    output reg  [3:0] an          // 4-digit anodes: an[3..0] (active low)
);

    // Refresh counter for multiplexing (100MHz / 2^18 ~ 381 Hz overall refresh rate)
    reg [REFRESH_BITS-1:0] refresh_counter = 0;
    always @(posedge clk) begin
        if (rst)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end

    wire [1:0] digit_select = refresh_counter[REFRESH_BITS-1 : REFRESH_BITS-2];

    // Decode single bit ('0' or '1') into active-low 7-segment cathodes
    // seg[0]=a, seg[1]=b, seg[2]=c, seg[3]=d, seg[4]=e, seg[5]=f, seg[6]=g
    function [6:0] get_seg_bit(input bit_val);
        begin
            case (bit_val)
                1'b0: get_seg_bit = 7'b1000000; // '0': a,b,c,d,e,f ON (0), g OFF (1)
                1'b1: get_seg_bit = 7'b1111001; // '1': b,c ON (0), a,d,e,f,g OFF (1)
            endcase
        end
    endfunction

    // 4 digits on Basys 3:
    // an[3] (Leftmost)  -> Disabled / unlit (an = 1)
    // an[2] (Mid-left)  -> Displays opcode[2] (MSB)
    // an[1] (Mid-right) -> Displays opcode[1]
    // an[0] (Rightmost) -> Displays opcode[0] (LSB)
    always @(*) begin
        case (digit_select)
            2'b00: begin
                an  = 4'b1110; // Activate Digit 0
                seg = get_seg_bit(opcode[0]);
            end
            2'b01: begin
                an  = 4'b1101; // Activate Digit 1
                seg = get_seg_bit(opcode[1]);
            end
            2'b10: begin
                an  = 4'b1011; // Activate Digit 2
                seg = get_seg_bit(opcode[2]);
            end
            2'b11: begin
                an  = 4'b1111; // Digit 3 disabled (OFF)
                seg = 7'b1111111;
            end
        endcase
    end

    // Active-low decimal point: lit up when zero_flag is asserted
    assign dp = ~zero_flag;

endmodule
