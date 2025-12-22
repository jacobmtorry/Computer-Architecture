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
    # --- Base pointers -------------------------------------------------
    lui   x5,  %hi(buf0)
    nop
    nop
    nop
    nop
    nop
    addi  x5,  x5,  %lo(buf0)
    nop
    nop
    nop
    nop
    nop

    lui   x8,  %hi(buf1)
    nop
    nop
    nop
    nop
    nop
    addi  x8,  x8,  %lo(buf1)
    nop
    nop
    nop
    nop
    nop

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

    lui   x15, %hi(value)
    nop
    nop
    nop
    nop
    nop
    addi  x15, x15, %lo(value)
    nop
    nop
    nop
    nop
    nop

    # --- Store/Load tests (SB/SH/SW + LB/LBU/LH/LHU/LW) ---------------
    # buf0: write four bytes with SB, verify with LW each time
    addi  x6,  x0, 0xAA
    nop
    nop
    nop
    nop
    nop
    sb    x6,  0(x5)
    nop
    nop
    nop
    nop
    nop
    lw    x7,  0(x5)          # expect 0x000000AA
    nop
    nop
    nop
    nop
    nop

    addi  x6,  x0, 0x55
    nop
    nop
    nop
    nop
    nop
    sb    x6,  1(x5)
    nop
    nop
    nop
    nop
    nop
    lw    x7,  0(x5)          # expect 0x000055AA
    nop
    nop
    nop
    nop
    nop

    addi  x6,  x0, 0xCC
    nop
    nop
    nop
    nop
    nop
    sb    x6,  2(x5)
    nop
    nop
    nop
    nop
    nop
    lw    x7,  0(x5)          # expect 0x00CC55AA
    nop
    nop
    nop
    nop
    nop

    addi  x6,  x0, 0x77
    nop
    nop
    nop
    nop
    nop
    sb    x6,  3(x5)
    nop
    nop
    nop
    nop
    nop
    lw    x7,  0(x5)          # expect 0x77CC55AA
    nop
    nop
    nop
    nop
    nop

    # buf1: SH lower then upper half, verify with LW
    addi  x9,  x0, 0x07EE
    nop
    nop
    nop
    nop
    nop
    sh    x9,  0(x8)
    nop
    nop
    nop
    nop
    nop
    lw    x11, 0(x8)          # expect 0x000007EE
    nop
    nop
    nop
    nop
    nop

    lui   x9,  0x0000B        # 0x0000B000
    nop
    nop
    nop
    nop
    nop
    addi  x9,  x9,  -1075     # -> 0x0000ABCD
    nop
    nop
    nop
    nop
    nop
    sh    x9,  2(x8)          # upper half
    nop
    nop
    nop
    nop
    nop
    lw    x11, 0(x8)          # expect 0xABCD07EE
    nop
    nop
    nop
    nop
    nop

    # buf2: SW then verify with LW
    lui   x13, 0x12345        # 0x12345000
    nop
    nop
    nop
    nop
    nop
    addi  x13, x13, 0x678     # -> 0x12345678
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
    lw    x14, 0(x12)         # expect 0x12345678
    nop
    nop
    nop
    nop
    nop

    # Loads from 'value' (aligned as required)
    lb    x16, 0(x15)         # 0x78 -> 120
    nop
    nop
    nop
    nop
    nop
    lbu   x17, 0(x15)         # 120
    nop
    nop
    nop
    nop
    nop
    lb    x16, 1(x15)         # 0x56 -> 86
    nop
    nop
    nop
    nop
    nop
    lbu   x17, 1(x15)         # 86
    nop
    nop
    nop
    nop
    nop
    lh    x18, 0(x15)         # 0x5678 -> 0x00005678
    nop
    nop
    nop
    nop
    nop
    lh    x18, 2(x15)         # 0x1234 -> 0x00001234
    nop
    nop
    nop
    nop
    nop
    lhu   x19, 0(x15)         # 0x00005678
    nop
    nop
    nop
    nop
    nop
    lhu   x19, 2(x15)         # 0x00001234
    nop
    nop
    nop
    nop
    nop
    lw    x20, 0(x15)         # 0x12345678
    nop
    nop
    nop
    nop
    nop

    # --- R-type arithmetic --------------------------------------------
    addi  x1,  x0, 7
    nop
    nop
    nop
    nop
    nop
    addi  x2,  x0, 5
    nop
    nop
    nop
    nop
    nop

    add   x3,  x1,  x2        # 12
    nop
    nop
    nop
    nop
    nop
    sub   x4,  x1,  x2        # 2
    nop
    nop
    nop
    nop
    nop
    xor   x6,  x1,  x2        # 2
    nop
    nop
    nop
    nop
    nop
    or    x7,  x1,  x2        # 7
    nop
    nop
    nop
    nop
    nop
    and   x8,  x1,  x2        # 5
    nop
    nop
    nop
    nop
    nop

    addi  x9,  x0, 4          # shamt in reg
    nop
    nop
    nop
    nop
    nop
    sll   x10, x1,  x9        # 7<<4 = 112
    nop
    nop
    nop
    nop
    nop
    lui   x11, 0x80000        # 0x80000000
    nop
    nop
    nop
    nop
    nop
    srl   x12, x11, x9        # -> 0x08000000
    nop
    nop
    nop
    nop
    nop
    sra   x13, x11, x9        # -> 0xF8000000
    nop
    nop
    nop
    nop
    nop

    addi  x14, x0, -1         # -1
    nop
    nop
    nop
    nop
    nop
    slt   x15, x14, x2        # -1 < 5  -> 1
    nop
    nop
    nop
    nop
    nop
    sltu  x16, x2,  x14       # 5 < 0xFFFFFFFF -> 1
    nop
    nop
    nop
    nop
    nop

    # --- I-type ALU ---------------------------------------------------
    addi  x17, x1,  -3        # 7 + (-3) = 4
    nop
    nop
    nop
    nop
    nop
    xori  x18, x1,  0x0FF     # 7 ^ 255 = 248
    nop
    nop
    nop
    nop
    nop
    ori   x19, x2,  0x0F0     # 5 | 240 = 245
    nop
    nop
    nop
    nop
    nop
    andi  x20, x2,  0x00F     # 5 & 15 = 5
    nop
    nop
    nop
    nop
    nop

    slli  x21, x1,  2         # 7 << 2 = 28
    nop
    nop
    nop
    nop
    nop
    srli  x22, x11, 31        # 1
    nop
    nop
    nop
    nop
    nop
    srai  x23, x14, 1         # -1 >>> 1 = 0xFFFFFFFF
    nop
    nop
    nop
    nop
    nop

    slti  x24, x14, 0         # 1
    nop
    nop
    nop
    nop
    nop
    sltiu x25, x2,  -1        # 1
    nop
    nop
    nop
    nop
    nop

    # --- U-type -------------------------------------------------------
    lui   x26, 0x7ABC         # 0x07ABC000
    nop
    nop
    nop
    nop
    nop
    auipc x27, 0              # PC
    nop
    nop
    nop
    nop
    nop

    # Done (keep core running without branches)
    slti  x0,  x0,  -256
    nop
    nop
    nop
    nop
    nop
