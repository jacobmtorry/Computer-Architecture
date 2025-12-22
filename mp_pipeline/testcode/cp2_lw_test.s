# Was given in campuswire as a test
.section .data
value:
    .word 0x12345678       

.section .text
.globl _start
_start:
    lui   x5, %hi(value)    
    nop
    nop
    nop
    nop
    nop
    addi  x5, x5, %lo(value)
    nop
    nop
    nop
    nop
    nop
    lw    x10, 0(x5)     
    nop
    nop
    nop
    nop
    nop
    # Byte 0 -> 0x78
    lb    x11, 0(x5)
    nop
    nop
    nop
    nop
    nop
    slti x0, x0, -256 # this is the magic instruction to end the simulation
    nop               # preventing fetching illegal instructions
    nop
    nop
    nop
    nop