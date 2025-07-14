`timescale 1ns / 1ns

module register_file (
    input           iCLK, iRST, iDONE,
    input   [4:0]   iRD, iRS1, iRS2,
    input   [31:0]  iALU_OUT,
    output  [31:0]  oALU_IN1, oALU_IN2
);

    integer i;

    reg [31:0] regfile [0:31];

    assign oALU_IN1 = regfile[iRS1];
    assign oALU_IN2 = regfile[iRS2];

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            regfile[i] = 0;
        end
    end

    always @(posedge iCLK or posedge iRST) begin
        if (iRST) begin
            for (i = 0; i < 32; i = i + 1) begin
                regfile[i] = 0;
            end

            $display("\n === INITIAL REGISTER VALUE === ");
            for (i = 0; i < 32; i = i + 8) begin
                $display("#REG: [0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x]", regfile[i+0], regfile[i+1], regfile[i+2], regfile[i+3], regfile[i+4], regfile[i+5], regfile[i+6], regfile[i+7]);
            end
        end else begin
            if (iDONE) begin
                if (iRD != 5'b00000) begin
                    regfile[iRD] <= iALU_OUT;
                end

                #1; 
                    $display("#REGISTERS:");
                    for (i = 0; i < 32; i = i + 8) begin
                        $display("#REG: [0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x]", regfile[i+0], regfile[i+1], regfile[i+2], regfile[i+3], regfile[i+4], regfile[i+5], regfile[i+6], regfile[i+7]);
                    end

            end
        end
    end

endmodule