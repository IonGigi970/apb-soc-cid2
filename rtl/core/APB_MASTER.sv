//------------------------------------------------------------------------------
// APB_MASTER.sv
//
// APB Master FSM. Converts CPU LOAD/STORE requests into APB SETUP/ACCESS phases and stalls PC until completion.
//
// Notes:
// - Academic project (CID2 - Digital Integrated Circuits).
// - RTL written in SystemVerilog.
//------------------------------------------------------------------------------

module APB_MASTER(
        input logic clock,
        input logic reset,
        
        // interface to processor
        input logic [15:0] data_mem_addr_read,
        input logic [15:0] data_mem_addr_write,
        input logic [15:0] data_mem_data_write,
        output logic [15:0] data_mem_data_read,
        output logic block_pc,
        input logic wr_transfer,
        input logic rd_transfer,
        
        //APB
        output logic pclk,
        output logic preset,
        output logic [9:0] paddr,
        output logic psel,
        output logic penable,
        output logic pwrite,
        output logic [15:0] pwdata,
        input logic [15:0] prdata,
        input logic pready,
        output logic [1:0] peripheral_select
    );
    
    // APB transaction FSM states
    localparam idle = 0;
    localparam access = 1;
    localparam transfer = 2;
    
    logic [1:0] state, state_next;
    
    always_ff@(posedge clock)
    begin
        if(reset)
        begin
            state <= idle;
        end
        else 
        begin
            state <= state_next;
        end
    end
    
    // Next-state logic (combinational)
    always_comb
    begin
        state_next = state;
        case(state)
            idle: 
            begin
                if(wr_transfer == 1 || rd_transfer == 1) state_next = access;  
            end  
            
            access: 
            begin
                state_next = transfer;  
            end  
            
            transfer: 
            begin
                if(pready == 1)
                begin
                    if(wr_transfer == 1 || rd_transfer == 1) state_next = access;
                    else state_next = idle;       
                end            
            end
        endcase  
    end 
    
    // In this simplified design, APB clock/reset are directly driven from core clock/reset
    assign pclk = clock;
    assign preset = reset;
    
    // Output logic (combinational)
    always_comb 
    begin
        data_mem_data_read = 0;
        block_pc = 0;
        paddr = 0;
        psel = 0;
        penable = 0;
        pwrite = 0;
        pwdata = 0;
        peripheral_select = 0;
        
        case(state)
            idle:
                begin
                    if(wr_transfer == 1 || rd_transfer == 1) block_pc = 1;
                end
            
            access: 
                begin
                    block_pc = 1;
                    paddr = wr_transfer ? data_mem_addr_write : data_mem_addr_read;
                    peripheral_select = wr_transfer ? data_mem_addr_write[11:10] : data_mem_addr_read[11:10];
                    psel = 1;
                    penable = 0;
                    pwrite = wr_transfer;
                    pwdata = wr_transfer ? data_mem_data_write : 0;
                end
            
            transfer: 
                begin
                    data_mem_data_read = (pready & ~pwrite) ? prdata : 0;
                    block_pc = ~pready;
                    paddr = wr_transfer ? data_mem_addr_write : data_mem_addr_read;
                    peripheral_select = wr_transfer ? data_mem_addr_write[11:10] : data_mem_addr_read[11:10];
                    psel = 1;
                    penable = 1;
                    pwrite = wr_transfer;
                    pwdata = wr_transfer ? data_mem_data_write : 0;
                end
        endcase
    end
    
endmodule
