`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Testbench: computer_APB_tb
// -----------------------------------------------------------------------------
// What this testbench does
//   1) Generates a free-running clock.
//   2) Applies a reset pulse.
//   3) Drives btn_in to exercise BTN_APB and the end-to-end PWM duty-control loop.
//   4) Loads a custom instruction program into the DUT instruction memory using
//      hierarchical access (simulation-only, not synthesizable).
//
// Test program structure (instruction indices):
//   A) Data memory (RAM APB slave) basic read/write
//   B) PWM_APB configuration and start
//   C) BTN_APB reads (polling)
//   D) MEAN_APB: write inputs, start, then read result (blocks until ready)
//   E) End-to-end system loop: read buttons -> set PWM duty -> repeat
// -----------------------------------------------------------------------------

module computer_APB_tb;

  // Testbench I/O
  logic        clock_tb;
  logic        reset_tb;
  logic [3:0]  btn_in_tb;
  logic        pwm_out_tb;

  // ---------------------------------------------------------------------------
  // DUT (Device Under Test)
  // ---------------------------------------------------------------------------
  computer_APB DUT (
    .clock   (clock_tb),
    .reset   (reset_tb),
    .btn_in  (btn_in_tb),
    .pwm_out (pwm_out_tb)
  );

  // ---------------------------------------------------------------------------
  // Clock generation: 2 ns period (500 MHz) for fast simulation
  // ---------------------------------------------------------------------------
  initial begin
    clock_tb = 1'b0;
    forever #1 clock_tb = ~clock_tb;
  end

  // ---------------------------------------------------------------------------
  // Reset + external stimulus (buttons)
  // ---------------------------------------------------------------------------
  initial begin
    reset_tb  = 1'b1;
    btn_in_tb = 4'b0000;

    // Hold reset for a couple of cycles
    #2 reset_tb = 1'b0;

    // Simple BTN_APB stimulus
    #30 btn_in_tb = 4'b0101;
    #10 btn_in_tb = 4'b1010;

    // End-to-end stimulus for test E (PWM duty selection via buttons)
    #150 btn_in_tb = 4'b0001; // Duty 10%
    #300 btn_in_tb = 4'b0010; // Duty 25%
    #300 btn_in_tb = 4'b0100; // Duty 50%
    #300 btn_in_tb = 4'b1000; // Duty 100%
    #300 btn_in_tb = 4'b0000; // Duty 0%

    #2000 $stop;
  end

  // ---------------------------------------------------------------------------
  // Program load: write instructions directly into the DUT instruction memory
  // NOTE: Hierarchical references are simulation-only.
  // ---------------------------------------------------------------------------
  initial begin

    // =========================================================
    // A) DATA MEMORY TEST (RAM APB slave)
    // Address interval: 0 ... 1023
    // =========================================================
    DUT.instr_mem0.mem_instr[0] = 32'b1010_0000_0000_0000_0000_0000_0000_1110; // R0 = 14
    DUT.instr_mem0.mem_instr[1] = 32'b1010_0001_0000_0000_0000_0000_0001_0001; // R1 = 17
    DUT.instr_mem0.mem_instr[2] = 32'b1010_0010_0000_0000_0000_0000_0001_0110; // R2 = 22
    DUT.instr_mem0.mem_instr[3] = 32'b1010_0011_0000_0000_0000_0000_0101_1100; // R3 = 92
    DUT.instr_mem0.mem_instr[4] = 32'b1101_0000_0000_0001_0000_0000_0000_0000; // MEM[17] = 14
    DUT.instr_mem0.mem_instr[5] = 32'b1101_0000_0010_0011_0000_0000_0000_0000; // MEM[92] = 22
    DUT.instr_mem0.mem_instr[6] = 32'b1110_0100_0001_0000_0000_0000_0000_0000; // R4 = MEM[17] (14)
    DUT.instr_mem0.mem_instr[7] = 32'b1110_0101_0011_0000_0000_0000_0000_0000; // R5 = MEM[92] (22)

    // =========================================================
    // B) PWM_APB TEST - Configuration
    // Address interval: 1024 ... 2047
    // =========================================================
    // Period = 100 (offset 1 -> 1025)
    DUT.instr_mem0.mem_instr[8]  = 32'b1010_0000_0000_0000_0000_0100_0000_0001; // R0 = 1025 (period addr)
    DUT.instr_mem0.mem_instr[9]  = 32'b1010_0001_0000_0000_0000_0000_0110_0100; // R1 = 100
    DUT.instr_mem0.mem_instr[10] = 32'b1101_0000_0001_0000_0000_0000_0000_0000; // MEM[1025] = 100

    // Duty cycle = 40 (offset 2 -> 1026)
    DUT.instr_mem0.mem_instr[11] = 32'b1010_0000_0000_0000_0000_0100_0000_0010; // R0 = 1026 (duty addr)
    DUT.instr_mem0.mem_instr[12] = 32'b1010_0001_0000_0000_0000_0000_0010_1000; // R1 = 40
    DUT.instr_mem0.mem_instr[13] = 32'b1101_0000_0001_0000_0000_0000_0000_0000; // MEM[1026] = 40

    // PWM start (offset 0 -> 1024)
    DUT.instr_mem0.mem_instr[14] = 32'b1010_0000_0000_0000_0000_0100_0000_0000; // R0 = 1024 (config addr)
    DUT.instr_mem0.mem_instr[15] = 32'b1010_0001_0000_0000_0000_0000_0000_0000; // R1 = 0
    DUT.instr_mem0.mem_instr[16] = 32'b1101_0000_0001_0000_0000_0000_0000_0000; // MEM[1024] = 0 (start PWM)

    // =========================================================
    // C) BTN_APB TEST (polling reads)
    // Address interval: 2048 ... 3071
    // =========================================================
    // Read buttons (offset 0 -> 2048)
    DUT.instr_mem0.mem_instr[17] = 32'b1010_0000_0000_0000_0000_1000_0000_0000; // R0 = 2048 (BTN addr)
    DUT.instr_mem0.mem_instr[18] = 32'b1110_0001_0000_0000_0000_0000_0000_0000; // R1 = MEM[2048]
    DUT.instr_mem0.mem_instr[19] = 32'b1110_0001_0000_0000_0000_0000_0000_0000; // R1 = MEM[2048]
    DUT.instr_mem0.mem_instr[20] = 32'b1110_0001_0000_0000_0000_0000_0000_0000; // R1 = MEM[2048]
    DUT.instr_mem0.mem_instr[21] = 32'b1110_0001_0000_0000_0000_0000_0000_0000; // R1 = MEM[2048]
    DUT.instr_mem0.mem_instr[22] = 32'b1110_0001_0000_0000_0000_0000_0000_0000; // R1 = MEM[2048]

    // =========================================================
    // D) MEAN_APB - Mean computation
    // Address interval: 3072 ... 4095
    // Example: mean = (10 + 20 + 30 + 40) / 4 = 25
    // =========================================================

    // Write A = 10
    DUT.instr_mem0.mem_instr[23] = 32'b1010_0000_0000_0000_0000_1100_0000_0001; // R0 = 3073 (A addr)
    DUT.instr_mem0.mem_instr[24] = 32'b1010_0001_0000_0000_0000_0000_0000_1010; // R1 = 10
    DUT.instr_mem0.mem_instr[25] = 32'b1101_0000_0001_0000_0000_0000_0000_0000; // MEM[3073] = 10

    // Write B = 20
    DUT.instr_mem0.mem_instr[26] = 32'b1010_0000_0000_0000_0000_1100_0000_0010; // R0 = 3074 (B addr)
    DUT.instr_mem0.mem_instr[27] = 32'b1010_0001_0000_0000_0000_0000_0001_0100; // R1 = 20
    DUT.instr_mem0.mem_instr[28] = 32'b1101_0000_0001_0000_0000_0000_0000_0000; // MEM[3074] = 20

    // Write C = 30
    DUT.instr_mem0.mem_instr[29] = 32'b1010_0000_0000_0000_0000_1100_0000_0011; // R0 = 3075 (C addr)
    DUT.instr_mem0.mem_instr[30] = 32'b1010_0001_0000_0000_0000_0000_0001_1110; // R1 = 30
    DUT.instr_mem0.mem_instr[31] = 32'b1101_0000_0001_0000_0000_0000_0000_0000; // MEM[3075] = 30

    // Write D = 40
    DUT.instr_mem0.mem_instr[32] = 32'b1010_0000_0000_0000_0000_1100_0000_0100; // R0 = 3076 (D addr)
    DUT.instr_mem0.mem_instr[33] = 32'b1010_0001_0000_0000_0000_0000_0010_1000; // R1 = 40
    DUT.instr_mem0.mem_instr[34] = 32'b1101_0000_0001_0000_0000_0000_0000_0000; // MEM[3076] = 40

    // Start mean computation (offset 0 -> 3072)
    DUT.instr_mem0.mem_instr[35] = 32'b1010_0000_0000_0000_0000_1100_0000_0000; // R0 = 3072 (config addr)
    DUT.instr_mem0.mem_instr[36] = 32'b1010_0001_0000_0000_0000_0000_0000_0001; // R1 = 1
    DUT.instr_mem0.mem_instr[37] = 32'b1101_0000_0001_0000_0000_0000_0000_0000; // MEM[3072] = 1 (start)

    // Read result (blocks until accelerator is ready)
    DUT.instr_mem0.mem_instr[38] = 32'b1010_0000_0000_0000_0000_1100_0000_0101; // R0 = 3077 (result addr)
    DUT.instr_mem0.mem_instr[39] = 32'b1110_0010_0000_0000_0000_0000_0000_0000; // R2 = MEM[3077]

    // =========================================================
    // E) SYSTEM TEST (infinite loop)
    // - Reads buttons and updates PWM duty accordingly.
    // =========================================================

    // Period = 100 (offset 1 -> 1025)
    DUT.instr_mem0.mem_instr[40] = 32'b1010_0000_0000_0000_0000_0100_0000_0001; // R0 = 1025
    DUT.instr_mem0.mem_instr[41] = 32'b1010_0001_0000_0000_0000_0000_0110_0100; // R1 = 100
    DUT.instr_mem0.mem_instr[42] = 32'b1101_0000_0001_0000_0000_0000_0000_0000; // MEM[1025] = 100

    // Start PWM
    DUT.instr_mem0.mem_instr[43] = 32'b1010_0000_0000_0000_0000_0100_0000_0000; // R0 = 1024
    DUT.instr_mem0.mem_instr[44] = 32'b1010_0001_0000_0000_0000_0000_0000_0000; // R1 = 0
    DUT.instr_mem0.mem_instr[45] = 32'b1101_0000_0001_0000_0000_0000_0000_0000; // MEM[1024] = 0 (start PWM)

    // Read buttons (address 2048)
    DUT.instr_mem0.mem_instr[46] = 32'b1010_0000_0000_0000_0000_1000_0000_0000; // R0 = 2048
    DUT.instr_mem0.mem_instr[47] = 32'b1110_0001_0000_0000_0000_0000_0000_0000; // R1 = MEM[2048]

    // IF (BTN == 1) -> jump to 10%
    DUT.instr_mem0.mem_instr[48] = 32'b1010_0010_0000_0000_0000_0000_0000_0001; // R2 = 1
    DUT.instr_mem0.mem_instr[49] = 32'b0010_0011_0001_0010_0000_0000_0000_0000; // R3 = R1 - R2
    DUT.instr_mem0.mem_instr[50] = 32'b1100_0000_0000_0000_0000_0000_0011_1110; // JMPZ to 62 (10%)

    // IF (BTN == 2) -> jump to 25%
    DUT.instr_mem0.mem_instr[51] = 32'b1010_0010_0000_0000_0000_0000_0000_0010; // R2 = 2
    DUT.instr_mem0.mem_instr[52] = 32'b0010_0011_0001_0010_0000_0000_0000_0000; // R3 = R1 - R2
    DUT.instr_mem0.mem_instr[53] = 32'b1100_0000_0000_0000_0000_0000_0100_0000; // JMPZ to 64 (25%)

    // IF (BTN == 4) -> jump to 50%
    DUT.instr_mem0.mem_instr[54] = 32'b1010_0010_0000_0000_0000_0000_0000_0100; // R2 = 4
    DUT.instr_mem0.mem_instr[55] = 32'b0010_0011_0001_0010_0000_0000_0000_0000; // R3 = R1 - R2
    DUT.instr_mem0.mem_instr[56] = 32'b1100_0000_0000_0000_0000_0000_0100_0010; // JMPZ to 66 (50%)

    // IF (BTN == 8) -> jump to 100%
    DUT.instr_mem0.mem_instr[57] = 32'b1010_0010_0000_0000_0000_0000_0000_1000; // R2 = 8
    DUT.instr_mem0.mem_instr[58] = 32'b0010_0011_0001_0010_0000_0000_0000_0000; // R3 = R1 - R2
    DUT.instr_mem0.mem_instr[59] = 32'b1100_0000_0000_0000_0000_0000_0100_0100; // JMPZ to 68 (100%)

    // ELSE -> duty = 0
    DUT.instr_mem0.mem_instr[60] = 32'b1010_0100_0000_0000_0000_0000_0000_0000; // R4 = 0
    DUT.instr_mem0.mem_instr[61] = 32'b1011_0000_0000_0000_0000_0000_0100_0110; // JMP to 70

    // Duty cases
    // 10%
    DUT.instr_mem0.mem_instr[62] = 32'b1010_0100_0000_0000_0000_0000_0000_1010; // R4 = 10
    DUT.instr_mem0.mem_instr[63] = 32'b1011_0000_0000_0000_0000_0000_0100_0110; // JMP to 70
    // 25%
    DUT.instr_mem0.mem_instr[64] = 32'b1010_0100_0000_0000_0000_0000_0001_1001; // R4 = 25
    DUT.instr_mem0.mem_instr[65] = 32'b1011_0000_0000_0000_0000_0000_0100_0110; // JMP to 70
    // 50%
    DUT.instr_mem0.mem_instr[66] = 32'b1010_0100_0000_0000_0000_0000_0011_0010; // R4 = 50
    DUT.instr_mem0.mem_instr[67] = 32'b1011_0000_0000_0000_0000_0000_0100_0110; // JMP to 70
    // 100%
    DUT.instr_mem0.mem_instr[68] = 32'b1010_0100_0000_0000_0000_0000_0110_0100; // R4 = 100
    DUT.instr_mem0.mem_instr[69] = 32'b1011_0000_0000_0000_0000_0000_0100_0110; // JMP to 70

    // Write duty into PWM duty register (offset 2 -> 1026)
    DUT.instr_mem0.mem_instr[70] = 32'b1010_0000_0000_0000_0000_0100_0000_0010; // R0 = 1026 (duty addr)
    DUT.instr_mem0.mem_instr[71] = 32'b1101_0000_0000_0100_0000_0000_0000_0000; // MEM[1026] = R4
    DUT.instr_mem0.mem_instr[72] = 32'b1011_0000_0000_0000_0000_0000_0010_1110; // JMP to 46 (loop)

    // HALT (not reached because of the infinite loop above)
    DUT.instr_mem0.mem_instr[73] = 32'b1111_0000_0000_0000_0000_0000_0000_0000; // HALT

  end

endmodule
