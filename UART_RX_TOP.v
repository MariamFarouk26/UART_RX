module UART_RX_TOP 
#(
 parameter out_width      = 8
)

(
    input  wire                          RX_IN,
    input  wire  [3:0]                   Prescale,
    input  wire                          Parity_EN,
    input  wire                          Parity_type,
    input  wire                          Clk,
    input  wire                          Rst,
    output wire [out_width-1:0]          Parallel_data,
    output wire                          Data_vaild
);
    //internal wires
wire        Enable;
wire [2:0]  Edge_count;
wire [3:0]  Bit_count;
wire        Sampled_bit;
wire        DeSerializer_EN;
wire        Parity_ERR;
wire        Parity_chk_EN;
wire        Strt_glitch;
wire        Strt_chk_EN;
wire        Stp_chk_EN;
wire        Stp_ERR;


Data_sampling u_Data_sampling(
    .Prescale    (Prescale    ),
    .RX_IN       (RX_IN       ),
    .Clk         (Clk         ),
    .Rst         (Rst         ),
    .Edge_count  (Edge_count  ),
    .Sampled_bit (Sampled_bit )
);



DeSerializer 
#(
    .out_width      (out_width      )
)
u_DeSerializer(
    .Clk             (Clk             ),
    .Rst             (Rst             ),
    .DeSerializer_EN (DeSerializer_EN ),
    .Sampled_bit     (Sampled_bit     ),
    .Parallel_data   (Parallel_data   )
);

Edge_bit_counter u_Edge_bit_counter(
    .Prescale   (Prescale   ),
    .Enable     (Enable     ),
    .Clk        (Clk        ),
    .Rst        (Rst        ),
    .Parity_EN  (Parity_EN  ),
    .Bit_count  (Bit_count  ),
    .Edge_count (Edge_count )
);




FSM u_FSM(
    .RX_IN           (RX_IN           ),
    .Parity_EN       (Parity_EN       ),
    .Bit_count       (Bit_count       ),
    .Edge_count      (Edge_count      ),
    .Parity_ERR      (Parity_ERR      ),
    .Strt_glitch     (Strt_glitch     ),
    .Stp_ERR         (Stp_ERR         ),
    .Clk             (Clk             ),
    .Rst             (Rst             ),
    .Parity_chk_EN   (Parity_chk_EN   ),
    .Strt_chk_EN     (Strt_chk_EN     ),
    .Stp_chk_EN      (Stp_chk_EN      ),
    .Data_vaild      (Data_vaild      ),
    .DeSerializer_EN (DeSerializer_EN ),
    .Enable          (Enable          )
);




Parity_check 
#(
    .out_width   (out_width   )
)
u_Parity_check(
    .Sampled_bit   (Sampled_bit   ),
    .Parity_chk_EN (Parity_chk_EN ),
    .Parity_type   (Parity_type   ),
    .Clk           (Clk           ),
    .Rst           (Rst           ),
    .Parallel_data (Parallel_data ),
    .Parity_ERR    (Parity_ERR    )
);

Stop_check u_Stop_check
(
    .Sampled_bit (Sampled_bit ),
    .Stp_chk_EN  (Stp_chk_EN ),
    .Clk         (Clk         ),
    .Rst         (Rst         ),
    .Stp_ERR     (Stp_ERR     )
);



Strt_check u_Strt_check
(
    .Sampled_bit (Sampled_bit ),
    .Strt_chk_EN (Strt_chk_EN ),
    .Clk         (Clk         ),
    .Rst         (Rst         ),
    .Strt_glitch (Strt_glitch )
);


endmodule
