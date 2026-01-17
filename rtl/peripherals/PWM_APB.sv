//------------------------------------------------------------------------------
// PWM_APB.sv
//
// APB peripheral: PWM generator. Period and duty cycle are configured via APB registers.
//
// Notes:
// - Academic project (CID2 - Digital Integrated Circuits).
// - RTL written in SystemVerilog.
//------------------------------------------------------------------------------

module PWM_APB(
        input logic pclk,
        input logic preset,
        input logic [9:0] paddr,
        input logic psel,
        input logic penable,
        input logic pwrite,
        input logic [15:0] pwdata,
        output logic [15:0] prdata,
        output logic pready,
        
        //PWM out
        output logic pwm_out
    );

// Free-running counter used for PWM generation
logic [15:0] counter;
logic reset;
logic period_reset;
// CONFIG register bit0: when 1, stops PWM counter (per spec)
logic configure;
logic [15:0] limit_period;
logic [15:0] limit_duty;


always_ff@(posedge pclk)
    begin
        if(reset)
            counter <= 0;
        else
            counter <= counter + 1;        
    end
    

always_ff@(posedge pclk)
    begin
        if(preset)
            begin
                configure <= 0;
                limit_period <= 0;
                limit_duty <= 0;
            end
        else if(psel & pwrite &penable & pready)
            begin
                case(paddr)
                    0: configure <= pwdata[0];
                    1: limit_period <= pwdata;
                    2: limit_duty <= pwdata;                    
                endcase    
            end
    end


// PWM output: high for counter < duty threshold
assign pwm_out = counter < limit_duty;
assign period_reset = counter >= (limit_period - 1);   
assign reset = preset | configure | period_reset;

// PWM peripheral is always ready (no wait states)
assign pready = 1;

always_comb
    begin
        if(psel & penable & pready & ~pwrite)
            begin
                case(paddr)
                    0: prdata = {15'b0, configure};
                    1: prdata = limit_period;
                    2: prdata = limit_duty;
                    default: prdata = 0; 
                endcase
            end
        else
            prdata = 0;     
    end

// Echivalent cu ce e mai sus - se foloseste in industrie    
//always_comb
//    begin
//        prdata = 0; 
//        if(psel & penable & pready & ~pwrite)
//            begin
//              case(paddr)
//                  0: prdata = {15'b0, configure};
//                  1: prdata = limit_period;
//                  2: prdata = limit_duty;
//              endcase
//            end
//    end
 
endmodule
