# Running an example program with QEMU

> Make sure to have prerequisites installed, if not click [here](../guide/qemu.md)

We will be running our example program [hello.s](hello.s)

**Build and run**

From the qemu-baremetal directory:

```bash
make run PROGRAM=hello
```

This will:

1. Assemble `hello.s` → `hello.o`
2. Link `hello.o` with `baremetal.ld` → `hello.elf`
3. Start QEMU with `hello.elf` as the “BIOS” and show serial output in the terminal

We need the RISC-V toolchain for assembly and linking, and QEMU to emulate the CPU

The Makefile handles this process for us, so we can run 1 clean command to build->load->execute our program

### What Is baremetal.ld?

baremetal.ld is a **linker script**. It tells the linker where to put code and data in memory.

Sooooo... baremetal.ld is what makes the program run at the address QEMU expects, and is required for this bare-metal setup
