 
// here SPI is interfaced  with  the DAC 

module spi(
input clk , rst ,newd , 
  input [11:0] data_in,
  output reg cs ,mosi , sclk
);

  typedef enum bit [1:0] {idle = 2'b00 , send = 2'b10} state_type;
  state_type state = idle;
  
  int countc= 0;
  int count= 0;
  
  
  /////////////////////////////////////////generation of sclk
  
  always @(posedge clk)
    begin 
      if(rst)
        begin 
           countc<=0;
          sclk<=1'b0;
          end
      
      else
        begin
          
          if(countc<50)
            begin
              
              countc <=countc +1;
              
            end
          else 
            begin 
              countc <=0;
              
              sclk <= ~sclk;
              
            end
          
        end
      
    end
  ///////////////////////////////////////state machine
  reg [12:0] temp ;
  always @(posedge sclk)
  begin 
    if(rst)
      begin 
        
        cs<= 1'b1;
        mosi <= 1'b0;
        
      end
    else 
      begin 
        case(state)
          idle:
        begin 
          if(newd==1'b1)
            begin 
              state<=send;
              temp<=data_in;
              
            cs<=1'b0;

            end
         else
           begin
             state<=idle;
             temp<=8'b0;
             
           end
        end
          send:begin
            
            if(count<=11)
              begin
                mosi <= temp[count];
                count= count+1;
              end
                
                else begin
                  
                  count<=0;
                  state<= idle;
                  cs<= 1'b1;
                  mosi<=1'b0;
              end
            
          end
          
          default: state<=idle;
          
        endcase
      end
     
  end
  
   
endmodule
          
 /////////////////////////////interface 
          interface spi_f;   
           logic clk ;
            logic rst ;
            logic newd ;
            logic [11:0] data_in;
            logic cs ;
            logic mosi ;
            logic sclk;
             
          endinterface 
