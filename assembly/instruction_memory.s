    .section .text
    .globl _start


_start:
    addi x1, x0, 5 #put value 5 
    addi x2, x0, 10
    addi x6, x0, 0
    add x3, x1, x2 # x3 = x1 + x2
    addi x4, x3, 34 # x4 = x3 + 1
    lw x6, 8(x4) #load into register x6, mem[x4+8]
    sub x5, x6, x2
    lui x7, 0x712 #load upper 20 bits
    addi x7, x7, 0x678 # add lower 12 bits
    beq x1, x2, 8
    nop

