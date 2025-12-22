    .section .data
value:
    .word 0x12345678          # unused here but kept for consistency

buf0:
    .word 0x00000000          # byte-write region
buf1:
    .word 0x00000000          # halfword-write region
buf2:
    .word 0x00000000          # word-write region

    .section .text
    .globl _start
_start:

    ############################################
    # BYTE STORES (sb) into buf0
    ############################################

    lui     x6, %hi(buf0)
    addi    x6, x6, %lo(buf0)

    li      x7, 0xAA
    sb      x7, 0(x6)

    li      x7, 0xBB
    sb      x7, 1(x6)

    li      x7, 0xCC
    sb      x7, 2(x6)

    li      x7, 0xDD
    sb      x7, 3(x6)

    ############################################
    # HALFWORD STORES (sh) into buf1
    ############################################

    lui     x6, %hi(buf1)
    addi    x6, x6, %lo(buf1)

    li      x7, 0x07EE
    sh      x7, 0(x6)

    li      x7, 0xABCD
    sh      x7, 2(x6)

    ############################################
    # WORD STORE (sw) into buf2
    ############################################

    lui     x6, %hi(buf2)
    addi    x6, x6, %lo(buf2)

    li      x7, 0x12345678
    sw      x7, 0(x6)
    lw      x7, 0(x6)

    li      x7, 0x12345679
    sw      x7, 0(x6)
    lw      x7, 0(x6)

    li      x7, 0x1234a579
    sw      x7, 0(x6)
    lw      x7, 0(x6)

    li      x7, 0xaabaaaba
    sw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x8, 0(x6)
    lw      x9, 0(x6)
    lw      x10, 0(x6)
    lw      x11, 0(x6)

    lw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x7, 0(x6)
    lw      x7, 0(x6)

    lw      x7, 0(x6)         # SECOND-TO-LAST LOAD

    ############################################
    # FINAL LOAD depends on the above x7 value
    ############################################

    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  
    lw      x7, 0(x6)
    sw      x6, 0(x6)
    lw      x7, 0(x6) 
    lw      x8, 0(x7)  

    ############################################
    # End — infinite loop
    ############################################

    slti x0, x0, -256
