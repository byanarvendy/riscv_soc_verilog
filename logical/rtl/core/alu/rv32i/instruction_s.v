module instruction_s (
    input           iCLK,
    input   [31:0]  iIR, iREG_OUT1, iREG_OUT2,
    output  [4:0]   oRD, oRS1, oRS2,
    output  [31:0]  oREG_IN,

    output          oRAM_CE, oRAM_WR,
    output  [3:0]   oRAM_WSTRB,
    output  [31:0]  oRAM_ADDR, oRAM_DATA
);

    wire    [2:0]   func3;
    wire    [3:0]   byte_sel;
    wire    [31:0]  alu_in1, alu_in2, imm, alu_out;

    assign oRD              = 5'h00;
    assign oRS1             = iIR[19:15];            
    assign oRS2             = iIR[24:20];
    
    assign imm              = {{20{iIR[31]}}, iIR[31:25], iIR[11:7]};
    assign func3            = iIR[14:12];
    
    assign alu_in1          = iREG_OUT1;
    assign alu_in2          = iREG_OUT2;
    
    assign oRAM_CE          = (iIR[6:0] == 7'b0100011) ? 1'b1 : 1'b0;
    assign oRAM_WR          = (iIR[6:0] == 7'b0100011) ? 1'b1 : 1'b0;

    assign oRAM_WSTRB       = (func3 == 3'h0) ? (4'b0001 << oRAM_ADDR[1:0])           :       /* store byte */
                              (func3 == 3'h1) ? (4'b0011 << {oRAM_ADDR[1], 1'b0})     :       /* store half */
                              (func3 == 3'h2) ? 4'b1111                               :       /* store word */
                              4'b0000;

    assign oRAM_ADDR        = alu_in1 + imm;
    assign oRAM_DATA        = alu_in2;
    assign oREG_IN          = 32'h00;
    
endmodule
