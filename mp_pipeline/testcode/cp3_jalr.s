.section .text
.globl _start
_start:
  .option norvc


    

  # Produce x1 = &After (link) using JAL
  jal   x1, L1

After:
  addi  x31, x0, 4        # PASS
  nop
  nop
  nop
  nop
  nop
  slti  x0,  x0, -256      # stop
  nop
  nop
  nop
  nop
  nop

L1:
  # ---- distance to avoid RAW hazard on x1 ----
  addi  x2,  x2, 0         # filler 1 (independent)
  nop
  nop
  nop
  nop
  nop
  addi  x3,  x3, 0         # filler 2 (independent)
  nop
  nop
  nop
  nop
  nop

  # Now safe to consume x1
  jalr  x0,  x1, 0         # jump back to After
  addi  x31, x0, 1         # FAIL if we didn't jump
  nop
  nop
  nop
  nop
  nop
  slti  x0,  x0, -256
  nop
  nop
  nop
  nop
  nop
