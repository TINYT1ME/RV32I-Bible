import cocotb
from cocotb.triggers import Timer

async def apply(dut, branch, funct3, rs1, rs2):
    dut.branch.value = branch
    dut.funct3.value = funct3
    dut.rs1_val.value = rs1 & 0xFFFFFFFF
    dut.rs2_val.value = rs2 & 0xFFFFFFFF
    await Timer(1, "ns")
    return int(dut.take_branch.value)

@cocotb.test()
async def test_beq(dut):
    
    out = await apply(dut, 1, 0b000, 10, 10)
    assert out == 1

    out = await apply(dut, 1, 0b000, 10, 5)
    assert out == 0

@cocotb.test()
async def test_bne(dut):
    out = await apply(dut, 1, 0b001, 10, 5)
    assert out == 1

 
    out = await apply(dut, 1, 0b001, 7, 7)
    assert out == 0

@cocotb.test()
async def test_blt_signed(dut):

    out = await apply(dut, 1, 0b100, -1, 1)
    assert out == 1

    out = await apply(dut, 1, 0b100, 5, -3)
    assert out == 0

@cocotb.test()
async def test_bge_signed(dut):
    out = await apply(dut, 1, 0b101, 5, 5)
    assert out == 1

    out = await apply(dut, 1, 0b101, -1, 3)
    assert out == 0

@cocotb.test()
async def test_branch_disabled(dut):
    out = await apply(dut, 0, 0b000, 10, 10)
    assert out == 0
