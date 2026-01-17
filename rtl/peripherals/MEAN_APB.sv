//------------------------------------------------------------------------------
// MEAN_APB.sv
//
// APB peripheral: arithmetic mean of 4 unsigned 16-bit numbers. Uses a sequential FSM and stalls APB via pready=0 while computing.
//
// Notes:
// - Academic project (CID2 - Digital Integrated Circuits).
// - RTL written in SystemVerilog.
//------------------------------------------------------------------------------

module MEAN_APB(
        input logic pclk,
        input logic preset,
        input logic [9:0] paddr,
        input logic psel,
        input logic penable,
        input logic pwrite,
        input logic [15:0] pwdata,
        output logic [15:0] prdata,
        output logic pready
    );

// FSM state: 0=IDLE/READY, 1..4 accumulate inputs, 5=finalize
logic [2:0] state; 
// Accumulator wide enough to hold sum of four 16-bit numbers (max 4*65535=262140 < 2^18)
logic [17:0] sum_acc; 
// CONFIG register: bit0=start (written by CPU), bit1=done (set by hardware)
logic [1:0] configure;
logic [15:0] data_a;
logic [15:0] data_b;
logic [15:0] data_c;
logic [15:0] data_d;
logic [15:0] result;


// Mean computation FSM (triggered by writing CONFIG[0]=1)
always_ff@(posedge pclk)
    begin
        if(preset)
            begin
                state <= 0;
                sum_acc <= 0;
                result <= 0;
                configure <= 0;
            end
        else
            begin
                if(state == 0)          // Pregatire adunare
                    begin
                        if(psel & penable & pwrite & (paddr == 0) & pwdata[0])
                            begin
                                state <= 1;
                                configure[0] <= 1; 
                                configure[1] <= 0; 
                                sum_acc <= 0;
                            end
                    end
                else if(state == 1)     // Adunare A
                    begin
                        sum_acc <= data_a;
                        state <= 2;
                    end
                else if(state == 2)     // Adunare B
                    begin
                        sum_acc <= sum_acc + data_b;
                        state <= 3;
                    end
                else if(state == 3)     // Adunare C
                    begin
                        sum_acc <= sum_acc + data_c;
                        state <= 4;
                    end
                else if(state == 4)     // Adunare D
                    begin
                        sum_acc <= sum_acc + data_d;
                        state <= 5;
                    end
                else if(state == 5)     // Rezultat final
                    begin
                        result <= sum_acc >> 2; 
                        configure[0] <= 0; 
                        configure[1] <= 1;
                        state <= 0;
                    end
            end       
    end
    
// Scriere 
always_ff@(posedge pclk)
    begin
        if(preset)
            begin
                data_a <= 0;
                data_b <= 0;
                data_c <= 0;
                data_d <= 0;
            end
        else if(psel & pwrite & penable & pready)
            begin
                case(paddr)
                    1: data_a <= pwdata;
                    2: data_b <= pwdata;
                    3: data_c <= pwdata;
                    4: data_d <= pwdata;                  
                endcase    
            end
    end

// Insert APB wait states while computing (pready=0 when state != 0)
assign pready = (state == 0) ? 1 : 0; 

// Readback mux for registers (valid only on APB read access)
always_comb
    begin
        if(psel & penable & pready & ~pwrite)
            begin
                case(paddr)
                    0: prdata = {14'b0, configure};
                    1: prdata = data_a;
                    2: prdata = data_b;
                    3: prdata = data_c;
                    4: prdata = data_d;
                    5: prdata = result;
                    default: prdata = 0; 
                endcase
            end
        else
            prdata = 0;      
    end
 
endmodule
