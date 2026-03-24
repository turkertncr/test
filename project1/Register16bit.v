`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2026 06:47:23 PM
// Design Name: 
// Module Name: register_16
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


module Register16bit(
    input   wire    Clock,
    input   wire    [1:0]   FunSel,
    input   wire    [15:0]  I,
    input   wire    E,
    output  reg     [15:0]  Q
);
    always @(posedge Clock) begin
        if (E == 1'b1) begin
            case (FunSel)
                2'b00:  Q <= 16'b0;    
                2'b01:  Q <= I;        
                2'b10:  Q <= Q + 1'b1; 
                2'b11:  Q <= Q - 1'b1; 
                default: Q <= Q;
            endcase
        end
    end
endmodule