`timescale 1ns / 1ps

module tb();
    
    reg clk, transmit, reset;
    reg [7:0] data;
    wire TxD, Tx_done;
    wire [7:0] RxData;
    
    initial begin
        clk = 0;
        reset = 0;
        transmit = 0;
        data = 8'b01000001;
    end
    
    Transmitter Tx (clk, data, transmit, reset, TxD, Tx_done);
    Reciever Rx (clk, reset, TxD, RxData);
    
    always #5 clk = ~clk;
    
    initial begin
        reset = 0;
        #30
        reset = 1;
        #30
        reset = 0; 
    end
    
    initial begin
        transmit = 0;
        #100
        transmit = 1;
        #30
        transmit = 0;
    end
    
    initial begin
        #100000
        $finish;
    end
endmodule
