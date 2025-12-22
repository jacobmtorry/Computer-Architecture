    .text
    .globl _start
_start:
    addi x1, x0, 1
    addi x2, x0, 2
    addi x3, x0, 3
    addi x4, x0, 4
    addi x5, x0, 5
    addi x6, x0, 6
    addi x7, x0, 7
    addi x8, x0, 8
    addi x11, x0, 11
    addi x12, x0, 12
    addi x13, x0, 13
    addi x14, x0, 14
    addi x15, x0, 15

    addi x9, x0, 9
    addi x10, x9, 1

    li x1, 2
    li x2, 3
    mul x3, x1, x2         # 2 * 3 = 6
    # Expected: x3 = 6
    
    slti x0, x0, -256
