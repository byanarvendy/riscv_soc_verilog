module alu (
    input           iCLK, iRST, RAM_DONE,
    input   [6:0]   OPCODE,
    input   [7:0]   PC,
    input   [31:0]  IR, ALU_IN1, ALU_IN2,
    output  [31:0]  ALU_OUT, BR_B, BR_J, BR_I,

    /* register */
    output  [4:0]   RD, RS1, RS2,

    /* ram */
    input   [31:0]  iRAM_DATA,
    output          oRAM_CE, oRAM_RD, oRAM_WR,
    output  [3:0]   oRAM_WSTRB,
    output  [31:0]  oRAM_ADDR,
    output  [31:0]  oRAM_DATA
);

    wire    [4:0]   RD, RS1, RS2;                           /* register file */
    wire    [31:0]  ALU_IN1, ALU_IN2, ALU_OUT;
    wire    [4:0]   RD_R, RS1_R, RS2_R;                     /* instruction r */
    wire    [31:0]  ALU_IN1_R, ALU_IN2_R, ALU_OUT_R;
    wire    [4:0]   RD_I, RS1_I, RS2_I;                     /* instruction i */
    wire    [31:0]  ALU_IN1_I, ALU_IN2_I, ALU_OUT_I;
    wire            RAM_CE_I, RAM_RD_I;                     
    wire    [31:0]  RAM_ADDR_I;
    wire    [4:0]   RD_S, RS1_S, RS2_S;                     /* instruction s */
    wire    [31:0]  ALU_IN1_S, ALU_IN2_S, ALU_OUT_S;
    wire            RAM_CE_S, RAM_RD_S;                     
    wire    [31:0]  RAM_ADDR_S;
    wire    [4:0]   RS1_B, RS2_B;                           /* instruction b */
    wire    [31:0]  ALU_IN1_B, ALU_IN2_B;
    wire    [4:0]   RD_U, RD_J;                             /* instruction u & j*/
    wire    [31:0]  ALU_OUT_U, ALU_OUT_J;

    instruction_mux mux (
        .OPCODE(OPCODE),

        .iRD_R(RD_R), .iRD_I(RD_I), .iRD_S(RD_S),
        .iRD_U(RD_U), .iRD_J(RD_J),

        .iRS1_R(RS1_R), .iRS1_I(RS1_I), .iRS1_S(RS1_S),
        .iRS1_B(RS1_B),

        .iRS2_R(RS2_R), .iRS2_I(RS2_I), .iRS2_S(RS2_S),
        .iRS2_B(RS2_B),

        .oALU_IN1_R(ALU_IN1_R), .oALU_IN1_I(ALU_IN1_I), .oALU_IN1_S(ALU_IN1_S),
        .oALU_IN1_B(ALU_IN1_B),
        
        .oALU_IN2_R(ALU_IN2_R), .oALU_IN2_I(ALU_IN2_I), .oALU_IN2_S(ALU_IN2_S), 
        .oALU_IN2_B(ALU_IN2_B),

        .iALU_OUT_R(ALU_OUT_R), .iALU_OUT_I(ALU_OUT_I), .iALU_OUT_S(ALU_OUT_S), 
        .iALU_OUT_U(ALU_OUT_U), .iALU_OUT_J(ALU_OUT_J),

        .oRD(RD), .oRS1(RS1), .oRS2(RS2),
        .iALU_IN1(ALU_IN1), .iALU_IN2(ALU_IN2),

        .oALU_OUT(ALU_OUT)
    );

    instruction_r r (
        .iCLK(iCLK), .iIR(IR),

        .iALU_IN1(ALU_IN1_R), .iALU_IN2(ALU_IN2_R),
        .oRD(RD_R), .oRS1(RS1_R), .oRS2(RS2_R),
        .oALU_OUT(ALU_OUT_R)
    );

    instruction_i i (
        .iCLK(iCLK), .iIR(IR), .RAM_DONE(RAM_DONE),

        .oRAM_CE(RAM_CE_I), .oRAM_RD(RAM_RD_I),
        .oRAM_ADDR(RAM_ADDR_I), .iRAM_DATA(iRAM_DATA),

        .iREG_OUT1(ALU_IN1_I), .iREG_OUT2(ALU_IN2_I),
        .oRD(RD_I), .oRS1(RS1_I), .oRS2(RS2_I),

        .oREG_IN(ALU_OUT_I),

        .iPC(PC), .oPC(BR_I)
    );

    instruction_s s (
        .iCLK(iCLK), .iIR(IR),

        .iREG_OUT1(ALU_IN1_S), .iREG_OUT2(ALU_IN2_S),
        .oRD(RD_S), .oRS1(RS1_S), .oRS2(RS2_S),
        .oREG_IN(ALU_OUT_S),

        .oRAM_CE(RAM_CE_S), .oRAM_WR(RAM_WR_S), 
        .oRAM_ADDR(RAM_ADDR_S), 

        .oRAM_WSTRB(oRAM_WSTRB), .oRAM_DATA(oRAM_DATA)
    );

    instruction_b b (
        .iCLK(iCLK), .iIR(IR), .iPC(PC),

        .iREG_OUT1(ALU_IN1_B), .iREG_OUT2(ALU_IN2_B),
        .oRS1(RS1_B), .oRS2(RS2_B),
        .oPCBR(BR_B)
    );

    instruction_u u (
        .iCLK(iCLK), .iIR(IR),
        .iPC(PC),
    
        .oRD(RD_U), .oREG_IN(ALU_OUT_U)
    );

    instruction_j j (
        .iCLK(iCLK), .iIR(IR),
        .iPC(PC),
    
        .oRD(RD_J), .oREG_IN(ALU_OUT_J),
        .oPCBR(BR_J)
    );

	assign oRAM_CE 			= (OPCODE == 7'b0000011) ? RAM_CE_I       :
					          (OPCODE == 7'b0100011) ? RAM_CE_S       :
					   		  1'b0;     
	assign oRAM_RD 			= (OPCODE == 7'b0000011) ? RAM_RD_I       : 1'b0;     					        
	assign oRAM_WR 			= (OPCODE == 7'b0100011) ? RAM_WR_S       : 1'b0;   
   
	assign oRAM_ADDR 		= (OPCODE == 7'b0000011) ? RAM_ADDR_I     :
					          (OPCODE == 7'b0100011) ? RAM_ADDR_S     :
							  32'h0;

endmodule
