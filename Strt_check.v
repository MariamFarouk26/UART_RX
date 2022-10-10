module Strt_check
(
    input  wire Sampled_bit,
    input  wire Strt_chk_EN,
    input  wire Clk,
    input  wire Rst,
    output reg  Strt_glitch
);



   
always @(posedge Clk or negedge Rst)
 begin
    if(!Rst )
        Strt_glitch <= 1'd0;
    else if(Strt_chk_EN && (Sampled_bit==1'd0))
        Strt_glitch <= 1'd0;
    else if(Strt_chk_EN && (Sampled_bit!=1'd0))
        Strt_glitch <= 1'd1;  
end 


endmodule
