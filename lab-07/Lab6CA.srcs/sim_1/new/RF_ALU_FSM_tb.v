`timescale 1ns / 1ps

module RF_ALU_FSM_tb;
    reg clk;
    reg reset;

    // Register File Control Signals
    reg [4:0] rs1, rs2, rd;
    reg [31:0] write_data;
    reg reg_write;
    wire [31:0] read_1, read_2;

    // ALU Control Signals
    reg [2:0] alu_op;
    wire [31:0] alu_result;
    wire alu_carry, alu_zero;

    // Instantiate Register File
    reg_file uut_rf (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .reg_write(reg_write),
        .read_1(read_1),
        .read_2(read_2)
    );

    // Instantiate ALU (Using the signature from your Lab 6 code)
    ALU_32bit uut_alu (
        .op_code(alu_op),
        .a(read_1),
        .b(read_2),
        .result(alu_result),
        .carry_out(alu_carry),
        .zero(alu_zero)
    );

    // FSM State Encoding
    parameter [3:0]
        S_RESET          = 4'd0,
        S_INIT_X1        = 4'd1,
        S_INIT_X2        = 4'd2,
        S_INIT_X3        = 4'd3,
        S_IDLE           = 4'd4,
        S_READ_REGISTERS = 4'd5,
        S_ALU_OPERATION  = 4'd6,
        S_WRITE_REGISTERS= 4'd7,
        S_BEQ_PREP       = 4'd8,
        S_BEQ_CHECK      = 4'd9,
        S_RAW_WRITE      = 4'd10,
        S_RAW_READ       = 4'd11,
        S_DONE           = 4'd12;

    reg [3:0] state;
    reg [2:0] op_counter; // Tracks ALU operation 0 through 6
    reg [4:0] dest_reg;   // Tracks destination registers x4 to x10

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // FSM Sequence Execution
    always @(posedge clk) begin
        if (reset) begin
            state <= S_RESET;
            op_counter <= 3'd0;
            dest_reg <= 5'd4;
            reg_write <= 0;
        end else begin
            // Default step (ensures reg_write pulses for exactly 1 cycle)
            reg_write <= 0; 
            
            case (state)
                S_RESET: begin
                    state <= S_INIT_X1;
                end
                
                // --- Initialize Constants ---
                S_INIT_X1: begin
                    rd <= 5'd1; write_data <= 32'h10101010; reg_write <= 1;
                    state <= S_INIT_X2;
                end
                S_INIT_X2: begin
                    rd <= 5'd2; write_data <= 32'h01010101; reg_write <= 1;
                    state <= S_INIT_X3;
                end
                S_INIT_X3: begin
                    rd <= 5'd3; write_data <= 32'h00000005; reg_write <= 1;
                    state <= S_IDLE;
                end

                // --- Core Testing Loop ---
                S_IDLE: begin
                    state <= S_READ_REGISTERS;
                end
                S_READ_REGISTERS: begin
                    rs1 <= 5'd1; rs2 <= 5'd2; // Read initialized constants
                    state <= S_ALU_OPERATION;
                end
                S_ALU_OPERATION: begin
                    alu_op <= op_counter; // Pass counter to ALU opcode
                    state <= S_WRITE_REGISTERS;
                end
                S_WRITE_REGISTERS: begin
                    rd <= dest_reg; 
                    write_data <= alu_result; 
                    reg_write <= 1; // Save output to x4..x10
                    $display("PASS: Op %0d -> rd=x%0d written with result=%h", op_counter, dest_reg, alu_result);
                    
                    if (op_counter == 3'd6) begin
                        state <= S_BEQ_PREP; // All 7 ops finished, move to BEQ test
                    end else begin
                        op_counter <= op_counter + 1;
                        dest_reg <= dest_reg + 1;
                        state <= S_IDLE; // Loop back
                    end
                end

                // --- BEQ Check ---
                S_BEQ_PREP: begin
                    rs1 <= 5'd1; rs2 <= 5'd1; // Compare x1 with itself
                    alu_op <= 3'd4;           // SUB op forces ALU Zero output
                    state <= S_BEQ_CHECK;
                end
                S_BEQ_CHECK: begin
                    if (alu_zero) begin
                        rd <= 5'd11; write_data <= 32'h00000001; reg_write <= 1; // Flag written on equality
                        $display("PASS: BEQ check -> ALU Zero flag asserted for equal operands (x1==x1), flag written to x11");
                    end else begin
                        $display("FAIL: BEQ check -> ALU Zero flag not asserted!");
                    end
                    state <= S_RAW_WRITE;
                end

                // --- Read-After-Write (RAW) Timing ---
                S_RAW_WRITE: begin
                    rd <= 5'd12; write_data <= 32'hBEEFCAFE; reg_write <= 1;
                    state <= S_RAW_READ;
                end
                S_RAW_READ: begin
                    rs1 <= 5'd12; // Read immediately following the write cycle
                    state <= S_DONE;
                end

                S_DONE: begin
                    if (read_1 == 32'hBEEFCAFE)
                        $display("PASS: RAW Timing -> Successfully read x12 = %h in following cycle", read_1);
                    else
                        $display("FAIL: RAW Timing -> Expected 32'hBEEFCAFE, got %h", read_1);
                    $display("=== All Integrated FSM Tests Completed Successfully ===");
                    $finish;
                end
            endcase
        end
    end

    // Booting the Reset sequence
    initial begin
        reset = 1;
        #15 reset = 0;
    end
endmodule