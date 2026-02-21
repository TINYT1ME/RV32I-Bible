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

async def apply(dut, alu_op, funct3, funct7):
    dut.alu_op.value = alu_op
    dut.funct3.value = funct3
    dut.funct7.value = funct7
    await Timer(1, "ns")
    return int(dut.alu_ctrl.value)

@cocotb.test()
async def test_load_store_add(dut):
    # alu_op=00 => always ADD
    out = await apply(dut, 0b00, 0b000, 0b0000000)
    assert out == ALU_ADD

@cocotb.test()
async def test_branch_sub(dut):
    # alu_op=01 => always SUB
    out = await apply(dut, 0b01, 0b000, 0b0000000)
    assert out == ALU_SUB

@cocotb.test()
async def test_rtype_add_sub(dut):
    # alu_op=10, funct3=000
    # ADD when funct7 != 0100000
    out = await apply(dut, 0b10, 0b000, 0b0000000)
    assert out == ALU_ADD

    # SUB when funct7 == 0100000
    out = await apply(dut, 0b10, 0b000, 0b0100000)
    assert out == ALU_SUB

@cocotb.test()
async def test_rtype_logic_and_shifts(dut):
    out = await apply(dut, 0b10, 0b111, 0b0000000)  # AND
    assert out == ALU_AND

    out = await apply(dut, 0b10, 0b110, 0b0000000)  # OR
    assert out == ALU_OR

    out = await apply(dut, 0b10, 0b100, 0b0000000)  # XOR
    assert out == ALU_XOR

    out = await apply(dut, 0b10, 0b010, 0b0000000)  # SLT
    assert out == ALU_SLT

    out = await apply(dut, 0b10, 0b001, 0b0000000)  # SLL
    assert out == ALU_SLL

    out = await apply(dut, 0b10, 0b101, 0b0000000)  # SRL
    assert out == ALU_SRL
