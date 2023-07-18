class transaction;
  
  //declaring the transaction items
  rand bit [7:0] TxData;
       bit [7:0] RxData;
  function void display(string name);
    $display("-------------------------");
    $display("- %s ",name);
    $display("-------------------------");
    $display("- Transmitted Data = %0d",TxData);
    $display("- Received Data = %0d",RxData);
    $display("-------------------------");
  endfunction
endclass
