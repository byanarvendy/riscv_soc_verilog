module memory_ram (
    input           iRAM_CLK, iRAM_RST,
    input           iRAM_CE, iRAM_RD, iRAM_WR,
	input	[3:0]   iRAM_WSTRB,
    input   [31:0]  READ_ADDR, WRITE_ADDR, iRAM_DATA,
    output	[31:0]  oRAM_DATA
	);

	reg [31:0] mem [0:255];
	integer i;

	assign oRAM_DATA = (iRAM_CE && iRAM_RD) ? mem[READ_ADDR] : 32'h00000000;

	initial begin
		$readmemh("logical/rtl/soc/ram/memory_ram_init.hex", mem, 0, 255);
	end

	always @(posedge iRAM_CLK or posedge iRAM_RST) begin
		if (iRAM_RST) begin
			for (i = 0; i < 256; i = i + 1) begin
				mem[i] = 32'h00000000;
			end
		end else begin
			if (iRAM_WR) begin
				if (iRAM_WSTRB[0]) mem[WRITE_ADDR][7:0]   <= iRAM_DATA[7:0];
				if (iRAM_WSTRB[1]) mem[WRITE_ADDR][15:8]  <= iRAM_DATA[15:8];
				if (iRAM_WSTRB[2]) mem[WRITE_ADDR][23:16] <= iRAM_DATA[23:16];
				if (iRAM_WSTRB[3]) mem[WRITE_ADDR][31:24] <= iRAM_DATA[31:24];
			end
		end
	end

endmodule
