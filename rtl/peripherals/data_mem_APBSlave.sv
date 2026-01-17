//------------------------------------------------------------------------------
// data_mem_APBSlave.sv
//
// APB slave: 1KB x 16-bit data memory. Always ready (pready=1).
//
// Notes:
// - Academic project (CID2 - Digital Integrated Circuits).
// - RTL written in SystemVerilog.
//------------------------------------------------------------------------------

module data_mem_APBSlave(
        input logic pclk,
        input logic [9:0] paddr,
        input logic psel,
        input logic penable,
        input logic pwrite,
        input logic [15:0] pwdata,
        output logic [15:0] prdata,
        output logic pready
    );
    
// 1KB memory (1024 x 16-bit) addressed by paddr[9:0]
logic [15:0] mem [0:2**10-1];

// Synchronous write (valid APB write: psel && penable && pwrite && pready)
always_ff@(posedge pclk) 
    begin
        if(pwrite & psel & penable & pready)
            mem[paddr] <= pwdata;
    end
    
assign pready = 1;


// Read data is returned only for a valid APB read in ACCESS phase
assign prdata = (~pwrite & psel & penable & pready) ? mem[paddr] : 0;     


endmodule
