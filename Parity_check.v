module Parity_check #(parameter out_width =8)
(
    input  wire                 Sampled_bit,
    input  wire                 Parity_chk_EN,
    input  wire                 Parity_type,
    input  wire                 Clk,
    input  wire                 Rst,
    input  wire [out_width-1:0] Parallel_data,
    output reg                  Parity_ERR
);


localparam     even_parity = 1'd0 ,
               odd_parity  = 1'd1;

    
reg [out_width-1:0] parallel_data_reg;
reg                 parity_bit_reg;
reg                 parity_bit;
reg                 Parity_ERR_reg;


always @(posedge Clk or negedge Rst) 
begin
    if(!Rst)
        parallel_data_reg <='d0;   
    else if(Parity_chk_EN)
        parallel_data_reg <= Parallel_data;
end

always @(*)
     begin
        if(Parity_chk_EN)
        begin
        case (Parity_type)
            even_parity  : begin
                             parity_bit_reg = ^parallel_data_reg  ;
                            end
            odd_parity   : begin
                            parity_bit_reg =  ~^parallel_data_reg;
                            end
            default: parity_bit_reg =1'd0 ; // in ideal state
        endcase
        end
        else
            parity_bit_reg = parity_bit;
    end


always @(posedge Clk or negedge Rst) 
begin
if(!Rst)
    parity_bit <= 1'd0;    
else
    parity_bit <= parity_bit_reg;    
end


always @(*)
 begin
    if( Sampled_bit ==parity_bit)
        Parity_ERR_reg = 1'd0 ;    
    else if(Sampled_bit !=parity_bit)
        Parity_ERR_reg = 1'd1  ;
    else
        Parity_ERR_reg = Parity_ERR;
end

always @(posedge Clk or negedge Rst) 
begin
    if(!Rst)
        Parity_ERR <= 1'd0;    
    else if(Parity_chk_EN)
        Parity_ERR <= Parity_ERR_reg ;
end


endmodule
