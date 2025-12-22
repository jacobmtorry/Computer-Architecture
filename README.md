# 🧠 RISC-V Processor Projects (ECE 411)

This repository contains my **personal implementations** of several RISC-V processor designs developed as part of **ECE 411: Computer Organization & Design** at the University of Illinois Urbana-Champaign.

The projects progress from a simple in-order pipeline to a full **out-of-order, Tomasulo-style processor** with a parameterized cache hierarchy. These implementations were built to pass **Spike / RVFI verification** and emphasize correctness, performance, and architectural clarity.

---

## 📁 Project Overview

### 🔹 `mp_pipeline`
A classic **in-order, 5-stage RISC-V pipeline**.

**Key features:**
- IF / ID / EX / MEM / WB pipeline
- Hazard detection and pipeline stalling
- Full forwarding paths (EX/MEM/WB)
- Branch handling with flush logic
- Blocking memory model
- Verified against Spike

This project establishes the baseline processor design and correctness.

---

### 🔹 `mp_cache`
A **parameterized cache subsystem** designed to integrate with both in-order and OoO cores.

**Key features:**
- Unified instruction/data cache interface
- Configurable sets, ways, and line size
- Write-back, write-allocate policy
- Tree-based PLRU replacement
- Line buffer for miss handling
- Memory arbiter integration
- Explored blocking vs pipelined cache designs

This project focuses on memory system behavior, timing, and correctness under realistic cache constraints.

---

### 🔹 `mp_ooo`
A full **out-of-order RISC-V processor** using Tomasulo-style execution.

**Key features:**
- Register renaming with physical register file
- Reorder Buffer (ROB)
- Reservation stations
- Common Data Bus (CDB) broadcast
- Speculative execution with precise exceptions
- Split Load/Store Queue (LSQ)
  - Store-to-load forwarding
  - Memory ordering enforcement
- Integrated cache and prefetching support
- Verified against Spike with RVFI monitoring

This project represents the culmination of the course, combining control, memory, and speculation into a high-performance core.

---

## 🛠️ Tools & Technologies
- SystemVerilog
- Spike RISC-V ISA Simulator
- RVFI verification
- Verdi / VCS
- Custom memory models and test programs

---

## 📌 Notes
- This repository is intended for **personal learning and portfolio purposes**.
- Code is written to course specifications and may not reflect production-ready design practices.
- Large portions were iteratively debugged and optimized to satisfy strict correctness checks.

---

## 👤 Author
**Jacob Torry**  
Electrical & Computer Engineering  
University of Illinois Urbana-Champaign
