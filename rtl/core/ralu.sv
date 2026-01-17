//------------------------------------------------------------------------------
// ralu.sv
//
// RALU (Register + ALU). Wraps the register file, operand mux, ALU and zero-flag register.
//
// Notes:
// - Academic project (CID2 - Digital Integrated Circuits).
// - RTL written in SystemVerilog.
//------------------------------------------------------------------------------

module ralu(
        input logic clock,
        input logic [3:0] opcode,
        input logic [3:0] addr_operand0,
        input logic [3:0] addr_operand1,
        input logic w_en,
        input logic [3:0] addr_result,
        input logic [15:0] data_mem_data_read, 
        input logic [15:0] instr_value,
        output logic [15:0] operand0,
        output logic [15:0] result,
        output logic zero_flag,
        output logic [15:0] operand1 
    );
    
logic [15:0] register_file0_X_operand1; // second register-file read port
logic alu0_X_zero; // combinational zero flag from ALU (registered by reg_zero_flag)



register_file register_file0(
        .clock(clock),
        .addr_operand0(addr_operand0),
        .addr_operand1(addr_operand1),
        .operand0(operand0),
        .operand1(register_file0_X_operand1),
        .w_en(w_en),
        .addr_result(addr_result),
        .data_write(result)
    );

// Operand1 selection based on opcode (matches ISA rules; e.g., immediate for VALUE_LOAD/JMP/JMPZ)
mux mux0(                  
        .in0(16'b0),   
        .in1(register_file0_X_operand1),   
        .in2(register_file0_X_operand1),   
        .in3(register_file0_X_operand1),
        .in4(register_file0_X_operand1),
        .in5(16'b0),
        .in6(register_file0_X_operand1),
        .in7(register_file0_X_operand1),
        .in8(register_file0_X_operand1),
        .in9(16'b0),
        .in10(instr_value),
        .in11(instr_value),
        .in12(instr_value),
        .in13(register_file0_X_operand1),
        .in14(data_mem_data_read),
        .in15(16'b0),    
        .sel(opcode),
        .out(operand1)
    );


alu alu0(
        .opcode(opcode),
        .operand0(operand0),
        .operand1(operand1),
        .result(result),
        .zero(alu0_X_zero)
    );  
    
reg_zero_flag reg_zero_flag0(
        .clock(clock),
        .in(alu0_X_zero),
        .out(zero_flag)
    );

   
endmodule
