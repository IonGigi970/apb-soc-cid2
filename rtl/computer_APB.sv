//------------------------------------------------------------------------------
// computer_APB.sv
//
// Top-level SoC wrapper. Connects the custom CPU (procesorAPB) to APB peripherals.
//
// Notes:
// - Academic project (CID2 - Digital Integrated Circuits).
// - RTL written in SystemVerilog.
//------------------------------------------------------------------------------

module computer_APB(
        input clock,
        input reset,
        
        input [3:0] btn_in,
        output pwm_out
    );

logic preset;
logic pclk;
logic [7:0] instr_mem_addr_read;
logic [31:0] instr_mem_data_read;
logic [9:0] paddr;
logic penable;
logic pwrite;
logic pready;
logic psel;
logic [15:0] prdata;
logic [15:0] pwdata;
logic [1:0] peripheral_select;

// Per-peripheral select lines (derived from master psel and decoded peripheral_select)
logic psel_mem, psel_pwm, psel_btn, psel_mean;
// Per-peripheral ready lines (muxed back to the master)
logic pready_mem, pready_pwm, pready_btn, pready_mean;
// Per-peripheral read data lines (muxed back to the master)
logic [15:0] prdata_mem, prdata_pwm, prdata_btn, prdata_mean;

    
procesorAPB procesorAPB0(
        .clock(clock),
        .reset(reset),
        
        .instr_mem_data_read(instr_mem_data_read),
        .instr_mem_addr_read(instr_mem_addr_read),
        
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
    
data_mem_APBSlave data_mem_APBSlave0(
        .pclk(pclk),
        .paddr(paddr),
        .psel(psel_mem),
        .penable(penable),
        .pwrite(pwrite),
        .pwdata(pwdata),
        .prdata(prdata_mem),
        .pready(pready_mem)
    );

instr_mem instr_mem0(
        .addr_read(instr_mem_addr_read),
        .data_read(instr_mem_data_read)
    );
    
PWM_APB PWM_APB0(
        .pclk(pclk),
        .preset(preset),
        .paddr(paddr),
        .psel(psel_pwm),
        .penable(penable),
        .pwrite(pwrite),
        .pwdata(pwdata),
        .prdata(prdata_pwm),
        .pready(pready_pwm),
        
        //PWM out
        .pwm_out(pwm_out)
    );

BTN_APB BTN_APB0(
        .pclk(pclk),
        .preset(preset),
        .paddr(paddr),
        .psel(psel_btn),
        .penable(penable),
        .pwrite(pwrite),
        .pwdata(pwdata),
        .prdata(prdata_btn),
        .pready(pready_btn),
        
        //to buttons
        .buttons(btn_in)     
    );

MEAN_APB MEAN_APB0(
        .pclk(pclk),
        .preset(preset),
        .paddr(paddr),
        .psel(psel_mean),
        .penable(penable),
        .pwrite(pwrite),
        .pwdata(pwdata),
        .prdata(prdata_mean),
        .pready(pready_mean)
    );

    
// Demultiplex psel to exactly one peripheral based on peripheral_select
always_comb
    begin
        psel_mem = 0;
        psel_pwm = 0;
        psel_btn = 0;
        psel_mean = 0;
        
        case(peripheral_select)
            0: psel_mem = psel;
            1: psel_pwm = psel;
            2: psel_btn = psel;
            3: psel_mean = psel;
            default: ;
        endcase       
    end


    
// Mux pready back from selected peripheral
always_comb
    begin
        case(peripheral_select)
            0: pready = pready_mem;
            1: pready = pready_pwm;
            2: pready = pready_btn;
            3: pready = pready_mean;
            default: pready = 0;
        endcase 
    end 

// Mux pready back from selected peripheral
// Mux prdata back from selected peripheral
always_comb
    begin
        case(peripheral_select)
            0: prdata = prdata_mem;
            1: prdata = prdata_pwm;
            2: prdata = prdata_btn;
            3: prdata = prdata_mean;
            default: prdata = 0;
        endcase 
    end 
    
endmodule
