//------------------------------------------------------------------------------
// instr_mem.sv
//
// Instruction memory (ROM/RAM model) used for simulation. Program is typically initialized in a testbench.
//
// Notes:
// - Academic project (CID2 - Digital Integrated Circuits).
// - RTL written in SystemVerilog.
//------------------------------------------------------------------------------

module instr_mem(
        input logic [7:0] addr_read,
        output logic [31:0] data_read
    );

// 256 x 32-bit instruction memory (addressed by PC[7:0])
logic [31:0] mem_instr [0:2**8-1]; 

assign data_read = mem_instr[addr_read];
 
endmodule
