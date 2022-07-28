`timescale 1ns / 1ps

// Considering Start Bit = 0, Stop Bit = 1

module Reciever(
    input clk,
    input reset,
    input RxD,
    output [7:0] RxData
    );
    
    //Internal Variables
    
    reg shift;
    reg state, next_state;
    reg [3:0] bit_counter;
    reg [1:0] sample_counter;
    reg [13:0] baudrate_counter;
    reg [9:0] rxshift_reg;
    reg clear_bit, inc_bit, clear_sample, inc_sample;
    
    //Constants
    
    parameter clk_freq = 100_000_000;
    parameter baud_rate = 115_200;
    parameter div_sample = 4;
    parameter div_counter = clk_freq/(baud_rate*div_sample);
    parameter mid_sample = (div_sample/2);
    parameter div_bit = 10;
    
    assign RxData = rxshift_reg[8:1];
    
    //UART Reciever Logic
    always@(posedge clk)
    begin
        if(reset) begin
            state <= 0;
            bit_counter <= 0;
            baudrate_counter <= 0;
            sample_counter <= 0; 
        end
        else begin
            baudrate_counter <= baudrate_counter +1;
            if (baudrate_counter >= div_counter -1) 
            begin
                baudrate_counter <= 0;
                state <= next_state;
                if(shift)
                    rxshift_reg <= {RxD, rxshift_reg[9:1]};
                if(clear_sample)
                    sample_counter <= 0;
                if(inc_sample)
                    sample_counter <= sample_counter +1;
                if(clear_bit)
                    bit_counter <= 0;
                if(inc_bit)
                    bit_counter <= bit_counter +1;    
            end
        end
    end
    
    //State Machine
    
    always@(posedge clk)
    begin
        shift <= 0;
        clear_sample <= 0;
        inc_sample <= 0;
        clear_bit <= 0;
        inc_bit <= 0;
        next_state <= 0;
        
        case(state)
            0:begin //Idle State
                if(RxD)
                    next_state <= 0;
                else begin
                    next_state <= 1;
                    clear_bit <= 1;
                    clear_sample <= 1;
                end
            end
            1: begin //Recieving State
                next_state <= 1;
                if(sample_counter == mid_sample - 1)
                    shift <= 1;
                if(sample_counter == div_sample -1)
                begin
                    if(bit_counter == div_bit - 1)
                        next_state <= 0;
                    inc_bit <= 1;
                    clear_sample <= 1;
                end
                else
                    inc_sample <= 1;
            end
            default: next_state <= 0;
        endcase
    end
    
endmodule
