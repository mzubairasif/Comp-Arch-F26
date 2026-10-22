`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: top_fsm_system
// Target Devices: Basys 3
// Description: Top-level module for Lab 6 Task 3: FPGA Synthesis and RTL Analysis.
//              - Operands A and B are hardcoded into 32-bit registers (Task 3(e)).
//              - An FSM continuously cycles through all 7 ALU operations in a loop (Task 3(b)).
//              - ALU results are displayed on the 16 onboard LEDs (Task 3(d,g)).
//              - The 3-bit opcode is displayed across 3 onboard seven-segment LEDs (an[2:0]).
//              - Digit 3 (an[3]) is kept OFF so exactly 3 digits are used.
//              - Debouncer, switches, and leds modules from Lab 5 are reused.
//////////////////////////////////////////////////////////////////////////////////

module top_fsm_system #(
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
    
    // Read switches (re-using Lab 5 switch interface module)
    wire [31:0] switch_data;
    switches switch_reader (
        .physical_sw(physical_sw),
        .switch_data(switch_data)
    );
    
    // 1Hz slow clock generator (1 second period)
    wire slow_clk;
    clock_divider #(
        .MAX_COUNT(SIM_DIVIDER_COUNT)
    ) ticker (
        .clk_in(clk),          		
        .rst(1'b0),       		
        .clk_out(slow_clk)     		
    );

    // Synchronize slow_clk to 100MHz clock domain and detect rising edge
    reg slow_clk_prev = 0;
    always @(posedge clk) begin
        slow_clk_prev <= slow_clk;
    end
    wire slow_tick = (slow_clk && !slow_clk_prev);

    // Task 3(e): Hardcode two fixed 32-bit numbers into registers
    // A = 0x10101010, B = 0x01010101
    reg [31:0] reg_A = 32'h10101010;
    reg [31:0] reg_B = 32'h01010101;
    reg [2:0]  reg_op = 3'd0;
    
    wire [31:0] alu_result;
    wire alu_carry;
    wire alu_zero;
    
    // 32-bit ALU Instantiation
    ALU_32bit my_alu (
        .op_code(reg_op),
        .a(reg_A),
        .b(reg_B),
        .result(alu_result),
        .carry_out(alu_carry),
        .zero(alu_zero)
    );

    // FSM Execution Control:
    // - physical_sw[0] == 0 (default): Loop automatically every ~1 second
    // - physical_sw[0] == 1: Pause the loop on the current operation
    // - Pressing pbin (btn_press): Manually step to the next operation anytime
    wire auto_step = (!switch_data[0]) && slow_tick;
    wire step_event = auto_step || btn_press;

    // FSM Sequencer: Cycles through all 7 supported ALU operations (0 to 6):
    // 3'd0: OR   (A | B = 0x11111111) -> LEDs: 0x1111
    // 3'd1: AND  (A & B = 0x00000000) -> LEDs: 0x0000, Zero = 1
    // 3'd2: ADD  (A + B = 0x11111111) -> LEDs: 0x1111
    // 3'd3: XOR  (A ^ B = 0x11111111) -> LEDs: 0x1111
    // 3'd4: SUB  (A - B = 0x0F0F0F0F) -> LEDs: 0x0F0F
    // 3'd5: SLL  (A << 1 = 0x20202020) -> LEDs: 0x2020
    // 3'd6: SRL  (A >> 1 = 0x08080808) -> LEDs: 0x0808
    always @(posedge clk) begin
        if (step_event) begin
            if (reg_op == 3'd6)
                reg_op <= 3'd0;
            else
                reg_op <= reg_op + 1;
        end
    end

    // LED Multiplexing:
    // Default (switches 15 & 14 = 0): Show lower 16 bits of ALU result
    // switch 15 == 1: Show upper 16 bits of ALU result
    // switch 14 == 1: Show status flags {14'd0, Carry, Zero}
    reg [31:0] led_write_data = 32'd0;
    always @(*) begin
        if (switch_data[15]) begin
            led_write_data = {16'd0, alu_result[31:16]};
        end else if (switch_data[14]) begin
            led_write_data = {14'd0, alu_carry, alu_zero};
        end else begin
            led_write_data = {16'd0, alu_result[15:0]};
        end
    end

    // Write LEDs (re-using Lab 5 LED interface module)
    leds led_writer (
        .clk(clk), 
        .rst(1'b0),
        .writeData(led_write_data),
        .physical_leds(physical_leds)      
    );

    // 7-Segment Display Controller:
    // Displays the 3-bit opcode across 3 of the onboard seven-segment LEDs:
    // - an[2] displays reg_op[2] ('0' or '1')
    // - an[1] displays reg_op[1] ('0' or '1')
    // - an[0] displays reg_op[0] ('0' or '1')
    // - an[3] is turned OFF (unlit)
    // - dp (decimal point) lights up when zero flag is high
    seven_seg_controller #(
        .REFRESH_BITS(SIM_REFRESH_BITS)
    ) seg_display (
        .clk(clk),
        .rst(1'b0),
        .opcode(reg_op),
        .zero_flag(alu_zero),
        .seg(seg),
        .dp(dp),
        .an(an)
    );

endmodule