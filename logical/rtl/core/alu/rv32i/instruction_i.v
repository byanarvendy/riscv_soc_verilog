module instruction_i (
    input           iCLK, RAM_DONE,
    input   [7:0]   iPC,
    input   [31:0]  iIR, iREG_OUT1, iREG_OUT2,

    input   [31:0]  iRAM_DATA,
    output          oRAM_CE, oRAM_RD,
    output  [31:0]  oRAM_ADDR,

    output  [4:0]   oRD, oRS1, oRS2,
    output  [31:0]  oREG_IN, oPC
);

    wire    [2:0]   func3;
    wire    [4:0]   shamt;
    wire    [6:0]   opcode;
    wire    [31:0]  alu_in1, alu_in2, alu_out;

    assign opcode       = iIR[6:0];
    assign oRD          = iIR[11:7];
    assign oRS1         = iIR[19:15];
    assign oRS2         = 5'h00;

    assign func3        = iIR[14:12];
    assign shamt        = iIR[24:20];

    assign alu_in1      = iREG_OUT1;
    assign alu_in2      = {{20{iIR[31]}}, iIR[31:20]};

    /* ram */
    assign oRAM_ADDR    = alu_in1 + alu_in2;

    assign alu_out  = (opcode == 7'b0010011) ?                                                      /* immediate operations */
                        ((func3 == 3'h0) ? alu_in1 + alu_in2                                    :       /* add immediate */
                         (func3 == 3'h4) ? alu_in1 ^ alu_in2                                    :       /* xor immediate */
                         (func3 == 3'h6) ? alu_in1 | alu_in2                                    :       /* or immediate */
                         (func3 == 3'h7) ? alu_in1 & alu_in2                                    :       /* and immediate */
                         (func3 == 3'h1) ? alu_in1 << shamt                                     :       /* shift left logical immediate */
                         (func3 == 3'h5 && alu_in2[11:5] == 7'h00) ? alu_in1 >> shamt           :       /* shift right logical */
                         (func3 == 3'h5 && alu_in2[11:5] == 7'h20) ? alu_in1 >>> shamt          :       /* shift right arithmetic */
                         (func3 == 3'h2) ? ($signed(alu_in1) < $signed(shamt) ? 1 : 0)          :       /* set less than, signed */
                         (func3 == 3'h3) ? (alu_in1 < shamt ? 1 : 0)                            :       /* set less than, unsigned */
                         32'h00000000) :

                     (RAM_DONE) ?                                                                   /* load operations */
                        ((func3 == 3'h0) ? {{24{iRAM_DATA[7]}}, iRAM_DATA[7:0]}                 :       /* load byte */
                         (func3 == 3'h1) ? {{16{iRAM_DATA[15]}}, iRAM_DATA[15:0]}               :       /* load half */
                         (func3 == 3'h2) ? iRAM_DATA                                            :       /* load word */
                         (func3 == 3'h4) ? {{24{1'b0}}, iRAM_DATA[7:0]}                         :       /* load byte (unsigned) */
                         (func3 == 3'h5) ? {{16{1'b0}}, iRAM_DATA[15:0]}                        :       /* load half (unsigned) */
                         32'h00000000) :

                     (opcode == 7'b1100111) ?                                                       /* jump and link register */
                        ((func3 == 3'h0) ? ((alu_in1 + alu_in2) & 32'hFFFFFFFE) : 32'h00000000)           :
                         32'h00000000;

    assign oREG_IN  = (opcode == 7'b1100111 && func3 == 3'h0) ? iPC + 4 : alu_out;
    assign oPC      = (opcode == 7'b1100111 && func3 == 3'h0) ? alu_out : 32'h00000000;

    assign oRAM_CE  = (opcode == 7'b0000011) ? 1'b1 : 1'b0;
    assign oRAM_RD  = (opcode == 7'b0000011) ? 1'b1 : 1'b0;

endmodule
