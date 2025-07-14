.PHONY: sim clean wave ass

# default top module
TOP 		?= top

# define tools #
IVERILOG 	= iverilog
VVP 		= vvp

# directory structure #
RTL 		= logical/rtl
TB 			= logical/tb
SIM 		= logical/sim

# include file #
INC 		= $(RTL)/include.vh

# source files #
SRC 		= $(INC) $(RTL)/$(TOP).v $(TB)/tb_$(TOP).v
OUT 		= $(SIM)/tb_$(TOP).vvp
VCD 		= $(SIM)/tb_$(TOP).vcd

# pattern rule #
%:
	@$(MAKE) TOP=$@ $(MAKECMDGOALS)

sim:
	$(IVERILOG) -o $(OUT) $(SRC)
	$(VVP) $(OUT)

wave: $(VCD)
	gtkwave $(VCD) &

# === Assembly Section ===
ASS_DIR		= logical/src
ROM_HEX     = $(RTL)/soc/rom/memory_rom_init.hex


CROSS_COMPILE ?= riscv32-unknown-elf-

AS      	= $(CROSS_COMPILE)as
LD      	= $(CROSS_COMPILE)ld
OBJCOPY 	= $(CROSS_COMPILE)objcopy
HEXDUMP 	= hexdump

LDFLAGS 	= -Ttext=0x00000000
HEXFLAGS 	= -ve '1/4 "%08x\n"'

ASS_TARGET_FILE := $(filter-out ass sim wave clean all, $(MAKECMDGOALS))

ass:
	@if [ -z "$(ASS_TARGET_FILE)" ]; then \
		echo "usage: make ass <filename> (e.g. make ass fib)"; \
		exit 1; \
	fi; \
	FILE=$(ASS_TARGET_FILE); \
	ASS_SRC=$(ASS_DIR)/$$FILE.s; \
	mkdir -p $(dir $(ROM_HEX)); \
	$(AS) $$ASS_SRC -o temp.o; \
	$(LD) temp.o -Ttext=0x00000000 -o temp.elf; \
	$(OBJCOPY) -O binary temp.elf temp.bin; \
	$(HEXDUMP) -ve '1/4 "%08x\n"' temp.bin > $(ROM_HEX); \
	rm -f temp.o temp.elf temp.bin; \
	echo "--- assembly successful ---"; \
	echo "source:  $$ASS_SRC"; \
	echo "output:  $(ROM_HEX)\n"; \

$(ASS_TARGET_FILE):
	@true

clean:
	rm -f $(OUT) $(SIM)/*.vcd

# default target
.DEFAULT_GOAL := sim
