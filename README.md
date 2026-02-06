# RV32I-Bible

This repository is a teaching resource for students wanting to know how to implement a CPU. It walks through building a single cycle RV32I RISC-V processor in SystemVerilog. With verification using Python & cocotb. The end goal is to be able to play simple games with vga output. Learn more here [Project Roadmap](PLAN.md)

### [Learn how to build a CPU](guide/01.md)

- 0 to 1 guide on how to implement a 32 bit RISC-V CPU
- Still in the works...

### [Programming the CPU using qemu](guide/qemu.md)

- Quick guide on how to install QEMU and toolchain
- Example program to run on emulator

### Resources:

[RISCV-Manual](RISC-V-ISA-Manual.pdf) - CPU implmentation follows this manual(Chapter 2)

[Instruction Set](https://www.vicilogic.com/static/ext/RISCV/RV32I_BaseInstructionSet.pdf) - RV32I full instructions list

## Quick Setup

### 1. Clone & Setup Environment

```bash
# Clone the repository
git clone https://github.com/TINYT1ME/RV32I-Bible

# Navigate to project directory
cd RV32I-Bible

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # Mac/Linux
# OR
venv\Scripts\activate     # Windows
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

## Verilator Installation

### macOS (using Homebrew)

```bash
brew install verilator
```

### Ubuntu/Debian

```bash
sudo apt-get install verilator
```

### Windows

As Verilator isn't natively built for Windows, you must use [MSYS2](https://sourceforge.net/projects/msys2/). Instructions can be found [here](https://gist.github.com/sgherbst/036456f807dc8aa84ffb2493d1536afd).

## Acknowledgment

- **[uODD Club Project](https://www.uofpga.ca/)**: This project is group effort
- **RISC-V ISA reference**: The CPU follows the [RISC-V Unprivileged ISA Specification](https://github.com/TINYT1ME/RV32I-Bible/blob/main/RISC-V-ISA-Manual.pdf) (RV32I, version 2.1). The manual is included in this repo for convenience. Maintained by [RISC-V International](https://riscv.org/technical/specifications/).
