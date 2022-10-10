`timescale 1ns/1ps
module UART_RX_TOP_tb ();

 parameter out_width_tb      = 8;
 parameter clk_period        = 5;  //5 nano



    reg                          RX_IN_tb;
    reg  [3:0]                   Prescale_tb;
    reg                          Parity_EN_tb;
    reg                          Parity_type_tb;
    reg                          Clk_tb;
    reg                          Rst_tb;
    wire [out_width_tb-1:0]      Parallel_data_tb;
    wire                         Data_vaild_tb;


initial 
begin
Clk_tb=1'd0;
RX_IN_tb=1'd1;
Parity_type_tb=1'd0;
Parity_EN_tb=1'd0;
Prescale_tb=4'd8;

reset;



/******************** case2: frame without parity with stop error *************************/

    frame_without_parity_without_stop(8'b01001100);

    RX_IN_tb = 1;
    #clk_period    
    RX_IN_tb = 0;
    #(3*clk_period)
    RX_IN_tb = 1;
    #clk_period
    RX_IN_tb = 0;
    #(3*clk_period)
    RX_IN_tb = 1;


    #clk_period
    if (Parallel_data_tb == 8'b01001100 && Data_vaild_tb == 0)
      $display ("pass1");
    else
      $display ("fail1");

    #(3*clk_period)

    /******************** case1: frame without parity *************************/

    frame_without_parity_with_stop(8'b10100111);

    #clk_period
    if (Parallel_data_tb == 8'b10100111 && Data_vaild_tb == 1)
      $display ("pass2");
    else
      $display ("fail2");

    #(3*clk_period)
/******************** case3: start glitching , no frame *************************/


    RX_IN_tb = 0;
    #clk_period    
    RX_IN_tb = 1;
    #(3*clk_period)
    RX_IN_tb = 0;
    #clk_period
    RX_IN_tb = 1;
    #(3*clk_period)

    #(72*clk_period)

    #clk_period
    if (Parallel_data_tb == 8'b10100111 && Data_vaild_tb == 0)
      $display ("pass3");
    else
      $display ("fail3");

    #(3*clk_period)

/******************** case4: frame with right even parity *************************/


    Parity_type_tb=1'd0;
    Parity_EN_tb=1'd1;

    frame_with_parity_with_stop(9'b001100110);

    #clk_period
    if (Parallel_data_tb == 8'b01100110 && Data_vaild_tb == 1)
      $display ("pass4");
    else
      $display ("fail4");

    #(3*clk_period)

/******************** case5: frame with wrong even parity *************************/

   frame_with_parity_with_stop(9'b101100110);

    #clk_period
    if (Parallel_data_tb == 8'b01100110 && Data_vaild_tb == 0)
      $display ("pass5");
    else
      $display ("fail5");

    #(3*clk_period)

/******************** case6: frame with right odd parity *************************/
 #(3*clk_period)
    Parity_type_tb = 1;
    Parity_EN_tb=1'd1;

    frame_with_parity_with_stop(9'b111001100);

    #(clk_period)
    if (Parallel_data_tb == 8'b11001100 && Data_vaild_tb == 1)
      $display ("pass6");
    else
      $display ("fail6");

    #(3*clk_period)

/******************** case7: frame with wrong odd parity *************************/
 Parity_EN_tb=1'd1;
 Parity_type_tb = 1;
    frame_with_parity_with_stop(9'b101100111);

    #(clk_period)
    if (Parallel_data_tb == 8'b01100111 && Data_vaild_tb == 0)
      $display ("pass7");
    else
      $display ("fail7");

    #(3*clk_period)

/******************** case8: frame with right parity and stop error *************************/
 Parity_EN_tb=1'd1;
 Parity_type_tb = 1;
    frame_with_parity_without_stop(9'b001100111);

    RX_IN_tb = 1;
    #clk_period    
    RX_IN_tb = 0;
    #(3*clk_period)
    RX_IN_tb = 1;
    #clk_period
    RX_IN_tb = 0;
    #(3*clk_period)
    RX_IN_tb = 1;


    #(clk_period)
    if (Parallel_data_tb == 8'b01100111 && Data_vaild_tb == 0)
      $display ("pass8");
    else
      $display ("fail8");

    #(3*clk_period)

/******************** case9: frame with wrong parity and stop error *************************/
 Parity_EN_tb=1'd1;
 Parity_type_tb = 0;
    frame_with_parity_without_stop(9'b011100001);

    RX_IN_tb = 1;
    #clk_period    
    RX_IN_tb = 0;
    #(3*clk_period)
    RX_IN_tb = 1;
    #clk_period
    RX_IN_tb = 0;
    #(3*clk_period)
    RX_IN_tb = 1;


    #(clk_period)
    if (Parallel_data_tb == 8'b11100001 && Data_vaild_tb == 0)
      $display ("pass9");
    else
      $display ("fail9");

    #(3*clk_period)

/******************** case10: 2 frames *************************/

    frame_with_parity_with_stop(9'b111100001);
    
    frame_with_parity_with_stop(9'b000010000);

    #(2*clk_period)

    /*look on wave you will found that 
      the 2 frames has been sent correctly 
      and there are valid signal after each frame*/ 

/***********************************************************************************/
  










$stop;
end


/***********reset**************/
task reset ();
    begin
         Rst_tb=1'b1;
         #clk_period
         Rst_tb=1'b0;
         #clk_period
         Rst_tb=1'b1;
         #clk_period;
    end
endtask
/*************clk generator**************/
always #(clk_period/2.0)  Clk_tb=~Clk_tb;


/**********frame_with_parity_with_stop*********/
task frame_with_parity_with_stop 
(
  input [8:0]  rx_in
);
begin
    RX_IN_tb = 0;
    #(8*clk_period)
    RX_IN_tb = rx_in[0];
    #(8*clk_period)
    RX_IN_tb= rx_in[1];
    #(8*clk_period)
    RX_IN_tb= rx_in[2];
    #(8*clk_period)
    RX_IN_tb= rx_in[3];
    #(8*clk_period)
    RX_IN_tb= rx_in[4];
    #(8*clk_period)
    RX_IN_tb= rx_in[5];
    #(8*clk_period)
    RX_IN_tb= rx_in[6];
    #(8*clk_period)
    RX_IN_tb= rx_in[7];
    #(8*clk_period)
    RX_IN_tb= rx_in[8];
    #(8*clk_period)
    RX_IN_tb= 1;
    #(8*clk_period);
end
endtask




/********************frame_without_parity_with_stop***********/
task frame_without_parity_with_stop 
(
  input [7:0]  rx_in
);
begin
    RX_IN_tb= 0;
    #(8*clk_period)
    RX_IN_tb= rx_in[0];
    #(8*clk_period)
    RX_IN_tb= rx_in[1];
    #(8*clk_period)
    RX_IN_tb= rx_in[2];
    #(8*clk_period)
    RX_IN_tb= rx_in[3];
    #(8*clk_period)
    RX_IN_tb= rx_in[4];
    #(8*clk_period)
    RX_IN_tb= rx_in[5];
    #(8*clk_period)
    RX_IN_tb= rx_in[6];
    #(8*clk_period)
    RX_IN_tb= rx_in[7];
    #(8*clk_period)
    RX_IN_tb= 1;
    #(8*clk_period);
end
endtask

/***********frame_with_parity_without_stop**************/
task frame_with_parity_without_stop 
(
  input [8:0]  rx_in
);
begin
    RX_IN_tb= 0;
    #(8*clk_period)
    RX_IN_tb= rx_in[0];
    #(8*clk_period)
    RX_IN_tb= rx_in[1];
    #(8*clk_period)
    RX_IN_tb= rx_in[2];
    #(8*clk_period)
    RX_IN_tb= rx_in[3];
    #(8*clk_period)
    RX_IN_tb= rx_in[4];
    #(8*clk_period)
    RX_IN_tb= rx_in[5];
    #(8*clk_period)
    RX_IN_tb= rx_in[6];
    #(8*clk_period)
    RX_IN_tb= rx_in[7];
    #(8*clk_period)
    RX_IN_tb= rx_in[8];
    #(8*clk_period);
end
endtask


/*************frame_without_parity_without_stop**********/
task frame_without_parity_without_stop 
(
  input [7:0]  rx_in
);
begin
    RX_IN_tb= 0;
    #(8*clk_period)
    RX_IN_tb= rx_in[0];
    #(8*clk_period)
    RX_IN_tb= rx_in[1];
    #(8*clk_period)
    RX_IN_tb= rx_in[2];
    #(8*clk_period)
    RX_IN_tb = rx_in[3];
    #(8*clk_period)
    RX_IN_tb= rx_in[4];
    #(8*clk_period)
    RX_IN_tb = rx_in[5];
    #(8*clk_period)
    RX_IN_tb = rx_in[6];
    #(8*clk_period)
    RX_IN_tb = rx_in[7];
    #(8*clk_period);
end
endtask


UART_RX_TOP 
#(
    .out_width      (out_width_tb      )
)
u_UART_RX_TOP(
    .RX_IN         (RX_IN_tb         ),
    .Prescale      (Prescale_tb      ),
    .Parity_EN     (Parity_EN_tb     ),
    .Parity_type   (Parity_type_tb   ),
    .Clk           (Clk_tb           ),
    .Rst           (Rst_tb           ),
    .Parallel_data (Parallel_data_tb ),
    .Data_vaild    (Data_vaild_tb    )
);

endmodule