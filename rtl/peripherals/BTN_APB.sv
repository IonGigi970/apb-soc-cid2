//------------------------------------------------------------------------------
// BTN_APB.sv
//
// APB peripheral: button input sampler. Captures 4 button inputs into a readable register.
//
// Notes:
// - Academic project (CID2 - Digital Integrated Circuits).
// - RTL written in SystemVerilog.
//------------------------------------------------------------------------------

module BTN_APB(
        input logic pclk,
        input logic preset,
        input logic [9:0] paddr,
        input logic psel,
        input logic penable,
        input logic pwrite,
        input logic [15:0] pwdata,
        output logic [15:0] prdata,
        output logic pready,
        
        //to buttons
        input logic [3:0] buttons     
    );
    
// Latched button state (sampled on each clock)
logic [3:0] btn_reg;

always_ff@(posedge pclk)
    begin
        if(preset)
            btn_reg <= 0;
        else 
            btn_reg <= buttons;
    end 

// BTN peripheral is always ready
assign pready = 1;
// Return button register during a valid APB read; otherwise prdata=0
assign prdata = (psel & pready & penable & (~pwrite)) ? {12'b0, btn_reg} : 0;
    
endmodule
