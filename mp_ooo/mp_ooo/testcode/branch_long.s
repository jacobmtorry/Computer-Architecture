    .text
    .globl _start
_start:
    # --- Register initialization ---
    li x1, 5
    li x2, 5
    li x3, 10
    li x4, 15
    li x5, 20
    li x6, 25
    li x7, 30
    li x8, 35
    li x9, 40
    li x10, 45
    li x11, 50
    li x12, 55
    li x13, 60
    li x14, 65
    li x15, 70
    li x16, 75
    li x17, 80
    li x18, 85
    li x19, 90
    li x20, 95

    # -------------------------------------------------------------
    # BEQ Loop (Taken until equal, then exit)
    # -------------------------------------------------------------
    li x21, 0
    li x22, 5
beq_loop:
    add x1, x1, x2
    mul x3, x3, x4
    addi x5, x5, 2
    sub x6, x6, x7
    add x8, x8, x9
    mul x10, x10, x11
    addi x12, x12, 3
    sub x13, x13, x14
    add x15, x15, x16
    mul x17, x17, x18
    addi x19, x19, 4
    addi x22, x22, -1
    beq x21, x22, beq_done
    add x20, x20, x21
    sub x2, x3, x4
    mul x4, x5, x6
    addi x7, x7, 1
    addi x8, x8, 1
    addi x9, x9, 1
    addi x10, x10, 1
    addi x11, x11, 1
    addi x12, x12, 1
    addi x7, x7, 7
    addi x8, x8, 8
    addi x9, x9, 9
    addi x10, x10, 10
    addi x11, x11, 11

    beq x0, x0, beq_loop
beq_done:

    # -------------------------------------------------------------
    # BNE Loop (Run while x23 != x24)
    # -------------------------------------------------------------
    li x23, 10
    li x24, 0
bne_loop:
    add x1, x1, x2
    addi x24, x24, 1
    sub x3, x3, x4
    mul x5, x5, x6
    add x7, x7, x8
    sub x9, x9, x10
    mul x11, x11, x12
    add x13, x13, x14
    addi x15, x15, 2
    addi x16, x16, 3
    addi x17, x17, 4
    addi x18, x18, 5
    bne x23, x24, bne_loop
    add x19, x19, x20
    sub x1, x1, x2
    mul x3, x4, x5
    addi x6, x6, 6
    addi x7, x7, 7
    addi x8, x8, 8
    addi x9, x9, 9
    addi x10, x10, 10
    addi x11, x11, 11

    # -------------------------------------------------------------
    # BLT Loop (x25 < x26)
    # -------------------------------------------------------------
    li x25, 0
    li x26, 5
blt_loop:
    add x1, x1, x2
    mul x3, x4, x5
    addi x25, x25, 1
    add x6, x7, x8
    sub x9, x10, x11
    mul x12, x13, x14
    addi x15, x15, 1
    addi x16, x16, 1
    addi x17, x17, 1
    addi x18, x18, 1
    blt x25, x26, blt_loop
    sub x19, x20, x1
    mul x2, x3, x4
    add x5, x6, x7
    addi x8, x8, 8
    addi x9, x9, 9
    addi x10, x10, 10
    addi x11, x11, 11
    addi x12, x12, 12
    addi x13, x13, 13

    # -------------------------------------------------------------
    # BGE Loop (x27 >= x28)
    # -------------------------------------------------------------
    
    li x27, 6
    li x28, 0
bge_loop:
    add x1, x1, x2
    addi x27, x27, -1       # fixed: subtract 1
    mul x3, x4, x5
    addi x6, x6, 1
    add x7, x7, x8
    sub x9, x9, x10
    mul x11, x11, x12
    add x13, x13, x14
    addi x15, x15, 1
    addi x16, x16, 1
    addi x17, x17, 1
    bge x27, x28, bge_loop
    addi x18, x18, 5
    addi x19, x19, 5
    addi x20, x20, 5
    add x2, x2, x3
    sub x4, x4, x5
    mul x6, x6, x7
    addi x8, x8, 8
    addi x9, x9, 9
    addi x10, x10, 10

    # -------------------------------------------------------------
    # BLTU Loop (unsigned less than)
    # -------------------------------------------------------------
    li x29, 0
    li x30, 5
bltu_loop:
    add x1, x1, x2 #
    mul x3, x4, x5
    addi x29, x29, 1
    add x6, x6, x7
    sub x8, x8, x9
    mul x10, x10, x11
    addi x12, x12, 1
    bltu x29, x30, bltu_loop
    add x13, x13, x14
    sub x15, x15, x16 #
    mul x17, x17, x18
    addi x19, x19, 2
    addi x20, x20, 3
    addi x21, x21, 4
    addi x22, x22, 5

    # -------------------------------------------------------------
    # BGEU Loop (unsigned greater/equal)
    # -------------------------------------------------------------
    li x29, 5
    li x30, 2
bgeu_loop:
    add x1, x1, x2
    addi x29, x29, -1       # fixed: subtract 1
    mul x3, x4, x5
    add x6, x7, x8
    sub x9, x10, x11
    mul x12, x13, x14
    addi x15, x15, 1
    addi x16, x16, 1
    bgeu x29, x30, bgeu_loop
    add x17, x17, x18
    addi x19, x19, 6
    addi x20, x20, 7
    addi x21, x21, 8
    addi x22, x22, 9
    addi x23, x23, 10
    add x24, x24, x25
    sub x26, x26, x27
    mul x28, x29, x30

    # --- End of Test ---
    nop
    nop
    nop

slti x0, x0, -256
