    .section .data
value:
    .word 0x12345678

buf0:
    .word 0x00000000
buf1:
    .word 0x00000000
buf2:
    .word 0x00000000

    .section .text
    .globl _start
_start:

    lui     x5, %hi(value)
    addi    x5, x5, %lo(value)



    lb      x10, 0(x5)          # expect 0x00000078
    lb      x11, 1(x5)          # expect 0x00000056
    lb      x12, 2(x5)          # expect 0x00000034
    lb      x13, 3(x5)          # expect 0x00000012 

    lh      x14, 0(x5)          # expect 0x00005678
    lh      x15, 2(x5)          # expect 0x00001234

    lw      x16, 0(x5)          # expect 0x12345678

    lbu     x17, 0(x5)          # expect 0x00000078
    lbu     x18, 1(x5)          # expect 0x00000056
    lbu     x18, 1(x5)          # expect 0x00000056
    lbu     x18, 1(x5)          # expect 0x00000056
    lbu     x18, 1(x5)          # expect 0x00000056
    lbu     x18, 1(x5)          # expect 0x00000056
    lbu     x18, 1(x5)          # expect 0x00000056
    lbu     x18, 1(x5)          # expect 0x00000056
    lbu     x18, 1(x5)          # expect 0x00000056

    lhu     x19, 0(x5)          # expect 0x00005678
    lhu     x20, 2(x5)          # expect 0x00001234

    # # buf0 used to test sb
    lui     x6, %hi(buf0)
    addi    x6, x6, %lo(buf0)

    addi    x7, x0, 0xAA
    sb      x7, 0(x6)
    lw      x8, 0(x6)           # expect 0x000000AA

    addi    x7, x0, 0xBB
    sb      x7, 1(x6)
    lw      x8, 0(x6)           # expect 0x0000BBAA

    addi    x7, x0, 0xCC
    sb      x7, 2(x6)
    lw      x8, 0(x6)           # expect 0x00CCBBAA

    addi    x7, x0, 0xDD
    sb      x7, 3(x6)
    lw      x8, 0(x6)           # expect 0xDDCCBBAA

    # # buf1 used for sh
    add     x6, x0, x0
    lui     x6, %hi(buf1)
    addi    x6, x6, %lo(buf1) 

    addi    x7, x0, 0x7EE
    sh      x7, 0(x6)
    lw      x8, 0(x6)           # expect 0x000007ee

    lui     x7, 0x0000b 
    addi    x7, x7, -1075
    sh      x7, 2(x6)
    lw      x8, 0(x6)           # expect 0xABCD07EE

    # # buf2 used for sw
    add     x6, x0, x0
    lui     x6, %hi(buf2)
    addi    x6, x6, %lo(buf2) 

    lui     x7, 0x12345
    addi    x7, x7, 0x678
    sw      x7, 0(x6)
    lw      x8, 0(x6)           # expect 0x12345678

    addi    x7, x0, 0xAA
    sb      x7, 0(x6)
    sb      x8, 1(x6)
    sb      x9, 2(x6)
    sb      x10, 3(x6)   

    lui     x7, 0x12345
    addi    x7, x7, 0x678
    sw      x7, 124(x6)
    lw      x8, 124(x6)                      

    slti x0, x0, -256