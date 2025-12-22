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

    lb    x10, 0(x5)     # expect 0x00000078
    nop
    nop
    nop
    nop
    nop

    lb    x11, 1(x5)     # expect 0x00000056
    nop
    nop
    nop
    nop
    nop

    lb    x12, 2(x5)     # expect 0x00000034
    nop
    nop
    nop
    nop
    nop

    lb    x13, 3(x5)     # expect 0x00000012
    nop
    nop
    nop
    nop
    nop

    lh    x14, 0(x5)     # expect 0x00005678
    nop
    nop
    nop
    nop
    nop

    lh    x15, 2(x5)     # expect 0x00001234
    nop
    nop
    nop
    nop
    nop

    lw    x16, 0(x5)     # expect 0x12345678
    nop
    nop
    nop
    nop
    nop

    lbu   x17, 0(x5)     # expect 0x00000078
    nop
    nop
    nop
    nop
    nop

    lbu   x18, 1(x5)     # expect 0x00000056
    nop
    nop
    nop
    nop
    nop

    lhu   x19, 0(x5)     # expect 0x00005678
    nop
    nop
    nop
    nop
    nop

    lhu   x20, 2(x5)     # expect 0x00001234
    nop
    nop
    nop
    nop
    nop

    slti  x0, x0, -256
    nop
    nop
    nop
