//------------------------------------------------------------------------------
// procesorAPB.sv
//
// Custom single-cycle (non-pipelined) CPU core with an integrated APB master interface.
//
// Notes:
// - Academic project (CID2 - Digital Integrated Circuits).
// - RTL written in SystemVerilog.
//------------------------------------------------------------------------------

module procesorAPB(
        input logic clock, 
        input logic reset, 

        // Instruction memory interface (Harvard architecture) 
        input logic [31:0] instr_mem_data_read, 
        output logic [7:0] instr_mem_addr_read, 
        
        // APB master interface (memory-mapped peripherals) 
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
    
logic control_block1_X_w_en; 
logic ralu1_X_zero_flag; 
logic control_block1_X_pc_en; 
logic control_block1_X_do_jump; 
logic APB_MASTER1_X_block_pc;
// Stall signal from APB_MASTER: blocks PC update while an APB transfer is pending 
logic APB_MASTER1_X_data_mem_w_en; 
logic [15:0] APB_MASTER1_X_data_mem_data_read; 
logic [15:0] APB_MASTER1_X_data_mem_addr_read; 
logic [15:0] APB_MASTER1_X_data_mem_data_write; 
logic [15:0] APB_MASTER1_X_data_mem_addr_write;

control_block control_block1( 
        .opcode(instr_mem_data_read[31:28]), 
        .zero_flag(ralu1_X_zero_flag), 
        .ralu_w_en(control_block1_X_w_en), 
        .pc_en(control_block1_X_pc_en), 
        .do_jump(control_block1_X_do_jump), 
        .data_mem_w_en(APB_MASTER1_X_data_mem_w_en) 
    ); 

ralu ralu1( 
        .clock(clock), 
        .opcode(instr_mem_data_read[31:28]), 
        .addr_operand0(instr_mem_data_read[23:20]), 
        .addr_operand1(instr_mem_data_read[19:16]), 
        .w_en(control_block1_X_w_en), 
        .addr_result(instr_mem_data_read[27:24]), 
        .data_mem_data_read(APB_MASTER1_X_data_mem_data_read), 
        .instr_value(instr_mem_data_read[15:0]), 
        .operand0(APB_MASTER1_X_data_mem_addr_read), 
        .result(APB_MASTER1_X_data_mem_data_write), 
        .zero_flag(ralu1_X_zero_flag), 
        .operand1(APB_MASTER1_X_data_mem_addr_write) 
    ); 
    
PC PC1( 
        .clock(clock), 
        .reset(reset), 
        .en(control_block1_X_pc_en & ~APB_MASTER1_X_block_pc), // advance PC only when not stalled by APB 
        .do_jump(control_block1_X_do_jump), 
        .jump_value(APB_MASTER1_X_data_mem_data_write[7:0]), 
        .pc(instr_mem_addr_read) 
    ); 
    

APB_MASTER APB_MASTER_1( 
        .clock(clock), 
        .reset(reset), 
        
        //interfata cu procesorul 
        .data_mem_addr_read(APB_MASTER1_X_data_mem_addr_read), 
        .data_mem_addr_write(APB_MASTER1_X_data_mem_addr_write), 
        .data_mem_data_write(APB_MASTER1_X_data_mem_data_write), 
        .data_mem_data_read(APB_MASTER1_X_data_mem_data_read), 
        .block_pc(APB_MASTER1_X_block_pc), 
        .wr_transfer(APB_MASTER1_X_data_mem_w_en), 
        .rd_transfer(instr_mem_data_read[31:28] == 14), // opcode 14 = LOAD (APB read) 
        
        //APB 
        .pclk(pclk), 
        .preset(preset), 
        .paddr(paddr), 
        .psel(psel), 
        .penable(penable), 
        .pwrite(pwrite), 
        .pwdata(pwdata), 
        .prdata(prdata), 
        .pready(pready), 
        .peripheral_select(peripheral_select) 
    ); 
    
endmodule
