# QEMU & Toolchain Installation

#### Checkout [qemu-baremetal](../qemu-baremetal/README.md) to run an example program on the qemu emulator

## Installation

You need [QEMU](https://www.qemu.org/) to emulate a machine & the [RISC-V toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)

### Macos

```bash
brew install qemu
brew tap riscv-software-src/riscv
brew install riscv-gnu-toolchain
```

Check it works:

```bash
qemu-system-riscv32 --version
riscv64-unknown-elf-gcc --version
```

### Linux

coming soon...

### Windows

coming soon...
