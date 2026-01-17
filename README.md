README


# Custom APB Microprocessor System (SoC)

**Project Type:** Academic Design Project
**Language:** SystemVerilog
**Architecture:** Custom 16-bit RISC Core + AMBA 3.0 APB Bus
**Tools:** Xilinx Vivado

## Project Overview

This repository hosts the RTL implementation of a complete **System-on-Chip (SoC)** based on a custom processor architecture. Unlike standard peripheral designs, this project implements the entire processing chain:
1.  **Custom CPU Core:** A 16-bit processor with a dedicated Instruction Set Architecture (ISA).
2.  **APB Master Interface:** Bridges the CPU to the system bus.
3.  **Peripheral Subsystem:** A set of custom slaves (Accelerator, PWM, GPIO, RAM) controlled via the bus.

The system demonstrates a full Fetch-Decode-Execute cycle, where software instructions stored in `instr_mem` drive physical hardware actions on the APB bus.

## Academic Context / Disclaimer

This repository contains an implementation developed as part of a university course assignment.
The original assignment statement and course handouts (PDFs, lab sheets, etc.) were provided by the teaching staff and are **not redistributed** here to respect the authors' rights.
Instead, the expected behavior and requirements are summarized in `docs/` in the author's own words.

## System Architecture

### 1. The Processor Core (`procesorAPB`)
The CPU is designed with a modular data path including:
* **Control Unit:** Decodes custom opcodes to generate control signals.
* **RALU (Register & ALU):** Handles arithmetic operations and register file management.
* **PC (Program Counter):** Manages instruction flow and jumps (JMP/JMPZ).
* **APB Master:** Translates CPU memory access instructions (Load/Store) into APB Read/Write transactions.

### 2. Peripheral Subsystem
The core communicates with four memory-mapped slaves:

| Peripheral | Module Name | Function |
| :--- | :--- | :--- |
| **RAM** | `data_mem_APBSlave` | 1KB General Purpose Data Memory. |
| **PWM** | `PWM_APB` | Pulse Width Modulation generator for actuator control. |
| **GPIO** | `BTN_APB` | Input interface for reading external buttons. |
| **ACCEL**| `MEAN_APB` | Hardware Accelerator for arithmetic mean computation. |

## Directory Structure

* **rtl/core/**: CPU design sources (ALU, Control Block, PC, Master Interface).
* **rtl/peripherals/**: Slave modules implementation.
* **rtl/computer_APB.sv**: Top-level wrapper connecting the Processor to the Periferals.
* **docs/**: Detailed register maps and instruction set documentation.

## Simulation

The system is verified by loading a program into `instr_mem` (simulated via an initial block or external file) and observing the bus behavior.
1.  Open **Xilinx Vivado**.
2.  Add all files from `rtl/` as design sources.
3.  Add `tb/computer_APB_tb.sv` as a simulation source.
4.  Run **Behavioral Simulation** on `computer_APB_tb`.
