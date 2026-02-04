import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def test_pc_imem(dut):
    """Testbench for PC and IM"""

    # initialize 10ns clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.resetn.value = 0
    #dut.read_addr.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.resetn.value = 1

    with open("../assembly/instruction_memory.hex") as f:
        lines = f.readlines()
    
    for i, line in enumerate(lines):
        val = int(line.strip(), 16)
        dut.im_inst.mem[i].value = val
    #dut.im_inst.mem[0].value = 0x002080B3  # R: add x5, x1, x2
    #dut.im_inst.mem[1].value = 0x00A00313  # I: addi x6, x0, 10
    #dut.im_inst.mem[2].value = 0x00502023  # S: sw x5, 0(x1)
    #dut.im_inst.mem[3].value = 0x123457B7  # U: lui x7, 0x12345
    #dut.im_inst.mem[4].value = 0x00208663  # B: beq x1, x2, +8


    print("Starting...\n")

    # simulation
    for i in range(len(lines)+1):
        await RisingEdge(dut.clk)
        print(f"Cycle {i}: PC={int(dut.pc_out.value):08X} -> Instruction={int(dut.instr_out.value):08X} -> Pipeline Instruction={int(dut.instr_pl_out.value):08X}")
        
    print("\nTest end.")
