"""
Test for immgen.sv
make TOPLEVEL=immgen MODULE=test_immgen
"""
import cocotb
from cocotb.triggers import Timer

def u32(x: int) -> int:
    return x & 0xFFFFFFFF

async def apply_instr(dut, instr: int):
    dut.instr.value = u32(instr)
    await Timer(1, "ns")
    return int(dut.imm.value)

@cocotb.test()
async def test_i_type(dut):
    """I-type"""
    # addi x1, x0, 5
    imm = await apply_instr(dut, 0x00500093)
    assert imm == 5, f"expected 5, got {imm}"

    # addi x2, x0, 10
    imm = await apply_instr(dut, 0x00A00113)
    assert imm == 10, f"expected 10, got {imm}"

    # addi x1, x0, -1
    imm = await apply_instr(dut, 0xFFF00093)
    assert imm == u32(-1), f"expected -1, got {imm}"


@cocotb.test()
async def test_r_type_default_zero(dut):
    """R-type"""
    # add x3, x1, x2
    imm = await apply_instr(dut, 0x002081B3)
    assert imm == 0, f"expected 0, got {imm}"


@cocotb.test()
async def test_u_type(dut):
    """U-type"""
    # lui x7, 0x712
    imm = await apply_instr(dut, 0x007123B7)
    assert imm == 0x712000, f"expected 0x712000, got {imm}"


@cocotb.test()
async def test_s_type(dut):
    """S-type"""
    # lw x6, 8(x4)
    imm = await apply_instr(dut, 0x00822303)
    assert imm == 8, f"expected 8, got {imm}"


@cocotb.test()
async def test_b_type(dut):
    """B-type"""
    # beq x1, x2, 8
    imm = await apply_instr(dut, 0x00208463)
    assert imm == 8, f"expected 8, got {imm}"


@cocotb.test()
async def test_j_type(dut):
    """J-type"""
    # jal x0, 2
    imm = await apply_instr(dut, 0x0020006F)
    assert imm == 2, f"expected 2, got {imm}"