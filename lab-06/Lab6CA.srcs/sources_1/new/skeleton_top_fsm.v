`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muddassir Ali
// 
// Module Name: top_fsm_system
// Project Name: Counter
// Target Devices: Baasys 3
// 
//////////////////////////////////////////////////////////////////////////////////

module top_fsm_system (
    input wire clk,
    input wire pbin,
    input wire [15:0] physical_sw,
    output wire [15:0] physical_leds
);

    // Debounce the physical button and detect rising edge
    wire btn_clean;
    reg btn_prev = 0;
    wire btn_press = (btn_clean && !btn_prev);
    
    debouncer btn_db (
        .clk(clk),
        .pbin(pbin), 
        .pbout(btn_clean)
    ); 

    always @(posedge clk) begin
        btn_prev <= btn_clean;
    end
    
    // Read switches
    wire [31:0] switch_data;
    switches switch_reader (
        .physical_sw(physical_sw),
        .switch_data(switch_data)
    );
    
    // Write LEDs
    reg [31:0] led_write_data = 32'd0;
    leds led_writer (
        .clk(clk), 
        .rst(1'b0),
        .writeData(led_write_data),
        .physical_leds(physical_leds)      
    );
    
    // 1Hz slow clock (Available but unused in our manual-step FSM)
    wire slow_clk;
    clock_divider ticker (
        .clk_in(clk),          		
        .rst(1'b0),       		
        .clk_out(slow_clk)     		
    );

    // ALU Instantiation
    reg [31:0] reg_A = 0;
    reg [31:0] reg_B = 0;
    reg [2:0]  reg_op = 0;
    
    wire [31:0] alu_result;
    wire alu_carry;
    
    ALU_32bit my_alu (
        .op_code(reg_op),
        .a(reg_A),
        .b(reg_B),
        .result(alu_result),
        .carry_out(alu_carry)
    );

    // Finite State Machine (FSM) Sequencer
    // We only have 16 switches, so we must load 67 bits of data sequentially.
    // 0: Load A[15:0]
    // 1: Load A[31:16]
    // 2: Load B[15:0]
    // 3: Load B[31:16]
    // 4: Load Opcode
    // 5: View Result[15:0]
    // 6: View Result[31:16]
    // 7: View Carry Out
    reg [2:0] state = 0;
    
    always @(posedge clk) begin
        if (btn_press) begin
            case(state)
                3'd0: begin reg_A[15:0]  <= switch_data[15:0]; state <= 3'd1; end
                3'd1: begin reg_A[31:16] <= switch_data[15:0]; state <= 3'd2; end
                3'd2: begin reg_B[15:0]  <= switch_data[15:0]; state <= 3'd3; end
                3'd3: begin reg_B[31:16] <= switch_data[15:0]; state <= 3'd4; end
                3'd4: begin reg_op       <= switch_data[2:0];  state <= 3'd5; end
                3'd5: begin state <= 3'd6; end 
                3'd6: begin state <= 3'd7; end 
                3'd7: begin state <= 3'd0; end 
            endcase
        end
    end

    // FSM Output Logic to LEDs
    always @(*) begin
        case(state)
            3'd0: led_write_data = switch_data; // Echo input to confirm
            3'd1: led_write_data = switch_data; 
            3'd2: led_write_data = switch_data; 
            3'd3: led_write_data = switch_data; 
            3'd4: led_write_data = switch_data; 
            3'd5: led_write_data = {16'd0, alu_result[15:0]};  // Lower 16 bits of result
            3'd6: led_write_data = {16'd0, alu_result[31:16]}; // Upper 16 bits of result
            3'd7: led_write_data = {31'd0, alu_carry};         // Carry out flag
            default: led_write_data = 32'd0;
        endcase
    end

endmodule