module Stop_check
(
    input  wire Sampled_bit,
    input  wire Stp_chk_EN,
    input  wire Clk,
    input  wire Rst,
    output reg  Stp_ERR
);
reg   Stp_ERR_reg;  


always @(*)
 begin
    if(Stp_chk_EN && (Sampled_bit==1'd1))
        Stp_ERR_reg = 1'd0 ;    
    else if(Stp_chk_EN && (Sampled_bit!=1'd1))
        Stp_ERR_reg = 1'd1  ;
    else
        Stp_ERR_reg = Stp_ERR;
end


always @(posedge Clk or negedge Rst) 
begin
    if(!Rst)
        Stp_ERR <= 1'd0;    
    else
        Stp_ERR <= Stp_ERR_reg ;
end




endmodule
