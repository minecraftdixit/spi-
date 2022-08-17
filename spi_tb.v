// Code your testbench here
// or browse Examples
module spi_tb ;
  
  reg clk ;
  reg rst;
  reg [15:0] data_in ;
  
  wire spi_cs ;
  wire [15:0] data_out;
  wire  s_clk;
  wire [4:0] counter;
  
  spi dut(
    .clk(clk), .rst(rst),  .spi_cs_l(spi_cs) , .data_out(data_out)
    , .s_clk(s_clk), .counter(counter));
  initial 
    begin 
      #10; rst = 1'b0;
      #30 ; data_in = 16'h1231 ;
      #115; data_in = 16'h2452;
      #130; data_in = 16'h1264 ;
      #140; data_in =16'hA234;
    
       
      
    end 
   always #2 clk= -clk;
  initial 
     
    begin 
    
      
          $dumpfile("spi.vcd");
      $dumpvars;
      #300 ;$finish;
    end 
endmodule 