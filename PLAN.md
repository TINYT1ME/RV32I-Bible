# Project Plan: RV32I FPGA Game System

## Project Goal

This project aims at implementing a **32-bit** simple game console using the **RISC-V** ISA. The goal is to design, build, and integrate a CPU, VGA display controller, and user input interface to run interactive games(think pong, snake...).

We will be using **SystemVerilog** for hardware description and **Cocotb** for testing.
The CPU implementation will follow the **RV32I version 2.1** ISA.
[Manual can be found here](./RISC-V-ISA-Manual.pdf)

## Architecture Overview

> Harvard Architecture - Seprate memory for data and instructions

|     | Stage                     | Main Components                                  |
| --- | ------------------------- | ------------------------------------------------ |
| ↓   | **Instruction Fetch**     | Program Counter (PC), Instruction Memory         |
| ↓   | **Instruction Decode**    | Control Unit, Register File, Immediate Generator |
| ↓   | **Instruction Execution** | ALU, ALU Control, Branch Unit                    |
| ↓   | **Data Store**            | Data Memory, Writeback Unit                      |
| ↓   | **PC Update**             | Increment/Branch Logic                           |

## Implementation Steps - as of Dec 18 2025

1.  **Implement RV32I Single Cycle CPU** ⬅️ Where we are

- CPU component implmentation
- Core instruction set v2.1
- CPU Programming Testing

2.  **Add Pipelining to CPU**

- 5-stage pipeline (IF, ID, EX, MEM, WB)
- Hazard detection and forwarding

3.  **Build VGA Output Component**

- ...

4.  **Integrate CPU with VGA Display**

- ...

5.  **Implement Game Framework**

- ...

6.  **Develop Games**

- Develop a few games to play around with : )

## Guide/Walktrough Goal

The goal of this github repo is to create a walkthough/guide that someone can read an fully understand how to implement this project on their own. Each section you work on must come with a guide explaining the theory behind your component/section.
