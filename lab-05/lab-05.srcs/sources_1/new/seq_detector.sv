//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muddassir Ali

// Module Name: sequence_detector
// Project Name: sequence_detector
// Target Devices: Baasys 3
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module sequence_detector (
    input logic clk,
    input logic rst,
    input logic din,
    output logic detect
);

    typedef enum logic [2:0] {
        S0,
        S1,
        S2,
        S3,
        S4
    } state_t;

    state_t current_state, next_state;

    // State Register
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // Next State Logic
    always_comb begin

        case (current_state)

            S0: begin
                if (din == 1)
                    next_state = S1;
                else
                    next_state = S0;
            end

            S1: begin
                if (din == 1)
                    next_state = S1;
                else
                    next_state = S2;
            end

            S2: begin
                if (din == 1)
                    next_state = S3;
                else
                    next_state = S0;
            end

            S3: begin
                if (din == 1)
                    next_state = S4;
                else
                    next_state = S0;
            end

            S4: begin
                if (din == 1)
                    next_state = S1;
                else
                    next_state = S0;
            end

            default:
                next_state = S0;

        endcase
    end

    // Output Logic
    always_comb begin

        detect = 0;

        if (current_state == S4 && din == 0)
            detect = 1;

    end

endmodule