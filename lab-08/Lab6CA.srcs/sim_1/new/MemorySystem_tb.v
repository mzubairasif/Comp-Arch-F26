`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2026 03:15:00 PM
// Design Name: 
// Module Name: MemorySystem_tb
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

module MemorySystem_tb;

    reg         clk;
    reg         rst;
    reg  [31:0] address;
    reg         readEnable;
    reg         writeEnable;
    reg  [31:0] writeData;
    reg  [15:0] switches;

    wire [31:0] readData;
    wire [15:0] leds;

    integer errors = 0;

    // Instantiate Device Under Test (DUT)
    addressDecoderTop dut (
        .clk(clk),
        .rst(rst),
        .address(address),
        .readEnable(readEnable),
        .writeEnable(writeEnable),
        .writeData(writeData),
        .switches(switches),
        .readData(readData),
        .leds(leds)
    );

    // Clock generation: 100MHz (10ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, MemorySystem_tb);

        $display("===================================================================");
        $display("        Starting Lab 8 Memory System & Address Decoder Tests       ");
        $display("===================================================================");

        // Initial setup
        clk = 0;
        rst = 1;
        address = 32'd0;
        readEnable = 0;
        writeEnable = 0;
        writeData = 32'd0;
        switches = 16'h0000;

        // Apply reset for 2 clock cycles
        #20;
        rst = 0;
        #10;

        // -------------------------------------------------------------------------
        // TEST 1: Data Memory Write & Read Back (address[9:8] == 2'b00)
        // -------------------------------------------------------------------------
        $display("\n--- TEST 1: Data Memory Write and Read-Back ---");

        // Write to address 0 (address[9:8] = 00, local 0)
        @(posedge clk);
        address = 32'h0000_0000;
        writeData = 32'hDEADBEEF;
        writeEnable = 1;
        readEnable = 0;
        @(posedge clk);
        writeEnable = 0;

        // Write to address 10 (address[9:8] = 00, local 10)
        @(posedge clk);
        address = 32'h0000_000A;
        writeData = 32'hCAFE1234;
        writeEnable = 1;
        @(posedge clk);
        writeEnable = 0;

        // Write to address 255 (address[9:8] = 00, local 255)
        @(posedge clk);
        address = 32'h0000_00FF;
        writeData = 32'h55AA33CC;
        writeEnable = 1;
        @(posedge clk);
        writeEnable = 0;

        // Read back from address 0
        @(posedge clk);
        address = 32'h0000_0000;
        readEnable = 1;
        #1; // combinational read settling
        if (readData === 32'hDEADBEEF) begin
            $display("[PASS] Read Memory[0]: Expected 32'hDEADBEEF, Got 32'h%h", readData);
        end else begin
            $display("[FAIL] Read Memory[0]: Expected 32'hDEADBEEF, Got 32'h%h", readData);
            errors = errors + 1;
        end

        // Read back from address 10
        @(posedge clk);
        address = 32'h0000_000A;
        readEnable = 1;
        #1;
        if (readData === 32'hCAFE1234) begin
            $display("[PASS] Read Memory[10]: Expected 32'hCAFE1234, Got 32'h%h", readData);
        end else begin
            $display("[FAIL] Read Memory[10]: Expected 32'hCAFE1234, Got 32'h%h", readData);
            errors = errors + 1;
        end

        // Read back from address 255
        @(posedge clk);
        address = 32'h0000_00FF;
        readEnable = 1;
        #1;
        if (readData === 32'h55AA33CC) begin
            $display("[PASS] Read Memory[255]: Expected 32'h55AA33CC, Got 32'h%h", readData);
        end else begin
            $display("[FAIL] Read Memory[255]: Expected 32'h55AA33CC, Got 32'h%h", readData);
            errors = errors + 1;
        end

        readEnable = 0;

        // -------------------------------------------------------------------------
        // TEST 2: Memory-Mapped LEDs Write (address[9:8] == 2'b01)
        // -------------------------------------------------------------------------
        $display("\n--- TEST 2: Memory-Mapped LEDs Write ---");

        // Write 0xABCD to LEDs (address[9:8] = 2'b01 -> address = 0x100 or 0x110)
        @(posedge clk);
        address = 32'h0000_0100; // address[9:8] = 2'b01
        writeData = 32'h0000_ABCD;
        writeEnable = 1;
        readEnable = 0;
        @(posedge clk);
        #1;
        if (leds === 16'hABCD) begin
            $display("[PASS] Write LEDs (0xABCD): LEDs correctly show 16'h%h", leds);
        end else begin
            $display("[FAIL] Write LEDs (0xABCD): Expected 16'hABCD, Got 16'h%h", leds);
            errors = errors + 1;
        end

        // Overwrite LEDs with 0x1234 at another LED offset (e.g. 0x110)
        @(posedge clk);
        address = 32'h0000_0110; // address[9:8] = 2'b01
        writeData = 32'hFFFF_1234;
        writeEnable = 1;
        @(posedge clk);
        #1;
        if (leds === 16'h1234) begin
            $display("[PASS] Overwrite LEDs (0x1234): LEDs correctly show 16'h%h", leds);
        end else begin
            $display("[FAIL] Overwrite LEDs (0x1234): Expected 16'h1234, Got 16'h%h", leds);
            errors = errors + 1;
        end

        writeEnable = 0;

        // -------------------------------------------------------------------------
        // TEST 3: Memory-Mapped Switches Read (address[9:8] == 2'b10)
        // -------------------------------------------------------------------------
        $display("\n--- TEST 3: Memory-Mapped Switches Read ---");

        // Set physical switch pattern 1
        switches = 16'hF0F0;
        @(posedge clk);
        address = 32'h0000_0200; // address[9:8] = 2'b10
        readEnable = 1;
        writeEnable = 0;
        #1;
        if (readData === 32'h0000_F0F0) begin
            $display("[PASS] Read Switches (0xF0F0): CPU readData = 32'h%h", readData);
        end else begin
            $display("[FAIL] Read Switches (0xF0F0): Expected 32'h0000F0F0, Got 32'h%h", readData);
            errors = errors + 1;
        end

        // Change switch pattern 2
        switches = 16'hA55A;
        #1;
        if (readData === 32'h0000_A55A) begin
            $display("[PASS] Read Switches dynamic change (0xA55A): CPU readData = 32'h%h", readData);
        end else begin
            $display("[FAIL] Read Switches dynamic change (0xA55A): Expected 32'h0000A55A, Got 32'h%h", readData);
            errors = errors + 1;
        end

        readEnable = 0;

        // -------------------------------------------------------------------------
        // TEST 4: Address Decoder Isolation & Contention Verification
        // -------------------------------------------------------------------------
        $display("\n--- TEST 4: Decoder Isolation & Mutual Exclusion ---");

        // 4A: Write to Data Memory must NOT alter LEDs
        @(posedge clk);
        address = 32'h0000_0005; // Memory address
        writeData = 32'h9999_9999;
        writeEnable = 1;
        @(posedge clk);
        #1;
        if (leds === 16'h1234) begin
            $display("[PASS] Memory write does NOT corrupt LEDs: LEDs remain 16'h%h", leds);
        end else begin
            $display("[FAIL] Memory write corrupted LEDs! LEDs = 16'h%h", leds);
            errors = errors + 1;
        end

        // 4B: Attempt to write to Switch address (read-only) must be ignored
        @(posedge clk);
        address = 32'h0000_0200; // Switch address
        writeData = 32'hDEAD_BEEF;
        writeEnable = 1;
        @(posedge clk);
        #1;
        if (leds === 16'h1234) begin
            $display("[PASS] Write to read-only Switch address is safely ignored");
        end else begin
            $display("[FAIL] Write to Switch address leaked to LEDs! LEDs = 16'h%h", leds);
            errors = errors + 1;
        end

        // 4C: Attempt to read from LED address (write-only) should return 0
        @(posedge clk);
        address = 32'h0000_0100; // LED address
        writeEnable = 0;
        readEnable = 1;
        #1;
        if (readData === 32'd0) begin
            $display("[PASS] Read from write-only LED address returns 32'h00000000");
        end else begin
            $display("[FAIL] Read from LED address returned non-zero: 32'h%h", readData);
            errors = errors + 1;
        end

        // 4D: Access to unused address space (address[9:8] == 2'b11) returns 0
        @(posedge clk);
        address = 32'h0000_0300; // Unused address (2'b11)
        writeEnable = 1;
        writeData = 32'hFFFF_FFFF;
        readEnable = 1;
        @(posedge clk);
        #1;
        if (readData === 32'd0 && leds === 16'h1234) begin
            $display("[PASS] Access to Unused address space (2'b11) has no side-effects and returns 0");
        end else begin
            $display("[FAIL] Unused address access caused unwanted side-effects! readData=%h, leds=%h", readData, leds);
            errors = errors + 1;
        end

        // 4E: Read without readEnable returns 0
        @(posedge clk);
        address = 32'h0000_0000; // Memory has DEADBEEF
        readEnable = 0;
        writeEnable = 0;
        #1;
        if (readData === 32'd0) begin
            $display("[PASS] Read with readEnable=0 returns 32'h00000000");
        end else begin
            $display("[FAIL] Read with readEnable=0 returned data: 32'h%h", readData);
            errors = errors + 1;
        end

        // -------------------------------------------------------------------------
        // Final Summary
        // -------------------------------------------------------------------------
        $display("\n===================================================================");
        if (errors == 0) begin
            $display("   *** ALL TESTS PASSED SUCCESSFULLY! (0 Errors) ***               ");
            $display("   Data Memory, Address Decoder, LEDs, and Switches are verified!  ");
        end else begin
            $display("   *** TEST FAILED WITH %0d ERROR(S) ***                           ", errors);
        end
        $display("===================================================================\n");

        #20;
        $finish;
    end

endmodule
