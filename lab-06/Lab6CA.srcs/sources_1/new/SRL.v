// 32-bit logical shift right by 1 (SRL)
// Bit 31 is filled with 0; bit 0 of the input is shifted out.
module SRL (
    input  [31:0] A,
    output [31:0] Result
);

    assign Result = {1'b0, A[31:1]};

endmodule
