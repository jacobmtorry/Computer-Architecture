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
    # buf0: SB all lanes then verify with LW
    lui   x5, %hi(buf0)
    nop
    nop
    nop
    nop
    nop
    addi  x5, x5, %lo(buf0)
    nop
    nop
    nop
    nop
    nop

    addi  x6, x0, 0xAA
    nop
    nop
    nop
    nop
    nop
    sb    x6, 0(x5)
    nop
    nop
    nop
    nop
    nop
    lw    x7, 0(x5)          # 0x000000AA
    nop
    nop
    nop
    nop
    nop

    addi  x6, x0, 0x55
    nop
    nop
    nop
    nop
    nop
    sb    x6, 1(x5)
    nop
    nop
    nop
    nop
    nop
    lw    x8, 0(x5)          # 0x000055AA
    nop
    nop
    nop
    nop
    nop

    addi  x6, x0, 0xCC
    nop
    nop
    nop
    nop
    nop
    sb    x6, 2(x5)
    nop
    nop
    nop
    nop
    nop
    lw    x9, 0(x5)          # 0x00CC55AA
    nop
    nop
    nop
    nop
    nop

    addi  x6, x0, 0x77
    nop
    nop
    nop
    nop
    nop
    sb    x6, 3(x5)
    nop
    nop
    nop
    nop
    nop
    lw    x10, 0(x5)         # 0x77CC55AA
    nop
    nop
    nop
    nop
    nop

    # buf1: SH lower then upper, verify with LW
    lui   x8, %hi(buf1)
    nop
    nop
    nop
    nop
    nop
    addi  x8, x8, %lo(buf1)
    nop
    nop
    nop
    nop
    nop

    addi  x9, x0, 0x7EE
    nop
    nop
    nop
    nop
    nop
    sh    x9, 0(x8)
    nop
    nop
    nop
    nop
    nop
    lw    x11, 0(x8)         # 0x000007EE
    nop
    nop
    nop
    nop
    nop

    # x9 := 0xABCD (explicit LUI+ADDI with bubble in between)
    lui   x9, 0x0000b        # 0x0000B000
    nop
    nop
    nop
    nop
    nop
    addi  x9, x9, -1075      # 0xB000 + (-0x433) = 0xABCD
    nop
    nop
    nop
    nop
    nop
    sh    x9, 2(x8)
    nop
    nop
    nop
    nop
    nop
    lw    x12, 0(x8)         # 0xABCD07EE
    nop
    nop
    nop
    nop
    nop

    # buf2: SW then verify with LW
    lui   x12, %hi(buf2)
    nop
    nop
    nop
    nop
    nop
    addi  x12, x12, %lo(buf2)
    nop
    nop
    nop
    nop
    nop

    # x13 := 0x12345678 (explicit LUI+ADDI with bubble in between)
    lui   x13, 0x12345       # 0x12345000
    nop
    nop
    nop
    nop
    nop
    addi  x13, x13, 0x678    # +0x0678 -> 0x12345678
    nop
    nop
    nop
    nop
    nop
    sw    x13, 0(x12)
    nop
    nop
    nop
    nop
    nop
    lw    x14, 0(x12)        # 0x12345678
    nop
    nop
    nop
    nop
    nop

    slti  x0, x0, -256
    nop
    nop
    nop
