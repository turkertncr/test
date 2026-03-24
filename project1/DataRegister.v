`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 13:22:00
// Design Name: 
// Module Name: DataRegister
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

module DataRegister(
    input [7:0] I,
    input E,
    input FunSel,
    input Clock,
    output reg [15:0] DROut
);
    
    initial begin
        DROut = 16'h0000;
    end

    always @(posedge Clock) begin
        if (E) begin
            if (!FunSel) begin
                DROut[7:0] <= I;
            end
            else begin
                DROut[15:8] <= I;
            end
        end    
    end    
endmodule