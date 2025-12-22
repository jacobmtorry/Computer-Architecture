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
# ===== BRANCH OPERATIONS =====
        # Setup for branch testing
        # Simple forward EX->EX
        addi x1, x0, 4         # x1 = 4
        addi x2, x1, 5         # depends on x1 (RAW hazard) | x1=4 x2=9

        # Forward chain EX->EX->EX
        addi x3, x2, 6         # depends on x2 | x1=4, x2=9, x3=f
        addi x4, x3, 7         # depends on x3 | x1=4, x2=9, x3=f, x4=16
        # Forward MEM->EX
        add  x5, x1, x2        # x1=4, x2=9, x3=f, x4=16, x5=d
        # depends on result of x5 (RAW hazard, one cycle later)
        add  x6, x5, x3        #x1=4, x2=9, x3=f, x4=16, x5=d, x6=1c

        # Forward WB->EX
        # depends on x6 (should come from WB if pipe is 5 stages)
        add  x7, x6, x4        #x1=4, x2=9, x3=f, x4=16, x5=d, x6=1c, x7=32
        

        # Dual-source hazard (both rs1 and rs2)
        add  x8, x7, x6        #x1=4, x2=9, x3=f, x4=16, x5=d, x6=1c, x7=32, x8=4e

        # Load-use hazard (should force a stall if no bypass from memory)
        la   x1, value
        lw   x9, 0(x1)         # load from memory
        addi x10, x9, 1        # must stall one cycle if only regfile WB is valid
    
        # Zero register (no forwarding should happen)
       addi x0, x1, 99        # should be ignored (x0 stays 0)
       add  x11, x0, x1       # x11 = 4


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

    # ===== COMPLETE JAL / JALR TESTS =====

    # --- JAL Forward Jump ---
    jal x25, jal_target1       # x25 = PC + 4
    nop
    nop
    nop
    nop
    nop

    # Skipped instruction
    addi x26, x0, 333          # should not execute
    nop
    nop
    nop
    nop
    nop

jal_target1:
    addi x27, x0, 7            # executes
    nop
    nop
    nop
    nop
    nop

    # --- JAL Backward Jump (bounded) ---
    addi x1, x0, 1000            # set counter = 5
loop_start:
    addi x1, x1, -1           # decrement
    jal x0, loop_body         # jump into loop body without link
    nop

loop_body:
    bnez x1, loop_start       # repeat if not zero
    # exits when x1 == 0


    # --- JAL with negative small offset ---
    addi x2, x0, 100
    jal x3, jal_back
    addi x2, x2, 111           # skipped

jal_back:
    addi x4, x0, 55            # executes
    nop
    nop
    nop
    nop
    nop

    # --- JALR Forward Jump via Register ---
    la   x5, jalr_target2
    jalr x6, 0(x5)             # x6 = PC + 4, jump to target
    addi x7, x0, 77            # skipped

jalr_target2:
    addi x8, x0, 88            # executes
    nop
    nop
    nop
    nop
    nop

    # --- JALR Forward with Offset ---
    la   x9, jalr_target3
    jalr x10, 8(x9)            # jumps past first instruction in target
    addi x11, x0, 123          # skipped

jalr_target3:
    nop
    addi x12, x0, 99           # executes if offset works
    nop
    nop
    nop
    nop
    nop

    # --- JALR Odd Address LSB Masking ---
    la   x13, jalr_odd
    addi x13, x13, 1           # make it odd
    jalr x14, 0(x13)           # should jump to jalr_odd (LSB masked)
    addi x15, x0, 123          # skipped

jalr_odd:
    addi x16, x0, 99           # executes
    nop
    nop
    nop
    nop
    nop

    # --- JALR to Same Register (link register = target register) ---
    la   x17, jalr_self
    jalr x17, 0(x17)           # x17 = PC + 4, jump to same address
    addi x18, x0, 111          # skipped

jalr_self:
    addi x19, x0, 222          # executes

    # --- Chained Jumps (JAL -> JALR -> JAL) ---
    jal x20, jal_chain1
    addi x21, x0, 333          # skipped

jal_chain1:
    la x22, jal_chain2
    jalr x23, 0(x22)
    addi x24, x0, 444          # skipped

jal_chain2:
    jal x25, jal_chain3
    addi x26, x0, 555          # skipped

jal_chain3:
    addi x27, x0, 666          # executes


    slti x0, x0, -256 # this is the magic instruction to end the simulation
    nop               # preventing fetching illegal instructions
    nop
    nop
    nop
    nop