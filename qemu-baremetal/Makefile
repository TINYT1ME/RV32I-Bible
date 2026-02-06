# RV32I baremetal build and run for QEMU virt
# Run from this directory:
#   make run PROGRAM=main
#   make run PROGRAM=hello QEMU_ARGS="-m 256M"
#   make build PROGRAM=main

CROSS   ?= riscv64-unknown-elf-
AS      := $(CROSS)as
CC      := $(CROSS)gcc
LDSCRIPT ?= baremetal.ld
RV32    := -march=rv32i -mabi=ilp32

PROGRAM ?= main
ELF     := $(PROGRAM).elf
QEMU    := qemu-system-riscv32
QEMU_BASE := -machine virt -nographic -serial mon:stdio
QEMU_ARGS ?=

SRC_S   := $(PROGRAM).s
SRC_C   := $(PROGRAM).c
OBJ     := $(PROGRAM).o
# Prefer .s over .c
SRC     := $(firstword $(wildcard $(SRC_S)) $(wildcard $(SRC_C)))

.PHONY: build run clean

build: $(ELF)

$(ELF): $(OBJ) $(LDSCRIPT)
	$(CC) -T $(LDSCRIPT) $(RV32) -nostdlib -static -o $@ $(OBJ)

$(OBJ): $(SRC)
	@test -n "$(SRC)" || (echo "No $(SRC_S) or $(SRC_C) found."; exit 1)
	@if [ -f "$(SRC_S)" ]; then $(AS) $(RV32) $(SRC_S) -o $@; else $(CC) $(RV32) -nostdlib -static -ffreestanding -c $(SRC_C) -o $@; fi

run: $(ELF)
	$(QEMU) $(QEMU_BASE) $(QEMU_ARGS) -bios $(ELF)

debug: $(ELF)
	$(QEMU) $(QEMU_BASE) $(QEMU_ARGS) -bios $(ELF) -s -S

gdb: $(ELF)
	$(CROSS)gdb $(ELF) -ex "target remote :1234"

clean:
	rm -f $(OBJ) $(ELF)
