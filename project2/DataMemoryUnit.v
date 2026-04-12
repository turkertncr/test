`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 13:19:41
// Design Name: 
// Module Name: DataMemoryUnit
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


module DataMemoryUnit(
    input  [7:0]  I,
    input  [15:0] Address,
    input         WR,
    input         CS,
    input         FunSel,
    input         Clock,
    output [15:0] DMUOut
);

    wire [7:0]  RAMOut;
    wire [15:0] REGOut;

    DataMemory DM (
        .Clock  (Clock),
        .Address(Address),
        .CS     (~CS),
        .WR     (WR),
        .Data   (I),              
        .MemOut (RAMOut)
    );

    DataRegister DR (
        .Clock  (Clock),
        .I      (RAMOut),
        .E      (CS & ~WR),      
        .FunSel (FunSel),
        .DROut  (REGOut)
    );

    assign DMUOut = REGOut;

endmodule