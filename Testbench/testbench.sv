//-------------------------------------------------------------------------
//	testbench.sv
//-------------------------------------------------------------------------
//tbench_top or testbench top, this is the top most file, in which DUT(Design Under Test) and Verification environment are connected. 
//-------------------------------------------------------------------------

//including interface and testcase files
`include "./interface.sv"
`include "./test.sv"
//----------------------------------------------------------------

module tbench_top;
  
  localparam TCK_TIMEPD = 10;
  localparam RCK_TIMEPD = 160;
  localparam TCK_FREQ = 1_000_000_000 / ( TCK_TIMEPD );
  localparam RCK_FREQ = 1_000_000_000 / ( RCK_TIMEPD );
  localparam BAUD_RATE = 9_600;

  //clock and reset signal declaration
  bit tck;
  bit rck;
  bit reset;
  
  //clock generation
  always #(TCK_TIMEPD/2) tck = ~tck;
  always #(RCK_TIMEPD/2) rck = ~rck;
  
  //reset Generation
  initial begin
    reset = 0;
    #5 reset = 1;
  end
  
  
  //creatinng instance of interface, inorder to connect DUT and testcase
  intf i_intf(tck, rck,reset);
  
  //Testcase instance, interface handle is passed to test as an argument
  test t1(i_intf);
  
  //DUT instance, interface signals are connected to the DUT ports
  uart #(
     .baud_rate(BAUD_RATE),
     .tck_freq (TCK_FREQ),
     .rck_freq (RCK_FREQ)
     ) 
  DUT (
    .tck(i_intf.tck),
    .rck(i_intf.rck),
    .reset(i_intf.reset),
    .TxEnable(i_intf.TxEnable),
    .TxD(i_intf.TxD),
    .TxData(i_intf.TxData),
    .TxDone(i_intf.TxDone),
    .RxData(i_intf.RxData),
    .RxD(i_intf.TxD)
   );
  
  //enabling the wave dump
  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
  end
endmodule
