//------------------------------------------------------------------------------
// alu.sv
//
// Arithmetic Logic Unit (ALU). Implements the ISA operations and a combinational zero flag.
//
// Notes:
// - Academic project (CID2 - Digital Integrated Circuits).
// - RTL written in SystemVerilog.
//------------------------------------------------------------------------------

module alu(
        input logic [3:0] opcode,
        input logic [15:0] operand0,
        input logic [15:0] operand1,
        output logic [15:0] result,
        output logic zero
    );

// Zero flag derived from ALU result (combinational)
always_comb 
    begin
        if(result == 0)
            zero = 1;
        else
            zero = 0;
    end

// assign zero = (result ==0);

always_comb 
    begin
        // Operation decode based on opcode
        case(opcode)
            0: result = operand0;               // NOP
            1: result = operand0 + operand1;    // ADD
            2: result = operand0 - operand1;    // SUB
            3: result = operand0 * operand1;    // MULT
            4: result = operand1 >> 1;          // SHIFT 1 RIGHT
            5: result = 0;                      // not implemented
            6: result = operand0 & operand1;    // AND
            7: result = operand0 | operand1;    // OR
            8: result = operand0 ^ operand1;    // XOR
            9: result = 0;                      // not implemented
            10: result = operand1;              // VALUE LOAD
            11: result = operand1;              // JMP
            12: result = operand1;              // JMPZ
            13: result = operand0;              // WRITE MEM (STORE)
            14: result = operand1;              // READ MEM (LOAD)
            15: result = 0;                     // HALT
            default: result = 0;
        endcase            
    end       
             
endmodule
