//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
//gets the packet from generator and drive the transaction paket items into interface (interface is connected to DUT, so the items driven into interface signal will get driven in to DUT) 

class driver;
  
  //used to count the number of transactions
  int no_transactions;
  
  //creating virtual interface handle
  virtual intf vif;
  
  //creating mailbox handle
  mailbox gen2driv;
  
  //constructor
  function new(virtual intf vif,mailbox gen2driv);
    //getting the interface
    this.vif = vif;
    //getting the mailbox handles from  environment 
    this.gen2driv = gen2driv;
  endfunction
  
  //Reset task, Reset the Interface signals to default/initial values
  task reset;
    wait(!vif.reset);
//    $display("[ DRIVER ] ----- Reset Started -----");
    vif.TxEnable <= 0;
    vif.TxData <= 0;
    wait(vif.reset);
//    $display("[ DRIVER ] ----- Reset Ended   -----");
  endtask
  
  //drivers the transaction items to interface signals
  task main;
    forever begin
      transaction trans;
      gen2driv.get(trans);
      @(posedge vif.tck);
      vif.TxEnable <= 1;
      vif.TxData     <= trans.TxData;
      @(posedge vif.tck);
      vif.TxEnable <= 0;
      @(posedge vif.TxDone);
      trans.RxData   = vif.RxData;
      @(posedge vif.tck);
//      trans.display("[ Driver ]");
      no_transactions++;
    end
  endtask
  
endclass
