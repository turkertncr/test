`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2026 12:02:12
// Design Name: 
// Module Name: InstructionRegister
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


module InstructionRegister(
    input [7:0] I,
    input Write,
    input LH,
    input Clock,
    output reg [15:0] IROut
    );
    
    always @(posedge Clock) begin
        if (Write) begin
            if (!LH) begin
                IROut[7:0] <= I;
            end
            else begin
                IROut[15:8] <= I;
            end
        end
    end
endmodule
