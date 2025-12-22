    .option norvc
    .option norelax          # keep AUIPC+ADDI as-is (no linker relax)
    .section .text
    .globl _start
_start:
	auipc x13, 0                    # x13 = PC of this AUIPC
    lw    x13, 0(x13)               # aligned word load
    add  x13, x13, x0       # x13 = &mydata (small, assembler-computed const)
    addi  x5,  x13, 1               # consume loaded value immediately (load-use)
    slti  x0,  x0, -256             # magic stop for your TB

    .balign 4                       # ensure word alignment

