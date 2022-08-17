// Code your design here
module spi(
  input clk , rst, 
  input [15:0] data_in , 
  
  
  
  output [15:0] data_out , 
  output   s_clk , 
  output wire [4:0] counter , 
  output wire spi_cs_l
  
  
);
  reg [15:0] mosi;
  reg [2:0] state;
  reg [4:0] count; 
  reg sclk;
  reg cs;
  
  always @(posedge clk , posedge rst)
    begin 
      if(rst)
        begin
          cs <= 1'b0;
          sclk <= 1'b1 ;
          mosi <= 16'b0 ;
          count <= 5'b0;
          end
      
      else 
        begin 
          case(state)
            0: begin
              sclk <= 1'b0;
              cs <=1'b1   ;
              state<=1;
            end 
            1: begin
              sclk <= 1'b1;
              cs <= 1'b0;
              mosi <= data_in[count-1];
              count<= count - 1;
              state <=2;
            end
            2:
              begin
                sclk <= 1'b1;
                if(count>0)
                  begin
                    state<=1;
                    end
                else 
                  begin
                    
                    
                    count <= 16;
                    state <=0;
                    
                  end
                
              end
                   default: state <=0;
          
          
              endcase
        end
      
      
    end
    assign  spi_cs_l =  cs;
  assign spi_clk = sclk ;
  assign  data_out = mosi ;
    assign counter = count;
  
  
endmodule 