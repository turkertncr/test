`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2026 18:01:53
// Design Name: 
// Module Name: ArithmeticLogicUnitSystem
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

module ArithmeticLogicUnitSystem(
    input Clock,

    input [1:0] MuxASel, 
    input [1:0] MuxBSel,
    input MuxCSel,

    input [2:0] RF_OutASel,  
    input [2:0] RF_OutBSel,  
    input [1:0] RF_FunSel,   
    input [3:0] RF_RegSel,   
    input [3:0] RF_ScrSel,   

    input [3:0] ALU_FunSel,   
    input ALU_WF,    

    input [1:0] ARF_OutCSel,  
    input ARF_OutDSel,  
    input [1:0] ARF_FunSel,   
    input [2:0] ARF_RegSel,   

    input IMU_CS, IMU_LH, DMU_WR, DMU_CS, DMU_FunSel          
);

    wire [15:0] ARF_OutC;
    wire [15:0] ARF_OutD;
    wire [15:0] ARF_OutE;
    
    reg [15:0] MuxA_Out;
    reg [15:0] MuxB_Out;
    reg [7:0] MuxC_Out;
    
    wire [15:0] DMU_Out;
    
    wire [15:0] IR_Out;
    wire [15:0] IMU_Out;
    
    wire [15:0] RF_OutA;
    wire [15:0] RF_OutB;
    
    wire [15:0] ALU_Out;
    wire [3:0] ALU_FlagsOut;
    
    AddressRegisterFile ARF(
        .Clock(Clock), 
        .FunSel(ARF_FunSel),
        .RegSel(ARF_RegSel),
        .I(MuxB_Out),
        .OutCSel(ARF_OutCSel),
        .OutDSel(ARF_OutDSel),
        .OutC(ARF_OutC),
        .OutD(ARF_OutD),
        .OutE(ARF_OutE)
    );
    
    DataMemoryUnit DMU(
        .Address(ARF_OutD),
        .WR(DMU_WR),
        .CS(DMU_CS),
        .FunSel(DMU_FunSel),
        .Clock(Clock),
        .I(MuxC_Out),
        .DMUOut(DMU_Out)
    );
    
    InstructionMemoryUnit IMU(
        .Address(ARF_OutE),
        .CS(IMU_CS),
        .LH(IMU_LH),
        .IMUOut(IMU_Out),
        .IROut(IR_Out),
        .Clock(Clock)
    );
    
    RegisterFile RF(
        .Clock(Clock),
        .FunSel(RF_FunSel),
        .RegSel(RF_RegSel),
        .ScrSel(RF_ScrSel),
        .OutASel(RF_OutASel),
        .OutBSel(RF_OutBSel),
        .I(MuxA_Out),
        .OutA(RF_OutA),
        .OutB(RF_OutB)
    );
    
    ArithmeticLogicUnit ALU(
        .Clock(Clock),
        .A(RF_OutA),
        .B(RF_OutB),
        .FunSel(ALU_FunSel),
        .WF(ALU_WF),
        .ALUOut(ALU_Out),
        .FlagsOut(ALU_FlagsOut)
    );
    
    always @(*) begin
        case(MuxASel)
            2'b00: MuxA_Out = ALU_Out;
            2'b01: MuxA_Out = ARF_OutC;
            2'b10: MuxA_Out = DMU_Out;
            2'b11: MuxA_Out = IMU_Out;
            default: MuxA_Out = 16'b0;
        endcase 
    end
    
    always @(*) begin
        case(MuxBSel)
            2'b00: MuxB_Out = ALU_Out;
            2'b01: MuxB_Out = ARF_OutC;
            2'b10: MuxB_Out = DMU_Out;
            2'b11: MuxB_Out = IMU_Out;
            default: MuxB_Out = 16'b0;
        endcase 
    end
        
    always @(*) begin
        case(MuxCSel)
            1'b0: MuxC_Out = ALU_Out[7:0];
            1'b1: MuxC_Out = ALU_Out[15:8];
            default: MuxC_Out = 8'b0;
        endcase 
    end
    
    // Testbench Output Wire Assignments
    wire [15:0] OutA = RF_OutA;
    wire [15:0] OutB = RF_OutB;
    wire [15:0] OutC = ARF_OutC;
    wire [15:0] OutD = ARF_OutD;
    wire [15:0] OutE = ARF_OutE;
    wire [15:0] MuxAOut = MuxA_Out;
    wire [15:0] MuxBOut = MuxB_Out;
    wire [7:0]  MuxCOut = MuxC_Out;
    wire [15:0] IROut = IR_Out;
    wire [15:0] ALUOut = ALU_Out;

endmodule