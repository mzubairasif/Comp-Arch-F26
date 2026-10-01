`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muhammad Zubair Asif
// 
// Create Date: 09/23/2026 07:54:07 PM
// Design Name: 
// Module Name: fsm_counter
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


module fsm_counter(
input wire clk,
input wire rst,
input wire [15:0]switches,
output reg [15:0]leds
);
    localparam S_WAIT = 1'b0;
    localparam S_COUNT = 1'b1;
    
    reg current_state, next_state;
    reg [15:0] counter;
    
    always @(*) begin
    
        case (current_state)
            S_WAIT: next_state = (switches != 16'd0)? S_COUNT: S_WAIT;
        
            S_COUNT: next_state = (counter == 16'd0)? S_WAIT: S_COUNT;
            
            default: next_state = S_WAIT;
        
    endcase   
                
    end
    
    always @(posedge clk or posedge rst) begin
        current_state <= rst? S_WAIT: next_state;
    end
    
    always @(posedge clk or posedge rst) begin
    
        if (rst) begin
            counter <= 16'd0;
            leds <= 16'd0;
        end else begin
            case (current_state)
            
            S_WAIT: begin
                if (switches != 16'd0) begin
                    counter <= switches;
                    leds <= switches;
                end else begin
                    counter <= 16'd0;
                    leds <= 16'd0;
                end
            end
            
            S_COUNT: begin
                if (counter > 16'd0) begin
                    counter <= counter - 1'b1;
                    leds <= counter - 1'b1;
                end else begin
                    counter <= 16'd0;
                    leds <= 16'd0;
                end
            end
                
            default: begin
                counter <= 16'd0;
                leds <= 16'd0;
            end
        endcase
    end
end 
    
endmodule
