`timescale 1ns / 1ps

module Transmitter
#(parameter baud_limit = 868) //10,415, counter= clock(100MHz) / BR (9600) //868, counter= clock(100MHz) / BR (115200)
(
    input clk,
    input [7:0] data,
    input transmit,
    input reset,
    output reg TxD,
    output reg Tx_done
    );
    
    //internal variables
    
    reg [3:0] bit_counter;//Counter to count the 10 bits
    reg [13:0] baudrate_counter; 
    reg [9:0] shiftright_register; //10 bits that will be serially transmitteed through UART
    reg state, next_state; //idle mode and transmitting mode
    reg shift; //shift signal to start shifting the bits in the UART
    reg load;  //load signal to start loading the data into the shiftright register, and add start and stop bits
    reg clear; //reset the bit_counter for UART transmission
    
    assign debug = baudrate_counter;
    
    //UART transmission
    
    always@(posedge clk)
    begin
        if(load) //if load is asserted
            shiftright_register<={1'b1, data, 1'b0}; //The data is loaded into the shift register, 10 bits
        if(reset)
        begin
            state<=0; //state is idle
            bit_counter <= 0; //counter for bit transmission is reset to 0
            baudrate_counter <= 0;
        end
        else begin
            baudrate_counter<=baudrate_counter+1;
            if (baudrate_counter == baud_limit)
            begin
                state<=next_state; //state changes from idle to transmitting
                baudrate_counter <= 0; //resetting counter
                if(clear) //if clear is asserted
                    bit_counter <= 0;
                else
                    bit_counter <= bit_counter +1;
                if(shift) //if shift signla is asserted
                    shiftright_register <= shiftright_register >>1; //start shifting the data and transmitting bit by bit
            end
        end    
    end
    
    //Mealy Machine, State Machine
    
    always@(posedge clk)
    begin
        load <= 0; //Setting load = 0
        shift <= 0; //initially 0
        clear <= 0; //initially 0
        TxD <= 1;
        Tx_done <= 0;
        case(state)
        0: begin //idle state
            if (transmit) //transmit button is pressed
            begin
                next_state <= 1; //switches to tramission state
                load <= 1; //start loading the bits
                shift <= 0; //no shift at this point
                clear <= 0; //to avoid any clearing of any counter
            end
//            else begin //if transmit button is not pressed
//                next_state <= 0; //stays at the idle mode
//                TxD <= 0; //no transmission
//            end
         end    
         1:  begin //transmitting state
            if(bit_counter == 10)
            begin
                next_state <= 0; //it should switch from transmission mode to idle mode
                clear <= 1; //clear all the counters
                TxD <= 1;
                Tx_done <= 1;
            end    
            else begin
                next_state <= 1; //stay in transmit state
                TxD <= shiftright_register[0];
                shift <= 1; //continue shifting the data, new bit arrives at the RMB
                Tx_done <= 0;
            end
         end
         default : next_state <= 0;
         endcase 
    end
endmodule
