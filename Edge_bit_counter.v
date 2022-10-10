module Edge_bit_counter 

(
    input  wire [3:0]  Prescale,
    input  wire        Enable,
    input  wire        Clk,
    input  wire        Rst,
    input  wire        Parity_EN,
    output reg [3:0]   Bit_count,
    output reg [2:0]   Edge_count
);

 

always @(posedge Clk or negedge Rst) 
begin
    if(!Rst )
    begin
        Edge_count<= 3'd0;
    end
    else if(Edge_count== Prescale-3'd1  || !Enable)
    begin
        Edge_count<= 3'd0;
    end
    else if(Enable & (Edge_count!=Prescale-3'd1))
    begin
        Edge_count<= Edge_count + 3'd1;
    end
end
    
always @(posedge Clk or negedge Rst) 
begin
    if(!Rst  )
    begin
        Bit_count<= 4'd0;
    end
    else if(!Enable)
    begin
        Bit_count<= 4'd0;
    end
    else if (Parity_EN && (Edge_count== Prescale-3'd1)  && (Bit_count !=4'd11))
    begin
        Bit_count<= Bit_count + 4'd1;
    end
    else if (!Parity_EN && (Edge_count== Prescale-3'd1)   && (Bit_count !=4'd10))
    begin
        Bit_count<= Bit_count + 4'd1;
    end
end
 


endmodule
