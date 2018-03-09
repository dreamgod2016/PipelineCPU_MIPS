`include "././define/instr_def.v"

module branch_jump_ctrl(
  input [5:0] OP_if,
  input [5:0] OP_id,
  input [4:0] rt_id,
  input [31:0] rf_rd1,
  input [31:0] rf_rd2,
  input [1:0] Jump,
  
  output reg[1:0] Branch,
  output reg IF_flush
  );

  always@(*)
  begin
    /*for Branch*/
    /*Whether the branch is actually taken or not*/
    if((OP_id ==`OP_BEQ && (rf_rd1 != rf_rd2)) ||
      (OP_id == `OP_BNE && (rf_rd1 == rf_rd2)) ||
      (OP_id == `OP_BLEZ && (!rf_rd1[31] && rf_rd1 != 32'b0))||
      (OP_id == `OP_BGTZ && (rf_rd1[31] || rf_rd1 == 32'b0)) ||
      (OP_id == `OP_BLTZ && (rt_id == 5'b0 && !rf_rd1[31])) ||  //`OP_BLTZ
      (OP_id == `OP_BGEZ && (rt_id != 5'b0 && rf_rd1[31]))) //`OP_BGEZ
    begin
      Branch = 2'b10;
      IF_flush = 1;
    end
    
    /*Always assume the branch taken*/   
    else if(OP_if == `OP_BEQ || OP_if == `OP_BNE || OP_if == `OP_BLEZ || OP_if == `OP_BGTZ ||
      OP_if == `OP_BLTZ || OP_if == `OP_BGEZ)
    begin
      Branch = 2'b01; 
      IF_flush = 0;
    end
    else 
    begin
      Branch = 2'b00;
      IF_flush = 0;
    end
      
    /*for Jump*/
    if(Jump == 2'b01)
      IF_flush = 1;
    else
      IF_flush = 0;
  end
  
endmodule     
