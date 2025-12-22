.section .text
.globl _start
_start:
# ===== BRANCH OPERATIONS =====
        # Setup for branch testing
        addi x10, x0, 5     # x10 = 5
        nop
        nop
        nop
        nop
        nop
        addi x11, x0, 10    # x11 = 10
        nop
        nop
        nop
        nop
        nop
        addi x12, x0, 5     # x12 = 5
        nop
        nop
        nop
        nop
        nop

        # BEQ - branch if equal
        beq x10, x12, branch_target1
        nop
        nop
        nop
        nop
        nop
        
        # This should not execute
        addi x13, x0, 999   # x13 = 999 (should not execute)
        nop
        nop
        nop
        nop
        nop

    branch_target1:
        addi x14, x0, 1     # x14 = 1 (branch target)
        nop
        nop
        nop
        nop
        nop

        # BNE - branch if not equal
        bne x10, x11, branch_target2
        nop
        nop
        nop
        nop
        nop
        
        # This should not execute
        addi x15, x0, 888   # x15 = 888 (should not execute)
        nop
        nop
        nop
        nop
        nop

    branch_target2:
        addi x16, x0, 2     # x16 = 2 (branch target)
        nop
        nop
        nop
        nop
        nop

        # BLT - branch if less than (signed)
        blt x10, x11, branch_target3
        nop
        nop
        nop
        nop
        nop
        
        # This should not execute
        addi x17, x0, 777   # x17 = 777 (should not execute)
        nop
        nop
        nop
        nop
        nop

    branch_target3:
        addi x18, x0, 3     # x18 = 3 (branch target)
        nop
        nop
        nop
        nop
        nop

        # BGE - branch if greater than or equal (signed)
        bge x11, x10, branch_target4
        nop
        nop
        nop
        nop
        nop
        
        # This should not execute
        addi x19, x0, 666   # x19 = 666 (should not execute)
        nop
        nop
        nop
        nop
        nop

    branch_target4:
        addi x20, x0, 4     # x20 = 4 (branch target)
        nop
        nop
        nop
        nop
        nop

        # BLTU - branch if less than (unsigned)
        bltu x10, x11, branch_target5
        nop
        nop
        nop
        nop
        nop
        
        # This should not execute
        addi x21, x0, 555   # x21 = 555 (should not execute)
        nop
        nop
        nop
        nop
        nop

    branch_target5:
        addi x22, x0, 5     # x22 = 5 (branch target)
        nop
        nop
        nop
        nop
        nop

        # BGEU - branch if greater than or equal (unsigned)
        bgeu x11, x10, branch_target6
        nop
        nop
        nop
        nop
        nop
        
        # This should not execute
        addi x23, x0, 444   # x23 = 444 (should not execute)
        nop
        nop
        nop
        nop
        nop

    branch_target6:
        addi x24, x0, 6     # x24 = 6 (branch target)
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
