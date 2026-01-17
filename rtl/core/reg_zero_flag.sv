//------------------------------------------------------------------------------
// reg_zero_flag.sv
//
// Registers the ALU zero flag to be used by conditional jump (JMPZ).
//
// Notes:
// - Academic project (CID2 - Digital Integrated Circuits).
// - RTL written in SystemVerilog.
//------------------------------------------------------------------------------

module reg_zero_flag(
        input logic clock,
        input logic in,
        output logic out
    );
    
// Register zero flag on clock edge
always_ff@(posedge clock) 
    begin
        out <= in;
    end
    
endmodule
