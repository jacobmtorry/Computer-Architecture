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

    ##############################################
    # Branch instruction tests (no jumps)
    ##############################################

    # --- BEQ test: taken and not taken ---
    # Case 1: taken (x1 == x2)
    beq x1, x2, beq_taken
    addi x3, x0, 999        # skipped
beq_taken:
    addi x3, x3, 1          # executes

    # Case 2: not taken (x1 != x3)
    beq x1, x3, beq_not_taken
    addi x4, x4, 2          # executes (branch not taken)
beq_not_taken:
    addi x4, x4, 1

    # --- BNE test: taken and not taken ---
    # Case 1: taken (x1 != x3)
    bne x1, x3, bne_taken
    addi x5, x5, 99         # skipped
bne_taken:
    addi x5, x5, 1

    # Case 2: not taken (x1 == x2)
    bne x1, x2, bne_not_taken
    addi x6, x6, 2          # executes (branch not taken)
bne_not_taken:
    addi x6, x6, 1

    # --- BLT test: taken and not taken ---
    # Case 1: taken (x3 < x5)
    blt x3, x5, blt_taken
    addi x7, x7, 111        # skipped
blt_taken:
    addi x7, x7, 2

    # Case 2: not taken (x5 >= x3)
    blt x5, x3, blt_not_taken
    addi x8, x8, 3          # executes
blt_not_taken:
    addi x8, x8, 1

    # --- BGE test: taken and not taken ---
    # Case 1: taken (x5 >= x3)
    bge x5, x3, bge_taken
    addi x9, x9, 111        # skipped
bge_taken:
    addi x9, x9, 4

    # Case 2: not taken (x3 < x5)
    bge x3, x5, bge_not_taken
    addi x10, x10, 5        # executes
bge_not_taken:
    addi x10, x10, 1

    # --- BLTU test: taken and not taken ---
    # Case 1: taken (unsigned x8 < x9)
    bltu x8, x9, bltu_taken
    addi x11, x11, 222      # skipped
bltu_taken:
    addi x11, x11, 6

    # Case 2: not taken (unsigned x9 > x8)
    bltu x9, x8, bltu_not_taken
    addi x12, x12, 7        # executes
bltu_not_taken:
    addi x12, x12, 1

    # --- BGEU test: taken and not taken ---
    # Case 1: taken (unsigned x9 >= x8)
    bgeu x9, x8, bgeu_taken
    addi x13, x13, 888      # skipped
bgeu_taken:
    addi x13, x13, 8

    # Case 2: not taken (unsigned x8 < x9)
    bgeu x8, x9, bgeu_not_taken
    addi x14, x14, 9        # executes
bgeu_not_taken:
    addi x14, x14, 1

    ##############################################
    # Small loop using branch (finite, no jumps)
    ##############################################
    li x15, 3               # loop counter = 3
loop_start:
    add x16, x16, x15
    addi x15, x15, -1
    bnez x15, loop_start    # executes 3 iterations

    ##############################################
    # Post-branch arithmetic section
    ##############################################
    add x1, x1, x2
    sub x2, x3, x4
    mul x3, x5, x6
    addi x4, x4, 10
    mul x5, x5, x7
    add x6, x6, x8
    sub x7, x9, x10
    mul x8, x11, x12
    add x9, x13, x14
    add x10, x15, x16
    sub x11, x17, x18
    addi x12, x12, 1
    addi x13, x13, 2
    addi x14, x14, 3
    addi x15, x15, 4
    addi x16, x16, 5
    addi x17, x17, 6
    addi x18, x18, 7
    addi x19, x19, 8
    addi x20, x20, 9

    ##############################################
    # End: verify results and finish
    ##############################################
    add x21, x12, x14       # combine for final check

    nop
    nop
    nop

    slti x0, x0, -256