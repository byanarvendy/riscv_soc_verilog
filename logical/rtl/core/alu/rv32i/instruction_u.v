module instruction_u (
    input           iCLK,
    input   [31:0]  iIR,
    input   [7:0]   iPC,

    output  [4:0]   oRD,
    output  [31:0]  oREG_IN
);

    wire    [6:0]   opcode;
    wire    [19:0]  imm;
    wire    [31:0]  alu_out;

    assign opcode   = iIR[6:0];
    assign oRD      = iIR[11:7];
    assign imm      = iIR[31:12];

    assign alu_out  = (opcode == 7'b0110111) ? imm << 12            :       /* load upper immediate */
                      (opcode == 7'b0010111) ? iPC + (imm << 12)    :       /* add upper immediate */
                      32'h0;

    assign oREG_IN  = alu_out;
    
endmodule