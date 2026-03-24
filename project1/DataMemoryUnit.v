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
    input [7:0] I,
    input [15:0] Address,
    input WR,
    input CS,
    input FunSel,
    input Clock,
    output [15:0] DMUOut
);

    wire [7:0] ram_data_out;
    wire [15:0] reg_data_out;

    DataMemory DM(
        .Clock(Clock),
        .Address(Address),
        .CS(~CS),                
        .WR(WR),
        .Data(reg_data_out[7:0]),
        .MemOut(ram_data_out)  
    );

    DataRegister DR (
        .Clock(Clock),
        .I(ram_data_out),        
        .E(1'b1),               
        .FunSel(FunSel),
        .DROut(reg_data_out)
    );

    assign DMUOut = reg_data_out; 

endmodule 