module forwarding(
  input [4:0] rs,
  input [4:0] rt,
  input [4:0] rs_ex,
  input [4:0] rt_ex,
  input [31:0] rf_wa,
  input [31:0] rf_wa_mem,
  input [31:0] rf_wa_wb,
  input [1:0] Jump,
  input MemRead_mem,
  input RegWrite_mem,
  input RegWrite_wb,
  
  output reg[1:0] forwardA,
  output reg[1:0] forwardB,
  output reg[1:0] JRegDst
  );

  always@(*)
  begin
    /*EX hazard A*/
    if((RegWrite_mem && rf_wa_mem != 0) && (rf_wa_mem == rs_ex))
      forwardA = 2'b10;
    /*MEM hazard A*/
    else if((RegWrite_wb && rf_wa_wb != 0) && (rf_wa_wb == rs_ex)
            && !((RegWrite_mem && rf_wa_mem != 0) && (rf_wa_mem == rs_ex))) 
      forwardA = 2'b01;
    else
      forwardA = 2'b00;
      
    /*EX hazard B*/
    if((RegWrite_mem && rf_wa_mem != 0) && (rf_wa_mem == rt_ex))
      forwardB = 2'b10;
    /*MEM hazard B*/
    else if((RegWrite_wb && rf_wa_wb != 0) && (rf_wa_wb == rt_ex)
            && !((RegWrite_mem && rf_wa_mem != 0) && (rf_wa_mem == rt_ex))) 
      forwardB = 2'b01;
    else
      forwardB = 2'b00;
      
    /*JR or JALR hazard*/
    if(RegWrite_mem && Jump == 2'b10 && (rf_wa == rt || rf_wa == rs)) 
    begin
      if(MemRead_mem)  // load + jr/jalr
        JRegDst = 2'b10;
      else             //alu + jr/jalr
        JRegDst = 2'b01;
    end
    else
      JRegDst = 2'b00;
  end
  
endmodule


