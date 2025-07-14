module riscv_32i (
    input           iRST, iCLK, iDONE,

    /* rom */
    input           ROM_DONE,
    input   [31:0]  iROM_DATA,
    output          oROM_CE, oROM_RD,
    output  [31:0]  oROM_ADDR,

    /* ram */
    input   [31:0]  iRAM_DATA,
    output          oRAM_CE, oRAM_RD, oRAM_WR,
    output  [3:0]   oRAM_WSTRB,
    output  [31:0]  oRAM_ADDR, oRAM_DATA
);

    integer i;

    reg     [7:0]   PC, iRAM_ADDR;

    /* register file */
    wire    [4:0]   RD, RS1, RS2;
    wire    [31:0]  ALU_IN1, ALU_IN2, ALU_OUT;

    /* branch */
    wire    [31:0]  BR_B, BR_J, BR_I;

    /* rom */
    wire    [31:0]  iROM_DATA, BR;
    wire    [6:0]   OPCODE;

    /* instruction */
    wire            INST_DONE, RAM_DONE, ALL_DONE;
    reg             RAM_OP;
    reg     [31:0]  IR_reg; 

    assign oROM_CE      = ~oRAM_CE;
    assign oROM_RD      = ~oRAM_CE;

    assign OPCODE       = IR_reg[6:0];
    assign oROM_ADDR    = (PC >> 2);

    register_file regfile (
        .iCLK(iCLK), .iRST(iRST), .iDONE(ALL_DONE),

        .iRD(RD), .iRS1(RS1), .iRS2(RS2),
        .oALU_IN1(ALU_IN1), .oALU_IN2(ALU_IN2), .iALU_OUT(ALU_OUT)
    );
        
    alu alu (
        .iCLK(iCLK), .iRST(iRST), .RAM_DONE(RAM_DONE),
        .OPCODE(OPCODE), .IR(IR_reg),

        .ALU_IN1(ALU_IN1), .ALU_IN2(ALU_IN2), .PC(PC),
        .ALU_OUT(ALU_OUT), .BR_B(BR_B), .BR_J(BR_J), .BR_I(BR_I),

        .RD(RD), .RS1(RS1), .RS2(RS2),

        .iRAM_DATA(iRAM_DATA),
        .oRAM_CE(oRAM_CE), .oRAM_RD(oRAM_RD), .oRAM_WR(oRAM_WR),
        .oRAM_ADDR(oRAM_ADDR), .oRAM_WSTRB(oRAM_WSTRB), .oRAM_DATA(oRAM_DATA)
    );

	initial begin
		i       = 0;
        PC      = 8'b00000000;
	end

    always @(posedge iCLK or posedge iRST) begin
        if (iRST) begin
            PC          <= 8'b0;
            i           <= 0;
            RAM_OP      <= 1'b0;
            IR_reg      <= 32'b0;
        end else begin
            if (ALL_DONE) begin
                $display("\n#CLOCK: {\"Clock\": %0d}", i);
                
                case (OPCODE)
                    7'b0110011:                         $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: R", PC, IR_reg, OPCODE);      
                    7'b0010011, 7'b0000011, 7'b1100111: $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: I", PC, IR_reg, OPCODE);
                    7'b0100011:                         $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: S", PC, IR_reg, OPCODE);
                    7'b0110111, 7'b0010111:             $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: U", PC, IR_reg, OPCODE);
                    7'b1100011:                         $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: B", PC, IR_reg, OPCODE);
                    7'b1101111:                         $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: J", PC, IR_reg, OPCODE);
                endcase

                PC <= (OPCODE == 7'b1100011) ? (BR_B) : 
                      (OPCODE == 7'b1101111) ? (BR_J) :
                      (OPCODE == 7'b1100111) ? (BR_I) :
                      PC + 4;
                
                // i <= i + 1;
            end

            RAM_OP      <= (OPCODE == (7'b0000011)) || (OPCODE == (7'b0100011));
            IR_reg      <= (ROM_DONE || RAM_DONE) ? iROM_DATA : IR_reg;
            i           <= i + 1;
        end
    end

    assign INST_DONE    = (iDONE && (OPCODE == 7'b0110011 || OPCODE == 7'b0010011 || OPCODE == 7'b1100111 ||
                                     OPCODE == 7'b0110111 || OPCODE == 7'b0010111 || OPCODE == 7'b1100011 || OPCODE == 7'b1101111 ));
    assign RAM_DONE     = (iDONE && RAM_OP);
    assign ALL_DONE     = INST_DONE || (iDONE  && RAM_DONE);

endmodule