module Data_sampling 
(
    input  wire [3:0]    Prescale,
    input  wire          RX_IN,
    input  wire          Clk,
    input  wire          Rst,
    input  wire [2:0]    Edge_count,
    output reg           Sampled_bit
);

reg [2:0] regfile ;
reg [1:0] index_counter ;
reg Sampled_bit_reg;

always @(*) 
begin
   if(Edge_count== (Prescale/2)+3'd1) 
    begin
     case (regfile)
       3'b000 : Sampled_bit_reg =1'd0;
       3'b001 : Sampled_bit_reg =1'd0;
       3'b010 : Sampled_bit_reg =1'd0;
       3'b011 : Sampled_bit_reg =1'd1;
       3'b100 : Sampled_bit_reg =1'd0;
       3'b101 : Sampled_bit_reg =1'd1;
       3'b110 : Sampled_bit_reg =1'd1;
       3'b111 : Sampled_bit_reg =1'd1;
       default: Sampled_bit_reg =1'd1;
     endcase
    end
   else
      Sampled_bit_reg =Sampled_bit;
end


always @(posedge Clk or negedge Rst) 
begin
 if(!Rst)
      Sampled_bit <=1'd0;  
 else 
      Sampled_bit <= Sampled_bit_reg;
end



always @(posedge Clk or negedge Rst) 
begin
 if(!Rst)
   regfile <= 3'd0;   
 //else if( index_counter == 2'd3)   
  // regfile <= 3'd0;   
 else if( Edge_count== (Prescale/2)-3'd1 || Edge_count== (Prescale/2) || Edge_count== (Prescale/2) +3'd1 )
   regfile[index_counter] <= RX_IN;
end
    

always @(posedge Clk or negedge Rst) 
begin
 if(!Rst) 
    index_counter <= 2'd0;
 else if(index_counter == 2'd2)
    index_counter <= 2'd0;
 else if(Edge_count== (Prescale/2)-3'd1 || Edge_count== (Prescale/2) || Edge_count== (Prescale/2) +3'd1 )
    index_counter <= index_counter + 2'd1; 
end


endmodule
