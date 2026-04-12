`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2026 13:03:41
// Design Name: 
// Module Name: InstructionMemoryUnit
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

module InstructionMemoryUnit(
    input [15:0] Address,
    input CS,
    input LH,
    input Clock,
    output reg [15:0] IMUOut,
    output reg [15:0] IROut
);

    wire [7:0] rom_data_wire;
    wire [15:0] ir_out_wire;

    InstructionMemory IM(
        .CS(CS),
        .Address(Address[7:0]), 
        .MemOut(rom_data_wire) 
    );

    InstructionRegister IR(
        .I(rom_data_wire),      
        .Write(CS),             
        .LH(LH),                
        .Clock(Clock),
        .IROut(ir_out_wire)     
    );

    always @(*) begin   
        IROut = ir_out_wire; 
        IMUOut = {8'h00, ir_out_wire[7:0]}; 
    end
    
endmodule

