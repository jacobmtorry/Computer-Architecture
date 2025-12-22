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
    addi x27, x27, -1       # subtract 1
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
    add x1, x1, x2
    mul x3, x4, x5
    addi x29, x29, 1
    add x6, x6, x7
    sub x8, x8, x9
    mul x10, x10, x11
    addi x12, x12, 1
    bltu x29, x30, bltu_loop
    add x13, x13, x14
    sub x15, x15, x16
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
    addi x29, x29, -1       # subtract 1
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

    # -------------------------------------------------------------
    # EXTRA BRANCH TESTS (no loads/stores, no infinite loops)
    # -------------------------------------------------------------

    # --- BEQ forward: not taken, then taken ---
    # First: x5 != x6 => BEQ not taken
    li   x5, 1
    li   x6, 2
    beq  x5, x6, beq_nt_target      # NOT taken
    addi x7, x7, 1                  # executes
    beq  x0, x0, beq_nt_join        # unconditional forward branch
beq_nt_target:
    addi x7, x7, 2                  # would run if BEQ taken
beq_nt_join:

    # Second: x5 == x6 => BEQ taken
    li   x5, 3
    li   x6, 3
    beq  x5, x6, beq_t_target       # taken
    addi x7, x7, 4                  # skipped
beq_t_target:
    addi x7, x7, 8                  # executes

    # --- BNE forward: taken and not taken ---
    li   x5, 10
    li   x6, 20
    bne  x5, x6, bne_t_target       # taken
    addi x8, x8, 1                  # skipped
bne_t_target:
    addi x8, x8, 2                  # executes

    li   x5, 30
    li   x6, 30
    bne  x5, x6, bne_nt_target      # NOT taken
    addi x8, x8, 3                  # executes
bne_nt_target:

    # --- BLT forward with positive values (taken & not taken) ---
    li   x5, 1
    li   x6, 5
    blt  x5, x6, blt_t_target       # taken (1 < 5)
    addi x9, x9, 1                  # skipped
blt_t_target:
    addi x9, x9, 2                  # executes

    li   x5, 7
    li   x6, 2
    blt  x5, x6, blt_nt_target      # NOT taken (7 !< 2)
    addi x9, x9, 3                  # executes
blt_nt_target:

    # --- BGE forward with zero/positive (taken & not taken) ---
    li   x5, 0
    li   x6, 0
    bge  x5, x6, bge_t_target0      # taken (0 >= 0)
    addi x10, x10, 1                # skipped
bge_t_target0:
    addi x10, x10, 2                # executes

    li   x5, -1
    li   x6, 5
    bge  x5, x6, bge_nt_target      # NOT taken (-1 !>= 5)
    addi x10, x10, 3                # executes
bge_nt_target:

    # --- Signed vs Unsigned behavior with negative numbers ---
    # x5 = -1 (0xFFFF...); x6 = 1
    li   x5, -1
    li   x6, 1

    # Signed: -1 < 1 => BLT taken
    blt  x5, x6, signed_lt_taken
    addi x11, x11, 10               # skipped
signed_lt_taken:
    addi x11, x11, 20               # executes

    # Unsigned: 0xFFFF... < 1 ? NO => BLTU not taken
    bltu x5, x6, unsigned_lt_taken  # NOT taken
    addi x12, x12, 30               # executes
    beq  x0, x0, unsigned_lt_join   # unconditional forward
unsigned_lt_taken:
    addi x12, x12, 40               # would execute if taken
unsigned_lt_join:

    # Unsigned: 0xFFFF... >= 1 => BGEU taken
    bgeu x5, x6, unsigned_geu_taken # taken
    addi x13, x13, 50               # skipped
unsigned_geu_taken:
    addi x13, x13, 60               # executes

    # Signed: -1 >= 1 ? NO => BGE not taken
    bge  x5, x6, signed_ge_taken    # NOT taken
    addi x14, x14, 70               # executes
signed_ge_taken:

    # --- Branches involving x0 directly ---
    # BEQ with x0: always taken
    beq  x0, x0, always_taken_label
    addi x15, x15, 1                # skipped
always_taken_label:
    addi x15, x15, 2                # executes

    # BNE with x0: never taken
    bne  x0, x0, never_taken_label
    addi x16, x16, 3                # executes
never_taken_label:

    # BLT with x0: 0 < 1 => taken
    li   x17, 1
    blt  x0, x17, x0_blt_taken
    addi x18, x18, 1                # skipped
x0_blt_taken:
    addi x18, x18, 2                # executes

    # BGEU with x0: 0 >= 1 ? no => not taken
    bgeu x0, x17, x0_bgeu_taken     # NOT taken
    addi x19, x19, 1                # executes
x0_bgeu_taken:

    # -------------------------------------------------------------
    # M-EXT: MULTIPLY / DIVIDE / REM TESTS (straight-line)
    # -------------------------------------------------------------
    li x5,  12345
    li x6, -6789
    li x7,  100
    li x8,  7
    li x9,  0x7FFFFFFF
    li x10, 0x80000000

    # Basic mul variants
    mul    x11, x5, x7       # 12345 * 100
    mulh   x12, x5, x6       # high signed
    mulhsu x13, x6, x7       # high signed x6, unsigned x7
    mulhu  x14, x9, x7       # high unsigned

    # Signed/unsigned divide/rem, non-zero divisors
    div    x15, x6, x8       # -6789 / 7
    rem    x16, x6, x8       # -6789 % 7
    divu   x17, x9, x7       # 0x7fffffff / 100
    remu   x18, x9, x7       # 0x7fffffff % 100

    # Division with negative divisor
    div    x19, x5, x6
    rem    x20, x5, x6

    # Some mixing with branches so results aren’t optimized out easily
    li     x21, 0
    beq    x15, x15, mext_branch_ok
    addi   x21, x21, 1       # skipped
mext_branch_ok:
    add    x22, x11, x17
    sub    x23, x18, x16
    add    x24, x19, x20

    # -------------------------------------------------------------
    # LOOPED M-EXT TESTS WITH BRANCHES
    # -------------------------------------------------------------
    # Loop 10 times, using div/rem each iteration
    li x25, 0          # i = 0
    li x26, 10         # limit = 10
    li x27, 1          # accumulators
    li x28, 2
mext_loop:
    addi x25, x25, 1       # i++
    add  x27, x27, x25     # x27 += i
    mul  x28, x28, x25     # x28 *= i (grows quickly)
    div  x11, x28, x25     # safe: i != 0
    rem  x12, x28, x25     # remainder should be 0
    add  x13, x13, x11
    add  x14, x14, x12
    blt  x25, x26, mext_loop

    # After loop, some branches based on results
    bne  x12, x0, mext_post_not_zero
    addi x15, x15, 1       # executes if x12 == 0
mext_post_not_zero:
    bge  x27, x26, mext_post_ge
    addi x16, x16, 2       # skipped (x27 definitely >= 10 here)
mext_post_ge:

    # -------------------------------------------------------------
    # NESTED LOOPS STRESSING BRANCHES + M-EXT
    # -------------------------------------------------------------
    # Outer loop: 3 iterations
    # Inner loop: 4 iterations
    li x5,  3       # outer count
    li x6,  0       # outer index
    li x7,  4       # inner limit
    li x8,  0       # inner index
    li x9,  1       # multiplicative accumulator
    li x10, 0       # additive accumulator

outer_loop:
    li   x8, 0              # reset inner index
inner_loop:
    addi x8, x8, 1
    add  x10, x10, x8       # sum inner indices
    mul  x9,  x9,  x8       # multiply by index
    divu x11, x9,  x8       # safe: x8 != 0
    remu x12, x9,  x8       # always 0 if exact
    blt  x8, x7, inner_loop

    addi x6, x6, 1          # outer index++
    blt  x6, x5, outer_loop

    # Post nested loops checks
    bge  x10, x0, nested_nonneg
    addi x13, x13, 10       # skipped
nested_nonneg:
    beq  x12, x0, nested_zero_rem
    addi x14, x14, 20       # skipped (rem was 0 in loop)
nested_zero_rem:
    addi x14, x14, 1

    # -------------------------------------------------------------
    # BRANCH PATTERN WALL – MANY SMALL LOOPS
    # -------------------------------------------------------------
    # Loop with BEQ as loop condition
    li x5, 0
    li x6, 5
beq_small_loop:
    addi x5, x5, 1
    add  x1, x1, x5
    mul  x2, x2, x5
    sub  x3, x3, x5
    beq  x5, x6, beq_small_done
    beq  x0, x0, beq_small_loop
beq_small_done:

    # Loop with BNE as loop condition
    li x7, 0
    li x8, 5
bne_small_loop:
    addi x7, x7, 1
    add  x4, x4, x7
    mul  x5, x5, x7
    div  x6, x5, x7      # safe: x7 != 0
    bne  x7, x8, bne_small_loop

    # Loop with BLT as loop condition
    li x9, 0
    li x10, 4
blt_small_loop:
    addi x9, x9, 1
    mul  x11, x9, x9
    add  x12, x12, x11
    blt  x9, x10, blt_small_loop

    # Loop with BGE as loop condition (count down)
    li x13, 5
    li x14, 0
bge_small_loop:
    add  x14, x14, x13
    mul  x15, x14, x13
    addi x13, x13, -1
    bge  x13, x0, bge_small_loop

    # Loop with BLTU / BGEU as condition, treating counts as unsigned
    li x16, 0
    li x17, 6
bltu_small_loop:
    addi x16, x16, 1
    add  x18, x18, x16
    mul  x19, x18, x16
    bltu x16, x17, bltu_small_loop

    li x20, 6
    li x21, 2
bgeu_small_loop:
    add  x21, x21, x20
    mul  x22, x21, x20
    addi x20, x20, -1

    # -------------------------------------------------------------
    # SIGNED vs UNSIGNED DIV/REM WITH BRANCHES
    # -------------------------------------------------------------
    li x5,  -100
    li x6,   7
    li x7,  100
    li x8,   7

    div   x9,  x5, x6   # signed
    rem   x10, x5, x6
    divu  x11, x7, x8   # unsigned
    remu  x12, x7, x8

    blt   x9, x0, signed_div_neg
    addi  x13, x13, 1   # skipped
signed_div_neg:
    bge   x11, x0, unsigned_div_nonneg
    addi  x14, x14, 2   # skipped
unsigned_div_nonneg:

    bne   x10, x0, signed_rem_nonzero
    addi  x15, x15, 1   # executes if rem = 0
signed_rem_nonzero:

    beq   x12, x0, unsigned_rem_zero
    addi  x16, x16, 3   # skipped
unsigned_rem_zero:
    addi  x16, x16, 4

    # -------------------------------------------------------------
    # LARGE COUNT LOOP MIXING EVERYTHING, BUT BOUNDED
    # -------------------------------------------------------------
    # 20-iteration loop with all branch types used in body
    li x5,  0      # i
    li x6,  20     # limit
    li x7,  1      # mul_acc
    li x8,  0      # add_acc
    li x9,  0xFFFFFFFF  # unsigned big
    li x10, 0      # temp

large_mix_loop:
    addi x5, x5, 1       # i++
    add  x8, x8, x5      # sum
    mul  x7, x7, x5      # product (will overflow, fine)
    divu x10, x9, x5     # safe: i != 0
    remu x11, x9, x5
    add  x12, x12, x10
    add  x13, x13, x11

    # BEQ / BNE: even/odd i
    andi x14, x5, 1
    beq  x14, x0, large_even
    addi x15, x15, 1      # odd path
    beq  x0, x0, large_even_join
large_even:
    addi x16, x16, 2      # even path
large_even_join:

    # BLT / BGE: compare i with 10
    li   x17, 10
    blt  x5, x17, large_lt_10
    addi x18, x18, 3      # i >= 10
    beq  x0, x0, large_cmp_join
large_lt_10:
    addi x19, x19, 4      # i < 10
large_cmp_join:

    # BLTU / BGEU: treat i as unsigned vs 15
    li   x20, 15
    bltu x5, x20, large_ult_15
    addi x21, x21, 5      # i >= 15 (unsigned)
    beq  x0, x0, large_u_cmp_join
large_ult_15:
    addi x22, x22, 6      # i < 15 (unsigned)
large_u_cmp_join:

    blt  x5, x6, large_mix_loop

    # -------------------------------------------------------------
    # DEEP BRANCH CHAINS (forward-only, no loops)
    # -------------------------------------------------------------
    li x5,  3
    li x6,  3
    li x7,  4
    li x8,  5

    beq  x5, x6, chain_eq_1
    addi x9, x9, 1        # skipped
chain_eq_1:
    bne  x5, x7, chain_ne_1
    addi x10, x10, 1      # skipped
chain_ne_1:
    blt  x5, x7, chain_lt_1
    addi x11, x11, 1      # skipped
chain_lt_1:
    bge  x7, x5, chain_ge_1
    addi x12, x12, 1      # skipped
chain_ge_1:
    bltu x5, x8, chain_ltu_1
    addi x13, x13, 1      # skipped
chain_ltu_1:
    bgeu x8, x5, chain_geu_1
    addi x14, x14, 1      # skipped
chain_geu_1:
    addi x15, x15, 7

    # Another chain with different comparisons
    li x16, -5
    li x17, -10
    li x18, 0xFFFFFFF0
    li x19, 0x0000000F

    blt  x17, x16, chain2_lt   # -10 < -5 => taken
    addi x20, x20, 1           # skipped
chain2_lt:
    bge  x16, x17, chain2_ge   # -5 >= -10 => taken
    addi x21, x21, 1           # skipped
chain2_ge:
    bltu x19, x18, chain2_ltu  # 0x0F < 0xFFFFFFF0 => taken
    addi x22, x22, 1           # skipped
chain2_ltu:
    bgeu x18, x19, chain2_geu  # unsigned: F0.. >= 0F => taken
    addi x23, x23, 1           # skipped
chain2_geu:
    addi x24, x24, 9

    # -------------------------------------------------------------
    # FINAL SMALL M-EXT VALIDATION LOOPS
    # -------------------------------------------------------------
    # Loop 5 times, using mul/mulh/mulhu each time
    li x5, 0
    li x6, 5
    li x7, -1234
    li x8,  5678
    li x9,  0

mext_val_loop:
    addi x5, x5, 1
    mul    x10, x7, x5
    mulh   x11, x7, x8
    mulhu  x12, x7, x8
    add    x9, x9, x10
    blt    x5, x6, mext_val_loop

    # Div/rem loop with changing divisor, 6 iterations
    li x13, 1          # divisor
    li x14, 6          # limit
    li x15, 0          # i
    li x16, 123456789  # dividend-ish (will wrap)

div_val_loop:
    addi x15, x15, 1
    addi x13, x13, 1      # divisor++
    div   x17, x16, x13
    rem   x18, x16, x13
    divu  x19, x16, x13
    remu  x20, x16, x13
    add   x21, x21, x17
    add   x22, x22, x18
    add   x23, x23, x19
    add   x24, x24, x20
    blt   x15, x14, div_val_loop

    # Some final branches checking signs / zero
    blt   x17, x0, div_final_neg
    addi  x25, x25, 1
div_final_neg:
    beq   x18, x0, div_final_zero_rem
    addi  x26, x26, 2
div_final_zero_rem:
    bgeu  x19, x0, div_final_nonneg_u
    addi  x27, x27, 3     # skipped
div_final_nonneg_u:
    bne   x20, x0, div_final_nonzero_u
    addi  x28, x28, 4
div_final_nonzero_u:
    addi  x28, x28, 5
    addi x12, x0, 12
    addi x13, x0, 13
    addi x14, x0, 14
    addi x15, x0, 15
    addi x9, x0, 9
    addi x10, x9, 1
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3 
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
    addi x1,  x0,  5      
    addi x2,  x1,  3      
    li   x3, 10            
    addi x4, x3, -7        
    li   x5, -123          
    addi x6, x5, 0         
    li   x7, 100
    addi x0, x7, 50        
    addi x8, x0, 42        
    addi x9, x0, -1        
    li   x10, 0x00001000   
    addi x11, x10, 2047    
    li   x12, 0x00001000   
    addi x13, x12, -2048   
    li   x14, 1
    addi x15, x14, -1      
    li   x16, 0
    addi x17, x16, -2048   
    li   x18, 200
    addi x18, x18, 55      
    li   x19, 0x7FFFFFF0
    addi x20, x19, 0x100   
    li   x21, 0x80000000   
    addi x22, x21, -1      
    addi x23, x0, 1        
    addi x24, x23, 1       
    addi x25, x24, 1       
    li   x29, 0x7          
    addi x30, x29, -1      
    li   x1, 0x40000000     
    addi x2, x1, 0x400      
    addi x2, x2, 0x400      
    addi x2, x2, 0x400      
    li   x5, 1234
    addi x6, x5, 10        
    li   x31, 0x7FFFFFFF
    addi x1, x31, -2048     
    addi x2, x2, 0        
    addi x3, x3, 0        
    li   x1, 0x0F0F0F0F
    xori x2, x1, 0x00FF       
    li   x3, 0x12345678
    xori x4, x3, 0
    li   x5, 0xAAAAAAAA
    xori x6, x5, -1
    li   x7, 0x00000FFF
    xori x8, x7, -2048
    li   x9, 0xFFFFF000
    xori x10, x9, 2047
    xori x11, x0, 0x7F
    xori x12, x0, -1
    li   x13, 0x55555555
    xori x0, x13, 0x2AA
    li   x14, 0x0F0F0F0F
    xori x14, x14, 0x00F0
    li   x15, 0xAAAAAAAA
    xori x16, x15, 0x555
    li   x17, 0x55555555
    xori x18, x17, 0x2AA
    li   x19, 0x12345678
    xori x20, x19, -1
    li   x21, 0xAAAAAAAA
    xori x22, x21, 0x555
    xori x23, x22, 0x3AA
    xori x24, x0, -2048
    li   x25, 0x80000000
    xori x26, x25, 0x7FF
    li   x27, 0x7FFFFFFF
    xori x28, x27, -1
    li   x29, 0x0000F0F0
    xori x30, x29, 0x0F0
    li   x31, 0x00000001
    xori x1, x31, 0x700     
    li   x2, 0x12345678
    xori x2, x2, 0x7FF
    li   x3, 0xDEADBEEF
    xori x4, x3, 0x3AD
    li   x5, 0xCAFEBABE
    xori x6, x5, -512
    li   x7, 0xABCDABCD
    xori x8, x7, 1
    li   x9, 0x00000001
    xori x10, x9, -2
    li x1, 0x00000000
    ori x2, x1, 0x0
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x0
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x700
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x000
    li x1, 0x00000000
    ori x2, x1, -1
    li x1, 0x12345678
    ori x2, x1, -1
    li x1, 0x80000000
    ori x2, x1, -2048
    li x1, 0x0000F0F0
    ori x2, x1, 0x00F
    li x1, 0xFFFF0000
    ori x2, x1, 0x123
    li x1, 0xDEADBEEF
    ori x2, x1, 0x0AA
    li x1, 0x00001234
    ori x2, x1, 0x7FF
    li x1, 0x7FFFFFFF
    ori x2, x1, 0x001
    li x1, 0x80000000
    ori x2, x1, 0x7FF
    li x1, 0x80000000
    ori x2, x1, 0x700
    ori x0, x1, 0x7FF
    li x1, 0x0000000F
    ori x2, x1, 0x0F0
    ori x3, x2, 0x700
    ori x4, x3, -1
    li x1, 0x00000000
    andi x2, x1, 0x0
    li x1, 0x00000000
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x700
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xAAAAAAAA
    andi x2, x1, 0x555
    li x1, 0x55555555
    andi x2, x1, 0x7AA
    li x1, 0x12345678
    andi x2, x1, 0x7FF
    li x1, 0x12345678
    andi x2, x1, 0x000
    li x1, 0x0000FFFF
    andi x2, x1, -1
    li x1, 0x0000FFFF
    andi x2, x1, -2048
    li x1, 0xF0F0F0F0
    andi x2, x1, -1
    li x1, 0xDEADBEEF
    andi x2, x1, 0x0AA
    li x1, 0x7FFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x700
    andi x0, x1, 0x7F
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0FF
    andi x2, x2, 0x00F
    andi x2, x2, -1
    andi x2, x2, 0x000
    li x1, 0x00000000
    slli x2, x1, 5
    li x1, 0xFFFFFFFF
    slli x2, x1, 0
    li x1, 0xFFFFFFFF
    slli x2, x1, 1
    li x1, 0xFFFFFFFF
    slli x2, x1, 31
    li x1, 0x00FF00FF
    slli x2, x1, 8
    li x1, 0x0F0F0F0F
    slli x2, x1, 4
    li x1, 0x40000000
    slli x2, x1, 1
    li x1, 0x40000000
    slli x2, x1, 2
    li x1, 0xAAAAAAAA
    slli x2, x1, 1
    li x1, 0x55555555
    slli x2, x1, 1
    li x1, 0x00000001
    slli x2, x1, 31
    li x1, 0x00000003
    slli x2, x1, 5
    li x1, 0x00000003
    slli x2, x1, 31
    li x1, 0xFFFFFFFF
    slli x0, x1, 4
    li x1, 0x00000001
    slli x2, x1, 1
    slli x2, x2, 1
    slli x2, x2, 2
    slli x2, x2, 3
    li x1, 0x80000000
    srli x2, x1, 1
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0xAAAAAAAA
    srli x2, x1, 1
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    li x1, 0xF0000000
    srli x2, x1, 4
    li x1, 0x80000000
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 4
    li x1, 0xF000000F
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 16
    li x1, 0xF000000F
    srli x2, x1, 24
    li x1, 0xFFFFFFFF
    srli x0, x1, 8
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    srli x2, x2, 1
    srli x2, x2, 2
    srli x2, x2, 3
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0x12345678
    srai x2, x1, 0
    li x1, 0x7FFFFFFF
    srai x2, x1, 31
    li x1, -1024               
    srai x2, x1, 0             
    srai x3, x1, 4
    srai x4, x1, 8
    srai x5, x1, 10
    li x1, 0x00000F00
    srai x2, x1, 4
    li x1, -0x00000F00
    srai x2, x1, 4
    li x1, 0xFFFFFFFF          
    srai x2, x1, 1
    li x1, 0x80000001
    srai x2, x1, 1
    li x10, 0xFFFFFFF0
    li x11, 2
    srai x12, x10, 1
    srai x13, x10, 4
    li x5, -64
    srai x5, x5, 1
    srai x5, x5, 1
    srai x5, x5, 2
    li x1, 0x7FFFFFFF
    .word 0x4070D093  
    li x1, 5
    slti x2, x1, 10
    li x1, -10
    slti x2, x1, -5
    li x1, -1
    slti x2, x1, 1
    li x1, 1
    slti x2, x1, -1
    li x1, 0x7FFFFFFF          
    slti x2, x1, 0x7FF
    li x1, 0
    slti x2, x1, -1
    li x1, 0x00001000
    slti x2, x1, -1
    li x1, -4096
    slti x2, x1, -1
    li x1, -2
    slti x2, x1, -2
    li x1, -3
    slti x2, x1, -2
    li x5, 3
    slti x5, x5, 10     
    slti x5, x5, 1      
    slti x5, x5, 2      
    li x10, -128
    slti x11, x10, -127
    slti x12, x11, 0
    li x13, 127
    slti x14, x13, 128
    li x1, 5
    sltiu x2, x1, 10
    li x1, 10
    sltiu x2, x1, 10
    li x1, 0
    sltiu x2, x1, 0
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFF
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFE
    li x1, 0x80000000
    sltiu x2, x1, 0x7FF
    li x1, 0x80000000
    sltiu x2, x1, 0xFFFFFFFF
    li x5, 3
    sltiu x5, x5, 10     
    sltiu x5, x5, 1      
    sltiu x5, x5, 2      
    li x1, 12345
    sltiu x0, x1, 100
    li x1, 0x0000FFFF
    sltiu x2, x1, 0x100
    li x1, 0x00010000
    sltiu x2, x1, 0x7FF
lui x1, 0x00000
lui x2, 0x00001
lui x3, 0x000AB
lui x4, 0xABCDE
lui x5, 0x80000
lui x6, 0xFFFFF
lui x7, 0x7FFFF
lui x0, 0x12345
lui x9, 0xABCDF
lui x11, 0x00000
lui x12, 0x7FFFF
lui x13, 0x80000
lui x14, 0xFFFFF
lui x15, 0x00010
addi x15, x15, 0x123
lui x16, 0xABCDE
addi x16, x16, -1
lui x17, 0xFFFFF
addi x17, x17, -2048
lui x18, 0x7FFFF
lui x19, 0x80000
    addi x6, x5, 10        
    li   x31, 0x7FFFFFFF
    addi x1, x31, -2048     
    addi x2, x2, 0        
    addi x3, x3, 0        
    li   x1, 0x0F0F0F0F
    xori x2, x1, 0x00FF       
    li   x3, 0x12345678
    xori x4, x3, 0
    li   x5, 0xAAAAAAAA
    xori x6, x5, -1
    li   x7, 0x00000FFF
    xori x8, x7, -2048
    li   x9, 0xFFFFF000
    xori x10, x9, 2047
    xori x11, x0, 0x7F
    xori x12, x0, -1
    li   x13, 0x55555555
    xori x0, x13, 0x2AA
    li   x14, 0x0F0F0F0F
    xori x14, x14, 0x00F0
    li   x15, 0xAAAAAAAA
    xori x16, x15, 0x555
    li   x17, 0x55555555
    xori x18, x17, 0x2AA
    li   x19, 0x12345678
    xori x20, x19, -1
    li   x21, 0xAAAAAAAA
    xori x22, x21, 0x555
    xori x23, x22, 0x3AA
    xori x24, x0, -2048
    li   x25, 0x80000000
    xori x26, x25, 0x7FF
    li   x27, 0x7FFFFFFF
    xori x28, x27, -1
    li   x29, 0x0000F0F0
    xori x30, x29, 0x0F0
    li   x31, 0x00000001
    xori x1, x31, 0x700     
    li   x2, 0x12345678
    xori x2, x2, 0x7FF
    li   x3, 0xDEADBEEF
    xori x4, x3, 0x3AD
    li   x5, 0xCAFEBABE
    xori x6, x5, -512
    li   x7, 0xABCDABCD
    xori x8, x7, 1
    li   x9, 0x00000001
    xori x10, x9, -2
    li x1, 0x00000000
    ori x2, x1, 0x0
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x0
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x700
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x000
    li x1, 0x00000000
    ori x2, x1, -1
    li x1, 0x12345678
    ori x2, x1, -1
    li x1, 0x80000000
    ori x2, x1, -2048
    li x1, 0x0000F0F0
    ori x2, x1, 0x00F
    li x1, 0xFFFF0000
    ori x2, x1, 0x123
    li x1, 0xDEADBEEF
    ori x2, x1, 0x0AA
    li x1, 0x00001234
    ori x2, x1, 0x7FF
    li x1, 0x7FFFFFFF
    ori x2, x1, 0x001
    li x1, 0x80000000
    ori x2, x1, 0x7FF
    li x1, 0x80000000
    ori x2, x1, 0x700
    ori x0, x1, 0x7FF
    li x1, 0x0000000F
    ori x2, x1, 0x0F0
    ori x3, x2, 0x700
    ori x4, x3, -1
    li x1, 0x00000000
    andi x2, x1, 0x0
    li x1, 0x00000000
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x700
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xAAAAAAAA
    andi x2, x1, 0x555
    li x1, 0x55555555
    andi x2, x1, 0x7AA
    li x1, 0x12345678
    andi x2, x1, 0x7FF
    li x1, 0x12345678
    andi x2, x1, 0x000
    li x1, 0x0000FFFF
    andi x2, x1, -1
    li x1, 0x0000FFFF
    andi x2, x1, -2048
    li x1, 0xF0F0F0F0
    andi x2, x1, -1
    li x1, 0xDEADBEEF
    andi x2, x1, 0x0AA
    li x1, 0x7FFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x700
    andi x0, x1, 0x7F
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0FF
    andi x2, x2, 0x00F
    andi x2, x2, -1
    andi x2, x2, 0x000
    li x1, 0x00000000
    slli x2, x1, 5
    li x1, 0xFFFFFFFF
    slli x2, x1, 0
    li x1, 0xFFFFFFFF
    slli x2, x1, 1
    li x1, 0xFFFFFFFF
    slli x2, x1, 31
    li x1, 0x00FF00FF
    slli x2, x1, 8
    li x1, 0x0F0F0F0F
    slli x2, x1, 4
    li x1, 0x40000000
    slli x2, x1, 1
    li x1, 0x40000000
    slli x2, x1, 2
    li x1, 0xAAAAAAAA
    slli x2, x1, 1
    li x1, 0x55555555
    slli x2, x1, 1
    li x1, 0x00000001
    slli x2, x1, 31
    li x1, 0x00000003
    slli x2, x1, 5
    li x1, 0x00000003
    slli x2, x1, 31
    li x1, 0xFFFFFFFF
    slli x0, x1, 4
    li x1, 0x00000001
    slli x2, x1, 1
    slli x2, x2, 1
    slli x2, x2, 2
    slli x2, x2, 3
    li x1, 0x80000000
    srli x2, x1, 1
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0xAAAAAAAA
    srli x2, x1, 1
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    li x1, 0xF0000000
    srli x2, x1, 4
    li x1, 0x80000000
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 4
    li x1, 0xF000000F
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 16
    li x1, 0xF000000F
    srli x2, x1, 24
    li x1, 0xFFFFFFFF
    srli x0, x1, 8
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    srli x2, x2, 1
    srli x2, x2, 2
    srli x2, x2, 3
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0x12345678
    srai x2, x1, 0
    li x1, 0x7FFFFFFF
    srai x2, x1, 31
    li x1, -1024               
    srai x2, x1, 0             
    srai x3, x1, 4
    srai x4, x1, 8
    srai x5, x1, 10
    li x1, 0x00000F00
    srai x2, x1, 4
    li x1, -0x00000F00
    srai x2, x1, 4
    li x1, 0xFFFFFFFF          
    srai x2, x1, 1
    li x1, 0x80000001
    srai x2, x1, 1
    li x10, 0xFFFFFFF0
    li x11, 2
    srai x12, x10, 1
    srai x13, x10, 4
    li x5, -64
    srai x5, x5, 1
    srai x5, x5, 1
    srai x5, x5, 2
    li x1, 0x7FFFFFFF
    .word 0x4070D093  
    li x1, 5
    slti x2, x1, 10
    li x1, -10
    slti x2, x1, -5
    li x1, -1
    slti x2, x1, 1
    li x1, 1
    slti x2, x1, -1
    li x1, 0x7FFFFFFF          
    slti x2, x1, 0x7FF
    li x1, 0
    slti x2, x1, -1
    li x1, 0x00001000
    slti x2, x1, -1
    li x1, -4096
    slti x2, x1, -1
    li x1, -2
    slti x2, x1, -2
    li x1, -3
    slti x2, x1, -2
    li x5, 3
    slti x5, x5, 10     
    slti x5, x5, 1      
    slti x5, x5, 2      
    li x10, -128
    slti x11, x10, -127
    slti x12, x11, 0
    li x13, 127
    slti x14, x13, 128
    li x1, 5
    sltiu x2, x1, 10
    li x1, 10
    sltiu x2, x1, 10
    li x1, 0
    sltiu x2, x1, 0
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFF
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFE
    li x1, 0x80000000
    sltiu x2, x1, 0x7FF
    li x1, 0x80000000
    sltiu x2, x1, 0xFFFFFFFF
    li x5, 3
    sltiu x5, x5, 10     
    sltiu x5, x5, 1      
    sltiu x5, x5, 2      
    li x1, 12345
    sltiu x0, x1, 100
    li x1, 0x0000FFFF
    sltiu x2, x1, 0x100
    li x1, 0x00010000
    sltiu x2, x1, 0x7FF
lui x1, 0x00000
lui x2, 0x00001
lui x3, 0x000AB
lui x4, 0xABCDE
lui x5, 0x80000
lui x6, 0xFFFFF
lui x7, 0x7FFFF
lui x0, 0x12345
lui x9, 0xABCDF
lui x11, 0x00000
lui x12, 0x7FFFF
lui x13, 0x80000
lui x14, 0xFFFFF
lui x15, 0x00010
addi x15, x15, 0x123
lui x16, 0xABCDE
addi x16, x16, -1
lui x17, 0xFFFFF
addi x17, x17, -2048
lui x18, 0x7FFFF
lui x19, 0x80000
    addi x6, x5, 10        
    li   x31, 0x7FFFFFFF
    addi x1, x31, -2048     
    addi x2, x2, 0        
    addi x3, x3, 0        
    li   x1, 0x0F0F0F0F
    xori x2, x1, 0x00FF       
    li   x3, 0x12345678
    xori x4, x3, 0
    li   x5, 0xAAAAAAAA
    xori x6, x5, -1
    li   x7, 0x00000FFF
    xori x8, x7, -2048
    li   x9, 0xFFFFF000
    xori x10, x9, 2047
    xori x11, x0, 0x7F
    xori x12, x0, -1
    li   x13, 0x55555555
    xori x0, x13, 0x2AA
    li   x14, 0x0F0F0F0F
    xori x14, x14, 0x00F0
    li   x15, 0xAAAAAAAA
    xori x16, x15, 0x555
    li   x17, 0x55555555
    xori x18, x17, 0x2AA
    li   x19, 0x12345678
    xori x20, x19, -1
    li   x21, 0xAAAAAAAA
    xori x22, x21, 0x555
    xori x23, x22, 0x3AA
    xori x24, x0, -2048
    li   x25, 0x80000000
    xori x26, x25, 0x7FF
    li   x27, 0x7FFFFFFF
    xori x28, x27, -1
    li   x29, 0x0000F0F0
    xori x30, x29, 0x0F0
    li   x31, 0x00000001
    xori x1, x31, 0x700     
    li   x2, 0x12345678
    xori x2, x2, 0x7FF
    li   x3, 0xDEADBEEF
    xori x4, x3, 0x3AD
    li   x5, 0xCAFEBABE
    xori x6, x5, -512
    li   x7, 0xABCDABCD
    xori x8, x7, 1
    li   x9, 0x00000001
    xori x10, x9, -2
    li x1, 0x00000000
    ori x2, x1, 0x0
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x0
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x700
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x000
    li x1, 0x00000000
    ori x2, x1, -1
    li x1, 0x12345678
    ori x2, x1, -1
    li x1, 0x80000000
    ori x2, x1, -2048
    li x1, 0x0000F0F0
    ori x2, x1, 0x00F
    li x1, 0xFFFF0000
    ori x2, x1, 0x123
    li x1, 0xDEADBEEF
    ori x2, x1, 0x0AA
    li x1, 0x00001234
    ori x2, x1, 0x7FF
    li x1, 0x7FFFFFFF
    ori x2, x1, 0x001
    li x1, 0x80000000
    ori x2, x1, 0x7FF
    li x1, 0x80000000
    ori x2, x1, 0x700
    ori x0, x1, 0x7FF
    li x1, 0x0000000F
    ori x2, x1, 0x0F0
    ori x3, x2, 0x700
    ori x4, x3, -1
    li x1, 0x00000000
    andi x2, x1, 0x0
    li x1, 0x00000000
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x700
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xAAAAAAAA
    andi x2, x1, 0x555
    li x1, 0x55555555
    andi x2, x1, 0x7AA
    li x1, 0x12345678
    andi x2, x1, 0x7FF
    li x1, 0x12345678
    andi x2, x1, 0x000
    li x1, 0x0000FFFF
    andi x2, x1, -1
    li x1, 0x0000FFFF
    andi x2, x1, -2048
    li x1, 0xF0F0F0F0
    andi x2, x1, -1
    li x1, 0xDEADBEEF
    andi x2, x1, 0x0AA
    li x1, 0x7FFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x700
    andi x0, x1, 0x7F
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0FF
    andi x2, x2, 0x00F
    andi x2, x2, -1
    andi x2, x2, 0x000
    li x1, 0x00000000
    slli x2, x1, 5
    li x1, 0xFFFFFFFF
    slli x2, x1, 0
    li x1, 0xFFFFFFFF
    slli x2, x1, 1
    li x1, 0xFFFFFFFF
    slli x2, x1, 31
    li x1, 0x00FF00FF
    slli x2, x1, 8
    li x1, 0x0F0F0F0F
    slli x2, x1, 4
    li x1, 0x40000000
    slli x2, x1, 1
    li x1, 0x40000000
    slli x2, x1, 2
    li x1, 0xAAAAAAAA
    slli x2, x1, 1
    li x1, 0x55555555
    slli x2, x1, 1
    li x1, 0x00000001
    slli x2, x1, 31
    li x1, 0x00000003
    slli x2, x1, 5
    li x1, 0x00000003
    slli x2, x1, 31
    li x1, 0xFFFFFFFF
    slli x0, x1, 4
    li x1, 0x00000001
    slli x2, x1, 1
    slli x2, x2, 1
    slli x2, x2, 2
    slli x2, x2, 3
    li x1, 0x80000000
    srli x2, x1, 1
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0xAAAAAAAA
    srli x2, x1, 1
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    li x1, 0xF0000000
    srli x2, x1, 4
    li x1, 0x80000000
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 4
    li x1, 0xF000000F
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 16
    li x1, 0xF000000F
    srli x2, x1, 24
    li x1, 0xFFFFFFFF
    srli x0, x1, 8
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    srli x2, x2, 1
    srli x2, x2, 2
    srli x2, x2, 3
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0x12345678
    srai x2, x1, 0
    li x1, 0x7FFFFFFF
    srai x2, x1, 31
    li x1, -1024               
    srai x2, x1, 0             
    srai x3, x1, 4
    srai x4, x1, 8
    srai x5, x1, 10
    li x1, 0x00000F00
    srai x2, x1, 4
    li x1, -0x00000F00
    srai x2, x1, 4
    li x1, 0xFFFFFFFF          
    srai x2, x1, 1
    li x1, 0x80000001
    srai x2, x1, 1
    li x10, 0xFFFFFFF0
    li x11, 2
    srai x12, x10, 1
    srai x13, x10, 4
    li x5, -64
    srai x5, x5, 1
    srai x5, x5, 1
    srai x5, x5, 2
    li x1, 0x7FFFFFFF
    .word 0x4070D093  
    li x1, 5
    slti x2, x1, 10
    li x1, -10
    slti x2, x1, -5
    li x1, -1
    slti x2, x1, 1
    li x1, 1
    slti x2, x1, -1
    li x1, 0x7FFFFFFF          
    slti x2, x1, 0x7FF
    li x1, 0
    slti x2, x1, -1
    li x1, 0x00001000
    slti x2, x1, -1
    li x1, -4096
    slti x2, x1, -1
    li x1, -2
    slti x2, x1, -2
    li x1, -3
    slti x2, x1, -2
    li x5, 3
    slti x5, x5, 10     
    slti x5, x5, 1      
    slti x5, x5, 2      
    li x10, -128
    slti x11, x10, -127
    slti x12, x11, 0
    li x13, 127
    slti x14, x13, 128
    li x1, 5
    sltiu x2, x1, 10
    li x1, 10
    sltiu x2, x1, 10
    li x1, 0
    sltiu x2, x1, 0
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFF
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFE
    li x1, 0x80000000
    sltiu x2, x1, 0x7FF
    li x1, 0x80000000
    sltiu x2, x1, 0xFFFFFFFF
    li x5, 3
    sltiu x5, x5, 10     
    sltiu x5, x5, 1      
    sltiu x5, x5, 2      
    li x1, 12345
    sltiu x0, x1, 100
    li x1, 0x0000FFFF
    sltiu x2, x1, 0x100
    li x1, 0x00010000
    sltiu x2, x1, 0x7FF
lui x1, 0x00000
lui x2, 0x00001
lui x3, 0x000AB
lui x4, 0xABCDE
lui x5, 0x80000
lui x6, 0xFFFFF
lui x7, 0x7FFFF
lui x0, 0x12345
lui x9, 0xABCDF
lui x11, 0x00000
lui x12, 0x7FFFF
lui x13, 0x80000
lui x14, 0xFFFFF
lui x15, 0x00010
addi x15, x15, 0x123
lui x16, 0xABCDE
addi x16, x16, -1
lui x17, 0xFFFFF
addi x17, x17, -2048
lui x18, 0x7FFFF
lui x19, 0x80000
    addi x6, x5, 10        
    li   x31, 0x7FFFFFFF
    addi x1, x31, -2048     
    addi x2, x2, 0        
    addi x3, x3, 0        
    li   x1, 0x0F0F0F0F
    xori x2, x1, 0x00FF       
    li   x3, 0x12345678
    xori x4, x3, 0
    li   x5, 0xAAAAAAAA
    xori x6, x5, -1
    li   x7, 0x00000FFF
    xori x8, x7, -2048
    li   x9, 0xFFFFF000
    xori x10, x9, 2047
    xori x11, x0, 0x7F
    xori x12, x0, -1
    li   x13, 0x55555555
    xori x0, x13, 0x2AA
    li   x14, 0x0F0F0F0F
    xori x14, x14, 0x00F0
    li   x15, 0xAAAAAAAA
    xori x16, x15, 0x555
    li   x17, 0x55555555
    xori x18, x17, 0x2AA
    li   x19, 0x12345678
    xori x20, x19, -1
    li   x21, 0xAAAAAAAA
    xori x22, x21, 0x555
    xori x23, x22, 0x3AA
    xori x24, x0, -2048
    li   x25, 0x80000000
    xori x26, x25, 0x7FF
    li   x27, 0x7FFFFFFF
    xori x28, x27, -1
    li   x29, 0x0000F0F0
    xori x30, x29, 0x0F0
    li   x31, 0x00000001
    xori x1, x31, 0x700     
    li   x2, 0x12345678
    xori x2, x2, 0x7FF
    li   x3, 0xDEADBEEF
    xori x4, x3, 0x3AD
    li   x5, 0xCAFEBABE
    xori x6, x5, -512
    li   x7, 0xABCDABCD
    xori x8, x7, 1
    li   x9, 0x00000001
    xori x10, x9, -2
    li x1, 0x00000000
    ori x2, x1, 0x0
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x0
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x700
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x000
    li x1, 0x00000000
    ori x2, x1, -1
    li x1, 0x12345678
    ori x2, x1, -1
    li x1, 0x80000000
    ori x2, x1, -2048
    li x1, 0x0000F0F0
    ori x2, x1, 0x00F
    li x1, 0xFFFF0000
    ori x2, x1, 0x123
    li x1, 0xDEADBEEF
    ori x2, x1, 0x0AA
    li x1, 0x00001234
    ori x2, x1, 0x7FF
    li x1, 0x7FFFFFFF
    ori x2, x1, 0x001
    li x1, 0x80000000
    ori x2, x1, 0x7FF
    li x1, 0x80000000
    ori x2, x1, 0x700
    ori x0, x1, 0x7FF
    li x1, 0x0000000F
    ori x2, x1, 0x0F0
    ori x3, x2, 0x700
    ori x4, x3, -1
    li x1, 0x00000000
    andi x2, x1, 0x0
    li x1, 0x00000000
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x700
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xAAAAAAAA
    andi x2, x1, 0x555
    li x1, 0x55555555
    andi x2, x1, 0x7AA
    li x1, 0x12345678
    andi x2, x1, 0x7FF
    li x1, 0x12345678
    andi x2, x1, 0x000
    li x1, 0x0000FFFF
    andi x2, x1, -1
    li x1, 0x0000FFFF
    andi x2, x1, -2048
    li x1, 0xF0F0F0F0
    andi x2, x1, -1
    li x1, 0xDEADBEEF
    andi x2, x1, 0x0AA
    li x1, 0x7FFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x700
    andi x0, x1, 0x7F
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0FF
    andi x2, x2, 0x00F
    andi x2, x2, -1
    andi x2, x2, 0x000
    li x1, 0x00000000
    slli x2, x1, 5
    li x1, 0xFFFFFFFF
    slli x2, x1, 0
    li x1, 0xFFFFFFFF
    slli x2, x1, 1
    li x1, 0xFFFFFFFF
    slli x2, x1, 31
    li x1, 0x00FF00FF
    slli x2, x1, 8
    li x1, 0x0F0F0F0F
    slli x2, x1, 4
    li x1, 0x40000000
    slli x2, x1, 1
    li x1, 0x40000000
    slli x2, x1, 2
    li x1, 0xAAAAAAAA
    slli x2, x1, 1
    li x1, 0x55555555
    slli x2, x1, 1
    li x1, 0x00000001
    slli x2, x1, 31
    li x1, 0x00000003
    slli x2, x1, 5
    li x1, 0x00000003
    slli x2, x1, 31
    li x1, 0xFFFFFFFF
    slli x0, x1, 4
    li x1, 0x00000001
    slli x2, x1, 1
    slli x2, x2, 1
    slli x2, x2, 2
    slli x2, x2, 3
    li x1, 0x80000000
    srli x2, x1, 1
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0xAAAAAAAA
    srli x2, x1, 1
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    li x1, 0xF0000000
    srli x2, x1, 4
    li x1, 0x80000000
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 4
    li x1, 0xF000000F
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 16
    li x1, 0xF000000F
    srli x2, x1, 24
    li x1, 0xFFFFFFFF
    srli x0, x1, 8
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    srli x2, x2, 1
    srli x2, x2, 2
    srli x2, x2, 3
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0x12345678
    srai x2, x1, 0
    li x1, 0x7FFFFFFF
    srai x2, x1, 31
    li x1, -1024               
    srai x2, x1, 0             
    srai x3, x1, 4
    srai x4, x1, 8
    srai x5, x1, 10
    li x1, 0x00000F00
    srai x2, x1, 4
    li x1, -0x00000F00
    srai x2, x1, 4
    li x1, 0xFFFFFFFF          
    srai x2, x1, 1
    li x1, 0x80000001
    srai x2, x1, 1
    li x10, 0xFFFFFFF0
    li x11, 2
    srai x12, x10, 1
    srai x13, x10, 4
    li x5, -64
    srai x5, x5, 1
    srai x5, x5, 1
    srai x5, x5, 2
    li x1, 0x7FFFFFFF
    .word 0x4070D093  
    li x1, 5
    slti x2, x1, 10
    li x1, -10
    slti x2, x1, -5
    li x1, -1
    slti x2, x1, 1
    li x1, 1
    slti x2, x1, -1
    li x1, 0x7FFFFFFF          
    slti x2, x1, 0x7FF
    li x1, 0
    slti x2, x1, -1
    li x1, 0x00001000
    slti x2, x1, -1
    li x1, -4096
    slti x2, x1, -1
    li x1, -2
    slti x2, x1, -2
    li x1, -3
    slti x2, x1, -2
    li x5, 3
    slti x5, x5, 10     
    slti x5, x5, 1      
    slti x5, x5, 2      
    li x10, -128
    slti x11, x10, -127
    slti x12, x11, 0
    li x13, 127
    slti x14, x13, 128
    li x1, 5
    sltiu x2, x1, 10
    li x1, 10
    sltiu x2, x1, 10
    li x1, 0
    sltiu x2, x1, 0
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFF
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFE
    li x1, 0x80000000
    sltiu x2, x1, 0x7FF
    li x1, 0x80000000
    sltiu x2, x1, 0xFFFFFFFF
    li x5, 3
    sltiu x5, x5, 10     
    sltiu x5, x5, 1      
    sltiu x5, x5, 2      
    li x1, 12345
    sltiu x0, x1, 100
    li x1, 0x0000FFFF
    sltiu x2, x1, 0x100
    li x1, 0x00010000
    sltiu x2, x1, 0x7FF
lui x1, 0x00000
lui x2, 0x00001
lui x3, 0x000AB
lui x4, 0xABCDE
lui x5, 0x80000
lui x6, 0xFFFFF
lui x7, 0x7FFFF
lui x0, 0x12345
lui x9, 0xABCDF
lui x11, 0x00000
lui x12, 0x7FFFF
lui x13, 0x80000
lui x14, 0xFFFFF
lui x15, 0x00010
addi x15, x15, 0x123
lui x16, 0xABCDE
addi x16, x16, -1
lui x17, 0xFFFFF
addi x17, x17, -2048
lui x18, 0x7FFFF
lui x19, 0x80000
    addi x6, x5, 10        
    li   x31, 0x7FFFFFFF
    addi x1, x31, -2048     
    addi x2, x2, 0        
    addi x3, x3, 0        
    li   x1, 0x0F0F0F0F
    xori x2, x1, 0x00FF       
    li   x3, 0x12345678
    xori x4, x3, 0
    li   x5, 0xAAAAAAAA
    xori x6, x5, -1
    li   x7, 0x00000FFF
    xori x8, x7, -2048
    li   x9, 0xFFFFF000
    xori x10, x9, 2047
    xori x11, x0, 0x7F
    xori x12, x0, -1
    li   x13, 0x55555555
    xori x0, x13, 0x2AA
    li   x14, 0x0F0F0F0F
    xori x14, x14, 0x00F0
    li   x15, 0xAAAAAAAA
    xori x16, x15, 0x555
    li   x17, 0x55555555
    xori x18, x17, 0x2AA
    li   x19, 0x12345678
    xori x20, x19, -1
    li   x21, 0xAAAAAAAA
    xori x22, x21, 0x555
    xori x23, x22, 0x3AA
    xori x24, x0, -2048
    li   x25, 0x80000000
    xori x26, x25, 0x7FF
    li   x27, 0x7FFFFFFF
    xori x28, x27, -1
    li   x29, 0x0000F0F0
    xori x30, x29, 0x0F0
    li   x31, 0x00000001
    xori x1, x31, 0x700     
    li   x2, 0x12345678
    xori x2, x2, 0x7FF
    li   x3, 0xDEADBEEF
    xori x4, x3, 0x3AD
    li   x5, 0xCAFEBABE
    xori x6, x5, -512
    li   x7, 0xABCDABCD
    xori x8, x7, 1
    li   x9, 0x00000001
    xori x10, x9, -2
    li x1, 0x00000000
    ori x2, x1, 0x0
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x0
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x700
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x000
    li x1, 0x00000000
    ori x2, x1, -1
    li x1, 0x12345678
    ori x2, x1, -1
    li x1, 0x80000000
    ori x2, x1, -2048
    li x1, 0x0000F0F0
    ori x2, x1, 0x00F
    li x1, 0xFFFF0000
    ori x2, x1, 0x123
    li x1, 0xDEADBEEF
    ori x2, x1, 0x0AA
    li x1, 0x00001234
    ori x2, x1, 0x7FF
    li x1, 0x7FFFFFFF
    ori x2, x1, 0x001
    li x1, 0x80000000
    ori x2, x1, 0x7FF
    li x1, 0x80000000
    ori x2, x1, 0x700
    ori x0, x1, 0x7FF
    li x1, 0x0000000F
    ori x2, x1, 0x0F0
    ori x3, x2, 0x700
    ori x4, x3, -1
    li x1, 0x00000000
    andi x2, x1, 0x0
    li x1, 0x00000000
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x700
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xAAAAAAAA
    andi x2, x1, 0x555
    li x1, 0x55555555
    andi x2, x1, 0x7AA
    li x1, 0x12345678
    andi x2, x1, 0x7FF
    li x1, 0x12345678
    andi x2, x1, 0x000
    li x1, 0x0000FFFF
    andi x2, x1, -1
    li x1, 0x0000FFFF
    andi x2, x1, -2048
    li x1, 0xF0F0F0F0
    andi x2, x1, -1
    li x1, 0xDEADBEEF
    andi x2, x1, 0x0AA
    li x1, 0x7FFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x700
    andi x0, x1, 0x7F
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0FF
    andi x2, x2, 0x00F
    andi x2, x2, -1
    andi x2, x2, 0x000
    li x1, 0x00000000
    slli x2, x1, 5
    li x1, 0xFFFFFFFF
    slli x2, x1, 0
    li x1, 0xFFFFFFFF
    slli x2, x1, 1
    li x1, 0xFFFFFFFF
    slli x2, x1, 31
    li x1, 0x00FF00FF
    slli x2, x1, 8
    li x1, 0x0F0F0F0F
    slli x2, x1, 4
    li x1, 0x40000000
    slli x2, x1, 1
    li x1, 0x40000000
    slli x2, x1, 2
    li x1, 0xAAAAAAAA
    slli x2, x1, 1
    li x1, 0x55555555
    slli x2, x1, 1
    li x1, 0x00000001
    slli x2, x1, 31
    li x1, 0x00000003
    slli x2, x1, 5
    li x1, 0x00000003
    slli x2, x1, 31
    li x1, 0xFFFFFFFF
    slli x0, x1, 4
    li x1, 0x00000001
    slli x2, x1, 1
    slli x2, x2, 1
    slli x2, x2, 2
    slli x2, x2, 3
    li x1, 0x80000000
    srli x2, x1, 1
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0xAAAAAAAA
    srli x2, x1, 1
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    li x1, 0xF0000000
    srli x2, x1, 4
    li x1, 0x80000000
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 4
    li x1, 0xF000000F
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 16
    li x1, 0xF000000F
    srli x2, x1, 24
    li x1, 0xFFFFFFFF
    srli x0, x1, 8
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    srli x2, x2, 1
    srli x2, x2, 2
    srli x2, x2, 3
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0x12345678
    srai x2, x1, 0
    li x1, 0x7FFFFFFF
    srai x2, x1, 31
    li x1, -1024               
    srai x2, x1, 0             
    srai x3, x1, 4
    srai x4, x1, 8
    srai x5, x1, 10
    li x1, 0x00000F00
    srai x2, x1, 4
    li x1, -0x00000F00
    srai x2, x1, 4
    li x1, 0xFFFFFFFF          
    srai x2, x1, 1
    li x1, 0x80000001
    srai x2, x1, 1
    li x10, 0xFFFFFFF0
    li x11, 2
    srai x12, x10, 1
    srai x13, x10, 4
    li x5, -64
    srai x5, x5, 1
    srai x5, x5, 1
    srai x5, x5, 2
    li x1, 0x7FFFFFFF
    .word 0x4070D093  
    li x1, 5
    slti x2, x1, 10
    li x1, -10
    slti x2, x1, -5
    li x1, -1
    slti x2, x1, 1
    li x1, 1
    slti x2, x1, -1
    li x1, 0x7FFFFFFF          
    slti x2, x1, 0x7FF
    li x1, 0
    slti x2, x1, -1
    li x1, 0x00001000
    slti x2, x1, -1
    li x1, -4096
    slti x2, x1, -1
    li x1, -2
    slti x2, x1, -2
    li x1, -3
    slti x2, x1, -2
    li x5, 3
    slti x5, x5, 10     
    slti x5, x5, 1      
    slti x5, x5, 2      
    li x10, -128
    slti x11, x10, -127
    slti x12, x11, 0
    li x13, 127
    slti x14, x13, 128
    li x1, 5
    sltiu x2, x1, 10
    li x1, 10
    sltiu x2, x1, 10
    li x1, 0
    sltiu x2, x1, 0
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFF
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFE
    li x1, 0x80000000
    sltiu x2, x1, 0x7FF
    li x1, 0x80000000
    sltiu x2, x1, 0xFFFFFFFF
    li x5, 3
    sltiu x5, x5, 10     
    sltiu x5, x5, 1      
    sltiu x5, x5, 2      
    li x1, 12345
    sltiu x0, x1, 100
    li x1, 0x0000FFFF
    sltiu x2, x1, 0x100
    li x1, 0x00010000
    sltiu x2, x1, 0x7FF
lui x1, 0x00000
lui x2, 0x00001
lui x3, 0x000AB
lui x4, 0xABCDE
lui x5, 0x80000
lui x6, 0xFFFFF
lui x7, 0x7FFFF
lui x0, 0x12345
lui x9, 0xABCDF
lui x11, 0x00000
lui x12, 0x7FFFF
lui x13, 0x80000
lui x14, 0xFFFFF
lui x15, 0x00010
addi x15, x15, 0x123
lui x16, 0xABCDE
addi x16, x16, -1
lui x17, 0xFFFFF
addi x17, x17, -2048
lui x18, 0x7FFFF
lui x19, 0x80000
    addi x6, x5, 10        
    li   x31, 0x7FFFFFFF
    addi x1, x31, -2048     
    addi x2, x2, 0        
    addi x3, x3, 0        
    li   x1, 0x0F0F0F0F
    xori x2, x1, 0x00FF       
    li   x3, 0x12345678
    xori x4, x3, 0
    li   x5, 0xAAAAAAAA
    xori x6, x5, -1
    li   x7, 0x00000FFF
    xori x8, x7, -2048
    li   x9, 0xFFFFF000
    xori x10, x9, 2047
    xori x11, x0, 0x7F
    xori x12, x0, -1
    li   x13, 0x55555555
    xori x0, x13, 0x2AA
    li   x14, 0x0F0F0F0F
    xori x14, x14, 0x00F0
    li   x15, 0xAAAAAAAA
    xori x16, x15, 0x555
    li   x17, 0x55555555
    xori x18, x17, 0x2AA
    li   x19, 0x12345678
    xori x20, x19, -1
    li   x21, 0xAAAAAAAA
    xori x22, x21, 0x555
    xori x23, x22, 0x3AA
    xori x24, x0, -2048
    li   x25, 0x80000000
    xori x26, x25, 0x7FF
    li   x27, 0x7FFFFFFF
    xori x28, x27, -1
    li   x29, 0x0000F0F0
    xori x30, x29, 0x0F0
    li   x31, 0x00000001
    xori x1, x31, 0x700     
    li   x2, 0x12345678
    xori x2, x2, 0x7FF
    li   x3, 0xDEADBEEF
    xori x4, x3, 0x3AD
    li   x5, 0xCAFEBABE
    xori x6, x5, -512
    li   x7, 0xABCDABCD
    xori x8, x7, 1
    li   x9, 0x00000001
    xori x10, x9, -2
    li x1, 0x00000000
    ori x2, x1, 0x0
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x0
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x700
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x000
    li x1, 0x00000000
    ori x2, x1, -1
    li x1, 0x12345678
    ori x2, x1, -1
    li x1, 0x80000000
    ori x2, x1, -2048
    li x1, 0x0000F0F0
    ori x2, x1, 0x00F
    li x1, 0xFFFF0000
    ori x2, x1, 0x123
    li x1, 0xDEADBEEF
    ori x2, x1, 0x0AA
    li x1, 0x00001234
    ori x2, x1, 0x7FF
    li x1, 0x7FFFFFFF
    ori x2, x1, 0x001
    li x1, 0x80000000
    ori x2, x1, 0x7FF
    li x1, 0x80000000
    ori x2, x1, 0x700
    ori x0, x1, 0x7FF
    li x1, 0x0000000F
    ori x2, x1, 0x0F0
    ori x3, x2, 0x700
    ori x4, x3, -1
    li x1, 0x00000000
    andi x2, x1, 0x0
    li x1, 0x00000000
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x700
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xAAAAAAAA
    andi x2, x1, 0x555
    li x1, 0x55555555
    andi x2, x1, 0x7AA
    li x1, 0x12345678
    andi x2, x1, 0x7FF
    li x1, 0x12345678
    andi x2, x1, 0x000
    li x1, 0x0000FFFF
    andi x2, x1, -1
    li x1, 0x0000FFFF
    andi x2, x1, -2048
    li x1, 0xF0F0F0F0
    andi x2, x1, -1
    li x1, 0xDEADBEEF
    andi x2, x1, 0x0AA
    li x1, 0x7FFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x700
    andi x0, x1, 0x7F
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0FF
    andi x2, x2, 0x00F
    andi x2, x2, -1
    andi x2, x2, 0x000
    li x1, 0x00000000
    slli x2, x1, 5
    li x1, 0xFFFFFFFF
    slli x2, x1, 0
    li x1, 0xFFFFFFFF
    slli x2, x1, 1
    li x1, 0xFFFFFFFF
    slli x2, x1, 31
    li x1, 0x00FF00FF
    slli x2, x1, 8
    li x1, 0x0F0F0F0F
    slli x2, x1, 4
    li x1, 0x40000000
    slli x2, x1, 1
    li x1, 0x40000000
    slli x2, x1, 2
    li x1, 0xAAAAAAAA
    slli x2, x1, 1
    li x1, 0x55555555
    slli x2, x1, 1
    li x1, 0x00000001
    slli x2, x1, 31
    li x1, 0x00000003
    slli x2, x1, 5
    li x1, 0x00000003
    slli x2, x1, 31
    li x1, 0xFFFFFFFF
    slli x0, x1, 4
    li x1, 0x00000001
    slli x2, x1, 1
    slli x2, x2, 1
    slli x2, x2, 2
    slli x2, x2, 3
    li x1, 0x80000000
    srli x2, x1, 1
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0xAAAAAAAA
    srli x2, x1, 1
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    li x1, 0xF0000000
    srli x2, x1, 4
    li x1, 0x80000000
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 4
    li x1, 0xF000000F
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 16
    li x1, 0xF000000F
    srli x2, x1, 24
    li x1, 0xFFFFFFFF
    srli x0, x1, 8
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    srli x2, x2, 1
    srli x2, x2, 2
    srli x2, x2, 3
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0x12345678
    srai x2, x1, 0
    li x1, 0x7FFFFFFF
    srai x2, x1, 31
    li x1, -1024               
    srai x2, x1, 0             
    srai x3, x1, 4
    srai x4, x1, 8
    srai x5, x1, 10
    li x1, 0x00000F00
    srai x2, x1, 4
    li x1, -0x00000F00
    srai x2, x1, 4
    li x1, 0xFFFFFFFF          
    srai x2, x1, 1
    li x1, 0x80000001
    srai x2, x1, 1
    li x10, 0xFFFFFFF0
    li x11, 2
    srai x12, x10, 1
    srai x13, x10, 4
    li x5, -64
    srai x5, x5, 1
    srai x5, x5, 1
    srai x5, x5, 2
    li x1, 0x7FFFFFFF
    .word 0x4070D093  
    li x1, 5
    slti x2, x1, 10
    li x1, -10
    slti x2, x1, -5
    li x1, -1
    slti x2, x1, 1
    li x1, 1
    slti x2, x1, -1
    li x1, 0x7FFFFFFF          
    slti x2, x1, 0x7FF
    li x1, 0
    slti x2, x1, -1
    li x1, 0x00001000
    slti x2, x1, -1
    li x1, -4096
    slti x2, x1, -1
    li x1, -2
    slti x2, x1, -2
    li x1, -3
    slti x2, x1, -2
    li x5, 3
    slti x5, x5, 10     
    slti x5, x5, 1      
    slti x5, x5, 2      
    li x10, -128
    slti x11, x10, -127
    slti x12, x11, 0
    li x13, 127
    slti x14, x13, 128
    li x1, 5
    sltiu x2, x1, 10
    li x1, 10
    sltiu x2, x1, 10
    li x1, 0
    sltiu x2, x1, 0
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFF
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFE
    li x1, 0x80000000
    sltiu x2, x1, 0x7FF
    li x1, 0x80000000
    sltiu x2, x1, 0xFFFFFFFF
    li x5, 3
    sltiu x5, x5, 10     
    sltiu x5, x5, 1      
    sltiu x5, x5, 2      
    li x1, 12345
    sltiu x0, x1, 100
    li x1, 0x0000FFFF
    sltiu x2, x1, 0x100
    li x1, 0x00010000
    sltiu x2, x1, 0x7FF
lui x1, 0x00000
lui x2, 0x00001
lui x3, 0x000AB
lui x4, 0xABCDE
lui x5, 0x80000
lui x6, 0xFFFFF
lui x7, 0x7FFFF
lui x0, 0x12345
lui x9, 0xABCDF
lui x11, 0x00000
lui x12, 0x7FFFF
lui x13, 0x80000
lui x14, 0xFFFFF
lui x15, 0x00010
addi x15, x15, 0x123
lui x16, 0xABCDE
addi x16, x16, -1
lui x17, 0xFFFFF
addi x17, x17, -2048
lui x18, 0x7FFFF
lui x19, 0x80000
    addi x6, x5, 10        
    li   x31, 0x7FFFFFFF
    addi x1, x31, -2048     
    addi x2, x2, 0        
    addi x3, x3, 0        
    li   x1, 0x0F0F0F0F
    xori x2, x1, 0x00FF       
    li   x3, 0x12345678
    xori x4, x3, 0
    li   x5, 0xAAAAAAAA
    xori x6, x5, -1
    li   x7, 0x00000FFF
    xori x8, x7, -2048
    li   x9, 0xFFFFF000
    xori x10, x9, 2047
    xori x11, x0, 0x7F
    xori x12, x0, -1
    li   x13, 0x55555555
    xori x0, x13, 0x2AA
    li   x14, 0x0F0F0F0F
    xori x14, x14, 0x00F0
    li   x15, 0xAAAAAAAA
    xori x16, x15, 0x555
    li   x17, 0x55555555
    xori x18, x17, 0x2AA
    li   x19, 0x12345678
    xori x20, x19, -1
    li   x21, 0xAAAAAAAA
    xori x22, x21, 0x555
    xori x23, x22, 0x3AA
    xori x24, x0, -2048
    li   x25, 0x80000000
    xori x26, x25, 0x7FF
    li   x27, 0x7FFFFFFF
    xori x28, x27, -1
    li   x29, 0x0000F0F0
    xori x30, x29, 0x0F0
    li   x31, 0x00000001
    xori x1, x31, 0x700     
    li   x2, 0x12345678
    xori x2, x2, 0x7FF
    li   x3, 0xDEADBEEF
    xori x4, x3, 0x3AD
    li   x5, 0xCAFEBABE
    xori x6, x5, -512
    li   x7, 0xABCDABCD
    xori x8, x7, 1
    li   x9, 0x00000001
    xori x10, x9, -2
    li x1, 0x00000000
    ori x2, x1, 0x0
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x0
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x700
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x000
    li x1, 0x00000000
    ori x2, x1, -1
    li x1, 0x12345678
    ori x2, x1, -1
    li x1, 0x80000000
    ori x2, x1, -2048
    li x1, 0x0000F0F0
    ori x2, x1, 0x00F
    li x1, 0xFFFF0000
    ori x2, x1, 0x123
    li x1, 0xDEADBEEF
    ori x2, x1, 0x0AA
    li x1, 0x00001234
    ori x2, x1, 0x7FF
    li x1, 0x7FFFFFFF
    ori x2, x1, 0x001
    li x1, 0x80000000
    ori x2, x1, 0x7FF
    li x1, 0x80000000
    ori x2, x1, 0x700
    ori x0, x1, 0x7FF
    li x1, 0x0000000F
    ori x2, x1, 0x0F0
    ori x3, x2, 0x700
    ori x4, x3, -1
    li x1, 0x00000000
    andi x2, x1, 0x0
    li x1, 0x00000000
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x700
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xAAAAAAAA
    andi x2, x1, 0x555
    li x1, 0x55555555
    andi x2, x1, 0x7AA
    li x1, 0x12345678
    andi x2, x1, 0x7FF
    li x1, 0x12345678
    andi x2, x1, 0x000
    li x1, 0x0000FFFF
    andi x2, x1, -1
    li x1, 0x0000FFFF
    andi x2, x1, -2048
    li x1, 0xF0F0F0F0
    andi x2, x1, -1
    li x1, 0xDEADBEEF
    andi x2, x1, 0x0AA
    li x1, 0x7FFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x700
    andi x0, x1, 0x7F
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0FF
    andi x2, x2, 0x00F
    andi x2, x2, -1
    andi x2, x2, 0x000
    li x1, 0x00000000
    slli x2, x1, 5
    li x1, 0xFFFFFFFF
    slli x2, x1, 0
    li x1, 0xFFFFFFFF
    slli x2, x1, 1
    li x1, 0xFFFFFFFF
    slli x2, x1, 31
    li x1, 0x00FF00FF
    slli x2, x1, 8
    li x1, 0x0F0F0F0F
    slli x2, x1, 4
    li x1, 0x40000000
    slli x2, x1, 1
    li x1, 0x40000000
    slli x2, x1, 2
    li x1, 0xAAAAAAAA
    slli x2, x1, 1
    li x1, 0x55555555
    slli x2, x1, 1
    li x1, 0x00000001
    slli x2, x1, 31
    li x1, 0x00000003
    slli x2, x1, 5
    li x1, 0x00000003
    slli x2, x1, 31
    li x1, 0xFFFFFFFF
    slli x0, x1, 4
    li x1, 0x00000001
    slli x2, x1, 1
    slli x2, x2, 1
    slli x2, x2, 2
    slli x2, x2, 3
    li x1, 0x80000000
    srli x2, x1, 1
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0xAAAAAAAA
    srli x2, x1, 1
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    li x1, 0xF0000000
    srli x2, x1, 4
    li x1, 0x80000000
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 4
    li x1, 0xF000000F
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 16
    li x1, 0xF000000F
    srli x2, x1, 24
    li x1, 0xFFFFFFFF
    srli x0, x1, 8
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    srli x2, x2, 1
    srli x2, x2, 2
    srli x2, x2, 3
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0x12345678
    srai x2, x1, 0
    li x1, 0x7FFFFFFF
    srai x2, x1, 31
    li x1, -1024               
    srai x2, x1, 0             
    srai x3, x1, 4
    srai x4, x1, 8
    srai x5, x1, 10
    li x1, 0x00000F00
    srai x2, x1, 4
    li x1, -0x00000F00
    srai x2, x1, 4
    li x1, 0xFFFFFFFF          
    srai x2, x1, 1
    li x1, 0x80000001
    srai x2, x1, 1
    li x10, 0xFFFFFFF0
    li x11, 2
    srai x12, x10, 1
    srai x13, x10, 4
    li x5, -64
    srai x5, x5, 1
    srai x5, x5, 1
    srai x5, x5, 2
    li x1, 0x7FFFFFFF
    .word 0x4070D093  
    li x1, 5
    slti x2, x1, 10
    li x1, -10
    slti x2, x1, -5
    li x1, -1
    slti x2, x1, 1
    li x1, 1
    slti x2, x1, -1
    li x1, 0x7FFFFFFF          
    slti x2, x1, 0x7FF
    li x1, 0
    slti x2, x1, -1
    li x1, 0x00001000
    slti x2, x1, -1
    li x1, -4096
    slti x2, x1, -1
    li x1, -2
    slti x2, x1, -2
    li x1, -3
    slti x2, x1, -2
    li x5, 3
    slti x5, x5, 10     
    slti x5, x5, 1      
    slti x5, x5, 2      
    li x10, -128
    slti x11, x10, -127
    slti x12, x11, 0
    li x13, 127
    slti x14, x13, 128
    li x1, 5
    sltiu x2, x1, 10
    li x1, 10
    sltiu x2, x1, 10
    li x1, 0
    sltiu x2, x1, 0
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFF
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFE
    li x1, 0x80000000
    sltiu x2, x1, 0x7FF
    li x1, 0x80000000
    sltiu x2, x1, 0xFFFFFFFF
    li x5, 3
    sltiu x5, x5, 10     
    sltiu x5, x5, 1      
    sltiu x5, x5, 2      
    li x1, 12345
    sltiu x0, x1, 100
    li x1, 0x0000FFFF
    sltiu x2, x1, 0x100
    li x1, 0x00010000
    sltiu x2, x1, 0x7FF
lui x1, 0x00000
lui x2, 0x00001
lui x3, 0x000AB
lui x4, 0xABCDE
lui x5, 0x80000
lui x6, 0xFFFFF
lui x7, 0x7FFFF
lui x0, 0x12345
lui x9, 0xABCDF
lui x11, 0x00000
lui x12, 0x7FFFF
lui x13, 0x80000
lui x14, 0xFFFFF
lui x15, 0x00010
addi x15, x15, 0x123
lui x16, 0xABCDE
addi x16, x16, -1
lui x17, 0xFFFFF
addi x17, x17, -2048
lui x18, 0x7FFFF
lui x19, 0x80000
    addi x6, x5, 10        
    li   x31, 0x7FFFFFFF
    addi x1, x31, -2048     
    addi x2, x2, 0        
    addi x3, x3, 0        
    li   x1, 0x0F0F0F0F
    xori x2, x1, 0x00FF       
    li   x3, 0x12345678
    xori x4, x3, 0
    li   x5, 0xAAAAAAAA
    xori x6, x5, -1
    li   x7, 0x00000FFF
    xori x8, x7, -2048
    li   x9, 0xFFFFF000
    xori x10, x9, 2047
    xori x11, x0, 0x7F
    xori x12, x0, -1
    li   x13, 0x55555555
    xori x0, x13, 0x2AA
    li   x14, 0x0F0F0F0F
    xori x14, x14, 0x00F0
    li   x15, 0xAAAAAAAA
    xori x16, x15, 0x555
    li   x17, 0x55555555
    xori x18, x17, 0x2AA
    li   x19, 0x12345678
    xori x20, x19, -1
    li   x21, 0xAAAAAAAA
    xori x22, x21, 0x555
    xori x23, x22, 0x3AA
    xori x24, x0, -2048
    li   x25, 0x80000000
    xori x26, x25, 0x7FF
    li   x27, 0x7FFFFFFF
    xori x28, x27, -1
    li   x29, 0x0000F0F0
    xori x30, x29, 0x0F0
    li   x31, 0x00000001
    xori x1, x31, 0x700     
    li   x2, 0x12345678
    xori x2, x2, 0x7FF
    li   x3, 0xDEADBEEF
    xori x4, x3, 0x3AD
    li   x5, 0xCAFEBABE
    xori x6, x5, -512
    li   x7, 0xABCDABCD
    xori x8, x7, 1
    li   x9, 0x00000001
    xori x10, x9, -2
    li x1, 0x00000000
    ori x2, x1, 0x0
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x0
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x700
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x000
    li x1, 0x00000000
    ori x2, x1, -1
    li x1, 0x12345678
    ori x2, x1, -1
    li x1, 0x80000000
    ori x2, x1, -2048
    li x1, 0x0000F0F0
    ori x2, x1, 0x00F
    li x1, 0xFFFF0000
    ori x2, x1, 0x123
    li x1, 0xDEADBEEF
    ori x2, x1, 0x0AA
    li x1, 0x00001234
    ori x2, x1, 0x7FF
    li x1, 0x7FFFFFFF
    ori x2, x1, 0x001
    li x1, 0x80000000
    ori x2, x1, 0x7FF
    li x1, 0x80000000
    ori x2, x1, 0x700
    ori x0, x1, 0x7FF
    li x1, 0x0000000F
    ori x2, x1, 0x0F0
    ori x3, x2, 0x700
    ori x4, x3, -1
    li x1, 0x00000000
    andi x2, x1, 0x0
    li x1, 0x00000000
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x700
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xAAAAAAAA
    andi x2, x1, 0x555
    li x1, 0x55555555
    andi x2, x1, 0x7AA
    li x1, 0x12345678
    andi x2, x1, 0x7FF
    li x1, 0x12345678
    andi x2, x1, 0x000
    li x1, 0x0000FFFF
    andi x2, x1, -1
    li x1, 0x0000FFFF
    andi x2, x1, -2048
    li x1, 0xF0F0F0F0
    andi x2, x1, -1
    li x1, 0xDEADBEEF
    andi x2, x1, 0x0AA
    li x1, 0x7FFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x700
    andi x0, x1, 0x7F
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0FF
    andi x2, x2, 0x00F
    andi x2, x2, -1
    andi x2, x2, 0x000
    li x1, 0x00000000
    slli x2, x1, 5
    li x1, 0xFFFFFFFF
    slli x2, x1, 0
    li x1, 0xFFFFFFFF
    slli x2, x1, 1
    li x1, 0xFFFFFFFF
    slli x2, x1, 31
    li x1, 0x00FF00FF
    slli x2, x1, 8
    li x1, 0x0F0F0F0F
    slli x2, x1, 4
    li x1, 0x40000000
    slli x2, x1, 1
    li x1, 0x40000000
    slli x2, x1, 2
    li x1, 0xAAAAAAAA
    slli x2, x1, 1
    li x1, 0x55555555
    slli x2, x1, 1
    li x1, 0x00000001
    slli x2, x1, 31
    li x1, 0x00000003
    slli x2, x1, 5
    li x1, 0x00000003
    slli x2, x1, 31
    li x1, 0xFFFFFFFF
    slli x0, x1, 4
    li x1, 0x00000001
    slli x2, x1, 1
    slli x2, x2, 1
    slli x2, x2, 2
    slli x2, x2, 3
    li x1, 0x80000000
    srli x2, x1, 1
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0xAAAAAAAA
    srli x2, x1, 1
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    li x1, 0xF0000000
    srli x2, x1, 4
    li x1, 0x80000000
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 4
    li x1, 0xF000000F
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 16
    li x1, 0xF000000F
    srli x2, x1, 24
    li x1, 0xFFFFFFFF
    srli x0, x1, 8
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    srli x2, x2, 1
    srli x2, x2, 2
    srli x2, x2, 3
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0x12345678
    srai x2, x1, 0
    li x1, 0x7FFFFFFF
    srai x2, x1, 31
    li x1, -1024               
    srai x2, x1, 0             
    srai x3, x1, 4
    srai x4, x1, 8
    srai x5, x1, 10
    li x1, 0x00000F00
    srai x2, x1, 4
    li x1, -0x00000F00
    srai x2, x1, 4
    li x1, 0xFFFFFFFF          
    srai x2, x1, 1
    li x1, 0x80000001
    srai x2, x1, 1
    li x10, 0xFFFFFFF0
    li x11, 2
    srai x12, x10, 1
    srai x13, x10, 4
    li x5, -64
    srai x5, x5, 1
    srai x5, x5, 1
    srai x5, x5, 2
    li x1, 0x7FFFFFFF
    .word 0x4070D093  
    li x1, 5
    slti x2, x1, 10
    li x1, -10
    slti x2, x1, -5
    li x1, -1
    slti x2, x1, 1
    li x1, 1
    slti x2, x1, -1
    li x1, 0x7FFFFFFF          
    slti x2, x1, 0x7FF
    li x1, 0
    slti x2, x1, -1
    li x1, 0x00001000
    slti x2, x1, -1
    li x1, -4096
    slti x2, x1, -1
    li x1, -2
    slti x2, x1, -2
    li x1, -3
    slti x2, x1, -2
    li x5, 3
    slti x5, x5, 10     
    slti x5, x5, 1      
    slti x5, x5, 2      
    li x10, -128
    slti x11, x10, -127
    slti x12, x11, 0
    li x13, 127
    slti x14, x13, 128
    li x1, 5
    sltiu x2, x1, 10
    li x1, 10
    sltiu x2, x1, 10
    li x1, 0
    sltiu x2, x1, 0
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFF
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFE
    li x1, 0x80000000
    sltiu x2, x1, 0x7FF
    li x1, 0x80000000
    sltiu x2, x1, 0xFFFFFFFF
    li x5, 3
    sltiu x5, x5, 10     
    sltiu x5, x5, 1      
    sltiu x5, x5, 2      
    li x1, 12345
    sltiu x0, x1, 100
    li x1, 0x0000FFFF
    sltiu x2, x1, 0x100
    li x1, 0x00010000
    sltiu x2, x1, 0x7FF
lui x1, 0x00000
lui x2, 0x00001
lui x3, 0x000AB
lui x4, 0xABCDE
lui x5, 0x80000
lui x6, 0xFFFFF
lui x7, 0x7FFFF
lui x0, 0x12345
lui x9, 0xABCDF
lui x11, 0x00000
lui x12, 0x7FFFF
lui x13, 0x80000
lui x14, 0xFFFFF
lui x15, 0x00010
addi x15, x15, 0x123
lui x16, 0xABCDE
addi x16, x16, -1
lui x17, 0xFFFFF
addi x17, x17, -2048
lui x18, 0x7FFFF
lui x19, 0x80000
    addi x6, x5, 10        
    li   x31, 0x7FFFFFFF
    addi x1, x31, -2048     
    addi x2, x2, 0        
    addi x3, x3, 0        
    li   x1, 0x0F0F0F0F
    xori x2, x1, 0x00FF       
    li   x3, 0x12345678
    xori x4, x3, 0
    li   x5, 0xAAAAAAAA
    xori x6, x5, -1
    li   x7, 0x00000FFF
    xori x8, x7, -2048
    li   x9, 0xFFFFF000
    xori x10, x9, 2047
    xori x11, x0, 0x7F
    xori x12, x0, -1
    li   x13, 0x55555555
    xori x0, x13, 0x2AA
    li   x14, 0x0F0F0F0F
    xori x14, x14, 0x00F0
    li   x15, 0xAAAAAAAA
    xori x16, x15, 0x555
    li   x17, 0x55555555
    xori x18, x17, 0x2AA
    li   x19, 0x12345678
    xori x20, x19, -1
    li   x21, 0xAAAAAAAA
    xori x22, x21, 0x555
    xori x23, x22, 0x3AA
    xori x24, x0, -2048
    li   x25, 0x80000000
    xori x26, x25, 0x7FF
    li   x27, 0x7FFFFFFF
    xori x28, x27, -1
    li   x29, 0x0000F0F0
    xori x30, x29, 0x0F0
    li   x31, 0x00000001
    xori x1, x31, 0x700     
    li   x2, 0x12345678
    xori x2, x2, 0x7FF
    li   x3, 0xDEADBEEF
    xori x4, x3, 0x3AD
    li   x5, 0xCAFEBABE
    xori x6, x5, -512
    li   x7, 0xABCDABCD
    xori x8, x7, 1
    li   x9, 0x00000001
    xori x10, x9, -2
    li x1, 0x00000000
    ori x2, x1, 0x0
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x0
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x700
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x000
    li x1, 0x00000000
    ori x2, x1, -1
    li x1, 0x12345678
    ori x2, x1, -1
    li x1, 0x80000000
    ori x2, x1, -2048
    li x1, 0x0000F0F0
    ori x2, x1, 0x00F
    li x1, 0xFFFF0000
    ori x2, x1, 0x123
    li x1, 0xDEADBEEF
    ori x2, x1, 0x0AA
    li x1, 0x00001234
    ori x2, x1, 0x7FF
    li x1, 0x7FFFFFFF
    ori x2, x1, 0x001
    li x1, 0x80000000
    ori x2, x1, 0x7FF
    li x1, 0x80000000
    ori x2, x1, 0x700
    ori x0, x1, 0x7FF
    li x1, 0x0000000F
    ori x2, x1, 0x0F0
    ori x3, x2, 0x700
    ori x4, x3, -1
    li x1, 0x00000000
    andi x2, x1, 0x0
    li x1, 0x00000000
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x700
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xAAAAAAAA
    andi x2, x1, 0x555
    li x1, 0x55555555
    andi x2, x1, 0x7AA
    li x1, 0x12345678
    andi x2, x1, 0x7FF
    li x1, 0x12345678
    andi x2, x1, 0x000
    li x1, 0x0000FFFF
    andi x2, x1, -1
    li x1, 0x0000FFFF
    andi x2, x1, -2048
    li x1, 0xF0F0F0F0
    andi x2, x1, -1
    li x1, 0xDEADBEEF
    andi x2, x1, 0x0AA
    li x1, 0x7FFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x700
    andi x0, x1, 0x7F
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0FF
    andi x2, x2, 0x00F
    andi x2, x2, -1
    andi x2, x2, 0x000
    li x1, 0x00000000
    slli x2, x1, 5
    li x1, 0xFFFFFFFF
    slli x2, x1, 0
    li x1, 0xFFFFFFFF
    slli x2, x1, 1
    li x1, 0xFFFFFFFF
    slli x2, x1, 31
    li x1, 0x00FF00FF
    slli x2, x1, 8
    li x1, 0x0F0F0F0F
    slli x2, x1, 4
    li x1, 0x40000000
    slli x2, x1, 1
    li x1, 0x40000000
    slli x2, x1, 2
    li x1, 0xAAAAAAAA
    slli x2, x1, 1
    li x1, 0x55555555
    slli x2, x1, 1
    li x1, 0x00000001
    slli x2, x1, 31
    li x1, 0x00000003
    slli x2, x1, 5
    li x1, 0x00000003
    slli x2, x1, 31
    li x1, 0xFFFFFFFF
    slli x0, x1, 4
    li x1, 0x00000001
    slli x2, x1, 1
    slli x2, x2, 1
    slli x2, x2, 2
    slli x2, x2, 3
    li x1, 0x80000000
    srli x2, x1, 1
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0xAAAAAAAA
    srli x2, x1, 1
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    li x1, 0xF0000000
    srli x2, x1, 4
    li x1, 0x80000000
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 4
    li x1, 0xF000000F
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 16
    li x1, 0xF000000F
    srli x2, x1, 24
    li x1, 0xFFFFFFFF
    srli x0, x1, 8
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    srli x2, x2, 1
    srli x2, x2, 2
    srli x2, x2, 3
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0x12345678
    srai x2, x1, 0
    li x1, 0x7FFFFFFF
    srai x2, x1, 31
    li x1, -1024               
    srai x2, x1, 0             
    srai x3, x1, 4
    srai x4, x1, 8
    srai x5, x1, 10
    li x1, 0x00000F00
    srai x2, x1, 4
    li x1, -0x00000F00
    srai x2, x1, 4
    li x1, 0xFFFFFFFF          
    srai x2, x1, 1
    li x1, 0x80000001
    srai x2, x1, 1
    li x10, 0xFFFFFFF0
    li x11, 2
    srai x12, x10, 1
    srai x13, x10, 4
    li x5, -64
    srai x5, x5, 1
    srai x5, x5, 1
    srai x5, x5, 2
    li x1, 0x7FFFFFFF
    .word 0x4070D093  
    li x1, 5
    slti x2, x1, 10
    li x1, -10
    slti x2, x1, -5
    li x1, -1
    slti x2, x1, 1
    li x1, 1
    slti x2, x1, -1
    li x1, 0x7FFFFFFF          
    slti x2, x1, 0x7FF
    li x1, 0
    slti x2, x1, -1
    li x1, 0x00001000
    slti x2, x1, -1
    li x1, -4096
    slti x2, x1, -1
    li x1, -2
    slti x2, x1, -2
    li x1, -3
    slti x2, x1, -2
    li x5, 3
    slti x5, x5, 10     
    slti x5, x5, 1      
    slti x5, x5, 2      
    li x10, -128
    slti x11, x10, -127
    slti x12, x11, 0
    li x13, 127
    slti x14, x13, 128
    li x1, 5
    sltiu x2, x1, 10
    li x1, 10
    sltiu x2, x1, 10
    li x1, 0
    sltiu x2, x1, 0
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFF
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFE
    li x1, 0x80000000
    sltiu x2, x1, 0x7FF
    li x1, 0x80000000
    sltiu x2, x1, 0xFFFFFFFF
    li x5, 3
    sltiu x5, x5, 10     
    sltiu x5, x5, 1      
    sltiu x5, x5, 2      
    li x1, 12345
    sltiu x0, x1, 100
    li x1, 0x0000FFFF
    sltiu x2, x1, 0x100
    li x1, 0x00010000
    sltiu x2, x1, 0x7FF
lui x1, 0x00000
lui x2, 0x00001
lui x3, 0x000AB
lui x4, 0xABCDE
lui x5, 0x80000
lui x6, 0xFFFFF
lui x7, 0x7FFFF
lui x0, 0x12345
lui x9, 0xABCDF
lui x11, 0x00000
lui x12, 0x7FFFF
lui x13, 0x80000
lui x14, 0xFFFFF
lui x15, 0x00010
addi x15, x15, 0x123
lui x16, 0xABCDE
addi x16, x16, -1
lui x17, 0xFFFFF
addi x17, x17, -2048
lui x18, 0x7FFFF
lui x19, 0x80000
    addi x6, x5, 10        
    li   x31, 0x7FFFFFFF
    addi x1, x31, -2048     
    addi x2, x2, 0        
    addi x3, x3, 0        
    li   x1, 0x0F0F0F0F
    xori x2, x1, 0x00FF       
    li   x3, 0x12345678
    xori x4, x3, 0
    li   x5, 0xAAAAAAAA
    xori x6, x5, -1
    li   x7, 0x00000FFF
    xori x8, x7, -2048
    li   x9, 0xFFFFF000
    xori x10, x9, 2047
    xori x11, x0, 0x7F
    xori x12, x0, -1
    li   x13, 0x55555555
    xori x0, x13, 0x2AA
    li   x14, 0x0F0F0F0F
    xori x14, x14, 0x00F0
    li   x15, 0xAAAAAAAA
    xori x16, x15, 0x555
    li   x17, 0x55555555
    xori x18, x17, 0x2AA
    li   x19, 0x12345678
    xori x20, x19, -1
    li   x21, 0xAAAAAAAA
    xori x22, x21, 0x555
    xori x23, x22, 0x3AA
    xori x24, x0, -2048
    li   x25, 0x80000000
    xori x26, x25, 0x7FF
    li   x27, 0x7FFFFFFF
    xori x28, x27, -1
    li   x29, 0x0000F0F0
    xori x30, x29, 0x0F0
    li   x31, 0x00000001
    xori x1, x31, 0x700     
    li   x2, 0x12345678
    xori x2, x2, 0x7FF
    li   x3, 0xDEADBEEF
    xori x4, x3, 0x3AD
    li   x5, 0xCAFEBABE
    xori x6, x5, -512
    li   x7, 0xABCDABCD
    xori x8, x7, 1
    li   x9, 0x00000001
    xori x10, x9, -2
    li x1, 0x00000000
    ori x2, x1, 0x0
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x0
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x700
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x000
    li x1, 0x00000000
    ori x2, x1, -1
    li x1, 0x12345678
    ori x2, x1, -1
    li x1, 0x80000000
    ori x2, x1, -2048
    li x1, 0x0000F0F0
    ori x2, x1, 0x00F
    li x1, 0xFFFF0000
    ori x2, x1, 0x123
    li x1, 0xDEADBEEF
    ori x2, x1, 0x0AA
    li x1, 0x00001234
    ori x2, x1, 0x7FF
    li x1, 0x7FFFFFFF
    ori x2, x1, 0x001
    li x1, 0x80000000
    ori x2, x1, 0x7FF
    li x1, 0x80000000
    ori x2, x1, 0x700
    ori x0, x1, 0x7FF
    li x1, 0x0000000F
    ori x2, x1, 0x0F0
    ori x3, x2, 0x700
    ori x4, x3, -1
    li x1, 0x00000000
    andi x2, x1, 0x0
    li x1, 0x00000000
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x700
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xAAAAAAAA
    andi x2, x1, 0x555
    li x1, 0x55555555
    andi x2, x1, 0x7AA
    li x1, 0x12345678
    andi x2, x1, 0x7FF
    li x1, 0x12345678
    andi x2, x1, 0x000
    li x1, 0x0000FFFF
    andi x2, x1, -1
    li x1, 0x0000FFFF
    andi x2, x1, -2048
    li x1, 0xF0F0F0F0
    andi x2, x1, -1
    li x1, 0xDEADBEEF
    andi x2, x1, 0x0AA
    li x1, 0x7FFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x700
    andi x0, x1, 0x7F
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0FF
    andi x2, x2, 0x00F
    andi x2, x2, -1
    andi x2, x2, 0x000
    li x1, 0x00000000
    slli x2, x1, 5
    li x1, 0xFFFFFFFF
    slli x2, x1, 0
    li x1, 0xFFFFFFFF
    slli x2, x1, 1
    li x1, 0xFFFFFFFF
    slli x2, x1, 31
    li x1, 0x00FF00FF
    slli x2, x1, 8
    li x1, 0x0F0F0F0F
    slli x2, x1, 4
    li x1, 0x40000000
    slli x2, x1, 1
    li x1, 0x40000000
    slli x2, x1, 2
    li x1, 0xAAAAAAAA
    slli x2, x1, 1
    li x1, 0x55555555
    slli x2, x1, 1
    li x1, 0x00000001
    slli x2, x1, 31
    li x1, 0x00000003
    slli x2, x1, 5
    li x1, 0x00000003
    slli x2, x1, 31
    li x1, 0xFFFFFFFF
    slli x0, x1, 4
    li x1, 0x00000001
    slli x2, x1, 1
    slli x2, x2, 1
    slli x2, x2, 2
    slli x2, x2, 3
    li x1, 0x80000000
    srli x2, x1, 1
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0xAAAAAAAA
    srli x2, x1, 1
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    li x1, 0xF0000000
    srli x2, x1, 4
    li x1, 0x80000000
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 4
    li x1, 0xF000000F
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 16
    li x1, 0xF000000F
    srli x2, x1, 24
    li x1, 0xFFFFFFFF
    srli x0, x1, 8
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    srli x2, x2, 1
    srli x2, x2, 2
    srli x2, x2, 3
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0x12345678
    srai x2, x1, 0
    li x1, 0x7FFFFFFF
    srai x2, x1, 31
    li x1, -1024               
    srai x2, x1, 0             
    srai x3, x1, 4
    srai x4, x1, 8
    srai x5, x1, 10
    li x1, 0x00000F00
    srai x2, x1, 4
    li x1, -0x00000F00
    srai x2, x1, 4
    li x1, 0xFFFFFFFF          
    srai x2, x1, 1
    li x1, 0x80000001
    srai x2, x1, 1
    li x10, 0xFFFFFFF0
    li x11, 2
    srai x12, x10, 1
    srai x13, x10, 4
    li x5, -64
    srai x5, x5, 1
    srai x5, x5, 1
    srai x5, x5, 2
    li x1, 0x7FFFFFFF
    .word 0x4070D093  
    li x1, 5
    slti x2, x1, 10
    li x1, -10
    slti x2, x1, -5
    li x1, -1
    slti x2, x1, 1
    li x1, 1
    slti x2, x1, -1
    li x1, 0x7FFFFFFF          
    slti x2, x1, 0x7FF
    li x1, 0
    slti x2, x1, -1
    li x1, 0x00001000
    slti x2, x1, -1
    li x1, -4096
    slti x2, x1, -1
    li x1, -2
    slti x2, x1, -2
    li x1, -3
    slti x2, x1, -2
    li x5, 3
    slti x5, x5, 10     
    slti x5, x5, 1      
    slti x5, x5, 2      
    li x10, -128
    slti x11, x10, -127
    slti x12, x11, 0
    li x13, 127
    slti x14, x13, 128
    li x1, 5
    sltiu x2, x1, 10
    li x1, 10
    sltiu x2, x1, 10
    li x1, 0
    sltiu x2, x1, 0
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFF
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFE
    li x1, 0x80000000
    sltiu x2, x1, 0x7FF
    li x1, 0x80000000
    sltiu x2, x1, 0xFFFFFFFF
    li x5, 3
    sltiu x5, x5, 10     
    sltiu x5, x5, 1      
    sltiu x5, x5, 2      
    li x1, 12345
    sltiu x0, x1, 100
    li x1, 0x0000FFFF
    sltiu x2, x1, 0x100
    li x1, 0x00010000
    sltiu x2, x1, 0x7FF
lui x1, 0x00000
lui x2, 0x00001
lui x3, 0x000AB
lui x4, 0xABCDE
lui x5, 0x80000
lui x6, 0xFFFFF
lui x7, 0x7FFFF
lui x0, 0x12345
lui x9, 0xABCDF
lui x11, 0x00000
lui x12, 0x7FFFF
lui x13, 0x80000
lui x14, 0xFFFFF
lui x15, 0x00010
addi x15, x15, 0x123
lui x16, 0xABCDE
addi x16, x16, -1
lui x17, 0xFFFFF
addi x17, x17, -2048
lui x18, 0x7FFFF
lui x19, 0x80000
    addi x6, x5, 10        
    li   x31, 0x7FFFFFFF
    addi x1, x31, -2048     
    addi x2, x2, 0        
    addi x3, x3, 0        
    li   x1, 0x0F0F0F0F
    xori x2, x1, 0x00FF       
    li   x3, 0x12345678
    xori x4, x3, 0
    li   x5, 0xAAAAAAAA
    xori x6, x5, -1
    li   x7, 0x00000FFF
    xori x8, x7, -2048
    li   x9, 0xFFFFF000
    xori x10, x9, 2047
    xori x11, x0, 0x7F
    xori x12, x0, -1
    li   x13, 0x55555555
    xori x0, x13, 0x2AA
    li   x14, 0x0F0F0F0F
    xori x14, x14, 0x00F0
    li   x15, 0xAAAAAAAA
    xori x16, x15, 0x555
    li   x17, 0x55555555
    xori x18, x17, 0x2AA
    li   x19, 0x12345678
    xori x20, x19, -1
    li   x21, 0xAAAAAAAA
    xori x22, x21, 0x555
    xori x23, x22, 0x3AA
    xori x24, x0, -2048
    li   x25, 0x80000000
    xori x26, x25, 0x7FF
    li   x27, 0x7FFFFFFF
    xori x28, x27, -1
    li   x29, 0x0000F0F0
    xori x30, x29, 0x0F0
    li   x31, 0x00000001
    xori x1, x31, 0x700     
    li   x2, 0x12345678
    xori x2, x2, 0x7FF
    li   x3, 0xDEADBEEF
    xori x4, x3, 0x3AD
    li   x5, 0xCAFEBABE
    xori x6, x5, -512
    li   x7, 0xABCDABCD
    xori x8, x7, 1
    li   x9, 0x00000001
    xori x10, x9, -2
    li x1, 0x00000000
    ori x2, x1, 0x0
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x0
    li x1, 0xFFFFFFFF
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x00000000
    ori x2, x1, 0x700
    li x1, 0x00000000
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x7FF
    li x1, 0x12345678
    ori x2, x1, 0x000
    li x1, 0x00000000
    ori x2, x1, -1
    li x1, 0x12345678
    ori x2, x1, -1
    li x1, 0x80000000
    ori x2, x1, -2048
    li x1, 0x0000F0F0
    ori x2, x1, 0x00F
    li x1, 0xFFFF0000
    ori x2, x1, 0x123
    li x1, 0xDEADBEEF
    ori x2, x1, 0x0AA
    li x1, 0x00001234
    ori x2, x1, 0x7FF
    li x1, 0x7FFFFFFF
    ori x2, x1, 0x001
    li x1, 0x80000000
    ori x2, x1, 0x7FF
    li x1, 0x80000000
    ori x2, x1, 0x700
    ori x0, x1, 0x7FF
    li x1, 0x0000000F
    ori x2, x1, 0x0F0
    ori x3, x2, 0x700
    ori x4, x3, -1
    li x1, 0x00000000
    andi x2, x1, 0x0
    li x1, 0x00000000
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x700
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0xAAAAAAAA
    andi x2, x1, 0x555
    li x1, 0x55555555
    andi x2, x1, 0x7AA
    li x1, 0x12345678
    andi x2, x1, 0x7FF
    li x1, 0x12345678
    andi x2, x1, 0x000
    li x1, 0x0000FFFF
    andi x2, x1, -1
    li x1, 0x0000FFFF
    andi x2, x1, -2048
    li x1, 0xF0F0F0F0
    andi x2, x1, -1
    li x1, 0xDEADBEEF
    andi x2, x1, 0x0AA
    li x1, 0x7FFFFFFF
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x7FF
    li x1, 0x80000000
    andi x2, x1, 0x700
    andi x0, x1, 0x7F
    li x1, 0xFFFFFFFF
    andi x2, x1, 0x0FF
    andi x2, x2, 0x00F
    andi x2, x2, -1
    andi x2, x2, 0x000
    li x1, 0x00000000
    slli x2, x1, 5
    li x1, 0xFFFFFFFF
    slli x2, x1, 0
    li x1, 0xFFFFFFFF
    slli x2, x1, 1
    li x1, 0xFFFFFFFF
    slli x2, x1, 31
    li x1, 0x00FF00FF
    slli x2, x1, 8
    li x1, 0x0F0F0F0F
    slli x2, x1, 4
    li x1, 0x40000000
    slli x2, x1, 1
    li x1, 0x40000000
    slli x2, x1, 2
    li x1, 0xAAAAAAAA
    slli x2, x1, 1
    li x1, 0x55555555
    slli x2, x1, 1
    li x1, 0x00000001
    slli x2, x1, 31
    li x1, 0x00000003
    slli x2, x1, 5
    li x1, 0x00000003
    slli x2, x1, 31
    li x1, 0xFFFFFFFF
    slli x0, x1, 4
    li x1, 0x00000001
    slli x2, x1, 1
    slli x2, x2, 1
    slli x2, x2, 2
    slli x2, x2, 3
    li x1, 0x80000000
    srli x2, x1, 1
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0x80000000
    srli x2, x1, 31
    li x1, 0xAAAAAAAA
    srli x2, x1, 1
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    li x1, 0xF0000000
    srli x2, x1, 4
    li x1, 0x80000000
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 4
    li x1, 0xF000000F
    srli x2, x1, 8
    li x1, 0xF000000F
    srli x2, x1, 16
    li x1, 0xF000000F
    srli x2, x1, 24
    li x1, 0xFFFFFFFF
    srli x0, x1, 8
    li x1, 0xFFFFFFFF
    srli x2, x1, 1
    srli x2, x2, 1
    srli x2, x2, 2
    srli x2, x2, 3
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0xFFFFFFFF
    srli x2, x1, 31
    li x1, 0x12345678
    srai x2, x1, 0
    li x1, 0x7FFFFFFF
    srai x2, x1, 31
    li x1, -1024               
    srai x2, x1, 0             
    srai x3, x1, 4
    srai x4, x1, 8
    srai x5, x1, 10
    li x1, 0x00000F00
    srai x2, x1, 4
    li x1, -0x00000F00
    srai x2, x1, 4
    li x1, 0xFFFFFFFF          
    srai x2, x1, 1
    li x1, 0x80000001
    srai x2, x1, 1
    li x10, 0xFFFFFFF0
    li x11, 2
    srai x12, x10, 1
    srai x13, x10, 4
    li x5, -64
    srai x5, x5, 1
    srai x5, x5, 1
    srai x5, x5, 2
    li x1, 0x7FFFFFFF
    .word 0x4070D093  
    li x1, 5
    slti x2, x1, 10
    li x1, -10
    slti x2, x1, -5
    li x1, -1
    slti x2, x1, 1
    li x1, 1
    slti x2, x1, -1
    li x1, 0x7FFFFFFF          
    slti x2, x1, 0x7FF
    li x1, 0
    slti x2, x1, -1
    li x1, 0x00001000
    slti x2, x1, -1
    li x1, -4096
    slti x2, x1, -1
    li x1, -2
    slti x2, x1, -2
    li x1, -3
    slti x2, x1, -2
    li x5, 3
    slti x5, x5, 10     
    slti x5, x5, 1      
    slti x5, x5, 2      
    li x10, -128
    slti x11, x10, -127
    slti x12, x11, 0
    li x13, 127
    slti x14, x13, 128
    li x1, 5
    sltiu x2, x1, 10
    li x1, 10
    sltiu x2, x1, 10
    li x1, 0
    sltiu x2, x1, 0
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFF
    li x1, 0xFFFFFFFF
    sltiu x2, x1, 0xFFFFFFFE
    li x1, 0x80000000
    sltiu x2, x1, 0x7FF
    li x1, 0x80000000
    sltiu x2, x1, 0xFFFFFFFF
    li x5, 3
    sltiu x5, x5, 10     
    sltiu x5, x5, 1      
    sltiu x5, x5, 2      
    li x1, 12345
    sltiu x0, x1, 100
    li x1, 0x0000FFFF
    sltiu x2, x1, 0x100
    li x1, 0x00010000
    sltiu x2, x1, 0x7FF
lui x1, 0x00000
lui x2, 0x00001
lui x3, 0x000AB
lui x4, 0xABCDE
lui x5, 0x80000
lui x6, 0xFFFFF
lui x7, 0x7FFFF
lui x0, 0x12345
lui x9, 0xABCDF
lui x11, 0x00000

    # -------------------------------------------------------------
    # --- End of Test ---
    # -------------------------------------------------------------
    nop
    nop
    nop

    slti x0, x0, -256
