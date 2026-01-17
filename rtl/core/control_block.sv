//------------------------------------------------------------------------------
// control_block.sv
//
// Control unit. Decodes opcode and generates control signals for PC, RALU and memory-mapped access.
//
// Notes:
// - Academic project (CID2 - Digital Integrated Circuits).
// - RTL written in SystemVerilog.
//------------------------------------------------------------------------------

module control_block(
        input logic [3:0] opcode,
        input logic zero_flag,
        output logic ralu_w_en,
        output logic pc_en,
        output logic do_jump,
        output logic data_mem_w_en
    );
    
// Combinational decode: set defaults per opcode
always_comb
    begin
        case(opcode)
            0: begin
                  ralu_w_en = 0; 
                  pc_en = 1;      
                  do_jump = 0;     
                  data_mem_w_en = 0;    
               end
               
            1: begin
                  ralu_w_en = 1; 
                  pc_en = 1;      
                  do_jump = 0;     
                  data_mem_w_en = 0;    
               end
               
            2: begin
                  ralu_w_en = 1; 
                  pc_en = 1;      
                  do_jump = 0;     
                  data_mem_w_en = 0;    
               end
               
            3: begin
                  ralu_w_en = 1; 
                  pc_en = 1;      
                  do_jump = 0;     
                  data_mem_w_en = 0;    
               end
               
            4: begin
                  ralu_w_en = 1; 
                  pc_en = 1;      
                  do_jump = 0;     
                  data_mem_w_en = 0;    
               end 
                             
            5: begin
                  ralu_w_en = 0; 
                  pc_en = 1;      
                  do_jump = 0;     
                  data_mem_w_en = 0;    
               end 
                             
            6: begin
                  ralu_w_en = 1; 
                  pc_en = 1;      
                  do_jump = 0;     
                  data_mem_w_en = 0;    
               end
                              
            7: begin
                  ralu_w_en = 1; 
                  pc_en = 1;      
                  do_jump = 0;     
                  data_mem_w_en = 0;    
               end
                              
            8: begin
                  ralu_w_en = 1; 
                  pc_en = 1;      
                  do_jump = 0;     
                  data_mem_w_en = 0;    
               end
               
            9: begin
                  ralu_w_en = 0; 
                  pc_en = 1;      
                  do_jump = 0;     
                  data_mem_w_en = 0;    
               end   
                           
            10: begin
                  ralu_w_en = 1; 
                  pc_en = 1;      
                  do_jump = 0;     
                  data_mem_w_en = 0;    
                end 
                             
            11: begin
                  ralu_w_en = 0; 
                  pc_en = 1;      
                  do_jump = 1;     
                  data_mem_w_en = 0;    
                end 
                             
            12: begin
                  ralu_w_en = 0;
                  pc_en = 1; 
                  if(zero_flag)
                        do_jump = 1;  
                  else 
                        do_jump = 0;  
                  data_mem_w_en = 0;                                              
                end   
                           
            13: begin
                  ralu_w_en = 0; 
                  pc_en = 1;      
                  do_jump = 0;     
                  data_mem_w_en = 1;    
                end 
                             
            14: begin
                  ralu_w_en = 1; 
                  pc_en = 1;      
                  do_jump = 0;     
                  data_mem_w_en = 0;    
                end
                               
            15: begin
                  ralu_w_en = 0; 
                  pc_en = 0;      
                  do_jump = 0;     
                  data_mem_w_en = 0;    
                end 
                             
            default: begin
                  ralu_w_en = 0; 
                  pc_en = 0;      
                  do_jump = 0;     
                  data_mem_w_en = 0;    
               end                                                          
        endcase 
    end
endmodule
