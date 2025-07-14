module instruction_b (
    input           iCLK,
    input   [31:0]  iIR,
    input   [7:0]   iPC,

    input   [31:0]  iREG_OUT1,
    input   [31:0]  iREG_OUT2,

    output  [4:0]   oRS1,
    output  [4:0]   oRS2,
    output  [31:0]  oPCBR
);

	wire    [2:0]   func3;
	wire    [31:0]  alu_in1, alu_in2, imm, alu_out;

	assign func3    = iIR[14:12];
	assign oRS1     = iIR[19:15];
	assign oRS2     = iIR[24:20];

	assign imm      = {{20{iIR[31]}}, iIR[7], iIR[30:25], iIR[11:8], 1'b0};
	
	assign alu_in1  = iREG_OUT1;
	assign alu_in2  = iREG_OUT2;

    assign alu_out  = (func3 == 3'h0) ? (alu_in1          == alu_in2            ? iPC + imm : iPC + 4) :        /* beq */
                      (func3 == 3'h1) ? (alu_in1          != alu_in2            ? iPC + imm : iPC + 4) :        /* bne */
                      (func3 == 3'h4) ? ($signed(alu_in1) <  $signed(alu_in2)   ? iPC + imm : iPC + 4) :        /* blt */
                      (func3 == 3'h5) ? ($signed(alu_in1) >= $signed(alu_in2)   ? iPC + imm : iPC + 4) :        /* bge */
                      (func3 == 3'h6) ? (alu_in1          <  alu_in2            ? iPC + imm : iPC + 4) :        /* bltu */
                      (func3 == 3'h7) ? (alu_in1          >= alu_in2            ? iPC + imm : iPC + 4) :        /* bgeu */
                      32'h0;

	assign oPCBR    = alu_out;
    
endmodule