# Tomasulo OOO Processor

Sam Slaw, Logan Wonnacott, Jacob Torry

# CP1

## Block Diagram

## Bugs

requesting from cache too agressively, changed it by passing a line bue enable as a parameter \

# CP2

## BUGS

BUG (10/30/2025): Previously, alu_pkt was driven purely combinationally, which meant operand and control signals could change mid-cycle as RS or CDB values updated. This caused unstable or incorrect data to reach the ALU.

- FIX: Added alu_pkt_next — registering alu_pkt before sending it to the ALU_FU.By introducing alu_pkt_next and latching it on the clock edge, the packet is now stable for the entire cycle, ensuring clean timing, preventing glitches, and maintaining correct behavior for dependent instructions.

BUG (10/31/2025):
We were letting decode hand out ROB tags every cycle, even if that instruction didn't actually get enqueued into the ROB/RS that cycle. So multiple instructions could end up "claiming" the same ROB entry. Then retirement wrote the wrong value for the wrong instruction.

- FIX: create one dispatch\*fire signal that means "yes, we are actually dispatching this instruction right now." Use that one signal to:
  - dequeue from imem\*q
  - allocate ROB entry
    _ rename the dest reg
    _ enqueue into RS
    If dispatch_fire is 0, none of those things happen. So tags can't get reused.

BUG (10/31/2025): In the old code, commit would always update regs[commit_rd] in the same cycle, even if we were also renaming that same architectural register this cycle. Which meant tha the commit would clobbering an in-flight rename to the same reg in the same cycle.

- FIX: (rd_to_rename != commit_rd || !rename_en) condition.\
  This addition prevents an older instruction's commit from overwriting the fact that a newer instruction is now the one responsible for that register.

BUG (10/31/2025): When the ROB commits a value, the register file only updates after the clock edge. If another instruction tries to read that register in the same cycle, it still sees the old value for one cycle.

- FIX: Line 61 and 81 in regfile.sv
  The fix adds a bypass so that when a register is committed, its new value is immediately forwarded to any instruction reading it in the same cycle. This prevents a one-cycle delay where the instruction would have seen outdated data.

BUG (10/31/2025): Reservation station entries only listened to the CDB to wake up their operands. If a source register was satisfied later at ROB commit (not by a functional unit result on the CDB), that value was never seen by the RS. Result: the RS operand stayed invalid, even though the value was now known, so the instruction could never become ready and issue.

- FIX: We added forward_from_commit from the ROB into issue. On every cycle, if the ROB commits a value, we compare its ROB tag against any waiting rs1/rs2 tags in the RS. If they match, we fill in the data and flip that operand to valid. This lets reservation station entries wake up on commit, not only on CDB broadcast, and prevents instructions from getting permanently stuck.

BUG (11/3/2025): Issues.sv line 271 -> Using only forward_from_commit.valid allowed instructions to forward values from ROB entries that were still marked as busy (not yet committed), causing stale or incorrect data to be used during issue.

- FIX: Adding !forward_from_commit.busy ensures that forwarding only occurs from completed ROB entries, preventing premature data forwarding and maintaining correct instruction dependencies.

CHANGE (11/3/2025): Completely changed the cdb arbiter. Before it was a round robin arbiter that only choose one result to broadcast per cycle, which meant we lost the other two requests (if there were 3 requests on the same cycle). Now it is a priority arbiter (DIV -> MUL -> ALU) where once a result is finished it is stored in a small FIFO so that we dont lose completed instructions.

# CP3

## BUGS

### 11/12/2025: Lost One-Cycle Read Pulse Between I-Cache Adapter and Memory Arbiter

Description:
The instruction cache adapter issued a single-cycle bmem_read pulse during its ISSUE state, but the memory arbiter was still in ARB_IDLE and not yet forwarding signals to memory. By the time the arbiter transitioned to SERVE_I, the adapter had already deasserted bmem_read, causing the memory to never receive the request. As a result, bmem_rvalid never asserted, leaving the adapter stuck in the WAIT state.

Fix:
Modified the arbiter’s ARB_IDLE case to forward the selected client’s memory request immediately (“look-through grant”). This ensures that single-cycle read pulses from the cache adapter are not lost when transitioning from ARB_IDLE to SERVE_I, allowing the memory to receive the request and return data correctly.

Higher frequencies count was getting close for cache adapters\

Dache adapter was just broke\

not invalidating inflight memory packets\

linebug using tag ans set to check if using line or needed cache\

assigning desitnation register to branches\

# Performance Log

When calculating $PD^4$ use mW and mS.

## CP3 Baseline

Clock Period: 10000 ps \
Frequency: 100 MHz \
Area: 229547 $um^2$

I$ \
Ways: 4 \
Sets: 16 \
Size: 2048 Bytes

D$ \
Ways: 4 \
Sets: 16 \
Size: 2048 Bytes

|                     | FFT          | Compression | Mergesort  | AES_SHA      | Coremark  |
| :------------------ | :----------- | :---------- | :--------- | :----------- | :-------- |
| IPC                 | 0.395        | 0.389       | 0.389      | 0.332        | 0.323     |
| Power               | 12.5         | 12.529      | 12.703     | 12.474       | 12.62     |
| Delay               | 29.41        | 11.04       | 12.36      | 23.38        | 9.04      |
| $PD^4$              | 9,357,168.84 | 186,195.52  | 296,875.95 | 3,730,341.15 | 84,177.00 |
| Avg I$ Cycles/Fetch | 12.27        | 7.91        | 8.22       | 15.96        | 8.21      |
| Avg D$ Cycles/Fetch | 11.07        | 12.75       | 9.84       | 7.63         | 10.72     |
| BR Accuracy %       | 24.48        | 41.28       | 63.79      | 40.71        | 46.50     |
| JARL Accuracy %     | 0            | 0           | 0          | 0            | 0         |

## Parameterized Cache:

Clock Period: 10000 ps \
Frequency: 100 MHz \

### Test 1 (Large Caches)

Area: 405749 $um^2$

I$ \
Ways: 8 \
Sets: 32 \
Size: 8192 Bytes

D$ \
Ways: 8 \
Sets: 32 \
Size: 8192 Bytes

|                     | FFT        | Compression | Mergesort | AES_SHA   | Coremark  |
| :------------------ | :--------- | :---------- | :-------- | :-------- | :-------- |
| IPC                 | 0.397      | 0.39        | 0.396     | 0.381     | 0.327     |
| Power               | 15.67      | 15.84       | 15.97     | 15.79     | 15.83     |
| Delay               | 29.19      | 11.02       | 12.17     | 20.35     | 8.91      |
| $PD^4$              | 11376413.6 | 233604.688  | 350321.85 | 2707944.6 | 99768.106 |
| Avg I$ Cycles\Fetch | 12.24      | 7.91        | 8.19      | 12.90     | 8.07      |
| Avg D$ Cycles\Fecth | 10.99      | 12.72       | 9.71      | 6.64      | 10.58     |
| BR Accuracy %       | 24.47      | 41.27       | 63.79     | 40.71     | 46.5      |
| JARL Accuracy %     | 0          | 0           | 0         | 0         | 0         |

### Test 2 (Small Caches)

Area: 185113 $um^2$

I$ \
Ways: 2 \
Sets: 16 \
Size: 1024 Bytes

D$ \
Ways: 2 \
Sets: 16 \
Size: 1024 Bytes

|                     | FFT        | Compression | Mergesort  | AES_SHA | Coremark  |
| :------------------ | :--------- | :---------- | :--------- | :------ | :-------- |
| IPC                 | 0.391      | 0.389       | 0.383      | 0.277   | 0.318     |
| Power               | 8.66       | 8.90        | 9.05       | 8.75    | 8.90      |
| Delay               | 29.68      | 11.04       | 12.58      | 28.00   | 9.15      |
| $PD^4$              | 6720065.07 | 132210.6073 | 226658.047 | 5378240 | 62384.167 |
| Avg I$ Cycles\Fetch | 12.31      | 7.91        | 8.25       | 20.07   | 8.31      |
| Avg D$ Cycles\Fecth | 11.16      | 12.75       | 10.00      | 9.14    | 10.86     |
| BR Accuracy %       | 24.47      | 41.27       | 63.79      | 40.71   | 46.5      |
| JARL Accuracy %     | 0          | 0           | 0          | 0       | 0         |

### Test 3 (Direct Mapped I$, Small D$)

Area: 180200 $um^2$

I$ \
Ways: 1 \
Sets: 32 \
Size: 1024 Bytes

D$ \
Ways: 2 \
Sets: 16 \
Size: 1024 Bytes

|                     | FFT          | Compression | Mergesort  | AES_SHA      | Coremark  |
| :------------------ | :----------- | :---------- | :--------- | :----------- | :-------- |
| IPC                 | 0.391        | 0.389       | 0.383      | 0.282        | 0.317     |
| Power               | 5.26         | 5.63        | 5.76       | 5.29         | 5.63      |
| Delay               | 29.67        | 11.04       | 12.58      | 27.47        | 9.18      |
| $PD^4$              | 4,076,204.17 | 83,634.35   | 144,259.70 | 3,012,245.12 | 39,983.34 |
| Avg I$ Cycles/Fetch | 12.31        | 7.91        | 8.25       | 19.66        | 8.33      |
| Avg D$ Cycles/Fetch | 11.16        | 12.74       | 10.00      | 8.96         | 10.90     |
| BR Accuracy %       | 24.47        | 41.27       | 63.79      | 40.71        | 46.50     |
| JARL Accuracy %     | 0            | 0           | 0          | 0            | 0         |

## CLOCK = 1430 before we fail timing

## CP3

|               | FFT          | Compression | Mergesort  | AES_SHA      | Coremark  |
| :------------ | :----------- | :---------- | :--------- | :----------- | :-------- |
| IPC           | 0.395        | 0.389       | 0.389      | 0.332        | 0.323     |
| Power         | 12.5         | 12.529      | 12.703     | 12.474       | 12.62     |
| Delay         | 29.41        | 11.04       | 12.36      | 23.38        | 9.04      |
| $PD^4$        | 9,357,168.84 | 186,195.52  | 296,875.95 | 3,730,341.15 | 84,177.00 |
| BR Accuracy % | 24.48        | 41.28       | 63.79      | 40.71        | 46.50     |

## BR_PRED 512

Area: 312,269

|               | FFT          | Compression | Mergesort  | AES_SHA      | Coremark  |
| :------------ | :----------- | :---------- | :--------- | :----------- | :-------- |
| IPC           | 0.416        | 0.490       | 0.369      | 0.336        | 0.392     |
| Power         | 14.03        | 21.81       | 21.32      | 13.61        | 22.08     |
| Delay         | 27.93        | 8.78        | 13.03      | 23.11        | 7.43      |
| $PD^4$        | 8,537,710.29 | 129,608.57  | 614,560.81 | 3,882,021.23 | 67,290.58 |
| BR Accuracy % | 94.34        | 99.78       | 80.20      | 95.67        | 91.74     |

| Benchmark       | PD⁴ Change  | BR Accuracy Change |
| --------------- | ----------- | ------------------ |
| **FFT**         | **−8.76%**  | **+285.4%**        |
| **Compression** | **−30.37%** | **+141.7%**        |
| **Mergesort**   | **+107.0%** | **+25.7%**         |
| **AES_SHA**     | **+4.07%**  | **+135.0%**        |
| **Coremark**    | **−20.06%** | **+97.3%**         |

## BR_PRED 256 W Updated JAL - 100 MHZ

Area: 289911.39

|               | FFT        | Compression | Mergesort | AES_SHA    | Coremark |
| :------------ | :--------- | :---------- | :-------- | :--------- | :------- |
| IPC           | 0.4149     | 0.5572      | 0.4058    | 0.3389     | 0.4031   |
| Power         | 76.59      | 80.30       | 81.20     | 76.63      | 80.01    |
| Delay         | 27.98      | 7.72        | 11.87     | 22.90      | 7.23     |
| $PD^4$        | 46,942,142 | 284,779     | 1,611,977 | 21,073,698 | 219,087  |
| BR Accuracy % | 93.21      | 99.749      | 79.13     | 95.45      | 91.14    |

## BASELINE

| Benchmark   | IPC  | Power (mW) | Delay (ms) | \(PD^4\)  |
| ----------- | ---- | ---------- | ---------- | --------- |
| coremark_im | 0.41 | 18.88      | 1.43       | 78.21     |
| aes_sha     | 0.32 | 18.61      | 4.85       | 10,266.89 |
| compression | 0.49 | 18.88      | 1.77       | 184.80    |
| fft         | 0.55 | 18.91      | 4.25       | 6,170.68  |
| mergesort   | 0.45 | 18.83      | 2.15       | 404.78    |

## BR_PRED 256 W Updated JAL - 666 MHZ

clock = 1500
inc_iter = 3

wtf idk why
Area: 301359

ok power is fucked and nuked
526.784??

|               | FFT | Compression | Mergesort | AES_SHA | Coremark  |
| :------------ | :-- | :---------- | :-------- | :------ | :-------- |
| IPC           |     |             |           |         | 0.381553  |
| Power         |     |             |           |         | 526.784   |
| Delay         |     |             |           |         | 909.3     |
| $PD^4$        |     |             |           |         | 1.1462235 |
| BR Accuracy % |     |             |           |         | 0.911310  |

## BR_PRED 256 W JAL-500MHz 3 iterations

| Program             | IPC      | Delay    | Power   | Power · (Time/1e9)⁴ | BR Ratio |
| ------------------- | -------- | -------- | ------- | ------------------- | -------- |
| **coremark_im.elf** | 0.392976 | 1.48387  | 43.3446 | **210.1**           | 0.915026 |
| **aes_sha.elf**     | 0.285804 | 5.429828 | 41.3714 | **35,984**          | 0.948507 |
| **fft.elf**         | 0.430454 | 5.394368 | 41.8494 | **35,483**          | 0.931832 |
| **compression.elf** | 0.553307 | 1.554334 | 44.2291 | **258.4**           | 0.995377 |
| **mergesort.elf**   | 0.401236 | 2.40181  | 44.2968 | **1,472**           | 0.790378 |

## BASELINE

| Benchmark   | IPC  | Power (mW) | Delay (ms) | \(PD^4\)  |
| ----------- | ---- | ---------- | ---------- | --------- |
| coremark_im | 0.41 | 18.88      | 1.43       | 78.21     |
| aes_sha     | 0.32 | 18.61      | 4.85       | 10,266.89 |
| compression | 0.49 | 18.88      | 1.77       | 184.80    |
| fft         | 0.55 | 18.91      | 4.25       | 6,170.68  |
| mergesort   | 0.45 | 18.83      | 2.15       | 404.78    |

## BR_Pred 256 W JAL-666MHZ 3 Iterations

| Test     | IPC      | Delay (s) | Power     | Branch Rate | **P·Delay⁴**  |
| -------- | -------- | --------- | --------- | ----------- | ------------- |
| Coremark | 0.385615 | 1.134147  | 53.179360 | 91.5026     | **87.98**     |
| AES      | 0.266579 | 4.366071  | 50.613809 | 94.8507     | **18,399.63** |
| Compress | 0.553341 | 1.1655345 | 54.508700 | 99.5377     | **100.49**    |
| FFT      | 0.428224 | 4.066695  | 51.316100 | 93.1832     | **14,048.63** |
| Merge    | 0.897712 | 1.8127425 | 54.557800 | 79.0378     | **589.23**    |

## BR_Pred 256 Deep (666Mhz - 3 iter) vs Baseline

| Test     | IPC Change  | Delay Change | Power Change | P·Delay⁴ Change |
| -------- | ----------- | ------------ | ------------ | --------------- |
| Coremark | **−5.94%**  | +20.69%      | **+181.6%**  | **+12.48%**     |
| AES      | **−16.71%** | +9.95%       | **+171.9%**  | **+79.15%**     |
| Compress | +12.95%     | +34.20%      | **+188.7%**  | −45.60%         |
| FFT      | **−22.13%** | +4.33%       | **+171.4%**  | **+127.60%**    |
| Merge    | +99.49%     | +15.66%      | **+189.8%**  | **+45.60%**     |

## Branch Prediction Accuracy

| Test     | Static Not Taken | Static Taken | GSHARE Only | Two Level Only | Tournament |
| -------- | ---------------- | ------------ | ----------- | -------------- | ---------- |
| Coremark | 46.50            | 53.5001      | 90.1758     | 61.1456        | 91.5026    |
| AES      | 40.71            | 59.2872      | 94.7018     | 60.3468        | 94.8507    |
| Compress | 41.27            | 58.7211      | 98.5107     | 41.6950        | 99.5377    |
| FFT      | 24.47            | 75.5232      | 93.6257     | 41.5069        | 93.1832    |
| Merge    | 63.79            | 36.2119      | 76.8669     | 65.8212        | 79.0378    |

# GSHARE ONlY

Program: ../testcode/coremark_im.elf
Segment IPC: 0.388092
Segment Time: 1502546000
BR Flushes: 5420 / 55170 Ratio=0.901758

Program: ../testcode/cp3_release_benches/im/aes_sha.elf
Segment IPC: 0.285805
Segment Time: 5429822000
BR Flushes: 605 / 11419 Ratio=0.947018

Program: ../testcode/cp3_release_benches/im/compression.elf
Segment IPC: 0.547056
Segment Time: 1572094000
BR Flushes: 902 / 60566 Ratio=0.985107

Program: ../testcode/cp3_release_benches/im/fft.elf
Segment IPC: 0.430711
Segment Time: 5391152000
BR Flushes: 1599 / 25085 Ratio=0.936257

Program: ../testcode/cp3_release_benches/im/mergesort.elf
Segment IPC: 0.392011
Segment Time: 2458332000
BR Flushes: 18478 / 79877 Ratio=0.768669

# 2-lvl ONLY

Program: ../testcode/coremark_im.elf
Segment IPC: 0.312633
Segment Time: 1865212000
BR Flushes: 21436 / 55170 Ratio=0.611456
Power: None

Program: ../testcode/cp3_release_benches/im/aes_sha.elf
Segment IPC: 0.276178
Segment Time: 5619090000
BR Flushes: 4528 / 11419 Ratio=0.603468
Power: None

Program: ../testcode/cp3_release_benches/im/compression.elf
Segment IPC: 0.354432
Segment Time: 2426484000
BR Flushes: 35313 / 60566 Ratio=0.41695
Power: None

Program: ../testcode/cp3_release_benches/im/fft.elf
Segment IPC: 0.40158
Segment Time: 5782224000
BR Flushes: 14673 / 25085 Ratio=0.415069
Power: None

Program: ../testcode/cp3_release_benches/im/mergesort.elf
Segment IPC: 0.368023
Segment Time: 2618564000
BR Flushes: 27301 / 79877 Ratio=0.658212
Power: None

# Tournament

Program: ../testcode/coremark_im.elf
Segment IPC: 0.392976
Segment Time: 1483870000
BR Flushes: 4688 / 55170 Ratio=0.915026
Power: None

Program: ../testcode/cp3_release_benches/im/aes_sha.elf
Segment IPC: 0.285804
Segment Time: 5429828000
BR Flushes: 588 / 11419 Ratio=0.948507
Power: None

Program: ../testcode/cp3_release_benches/im/compression.elf
Segment IPC: 0.553307
Segment Time: 1554334000
BR Flushes: 280 / 60566 Ratio=0.995377
Power: None

Program: ../testcode/cp3_release_benches/im/fft.elf
Segment IPC: 0.430454
Segment Time: 5394368000
BR Flushes: 1710 / 25085 Ratio=0.931832
Power: None

Program: ../testcode/cp3_release_benches/im/mergesort.elf
Segment IPC: 0.401236
Segment Time: 2401810000
BR Flushes: 16744 / 79877 Ratio=0.790378
Power: None

# Static Taken

Program: ../testcode/coremark_im.elf
Segment IPC: 0.283252
Segment Time: 2058684000
BR Flushes: 25654 / 55170 Ratio=0.535001
Power: None

Program: ../testcode/cp3_release_benches/im/aes_sha.elf
Segment IPC: 0.276568
Segment Time: 5611160000
BR Flushes: 4649 / 11419 Ratio=0.592872
Power: None

Program: ../testcode/cp3_release_benches/im/compression.elf
Segment IPC: 0.389866
Segment Time: 2205950000
BR Flushes: 25001 / 60566 Ratio=0.587211
Power: None

Program: ../testcode/cp3_release_benches/im/fft.elf
Segment IPC: 0.417317
Segment Time: 5564184000
BR Flushes: 6140 / 25085 Ratio=0.755232
Power: None

Program: ../testcode/cp3_release_benches/im/mergesort.elf
Segment IPC: 0.293085
Segment Time: 3288092000
BR Flushes: 50952 / 79877 Ratio=0.362119
Power: None

# Performance Attempts

### CP3 w/ GShare (700 - 5iter)

| Program     | IPC      | Delay (s) | Power     | Branch Pr Rate | P·Delay⁴  | Place on LB |
| ----------- | -------- | --------- | --------- | -------------- | --------- | ----------- |
| Coremark    | 0.407423 | 1.023348  | 64.827400 | 90.35%         | 71.10     | 3rd         |
| AES         | 0.268639 | 4.130396  | 62.737500 | 94.86%         | 18,259.72 | 5th         |
| Compression | 0.614550 | 1.000597  | 66.029800 | 99.37%         | 66.19     | 3rd         |
| FFT         | 0.410784 | 4.041660  | 63.444100 | 90.87%         | 16,928.97 | 5th         |
| Mergesort   | 0.417170 | 1.651700  | 65.456500 | 77.29%         | 487.17    | 4th         |

## CP3 w/ GSHARE (700 - 5iter) Pipelined multiplier (3 cycles)

AREA: 253313

| Program     | IPC      | Delay (s) | Power     | Branch Pr Rate | P·Delay⁴  | Place on LB |
| ----------- | -------- | --------- | --------- | -------------- | --------- | ----------- |
| Coremark    | 0.415608 | 1.003194  | 61.104400 | 90.61%         | 61.88     | 2nd         |
| AES         | 0.268639 | 4.130396  | 58.636000 | 94.86%         | 17,166.12 | 3rd         |
| Compression | 0.614550 | 1.000597  | 62.534000 | 99.37%         | 62.57     | 2nd         |
| FFT         | 0.460032 | 3.608985  | 60.003900 | 90.87%         | 17,060.43 | 3rd         |
| Mergesort   | 0.417170 | 1.651700  | 62.384000 | 77.29%         | 278.50    | 1st         |

###### 1500 mult (2)? divider 20

Program: ../testcode/coremark_im.elf
Segment IPC: 0.444729
Segment Time: .983395500
BR Flushes: 5216 / 55170 Ratio=0.905456
Power: 58.196900

Program: ../testcode/cp3_release_benches/im/aes_sha.elf
Segment IPC: 0.37185
Segment Time: 3.130029000
BR Flushes: 677 / 11419 Ratio=0.940713
Power: 57.136100

Program: ../testcode/cp3_release_benches/im/compression.elf
Segment IPC: 0.614556
Segment Time: 1.049568000
BR Flushes: 383 / 60566 Ratio=0.993676
Power: 59.274000

Program: ../testcode/cp3_release_benches/im/fft.elf
Segment IPC: 0.469765
Segment Time: 3.707220000
BR Flushes: 2290 / 25085 Ratio=0.90871
Power: 56.833200

Program: ../testcode/cp3_release_benches/im/mergesort.elf
Segment IPC: 0.417171
Segment Time: 1.732546500
BR Flushes: 18140 / 79877 Ratio=0.772901
Power: 58.926900

###### 1450 mult (2) divider 20 (ICACHE 8 SETS 32 WAYS)

#area overflow
Program: ../testcode/coremark_im.elf
Segment IPC: 0.444724
Segment Time: 0.950625
Power: 90

Program: ../testcode/cp3_release_benches/im/aes_sha.elf
Segment IPC: 0.37185
Segment Time: 3.025
Power: 90

Program: ../testcode/cp3_release_benches/im/compression.elf
Segment IPC: 0.614550
Segment Time: 1.014
Power: 90

Program: ../testcode/cp3_release_benches/im/fft.elf
Segment IPC: 0.46975
Segment Time: 3.58372720
Power: 90

Program: ../testcode/cp3_release_benches/im/mergesort.elf
Segment IPC: 0.417170
Segment Time: 1.674
Power: 90

## 1450 mult 2 divider 17 (Icache 4 sets, 32 ways)
