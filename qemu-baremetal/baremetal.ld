/*
 * Why this script is necessary:
 *   There is no OS to load or relocate our program. We must tell the linker
 *   exactly where in memory the code and data will live so that addresses
 *   in the final ELF match where QEMU will actually place the program
 */

SECTIONS
{
  /* QEMU loads the bios ELF at 0x80000000 and starts execution there
   * The program must be linked for this address so that the first instruction is at 0x80000000
   */
  . = 0x80000000;

  .text : { *(.text) }

  /* Align the next section so .data starts on a word boundary (4 bytes)
   * In our example we do not use the data section...but it is good to have incase we do use it
   */
  . = ALIGN(4);
  .data : { *(.data) }
}
