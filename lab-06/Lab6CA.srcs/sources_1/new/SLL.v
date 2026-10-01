// 32-bit logical shift left by 1 (SLL)
// Bit 0 is filled with 0; bit 31 of the input is shifted out.
module SLL (
    input  [31:0] A,
    output [31:0] Result
);

    assign Result = {A[30:0], 1'b0};

endmodule
