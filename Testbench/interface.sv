interface intf(input logic tck, rck, reset);
  
  //declaring the signals
  logic	      TxEnable;
  logic [7:0] TxData;
  logic	      TxD;
  logic	      TxDone;
  logic [7:0] RxData;
endinterface
