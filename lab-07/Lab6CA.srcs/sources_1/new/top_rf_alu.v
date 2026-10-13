`timescale 1ns / 1ps

module top_rf_alu #(
    parameter SIM_DIVIDER_COUNT = 50_000_000 - 1,
    parameter SIM_REFRESH_BITS  = 18
)(
    input wire clk,
    input wire pbin,
    input wire [15:0] physical_sw,
    output wire [15:0] physical_leds,
    output wire [6:0] seg,
    output wire dp,
    output wire [3:0] an
);

    // 1. Re-use Lab 5 Components
    wire btn_clean;
    reg btn_prev = 0;
    wire btn_press = (btn_clean && !btn_prev);
    
    debouncer btn_db (.clk(clk), .pbin(pbin), .pbout(btn_clean)); 
    
    always @(posedge clk) btn_prev <= btn_clean;
    
    wire [31:0] switch_data;
    switches switch_reader (.physical_sw(physical_sw), .switch_data(switch_data));
    
    wire slow_clk;
    clock_divider #(.MAX_COUNT(SIM_DIVIDER_COUNT)) ticker (
        .clk_in(clk), .rst(1'b0), .clk_out(slow_clk)       
    );

    reg slow_clk_prev = 0;
    always @(posedge clk) slow_clk_prev <= slow_clk;
    wire slow_tick = (slow_clk && !slow_clk_prev);

    // 2. Register File and ALU Wires
    reg [4:0] rf_rs1, rf_rs2, rf_rd;
    reg [31:0] rf_wd;
    reg rf_we;
    wire [31:0] rf_r1, rf_r2;
    
    reg [2:0] alu_op = 3'd0;
    wire [31:0] alu_result;
    wire alu_carry, alu_zero;

    // Instantiate Register File
    reg_file my_rf (
        .clk(clk),
        .reset(1'b0), // Tied to 0 for hardware demo stability
        .rs1(rf_rs1),
        .rs2(rf_rs2),
        .rd(rf_rd),
        .write_data(rf_wd),
        .reg_write(rf_we),
        .read_1(rf_r1),
        .read_2(rf_r2)
    );

    // Instantiate ALU 
    ALU_32bit my_alu (
        .op_code(alu_op),
        .a(rf_r1),
        .b(rf_r2),
        .result(alu_result),
        .carry_out(alu_carry),
        .zero(alu_zero)
    );

    // 3. Hardware FSM
    localparam S_INIT_X1 = 2'd0;
    localparam S_INIT_X2 = 2'd1;
    localparam S_RUN     = 2'd2;
    
    reg [1:0] state = S_INIT_X1;
    wire auto_step = (!switch_data[0]) && slow_tick;
    wire step_event = auto_step || btn_press;

    always @(posedge clk) begin
        case (state)
            S_INIT_X1: begin
                rf_rd <= 5'd1; 
                rf_wd <= 32'h10101010; // Constant A
                rf_we <= 1'b1;
                state <= S_INIT_X2;
            end
            S_INIT_X2: begin
                rf_rd <= 5'd2; 
                rf_wd <= 32'h01010101; // Constant B
                rf_we <= 1'b1;
                state <= S_RUN;
            end
            S_RUN: begin
                rf_rs1 <= 5'd1; 
                rf_rs2 <= 5'd2;
                
                if (switch_data[1]) begin
                    // Manual Switch Mode:
                    // SW[4:2] directly selects ALU operation
                    // SW[9] enables writing ALU result to register SW[13:10] upon pushbutton press
                    alu_op <= switch_data[4:2];
                    rf_we  <= switch_data[9] && btn_press;
                    rf_rd  <= {1'b0, switch_data[13:10]};
                    rf_wd  <= alu_result;
                end else begin
                    // FSM Stepper Mode:
                    // Cycles ALU operations when step_event occurs (auto or btn)
                    rf_we <= 1'b0;
                    if (step_event) begin
                        if (alu_op >= 3'd6) alu_op <= 3'd0;
                        else alu_op <= alu_op + 1;
                    end
                end
            end
            default: begin
                state  <= S_INIT_X1;
                rf_we  <= 1'b0;
                alu_op <= 3'd0;
            end
        endcase
    end

    // 4. LED Output Multiplexer
    reg [31:0] led_write_data = 32'd0;
    always @(*) begin
        if (switch_data[15]) begin
            // Show upper 16 bits of ALU result
            led_write_data = {16'd0, alu_result[31:16]};
        end else if (switch_data[14]) begin
            // Show Status Flags, State, and Opcode:
            // LEDs [9:7]: alu_op, LEDs [5:4]: state, LED 1: carry, LED 0: zero
            led_write_data = {6'd0, alu_op, 1'b0, state, 2'b0, alu_carry, alu_zero};
        end else begin
            // Show lower 16 bits of ALU result
            led_write_data = {16'd0, alu_result[15:0]};
        end
    end

    leds led_writer (
        .clk(clk), .rst(1'b0),
        .writeData(led_write_data),
        .physical_leds(physical_leds)      
    );

    seven_seg_controller #(.REFRESH_BITS(SIM_REFRESH_BITS)) seg_display (
        .clk(clk), .rst(1'b0),
        .opcode(alu_op), .zero_flag(alu_zero),
        .seg(seg), .dp(dp), .an(an)
    );

endmodule