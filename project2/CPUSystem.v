`timescale 1ns / 1ps

module CPUSystem(
    input Clock,
    input Reset,
    output reg [11:0] T, // 12-bit Ring Counter for states
    
    // Simulation Outputs
    output [5:0] Opcode,
    output [1:0] RegSel,
    output [7:0] Address,
    output [2:0] DestReg,
    output [2:0] SrcReg1,
    output [2:0] SrcReg2
);

    // ==========================================
    // 1. TIMING COUNTER (Ring Counter)
    // ==========================================
    reg T_Reset;

    always @(posedge Clock or negedge Reset) begin
        if (!Reset) begin
            T <= 12'b0000_0000_0001; // Start at T0
        end else if (T_Reset) begin
            T <= 12'b0000_0000_0001; // Go back to T0
        end else begin
            T <= {T[10:0], T[11]}; 
        end
    end

    // ==========================================
    // 2. INSTRUCTION DECODING
    // ==========================================
    wire [15:0] IR = ALUSys.IROut;
    
    assign Opcode = IR[15:10];
    assign RegSel = IR[9:8];
    assign Address = IR[7:0];
    assign DestReg = IR[9:7];
    assign SrcReg1 = IR[6:4];
    assign SrcReg2 = IR[3:1];

    wire [3:0] Flags = ALUSys.ALU.FlagsOut;
    wire Z = Flags[3]; // Zero Flag
    wire N = Flags[1]; // Negative Flag
    wire C = Flags[2]; // Carry Flag
    wire V = Flags[0]; // Overflow Flag

    reg [2:0] Active_SrcReg1;
    reg [3:0] Decoded_RF_RegSel_Dest, Decoded_RF_RegSel_Imm;
    reg [2:0] Decoded_ARF_RegSel_Dest;
    reg [2:0] RF_OutASel, RF_OutBSel;
    reg [1:0] ARF_OutCSel;
    reg ARF_OutDSel;

    always @(*) begin
        // In T4 for INC/DEC, we must read the DestReg to update ALU flags
        if (T == 12'b0000_0001_0000 && (Opcode == 6'h07 || Opcode == 6'h08)) begin
            Active_SrcReg1 = DestReg;
        end else begin
            Active_SrcReg1 = SrcReg1;
        end

        // --- Register Mapping (RF) ---
        case (DestReg)
            3'b100: Decoded_RF_RegSel_Dest = 4'b0111; // R1
            3'b101: Decoded_RF_RegSel_Dest = 4'b1011; // R2
            3'b110: Decoded_RF_RegSel_Dest = 4'b1101; // R3
            3'b111: Decoded_RF_RegSel_Dest = 4'b1110; // R4
            default: Decoded_RF_RegSel_Dest = 4'b1111; // None
        endcase

        case ({1'b1, RegSel})
            3'b100: Decoded_RF_RegSel_Imm = 4'b0111; // R1
            3'b101: Decoded_RF_RegSel_Imm = 4'b1011; // R2
            3'b110: Decoded_RF_RegSel_Imm = 4'b1101; // R3
            3'b111: Decoded_RF_RegSel_Imm = 4'b1110; // R4
            default: Decoded_RF_RegSel_Imm = 4'b1111; // None
        endcase

        // --- Register Mapping (ARF - WRITE) ---
        // Based precisely on your AddressRegisterFile module
        case (DestReg)
            3'b000, 3'b001: Decoded_ARF_RegSel_Dest = 3'b011; // PC (enabled by ~RegSel[2])
            3'b011: Decoded_ARF_RegSel_Dest = 3'b101;         // SP (enabled by ~RegSel[1])
            3'b010: Decoded_ARF_RegSel_Dest = 3'b110;         // AR (enabled by ~RegSel[0])
            default: Decoded_ARF_RegSel_Dest = 3'b111;        // None
        endcase

        // --- Output Selections (RF) ---
        case (Active_SrcReg1)
            3'b100: RF_OutASel = 3'b000;
            3'b101: RF_OutASel = 3'b001;
            3'b110: RF_OutASel = 3'b010;
            3'b111: RF_OutASel = 3'b011;
            default: RF_OutASel = 3'b000;
        endcase

        case (SrcReg2)
            3'b100: RF_OutBSel = 3'b000;
            3'b101: RF_OutBSel = 3'b001;
            3'b110: RF_OutBSel = 3'b010;
            3'b111: RF_OutBSel = 3'b011;
            default: RF_OutBSel = 3'b000;
        endcase

        // --- Output Selections (ARF - READ) ---
        // Based precisely on your AddressRegisterFile module
        case (Active_SrcReg1)
            3'b000, 3'b001: ARF_OutCSel = 2'b00; // PC is Mux Line 00
            3'b010: ARF_OutCSel = 2'b11;         // SP is Mux Line 11
            3'b011: ARF_OutCSel = 2'b10;         // AR is Mux Line 10
            default: ARF_OutCSel = 2'b00;
        endcase

        if (SrcReg2 == 3'b010) ARF_OutDSel = 1'b1; // SP is 1
        else                   ARF_OutDSel = 1'b0; // AR is 0
    end

    // ==========================================
    // 4. BRANCH DECISION LOGIC 
    // ==========================================
    reg Branch_Taken;
    always @(*) begin
        Branch_Taken = 1'b0; 
        if (Opcode == 6'h00) begin
            Branch_Taken = 1'b1; // BRA 
        end else if (Opcode == 6'h01 && Z == 0) begin
            Branch_Taken = 1'b1; // BNE
        end else if (Opcode == 6'h02 && Z == 1) begin
            Branch_Taken = 1'b1; // BEQ
        end else if (Opcode == 6'h03 && (N != V)) begin
            Branch_Taken = 1'b1; // BLT 
        end else if (Opcode == 6'h04 && (Z == 0 && N == V)) begin
            Branch_Taken = 1'b1; // BGT 
        end else if (Opcode == 6'h05 && (Z == 1 || N != V)) begin
            Branch_Taken = 1'b1; // BLE 
        end else if (Opcode == 6'h06 && (N == V)) begin
            Branch_Taken = 1'b1; // BGE 
        end
    end

    // ==========================================
    // 5. MAIN CONTROL SYSTEM
    // ==========================================
    reg [1:0] MuxASel, MuxBSel;
    reg MuxCSel;
    reg [1:0] RF_FunSel;
    reg [3:0] RF_RegSel, RF_ScrSel;
    reg [3:0] ALU_FunSel;
    reg ALU_WF;
    reg [1:0] ARF_FunSel;
    reg [2:0] ARF_RegSel;
    reg IMU_CS, IMU_LH, DMU_WR, DMU_CS, DMU_FunSel;

    always @(*) begin
        // --- 5A. COMBINATIONAL DATA PATH ROUTING ---
        if (Opcode == 6'h17 || (Opcode >= 6'h00 && Opcode <= 6'h06)) begin
            MuxASel = 2'b11; 
            MuxBSel = 2'b11; 
        end else begin
            if (Active_SrcReg1[2] == 1'b1) MuxASel = 2'b00; // RF Output A
            else                           MuxASel = 2'b01; // ARF Output C
            
            if (SrcReg2[2] == 1'b1) MuxBSel = 2'b00; // RF Output B
            else                    MuxBSel = 2'b01; // ARF Output D
        end
        MuxCSel = 1'b0;

        ALU_FunSel = 4'b0000; // Standard Pass A for INC, DEC, Branches, IMM, MOV
        if (Opcode >= 6'h09 && Opcode <= 6'h0E) begin
            case (Opcode)
                6'h09: ALU_FunSel = 4'b1011; // LSL
                6'h0A: ALU_FunSel = 4'b1100; // LSR
                6'h0B: ALU_FunSel = 4'b1101; // ASR
                6'h0C: ALU_FunSel = 4'b1110; // CSL
                6'h0D: ALU_FunSel = 4'b1111; // CSR
                6'h0E: ALU_FunSel = 4'b0010; // [FIXED] NOT mapped to ~A (0010)
            endcase
        end else if (Opcode >= 6'h0F && Opcode <= 6'h15) begin
            case (Opcode)
                6'h0F: ALU_FunSel = 4'b0111; // AND
                6'h10: ALU_FunSel = 4'b1000; // ORR
                6'h11: ALU_FunSel = 4'b1001; // XOR
                6'h12: ALU_FunSel = 4'b1010; // NAND
                6'h13: ALU_FunSel = 4'b0100; // ADD
                6'h14: ALU_FunSel = 4'b0101; // ADC
                6'h15: ALU_FunSel = 4'b0110; // SUB
            endcase
        end

        // --- 5B. SYNCHRONOUS WRITE / STATE-DRIVEN CONTROL ---
        ALU_WF = 1'b0;
        RF_FunSel = 2'b00;
        RF_RegSel = 4'b1111;
        RF_ScrSel = 4'b1111;
        ARF_FunSel = 2'b00;
        ARF_RegSel = 3'b111;
        IMU_CS = 1'b0;
        IMU_LH = 1'b0;
        DMU_WR = 1'b0;
        DMU_CS = 1'b0;
        DMU_FunSel = 1'b0;
        T_Reset = 1'b0;

        if (!Reset) begin
            RF_FunSel = 2'b00; 
            RF_RegSel = 4'b0000; 
            RF_ScrSel = 4'b0000;
            ARF_FunSel = 2'b00; 
            ARF_RegSel = 3'b000; 
            T_Reset = 1'b1;
        end else begin
            case (T)
                12'b0000_0000_0001: begin // T0: Fetch LSB
                    IMU_CS = 1'b1; 
                    IMU_LH = 1'b0;
                    ARF_RegSel = 3'b011; // PC 
                    ARF_FunSel = 2'b10;  // PC++
                end
                
                12'b0000_0000_0010: begin // T1: Fetch MSB
                    IMU_CS = 1'b1; 
                    IMU_LH = 1'b1;
                    ARF_RegSel = 3'b011; // PC
                    ARF_FunSel = 2'b10;  // PC++
                end
                
                12'b0000_0000_0100: begin // T2: Execute Instructions
                    // --- BRANCH INSTRUCTIONS (00 to 06) ---
                    if (Opcode >= 6'h00 && Opcode <= 6'h06) begin
                        if (Branch_Taken == 1'b1) begin
                            ARF_RegSel = 3'b011; // Select PC to overwrite
                            ARF_FunSel = 2'b01;  // Load Branch Addr from ALU Out
                        end
                        T_Reset = 1'b1;
                    end
                    
                    // --- INC, DEC (07, 08) ---
                    else if (Opcode == 6'h07 || Opcode == 6'h08) begin
                        // Move SrcReg1 -> DestReg via ALU Pass A
                        if (DestReg[2] == 1'b1) begin
                            RF_RegSel = Decoded_RF_RegSel_Dest;
                            RF_FunSel = 2'b01; 
                        end else begin
                            ARF_RegSel = Decoded_ARF_RegSel_Dest;
                            ARF_FunSel = 2'b01; 
                        end
                        T_Reset = 1'b0; // PROCEED TO T3
                    end
                    
                    // --- LOGIC, ARITH, MOV (09 to 16) ---
                    else if (Opcode >= 6'h09 && Opcode <= 6'h16) begin
                        if (Opcode >= 6'h09 && Opcode <= 6'h15) begin
                            ALU_WF = 1'b1; // Update flags
                        end
                        
                        if (DestReg[2] == 1'b1) begin
                            RF_RegSel = Decoded_RF_RegSel_Dest;
                            RF_FunSel = 2'b01; 
                        end else begin
                            ARF_RegSel = Decoded_ARF_RegSel_Dest;
                            ARF_FunSel = 2'b01; 
                        end
                        T_Reset = 1'b1;
                    end
                    
                    // --- IMM INSTRUCTION (17) ---
                    else if (Opcode == 6'h17) begin
                        RF_RegSel = Decoded_RF_RegSel_Imm;
                        RF_FunSel = 2'b01; 
                        T_Reset = 1'b1;
                    end
                    
                    else begin
                        T_Reset = 1'b1;
                    end
                end

                12'b0000_0000_1000: begin // T3: Multi-Cycle Internal INC/DEC
                    if (Opcode == 6'h07 || Opcode == 6'h08) begin
                        if (DestReg[2] == 1'b1) begin
                            RF_RegSel = Decoded_RF_RegSel_Dest;
                            if (Opcode == 6'h07) RF_FunSel = 2'b10; // INC
                            else                 RF_FunSel = 2'b11; // DEC
                        end else begin
                            ARF_RegSel = Decoded_ARF_RegSel_Dest;
                            if (Opcode == 6'h07) ARF_FunSel = 2'b10; // INC
                            else                 ARF_FunSel = 2'b11; // DEC
                        end
                        T_Reset = 1'b0; // PROCEED TO T4
                    end else begin
                        T_Reset = 1'b1;
                    end
                end
                
                12'b0000_0001_0000: begin // T4: Multi-Cycle Flag Update
                    if (Opcode == 6'h07 || Opcode == 6'h08) begin
                        // ALU_FunSel defaults to 0000 (Pass A). Active_SrcReg1 is pointing to DestReg.
                        ALU_WF = 1'b1; // Triggers flag calculation on the newly decremented result
                        T_Reset = 1'b1; // DONE
                    end else begin
                        T_Reset = 1'b1;
                    end
                end
                
                default: begin
                    T_Reset = 1'b1; 
                end
            endcase
        end
    end

    // ==========================================
    // 6. MODULE INSTANTIATION
    // ==========================================
    ArithmeticLogicUnitSystem ALUSys(
        .Clock(Clock),
        .MuxASel(MuxASel),
        .MuxBSel(MuxBSel),
        .MuxCSel(MuxCSel),
        .RF_OutASel(RF_OutASel),
        .RF_OutBSel(RF_OutBSel),
        .RF_FunSel(RF_FunSel),
        .RF_RegSel(RF_RegSel),
        .RF_ScrSel(RF_ScrSel),
        .ALU_FunSel(ALU_FunSel),
        .ALU_WF(ALU_WF),
        .ARF_OutCSel(ARF_OutCSel),
        .ARF_OutDSel(ARF_OutDSel),
        .ARF_FunSel(ARF_FunSel),
        .ARF_RegSel(ARF_RegSel),
        .IMU_CS(IMU_CS),
        .IMU_LH(IMU_LH),
        .DMU_WR(DMU_WR),
        .DMU_CS(DMU_CS),
        .DMU_FunSel(DMU_FunSel)
    );

endmodule