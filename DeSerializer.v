module DeSerializer 
#(parameter out_width  =8)

(
    input  wire                         Clk,
    input  wire                         Rst,
    input  wire                         DeSerializer_EN,
    input  wire                         Sampled_bit,
    output reg  [out_width-1:0]         Parallel_data
    
);

reg [2:0] index;

always @(posedge Clk or negedge Rst) 
begin
    if(!Rst)
        Parallel_data <= 'd0;
    else if(DeSerializer_EN )
        Parallel_data[index] <= Sampled_bit;
end

always @(posedge Clk or negedge Rst) 
begin
 if(!Rst) 
    index <= 3'd0;
 else if(DeSerializer_EN )
  index <= index + 3'd1; 
end
endmodule

