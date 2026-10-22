`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2026 03:20:00 PM
// Design Name: 
// Module Name: top_memory_system
// Project Name: 
// Target Devices: 
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

module top_memory_system #(
    parameter SIM_DIVIDER_COUNT = 50_000_000 - 1,
    parameter SIM_REFRESH_BITS  = 18
)(
    input  wire        clk,
    input  wire        pbin,
    input  wire [15:0] physical_sw,
    output wire [15:0] physical_leds,
    output wire [6:0]  seg,
    output wire        dp,
    output wire [3:0]  an
);

    // 1. Debounce Push Button & Detect Rising Edge
    wire btn_clean;
    reg  btn_prev = 0;
    wire btn_press = (btn_clean && !btn_prev);

    debouncer btn_db (
        .clk(clk),
        .pbin(pbin),
        .pbout(btn_clean)
    );

    always @(posedge clk) begin
        btn_prev <= btn_clean;
    end

    // 2. 1Hz Slow Clock Generator for Auto FSM Stepping
    wire slow_clk;
    clock_divider #(.MAX_COUNT(SIM_DIVIDER_COUNT)) ticker (
        .clk_in(clk),
        .rst(1'b0),
        .clk_out(slow_clk)
    );

    reg slow_clk_prev = 0;
    always @(posedge clk) begin
        slow_clk_prev <= slow_clk;
    end
    wire slow_tick = (slow_clk && !slow_clk_prev);

    // Auto-stepping enabled when physical_sw[0] == 0 and not paused
    wire auto_step  = (!physical_sw[0]) && slow_tick;
    wire step_event = auto_step || btn_press;

    // 3. CPU Control Signals & MMIO Wires
    reg  [31:0] cpu_address;
    reg         cpu_read_en;
    reg         cpu_write_en;
    reg  [31:0] cpu_write_data;

    wire [31:0] cpu_read_data;
    wire [15:0] mmio_leds;

    // Instantiate Memory Subsystem (addressDecoderTop)
    addressDecoderTop mem_subsystem (
        .clk(clk),
        .rst(1'b0),
        .address(cpu_address),
        .readEnable(cpu_read_en),
        .writeEnable(cpu_write_en),
        .writeData(cpu_write_data),
        .switches(physical_sw),
        .readData(cpu_read_data),
        .leds(mmio_leds)
    );

    // 4. Demonstration FSM States
    localparam [2:0]
        S_WRITE_MEM0 = 3'd0,  // Write 0xAAAA to Memory[0]
        S_WRITE_MEM1 = 3'd1,  // Write 0x5555 to Memory[1]
        S_WRITE_LEDS = 3'd2,  // Write 0x0F0F to MMIO LEDs (address 0x100)
        S_READ_MEM0  = 3'd3,  // Read Memory[0] (verifies 0xAAAA)
        S_READ_MEM1  = 3'd4,  // Read Memory[1] (verifies 0x5555)
        S_READ_SW    = 3'd5,  // Read MMIO Switches (address 0x200)
        S_WRITE_SWMEM= 3'd6,  // Write Switch values into Memory[2]
        S_READ_SWMEM = 3'd7;  // Read back Memory[2] (verifies Switch values)

    reg [2:0] state = S_WRITE_MEM0;

    // FSM State Transition
    always @(posedge clk) begin
        if (!physical_sw[1]) begin
            // FSM Mode (physical_sw[1] == 0)
            if (step_event) begin
                state <= state + 1;
            end
        end else begin
            // Manual Mode: reset FSM state to 0 for when user returns to FSM
            state <= S_WRITE_MEM0;
        end
    end

    // FSM / Manual Control Signal Multiplexing
    always @(*) begin
        if (physical_sw[1]) begin
            // Manual Mode:
            // physical_sw[15:14]: Device select (00=Mem, 01=LEDs, 10=Switches)
            // physical_sw[13:8] : Local address
            // physical_sw[7:2]  : Write Data [5:0] (expanded)
            // physical_sw[9]    : 1 = Write (on btn_press), 0 = Read
            cpu_address    = {22'd0, physical_sw[15:14], 2'b00, physical_sw[13:8]};
            cpu_write_data = {26'd0, physical_sw[7:2]};
            cpu_write_en   = physical_sw[9] && btn_press;
            cpu_read_en    = !physical_sw[9];
        end else begin
            // Automated FSM Mode:
            case (state)
                S_WRITE_MEM0: begin
                    cpu_address    = 32'h0000_0000; // Memory[0] (address[9:8] = 00)
                    cpu_write_data = 32'h0000_AAAA;
                    cpu_write_en   = 1'b1;
                    cpu_read_en    = 1'b0;
                end
                S_WRITE_MEM1: begin
                    cpu_address    = 32'h0000_0001; // Memory[1] (address[9:8] = 00)
                    cpu_write_data = 32'h0000_5555;
                    cpu_write_en   = 1'b1;
                    cpu_read_en    = 1'b0;
                end
                S_WRITE_LEDS: begin
                    cpu_address    = 32'h0000_0100; // LEDs (address[9:8] = 01)
                    cpu_write_data = 32'h0000_0F0F;
                    cpu_write_en   = 1'b1;
                    cpu_read_en    = 1'b0;
                end
                S_READ_MEM0: begin
                    cpu_address    = 32'h0000_0000; // Read Memory[0]
                    cpu_write_data = 32'd0;
                    cpu_write_en   = 1'b0;
                    cpu_read_en    = 1'b1;
                end
                S_READ_MEM1: begin
                    cpu_address    = 32'h0000_0001; // Read Memory[1]
                    cpu_write_data = 32'd0;
                    cpu_write_en   = 1'b0;
                    cpu_read_en    = 1'b1;
                end
                S_READ_SW: begin
                    cpu_address    = 32'h0000_0200; // Read Switches (address[9:8] = 10)
                    cpu_write_data = 32'd0;
                    cpu_write_en   = 1'b0;
                    cpu_read_en    = 1'b1;
                end
                S_WRITE_SWMEM: begin
                    cpu_address    = 32'h0000_0002; // Write Switches to Memory[2]
                    cpu_write_data = {16'd0, physical_sw};
                    cpu_write_en   = 1'b1;
                    cpu_read_en    = 1'b0;
                end
                S_READ_SWMEM: begin
                    cpu_address    = 32'h0000_0002; // Read back Memory[2]
                    cpu_write_data = 32'd0;
                    cpu_write_en   = 1'b0;
                    cpu_read_en    = 1'b1;
                end
            endcase
        end
    end

    // 5. Physical LEDs Display Logic
    // In FSM Mode:
    // - During Write LEDs state (or when physical_sw[8]==1), display mmio_leds
    // - During Read states, display the cpu_read_data[15:0]
    assign physical_leds = (physical_sw[8] || (state == S_WRITE_LEDS)) ? mmio_leds : cpu_read_data[15:0];

    // 6. Seven-Segment Display Controller
    // Displays the current FSM state / mode on an[2:0]
    // dp lights up when a write operation is active
    seven_seg_controller #(.REFRESH_BITS(SIM_REFRESH_BITS)) seg_display (
        .clk(clk),
        .rst(1'b0),
        .opcode(state),
        .zero_flag(cpu_write_en),
        .seg(seg),
        .dp(dp),
        .an(an)
    );

endmodule
