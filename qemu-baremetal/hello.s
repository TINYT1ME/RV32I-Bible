# This is an example program that prints 'k' to the emulators terminal
# We print to screen by writing a byte to the UART (this is handled by qemu)

# Risc-v qemu uses 0x10000 as the UART address(memory mapped io)
# So whatever we write to 0x10000, qemu will print it to the terminal
.equ UART_BASE, 0x10000

.section .text
  # Store 107(letter 'k' in ASCII) in register x3
  addi  x3, zero, 107

  # Send the raw byte to QEMU's UART
  lui   x1, UART_BASE
  sb    x3, 0(x1)

  # End the program
  # Another qemu specific thing...
  # Writing 0x55550000 to 0x100 will cause qemu to exit
  lui   x1, 0x100
  lui   x2, 0x5
  addi  x2, x2, 0x555
  sw    x2, 0(x1)