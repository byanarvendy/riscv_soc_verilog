module instruction_mux(
    input   [6:0]   OPCODE,

    input   [4:0]   iRD_R, iRD_I, iRD_S, iRD_U, iRD_J,
    input   [4:0]   iRS1_R, iRS1_I, iRS1_S, iRS1_B,
    input   [4:0]   iRS2_R, iRS2_I, iRS2_S, iRS2_B,

    output  [31:0]  oALU_IN1_R, oALU_IN1_I, oALU_IN1_S, oALU_IN1_B, 
    output  [31:0]  oALU_IN2_R, oALU_IN2_I, oALU_IN2_S, oALU_IN2_B,

    input   [31:0]  iALU_OUT_R, iALU_OUT_I, iALU_OUT_S, iALU_OUT_U, iALU_OUT_J,

    output  [4:0]   oRD, oRS1, oRS2,
    input   [31:0]  iALU_IN1, iALU_IN2,
    output  [31:0]  oALU_OUT
);

    assign oRD          =  (OPCODE == 7'b0110011) ? iRD_R  :
                           (OPCODE == 7'b0010011) | (OPCODE == 7'b0000011) | (OPCODE == 7'b1100111) ? iRD_I :
                           (OPCODE == 7'b0100011) ? iRD_S  :
                           (OPCODE == 7'b0110111) | (OPCODE == 7'b0010111) ? iRD_U  :
                           (OPCODE == 7'b1101111) ? iRD_J  :
                           5'h0;

    assign oRS1         = (OPCODE == 7'b0110011) ? iRS1_R  :
                          (OPCODE == 7'b0010011) | (OPCODE == 7'b0000011) | (OPCODE == 7'b1100111) ? iRS1_I :
                          (OPCODE == 7'b0100011) ? iRS1_S  :
                          (OPCODE == 7'b1100011) ? iRS1_B  :
                          5'h0;

    assign oRS2         = (OPCODE == 7'b0110011) ? iRS2_R  :
                          (OPCODE == 7'b0010011) | (OPCODE == 7'b0000011) | (OPCODE == 7'b1100111) ? iRS2_I :
                          (OPCODE == 7'b0100011) ? iRS2_S  :
                          (OPCODE == 7'b1100011) ? iRS2_B  :
                          5'h0;

    assign oALU_OUT     = (OPCODE == 7'b0110011) ? iALU_OUT_R  :
                          (OPCODE == 7'b0010011) | (OPCODE == 7'b0000011) | (OPCODE == 7'b1100111) ? iALU_OUT_I :
                          (OPCODE == 7'b0100011) ? iALU_OUT_S  :
                          (OPCODE == 7'b0110111) | (OPCODE == 7'b0010111) ? iALU_OUT_U  :
                          (OPCODE == 7'b1101111) ? iALU_OUT_J  :
                          5'h0;

    assign oALU_IN1_R   = (OPCODE == 7'b0110011) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_I   = (OPCODE == 7'b0010011) | (OPCODE == 7'b0000011) | (OPCODE == 7'b1100111) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_S   = (OPCODE == 7'b0100011) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_B   = (OPCODE == 7'b1100011) ? iALU_IN1 : 32'h0;

    assign oALU_IN2_R   = (OPCODE == 7'b0110011) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_I   = (OPCODE == 7'b0010011) | (OPCODE == 7'b0000011) | (OPCODE == 7'b1100111) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_S   = (OPCODE == 7'b0100011) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_B   = (OPCODE == 7'b1100011) ? iALU_IN2 : 32'h0;

endmodule