`include "././define/ctrl_def.v"

module alu(
  input [31:0] A,    //1st operand
  input [31:0] B,    //2nd operand
  input [4:0] ALUOp,
  output reg[31:0] result 
  );
  
  integer dif;
  initial  dif = A - B;
  
  always@(*)
  begin
    case(ALUOp)
      `ALUOP_ADD:
        result = A + B;
      `ALUOP_SUB:
        result = A - B;
      `ALUOP_SLL:
        result = B << A[4:0];
      `ALUOP_SRL:
        result = B >> A[4:0];
      `ALUOP_SRA:
        result = B >> A[4:0] | ( {32{B[31]}} << (6'b100000-{1'b0, A[4:0]}));
      `ALUOP_AND:
        result = A & B;
      `ALUOP_OR:
        result = A | B;
      `ALUOP_XOR:
        result = A ^ B;
      `ALUOP_NOR:
        result = ~ (A | B);
      `ALUOP_SLT:
        result = ((A[31] && !B[31]) || ((!(A[31] ^ B[31])) && dif[31]))? 32'h1 : 32'h0;
      `ALUOP_SLTU:
        result = (A < B)? 32'b1 : 32'b0;
      `ALUOP_LUI:
        result = {B[15:0],16'b0};
      `ALUOP_BNE:
        result = (A == B)? 32'b1 : 32'b0;
      `ALUOP_BLEZ:
        result = (!A[31] && A!=32'b0)? 32'b1: 32'b0;
      `ALUOP_BGTZ:
        result = (!A[31] && A!=32'b0)? 32'b0: 32'b1;
      `ALUOP_BLTZ:
        result = (A[31])? 32'b0 : 32'b1;
      `ALUOP_BGEZ:
        result = (!A[31])? 32'b0 : 32'b1;      
      default: result = 32'b0;
    endcase
  end
  
endmodule


