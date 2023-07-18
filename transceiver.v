module uart (
   tck,
   rck,
   reset,
   TxEnable,
   TxD,
   TxData,
   TxDone,
   RxData,
   RxD
);

// Port Declaration
   input	     tck;
   input	     rck;
   input	     reset;
   input	     TxEnable;
   input [7:0]	     TxData;
   output	     TxD;
   output	     TxDone;
   output [7:0]	     RxData;
   input	     RxD;

// Global Parameters Conrtolled from Testbench 
   parameter baud_rate = 115_200; 
   parameter tck_freq = 100_000_000;
   parameter rck_freq = 100_000_000;
// General Local Parameters
   localparam start_bit = 1'b0;
   localparam stop_bit = 1'b1;
   localparam baud_limit_tck = tck_freq / baud_rate;
   localparam baud_limit_rck = rck_freq / baud_rate;
   localparam baud_limit_mid = rck_freq / (baud_rate * 2);

// Transmitter Local Parameters
   localparam Tx_idle = 2'b00;
   localparam Tx_load = 2'b01;
   localparam Tx_transmit = 2'b10;
   localparam Tx_done = 2'b11;

// Receiver Local Parameters
   localparam Rx_idle = 1'b0;
   localparam Rx_receive = 1'b1;

// Registers
   reg        TxD ;
   reg [9:0]  Tx_data ;
   reg [1:0]  Tx_fsm_state ;
   reg [13:0] Tx_baud_counter ;
   reg [3:0]  Tx_bit_counter ;
   reg        transmit_done ;
   reg [13:0] Rx_baud_counter ;
   reg [3:0]  Rx_bit_counter ;
   reg	      Rx_fsm_state ;
   reg [7:0]  RxData ;

// Wires
   wire [1:0] Tx_fsm_state_n ;
   wire	      Rx_fsm_state_n ;

// Assign Statements
   assign TxDone = ( Tx_fsm_state == Tx_done ) ? 1'b1 : 1'b0 ;
   assign Tx_fsm_state_n = (Tx_fsm_state == Tx_idle && TxEnable == 1'b1) ? Tx_load :
			   (Tx_fsm_state == Tx_load) ? Tx_transmit :
			   (Tx_fsm_state == Tx_transmit && !transmit_done ) ? Tx_transmit :
			   (Tx_fsm_state == Tx_transmit && transmit_done ) ? Tx_done : Tx_idle ;
   assign Rx_fsm_state_n = Rx_fsm_state ? ( ( Rx_bit_counter == 4'b1010 ) ? 1'b0 : 1'b1 ) : ( RxD ? 1'b0 : 1'b1 );

// Transmitter Always Block
   always @(posedge tck or negedge reset)
   begin
      if (reset == 1'b0) begin
	 Tx_fsm_state <= 2'b00;
	 Tx_data <= 10'd0;
	 Tx_baud_counter <= 14'd0;
	 Tx_bit_counter  <= 4'd0;
	 transmit_done <= 1'b0;
	 TxD <= 1'b1;
      end else begin
	 Tx_fsm_state <= Tx_fsm_state_n;
         if ( Tx_fsm_state == Tx_transmit ) begin
	    Tx_baud_counter <= Tx_baud_counter + 1;
	    if ( Tx_baud_counter == baud_limit_tck ) begin
	       Tx_bit_counter <= Tx_bit_counter + 1;
	       TxD <= Tx_data [0];
	       Tx_data <= Tx_data >> 1;
	       Tx_baud_counter <= 14'd0;
	    end
	    if ( Tx_bit_counter == 4'b1010 ) begin
	       transmit_done <= 1'b1;
	    end
	 end else if ( Tx_fsm_state == Tx_load ) begin
	    Tx_data <= {stop_bit, TxData, start_bit };
	 end else begin
	    Tx_data <= 10'd0;
	    Tx_baud_counter <= 14'd0;
	    Tx_bit_counter  <= 4'd0;
	    transmit_done <= 1'b0;
	    TxD <= 1'b1;
	 end
      end
   end

//Receiver Always Block
   always @(posedge rck or negedge reset)
   begin
      if(reset == 1'b0) begin
	 Rx_fsm_state <= Rx_idle;
	 RxData <= 8'd0;
	 Rx_baud_counter <=14'd0 ;
	 Rx_bit_counter <= 4'd0 ;
      end else begin
	 Rx_fsm_state <= Rx_fsm_state_n;
      
	 if ( Rx_fsm_state == Rx_receive ) begin
	    Rx_baud_counter <= Rx_baud_counter + 1;
	    if ( Rx_baud_counter == baud_limit_mid ) begin
	       if ( Rx_bit_counter != 4'd0 && Rx_bit_counter != 4'd9 ) begin
		  RxData <= { RxD, RxData[7:1] };
	       end
	       Rx_bit_counter <= Rx_bit_counter + 1;
	    end else if ( Rx_baud_counter == baud_limit_rck ) begin
	       Rx_baud_counter <=14'd0 ;
	    end
         end else begin
	    Rx_baud_counter <=14'd0 ;
	    Rx_bit_counter <= 4'd0 ;
         end
      end
   end

endmodule
