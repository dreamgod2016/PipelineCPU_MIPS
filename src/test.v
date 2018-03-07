module mips_tb();
  `timescale 1ns / 1ns
  reg clk;
  reg rst;

  initial
  begin
    clk = 0;
    rst = 1;
    
   //wait 50ns for global reset to finish
    #50; 
    clk = ~clk;
    #50;
    rst = 0;
    
    forever #50  
    begin
      clk = ~clk;
    end
  end
  
  mips mips(clk, rst);
endmodule

