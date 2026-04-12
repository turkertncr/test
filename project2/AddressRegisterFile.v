`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2026 09:06:54 PM
// Design Name: 
// Module Name: address_register_file
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


module AddressRegisterFile(
    input   wire    Clock,
    input   wire    [1:0]   FunSel,
    input   wire    [2:0]   RegSel,
    input   wire    [1:0]   OutCSel,
    input   wire    OutDSel,
    input   wire    [15:0]  I,
    output  reg     [15:0]  OutC,
    output  reg     [15:0]  OutD,
    output  reg     [15:0]  OutE
);

    wire    [15:0]  WPC, WSP, WAR;
    
    Register16bit AR(.Clock(Clock), .FunSel(FunSel), .I(I), .E(~RegSel[0]), .Q(WAR));
    Register16bit SP(.Clock(Clock), .FunSel(FunSel), .I(I), .E(~RegSel[1]), .Q(WSP));
    Register16bit PC(.Clock(Clock), .FunSel(FunSel), .I(I), .E(~RegSel[2]), .Q(WPC));
    
    always @(*) begin
        case (OutCSel)
            2'b00:  OutC = WPC;
            2'b01:  OutC = WPC;
            2'b10:  OutC = WAR;
            2'b11:  OutC = WSP;
        endcase
        if (OutDSel == 0) begin
            OutD = WAR;
        end else begin
            OutD = WSP;
        end
        OutE = WPC;
    end
    
endmodule
