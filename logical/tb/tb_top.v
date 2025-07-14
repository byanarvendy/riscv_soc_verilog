`timescale 1ns / 1ns

module tb_top();
    reg             iCLK, iRST;
    integer         i;

    initial begin
        $dumpfile("logical/sim/tb_top.vcd");
    	$dumpvars(0, tb_top);

        iCLK = 0;
        iRST = 1;

        #10; iRST = 0;

        for (i = 0; i < 50000; i = i + 1) begin
            #5 iCLK = 0;
            #5 iCLK = 1;
        end

        #20;
    end

    top top(
        .iCLK(iCLK), .iRST(iRST)
    );

endmodule
