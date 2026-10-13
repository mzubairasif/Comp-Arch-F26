`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muddassir Ali
// 
// Module Name: debouncer
// Project Name: Counter
// Target Devices: Baasys 3
// 
//////////////////////////////////////////////////////////////////////////////////

module debouncer(
    input clk,
    input pbin,
    output pbout
);
    reg pb_sync_0 = 0;
    reg pb_sync_1 = 0;
    reg [15:0] count = 0;
    reg pb_state = 0;
    
    always @(posedge clk) begin
        // 2-stage synchronizer to prevent metastability
        pb_sync_0 <= pbin;
        pb_sync_1 <= pb_sync_0;
        
        // Counter-based debouncer
        if (pb_state == pb_sync_1) begin
            count <= 0;
        end else begin
            count <= count + 1;
            // 16'hFFFF at 100MHz is ~6.5ms of stable signal needed
            if (count == 16'hFFFF) begin
                pb_state <= pb_sync_1;
                count <= 0;
            end
        end
    end
    
    assign pbout = pb_state;
endmodule