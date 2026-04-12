`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 18.03.2026 12:51:43
// Design Name:
// Module Name: ArithmeticLogicUnit
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


module ArithmeticLogicUnit(
    input [15:0] A,
    input [15:0] B,
    input [3:0] FunSel,
    input Clock,
    input WF,                 
    output reg [15:0] ALUOut,
    output reg [3:0] FlagsOut
    );

    initial begin
        ALUOut = 16'h0000;
        FlagsOut = 4'b0000;
    end

    reg [16:0] results;
    reg [3:0] next_flags;

    always @(*) begin
        results = 17'b0;

        case (FunSel)
            4'b0000: results = {1'b0, A};
            4'b0001: results = {1'b0, B};
            4'b0010: results = {1'b0, ~A};
            4'b0011: results = {1'b0, ~B};
            4'b0100: results = A + B;
            4'b0101: results = A + B + FlagsOut[2];
            4'b0110: results = A - B;
            4'b0111: results = {1'b0, A & B};
            4'b1000: results = {1'b0, A | B};
            4'b1001: results = {1'b0, A ^ B};
            4'b1010: results = {1'b0, ~(A & B)};
            4'b1011: results = {A[15], A[14:0], 1'b0};
            4'b1100: results = {A[0], 1'b0, A[15:1]};
            4'b1101: results = {1'b0, A[15], A[15:1]};
            4'b1110: results = {A[15], A[14:0], A[15]};
            4'b1111: results = {A[0], A[0], A[15:1]};
            default: results = 17'b0;
        endcase

        next_flags[3] = (results[15:0] == 16'b0); 
        next_flags[1] = results[15];              
        
        if (FunSel == 4'b0100 || FunSel == 4'b0101 || FunSel == 4'b0110) begin
            next_flags[2] = results[16];
            
            if (FunSel == 4'b0110)
                next_flags[0] = (~A[15] & B[15] & results[15]) | (A[15] & ~B[15] & ~results[15]);
            else
                next_flags[0] = (~A[15] & ~B[15] & results[15]) | (A[15] & B[15] & ~results[15]);
        end else begin
            next_flags[2] = FlagsOut[2];
            next_flags[0] = FlagsOut[0];
        end
    end

    always @(*) begin
        ALUOut = results[15:0];
    end

    always @(posedge Clock) begin
        if (WF)
            FlagsOut <= next_flags;
    end
endmodule