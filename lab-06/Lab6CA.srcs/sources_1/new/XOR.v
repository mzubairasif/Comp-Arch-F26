`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2026 10:14:54 AM
// Design Name: 
// Module Name: XOR
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


module XOR(
input wire a,b,output c
    );
    wire temp1,temp2;
   OR t1(a,~b,temp1);
   OR t2 (~a,b,temp2);
   AND combined(temp1,temp2,c);
    
endmodule
