import cocotb
from cocotb.triggers import Timer

ALU_ADD = 0
ALU_SUB = 1
ALU_AND = 2
ALU_OR  = 3
ALU_XOR = 4
ALU_SLT = 5
ALU_SLL = 6
ALU_SRL = 7

def u32(x: int) -> int:
    return x & 0xFFFFFFFF

def s32(x: int) -> int:
    x = u32(x)
    return x - 0x100000000 if x & 0x80000000 else x

async def apply(dut, A, B, op):
    dut.A.value = u32(A)
    dut.B.value = u32(B)
    dut.alu_ctrl.value = op
    await Timer(1, "ns")
    return int(dut.result.value), int(dut.zero.value)

@cocotb.test()
async def test_add_sub(dut):
    r, z = await apply(dut, 5, 7, ALU_ADD)
    assert r == 12 and z == 0

    r, z = await apply(dut, 7, 7, ALU_SUB)
    assert r == 0 and z == 1

    r, z = await apply(dut, 3, 10, ALU_SUB)
    # 3 - 10 = -7 in 32-bit two's complement
    assert r == u32(-7) and z == 0

@cocotb.test()
async def test_logic_ops(dut):
    r, _ = await apply(dut, 0b1100, 0b1010, ALU_AND)
    assert r == 0b1000

    r, _ = await apply(dut, 0b1100, 0b1010, ALU_OR)
    assert r == 0b1110

    r, _ = await apply(dut, 0b1100, 0b1010, ALU_XOR)
    assert r == 0b0110

@cocotb.test()
async def test_slt_signed(dut):
    # -1 < 1  => true
    r, _ = await apply(dut, -1, 1, ALU_SLT)
    assert r == 1

    # 5 < -3 => false (signed)
    r, _ = await apply(dut, 5, -3, ALU_SLT)
    assert r == 0

@cocotb.test()
async def test_shifts(dut):
    r, _ = await apply(dut, 1, 5, ALU_SLL)
    assert r == 32

    r, _ = await apply(dut, 0x80000000, 1, ALU_SRL)
    assert r == 0x40000000
