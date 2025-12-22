    .section .text
    .globl _start

_start:
    #############################################
    # 1. Setup registers
    #############################################
    lui x1, 0x11111
    lui x2, 0x22222
    lui x3, 0x33333
    lui x4, 0x44444
    lui x5, 0x55555

    #############################################
    # 2. AUIPC sets x3 to current PC
    #############################################
    auipc x3, 0          # x3 = PC (call this P0)

    #############################################
    # 3. A block of fixed-size instructions (padding)
    #    We know the exact offset from P0 → target
    #    below. We will place target exactly 32 bytes
    #    from the AUIPC instruction.
    #############################################

    nop                  # +4 = 4
    nop                  # +4 = 8
    nop                  # +4 = 12
    nop                  # +4 = 16
    nop                  # +4 = 20
    nop                  # +4 = 24
    nop                  # +4 = 28

    # Now 28 bytes have passed.
    # We want target at +32 bytes, so addi x3, x3, 32.
    addi x3, x3, 32      # +4 = 32 bytes from AUIPC to target

    #############################################
    # 4. Now JALR should land exactly at L_target
    #############################################
    jalr x5, 0(x3)

    # If we land here, JALR failed
    j fail


#############################################
# 5. Target located exactly +32 bytes ahead
#############################################
L_target:
    nop
    nop
    nop

    # Magic halt instruction (illegal ==> PASS)
    slti x0, x0, -256
    nop
    nop


#############################################
fail:
    j fail
