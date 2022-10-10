module FSM 
(
    input  wire             RX_IN,
    input  wire             Parity_EN,
    input  wire  [3:0]      Bit_count,
    input  wire  [2:0]      Edge_count,
    input  wire             Parity_ERR,
    input  wire             Strt_glitch,
    input  wire             Stp_ERR,
    input  wire             Clk,
    input  wire             Rst,
    output reg              Parity_chk_EN,
    output reg              Strt_chk_EN,
    output reg              Stp_chk_EN,
    output reg              Data_vaild,
    output reg              DeSerializer_EN,
    output reg              Enable
);
    
   reg [2:0]   current_state;
   reg [2:0]   next_state;

 localparam    idle_state    =3'd0 ,
               start_state   =3'd1 ,
               data_state    =3'd2 , 
               parity_state  =3'd3 ,
               stop_state    =3'd4 ;
 
 localparam  Edge0 = 3'd0,
             Edge7 = 3'd7,
             Edge1 = 3'd1,
             Edge2 = 3'd2;

 always @(posedge Clk or negedge Rst)
  begin
    if(!Rst)
        current_state <= idle_state;
    else
        current_state <= next_state ;
  end           

always @(*)
 begin
    case (current_state)
      idle_state     : begin
                      if(RX_IN==1'd0 &&Bit_count==4'd0)
                        next_state =start_state ;
                      else
                        next_state =idle_state ;
                       end
      start_state    : begin
                      if(Bit_count==4'd1 && Strt_glitch==1'd0)
                        next_state =data_state ;
                      else if(Bit_count==4'd1 && Strt_glitch==1'd1)
                        next_state =idle_state ;
                      else
                        next_state =start_state ;
                       end
      data_state      : begin
                        if(Bit_count==4'd9 && Parity_EN)
                          next_state =parity_state ;
                        else if(Bit_count==4'd9 && !Parity_EN)
                          next_state =stop_state ;
                        else
                          next_state =data_state ;
                        end
      parity_state    : begin
                        if(Bit_count==4'd10)
                          next_state =stop_state ;
                        else
                          next_state =parity_state ;
                        end
      stop_state     : begin
                      if(((Bit_count==4'd11 && Parity_EN) || (Bit_count==4'd10 && !Parity_EN)) && RX_IN)
                        next_state = idle_state ;
                      else if(((Bit_count==4'd11 && Parity_EN) || (Bit_count==4'd10 && !Parity_EN)) && !RX_IN)
                         next_state = start_state ;
                      else
                        next_state = stop_state ;
                       end
      default         : begin
                        next_state = idle_state ;
                        end
    endcase
end



always @(*)
 begin
    Parity_chk_EN=1'd0;
    Strt_chk_EN=1'd0;
    Stp_chk_EN=1'd0;
    Data_vaild=1'd0;
    DeSerializer_EN=1'd0;
    Enable=1'd1;
    case (current_state)
      idle_state    : begin
                      Enable =1'd0;
                      end
      start_state   : begin
                      if(Edge_count==3'd7)
                        Strt_chk_EN=1'd1;
                      else
                        Strt_chk_EN=1'd0;
                      end
      data_state     : begin
                      if (Edge_count==3'd7)
                        DeSerializer_EN=1'd1;
                      else
                        DeSerializer_EN=1'd0;
                      end
      parity_state   : begin
                      if( Edge_count==3'd0 )
                        Parity_chk_EN=1'd1;
                      else
                        Parity_chk_EN=1'd0;
                       end
      stop_state     : begin
                        case (Edge_count)
                         Edge1 :Parity_chk_EN=1'd1;
                         Edge2 :Parity_chk_EN=1'd1;
                         Edge7 :  begin
                                  Data_vaild =1'd0;
                                  Stp_chk_EN=1'd1;
                                  end
                         Edge0 :  begin
                                  Stp_chk_EN=1'd0;
                                  if(Parity_EN)
                                  begin
                                  if(Stp_ERR && Parity_ERR )
                                    Data_vaild =1'd0;
                                  else if(!Stp_ERR && !Parity_ERR )
                                    Data_vaild =1'd1;  
                                  else
                                    Data_vaild =1'd0;                      
                                  end
                                  else
                                  begin
                                    if(Stp_ERR )
                                    Data_vaild =1'd0;
                                  else if(!Stp_ERR )
                                    Data_vaild =1'd1;  
                                  else
                                    Data_vaild =1'd0;                      
                                  end
                                  end
                        default : begin
                                  Data_vaild =1'd0;
                                  Stp_chk_EN=1'd0;
                                  end 
                        endcase
                      end
    default       : begin
                    Parity_chk_EN=1'd0;
                    Strt_chk_EN=1'd0;
                    Stp_chk_EN=1'd0;
                    Data_vaild=1'd0;
                    DeSerializer_EN=1'd0;
                    Enable=1'd0;
                    end
    endcase
end



endmodule
