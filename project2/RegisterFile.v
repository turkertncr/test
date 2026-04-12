`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2026 07:54:21 PM
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile(
    input   wire    Clock,
    input   wire    [1:0]   FunSel,
    input   wire    [3:0]   RegSel,
    input   wire    [3:0]   ScrSel,
    input   wire    [2:0]   OutASel,
    input   wire    [2:0]   OutBSel,
    input   wire    [15:0]  I,
    output  reg     [15:0]  OutA,
    output  reg     [15:0]  OutB
);
    wire [15:0] wR1, wR2, wR3, wR4, wS1, wS2, wS3, wS4;

    Register16bit R1(.Clock(Clock), .FunSel(FunSel), .I(I), .E(~RegSel[3]), .Q(wR1));
    Register16bit R2(.Clock(Clock), .FunSel(FunSel), .I(I), .E(~RegSel[2]), .Q(wR2));
    Register16bit R3(.Clock(Clock), .FunSel(FunSel), .I(I), .E(~RegSel[1]), .Q(wR3));
    Register16bit R4(.Clock(Clock), .FunSel(FunSel), .I(I), .E(~RegSel[0]), .Q(wR4));

    Register16bit S1(.Clock(Clock), .FunSel(FunSel), .I(I), .E(~ScrSel[3]), .Q(wS1));
    Register16bit S2(.Clock(Clock), .FunSel(FunSel), .I(I), .E(~ScrSel[2]), .Q(wS2));
    Register16bit S3(.Clock(Clock), .FunSel(FunSel), .I(I), .E(~ScrSel[1]), .Q(wS3));
    Register16bit S4(.Clock(Clock), .FunSel(FunSel), .I(I), .E(~ScrSel[0]), .Q(wS4));

    always @(*) begin
        case (OutASel)
            3'b000: OutA = wR1;
            3'b001: OutA = wR2;
            3'b010: OutA = wR3;
            3'b011: OutA = wR4;
            3'b100: OutA = wS1;
            3'b101: OutA = wS2;
            3'b110: OutA = wS3;
            3'b111: OutA = wS4;
            default: OutA = 16'h0;
        endcase
        case (OutBSel)
            3'b000: OutB = wR1;
            3'b001: OutB = wR2;
            3'b010: OutB = wR3;
            3'b011: OutB = wR4;
            3'b100: OutB = wS1;
            3'b101: OutB = wS2;
            3'b110: OutB = wS3;
            3'b111: OutB = wS4;
            default: OutB = 16'h0;
        endcase
    end
endmodule