//------------------------------------------------------------------------------
// PC.sv
//
// Program Counter (PC). Supports sequential increment and jump; can be stalled via en=0.
//
// Notes:
// - Academic project (CID2 - Digital Integrated Circuits).
// - RTL written in SystemVerilog.
//------------------------------------------------------------------------------

module PC(
        input logic clock,
        input logic reset,
        input logic en,
        input logic do_jump,
        input logic [7:0] jump_value,
        output logic [7:0] pc
    );

// PC update (synchronous reset)
always_ff@(posedge clock) 
    begin
        if(reset) 
            pc <= 0;
        else if(en)
                if(do_jump)
                    pc <= jump_value;
                else
                    pc <= pc + 1;
             else
                pc <= pc;
    end    

endmodule
