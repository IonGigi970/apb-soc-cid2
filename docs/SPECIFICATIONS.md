SPECIFICATIONS


# Technical Specifications & Register Map

## 1. Global Address Map
The system uses a simplified addressing scheme decoded by the `computer_APB` top module.

| Peripheral | Select Index | Description |
| :--- | :--- | :--- |
| **MEM_APB** | 0 | Data Memory Slave |
| **PWM_APB** | 1 | PWM Generator |
| **BTN_APB** | 2 | Button Input Interface |
| **MEAN_APB** | 3 | Mean Calculator Accelerator |

---

## 2. Peripheral Registers

### 2.1. MEAN_APB (Arithmetic Accelerator)
**Base Selection Index:** 3
**Function:** Computes the average of 4 values using a sequential state machine.

| Address Offset | Name | R/W | Description |
| :--- | :--- | :--- | :--- |
| **0** | CONFIG | R/W | Bit[0]: Start (Write 1 to trigger). Bit[1]: Done Flag (Read only). |
| **1** | DATA_A | R/W | Input Operand 1. |
| **2** | DATA_B | R/W | Input Operand 2. |
| **3** | DATA_C | R/W | Input Operand 3. |
| **4** | DATA_D | R/W | Input Operand 4. |
| **5** | RESULT | R | Read the computed mean value. |

**Hardware Behavior:**
* Writing `1` to `CONFIG[0]` triggers the state machine.
* The module asserts `PREADY = 0` (Wait State) while calculating.
* When finished, `PREADY = 1` and the result is available in `RESULT`.

---

### 2.2. PWM_APB (Pulse Width Modulation)
**Base Selection Index:** 1

| Address Offset | Name | R/W | Description |
| :--- | :--- | :--- | :--- |
| **0** | CONFIG | R/W | Bit[0]: Enable/Disable PWM output. |
| **1** | LIMIT_PERIOD| R/W | Sets the frequency (Counter Limit). |
| **2** | LIMIT_DUTY | R/W | Sets the duty cycle (Comparison Threshold). |

**Logic:** `pwm_out` is High when internal counter < `LIMIT_DUTY`.

---

### 2.3. BTN_APB (Input Interface)
**Base Selection Index:** 2

| Address Offset | Name | R/W | Description |
| :--- | :--- | :--- | :--- |
| **0** | BTN_DATA | R | Reads the state of the external buttons. |

---

## 3. Processor Instruction Set (Custom ISA)

The CPU interprets the 32-bit instruction word `[31:0]` as follows:
* `[31:28]`: **Opcode**
* `[27:24]`: **Result Address** (Register File)
* `[23:20]`: **Operand 0 Address** (Register File)
* `[19:16]`: **Operand 1 Address** (Register File)
* `[15:0]`: **Immediate Value**

### Supported Opcodes
| Opcode | Mnemonic | Operation |
| :--- | :--- | :--- |
| `0` | NOP | No Operation. |
| `1` | ADD | `Res = Op0 + Op1` |
| `2` | SUB | `Res = Op0 - Op1` |
| `3` | MULT | `Res = Op0 * Op1` |
| `4` | SHR | `Res = Op1 >> 1` |
| `6` | AND | `Res = Op0 & Op1` |
| `7` | OR | `Res = Op0 | Op1` |
| `8` | XOR | `Res = Op0 ^ Op1` |
| `10` | LOAD_VAL | `Res = Op1` (Load Immediate/Register) |
| `11` | JMP | Unconditional Jump to Address. |
| `12` | JMPZ | Jump if Zero Flag is Set. |
| `13` | STORE | **APB Write Transaction**: Writes `Op0` to Memory Address `Op1`. |
| `14` | LOAD | **APB Read Transaction**: Reads from Memory Address `Op1` into `Res`. |
| `15` | HALT | Stop Execution. |
