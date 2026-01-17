//------------------------------------------------------------------------------
// register_file.sv
//
// 16 x 16-bit register file. Two asynchronous read ports and one synchronous write port.
//
// Notes:
// - Academic project (CID2 - Digital Integrated Circuits).
// - RTL written in SystemVerilog.
//------------------------------------------------------------------------------

module register_file(
        input logic clock,
        input logic [3:0] addr_operand0,
        input logic [3:0] addr_operand1,
        output logic [15:0] operand0,
        output logic [15:0] operand1,
        input logic w_en,
        input logic [3:0] addr_result,
        input logic [15:0] data_write
    );

// 16 general-purpose registers (16-bit each)
logic [15:0] registre [0:15];
// [index] selects the register; each entry is 16-bit wide

// Synchronous write on rising clock edge
always_ff@(posedge clock) 
    begin
        if(w_en == 1) 
            registre[addr_result] <= data_write;       
    end   
    
    
// Asynchronous read port 0
always_comb 
    begin
        operand0 = registre[addr_operand0];    
    end

// Asynchronous read port 1
always_comb 
    begin
        operand1 = registre[addr_operand1];    
    end
         

endmodule
