class transaction ;
         rand  bit newd;
          rand  bit [11:0] d_in;
          rand bit cs ;
           rand bit mosi ;
  function void display( input string tag);
    $display("[%0s]: din=%0b \twd = %0d , cs = %0b, mosi=%0b", tag, d_in, newd,cs,mosi);
  endfunction
  
  function transaction copy();
    copy=new();
    
    copy.newd = this.newd;
    copy.d_in = this.d_in;
    copy.cs = this.cs;
    copy.mosi= this.mosi;
    
  endfunction
endclass

/////////////////////////////////////////////////////generator
class generator;
  
  transaction tr;
  mailbox #(transaction) mbxgd;
  event done ;
  event drvnext;
  event sconext;
  int count = 0 ;
  
  function new(mailbox #(transaction) mbxgd);
  this.mbxgd=mbxgd;
    tr= new();
    
  endfunction 
  
  task run();
    repeat(count)
      begin
        assert(tr.randomize) else $error("FAILED RANDOMIZATION!");
        tr.display("GEN");
        mbxgd.put(tr.copy);
        @(drvnext);
       @(sconext);
      end
    ->done;
  endtask
endclass
//////////////////////////////////////////////////////////driver

class driver ;
  virtual spi_f vif;
  transaction datac;
  mailbox #(transaction) mbxgd;
  mailbox #(bit [11:0]) mbxds;
  event drvnext;
   transaction tr;
  
  function new(mailbox #(transaction) mbxgd, mailbox #(bit [11:0]) mbxds);
  this.mbxgd=mbxgd;
    this.mbxds= mbxds;
    
  endfunction
    
    task reset();
      vif.rst <=1'b1;
      vif.cs <= 1'b1;
      vif.mosi<=1'b0;
      vif.newd <=1'b0;
      vif.d_in <=0;
      repeat(10) @(posedge vif.clk);
        vif.rst<=1'b0;
      repeat(5) @(posedge vif.clk);
      $display("[DRV]:RESET DONE!!");
      
    endtask
  
  
  task run();
    forever begin
      mbxgd.get(tr);
      @(posedge vif.sclk);
      vif.newd <= 1'b1;
      vif.d_in <=tr.d_in;
      mbxds.put(tr.d_in);
  
      @(posedge vif.sclk);
      vif.newd <= 1'b0;
      wait( vif.cs == 1'b0);
      $display("[DRV]:DATA SENT=%0d", tr.d_in);
      ->drvnext;
      
    end
  endtask
endclass

////////////////////////////////////////monitor 
class monitor;
  virtual spi_f vif;
 
  
  
  bit [11:0] srx;
  
  mailbox #(bit [11:0]) mbxms;  
  
  function new(mailbox #(bit [11:0]) mbxms);
  this.mbxms=mbxms;  
  endfunction
  task run();
    forever  begin
      @(posedge vif.sclk);
      wait(vif.cs ==1'b0);
      @(posedge vif.sclk);
      for(int i=0;i<=11;  i++)
        begin 
            @(posedge vif.sclk);
          srx[i] = vif.mosi;
        
          

        end
      wait(vif.cs ==1'b1);
      $display("[MON]: data :%0d", srx);
      mbxms.put(srx);
      
 
    end
  endtask
 
endclass

//////////////////////////////////////////////////////////////scoreboard
class scoreboard;
  mailbox #(bit [11:0]) mbxds, mbxms;
  bit [11:0] ds;
  bit [11:0] ms;
  event sconext;
  
  function new(mailbox #(bit [11:0]) mbxds, mailbox #(bit [11:0]) mbxms);
    this.mbxds = mbxds;
    this.mbxms = mbxms;
  endfunction
  
  task run();
    forever begin
      
      mbxds.get(ds);
      mbxms.get(ms);
      $display("[SCO] : DRV : %0d MON : %0d", ds, ms);
      if(ds == ms)
        $display("[SCO] : DATA MATCHED");
      else
        $display("[SCO] : DATA MISMATCHED");
      ->sconext;     
    end
  endtask
endclass

////////////////////////////environment
class environment;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco ;
  event nextgd;
  
  event nextgs;
mailbox #(bit [11:0]) mbxms;  
  mailbox #(bit [11:0]) mbxds;  
mailbox #(transaction) mbxgd;
  virtual spi_f vif;
  function new(virtual spi_f vif);
    mbxgd= new();
    mbxds= new();
    mbxms= new();
    gen = new(mbxgd);
    drv= new(mbxgd, mbxds);
    mon= new(mbxms);
    sco= new(mbxds, mbxms);
  this.vif= vif;
    drv.vif= this.vif;
    mon.vif = this.vif;
    gen.drvnext = nextgd;
    drv.drvnext= nextgd;
  gen.sconext= nextgs;
    sco.sconext = nextgs;
    
  endfunction
  
  task pre_test();
    drv.reset();
    
  endtask
  task test();
  fork
    gen.run();
    drv.run();
    mon.run();
    sco.run();
    
    
  join_any
  endtask


  task post_test();
    
    wait(gen.done.triggered);
    $finish();
    

  endtask

  task run();
    pre_test();
    test();
    post_test();
    
  endtask

endclass












 
  ///////////////////////////////////////////////////////////tb
 
   module tb;
     
    
    spi_f vif();
    
    spi DUT (vif.clk,vif.rst, vif.newd, vif.d_in , vif.cs, vif.mosi , vif.sclk);
    
    initial begin
      vif.clk <=0;
    end
    always #5 vif.clk <= ~vif.clk;
    environment env;    
    initial begin

      env= new(vif);
     env.gen.count= 20;
      env.run();
      
    end
      initial begin
      
      $dumpfile("test.vcd");
      $dumpvars;
    
    end
     
    
    
  endmodule
 
