module memory_rom (
	input			iROM_CE, iROM_RD,
	input	[31:0]	iROM_ADDR,
	
	output	[31:0]	oROM_DATA
);

	reg [31:0] mem [0:255];

	initial begin
		$readmemh("logical/rtl/soc/rom/memory_rom_init.hex", mem, 0, 255);
	end

	assign oROM_DATA = (iROM_CE && iROM_RD) ? mem[iROM_ADDR] : 32'h00000000;

endmodule