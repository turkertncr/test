`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2026 13:24:11
// Design Name: 
// Module Name: InstructionMemory
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


module InstructionMemory(
    input CS,
    input [7:0] Address,
    output reg [7:0] MemOut
);
    reg [7:0] ROM_DATA [0:255];
    
    initial begin
        $readmemh("ROM.mem", ROM_DATA);
    end    
    
    always @(*) begin
        if (CS) 
            MemOut = ROM_DATA[Address];
        else 
            MemOut = 8'h00; 
    end
endmodule