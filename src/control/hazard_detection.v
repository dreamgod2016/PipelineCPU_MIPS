module hazard_detection(
  input [4:0] rs,
  input [4:0] rt,
  input [31:0] rf_wa,
  input MemRead_ex, 
  input RegWrite_ex,
  
  output reg PC_IFWrite,
  output reg stall
  );

  always@(*)
  begin
    if(MemRead_ex && (rf_wa == rt || rf_wa == rs)) //load hazard
    begin
      stall = 1;
      PC_IFWrite = 0;
    end
    else
    begin
      stall = 0;
      PC_IFWrite = 1;
    end
  end
  
endmodule
      