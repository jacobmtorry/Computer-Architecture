    .section .text
    .globl _start
_start:
    .option norvc

    # Pure jump (no link writeback) to avoid any read-after-write hazards
    jal   x0, PASS

FAIL:
    addi  x31, x0, 1        # fail code
    nop
    nop
    nop
    nop
    nop
    slti  x0,  x0, -256     # stop sim
    nop
    nop
    nop
    nop
    nop
    
PASS:
    addi  x31, x0, 0        # pass code
    nop
    nop
    nop
    nop
    nop
    slti  x0,  x0, -256     # stop sim
    nop
    nop
    nop
    nop
    nop