module mips(
  input clk,
  input rst
  );
  
  //DATAPATH WIRES
  wire[31:0] pc_current;
  wire[31:0] pc_temp;
  wire[31:0] pc_new;
  wire[31:0] im_rd;
  wire[31:0]  instr;
  wire[31:0] instr_ex;
  wire[31:0] instr_mem;
  wire[31:0] instr_wb;
  wire[31:0] pc_next_if;
  wire[31:0] pc_next_id;
  wire[31:0] pc_next_ex;
  wire[31:0]  ext_result;
  wire[31:0] ext_result_ex;
  wire[31:0]  rf_wa;
  wire[31:0]  rf_wa_mem;
  wire[31:0]  rf_wa_wb;
  wire[31:0] rf_wd; 
  wire[31:0] rf_rd1;
  wire[31:0] rf_rd1_ex;
  wire[31:0] rf_rd2;
  wire[31:0] rf_rd2_ex;
  wire[31:0]  alu_srcA;
  wire[31:0]  alu_srcB;
  wire[31:0]  alu_result;
  wire[31:0] alu_result_mem;
  wire[31:0] alu_result_wb;
  wire[31:0] forwardA_result;
  wire[31:0] forwardB_result;
  wire[3:0] be;
  wire[31:0] dm_rd;
  wire[31:0] dm_rd_ext;
  wire[31:0] dm_rd_wb;
  wire[31:0] dm_wd;
  wire[4:0] rs;
  wire[4:0] rs_ex;
  wire[4:0] rt;
  wire[4:0] rt_ex;
  wire[4:0] rd;
  wire[4:0] rd_ex;
  wire[31:0] shamt;
  wire[31:0] shamt_ex;
  wire[31:0] branch_offset_ext;
  wire[31:0] jreg_dst;
  
  //SIGNALS
  wire[1:0] RegDst_id;
  wire[1:0] RegDst_ex;
  wire[4:0] ALUOp_id;
  wire[4:0] ALUOp_ex;
  wire[1:0] ALUSrcA_id;
  wire[1:0] ALUSrcA_ex;
  wire[1:0] ALUSrcB_id;
  wire[1:0] ALUSrcB_ex;
  wire[1:0] ForwardA;
  wire[1:0] ForwardB;
  wire MemRead_id;
  wire MemRead_ex;
  wire MemWrite_id;
  wire MemWrite_ex;
  wire MemWrite_mem;
  wire RegWrite_id;
  wire RegWrite_ex;
  wire RegWrite_mem;
  wire RegWrite_wb;
  wire[1:0] MemtoReg_id;
  wire[1:0] MemtoReg_ex;
  wire[1:0] MemtoReg_mem;
  wire[1:0] MemtoReg_wb;
  wire[1:0] EXTOp;  
  wire IF_flush;
  wire stall;
  wire[1:0] Branch;
  wire[1:0] Jump;
  wire[1:0] JRegDst;
  wire PC_IFWrite;
  
  assign rs = instr[25:21];
  assign rt = instr[20:16];
  assign rd = instr[15:11];
  assign shamt = {27'b0, instr[10:6]};
  assign branch_offset_ext = {{16{im_rd[15]}}, im_rd[15:0]};  
  assign pc_next_if = pc_current + 4;

  //------------------Link Modules---------------------//
  
  mux MemtoReg_mux(MemtoReg_wb, alu_result_wb, dm_rd_ext, pc_current, 0, rf_wd);
  mux RegDst_mux(RegDst_ex, {27'b0,rt_ex}, {27'b0,rd_ex}, 31, 0, rf_wa);
  mux ForwardA_mux(ForwardA, rf_rd1_ex, rf_wd, alu_result_mem, 0, forwardA_result);
  mux ForwardB_mux(ForwardB, rf_rd2_ex, rf_wd, alu_result_mem, 0, forwardB_result);
  mux ALUSrcA_mux(ALUSrcA_ex, forwardA_result, shamt_ex, pc_next_ex, 0, alu_srcA);
  mux ALUSrcB_mux(ALUSrcB_ex, forwardB_result, ext_result_ex, 0, 0, alu_srcB);   
  mux PC_Branch_mux(Branch, pc_next_if, pc_next_if+{branch_offset_ext[29:0], 2'b00}, pc_next_id, 0, pc_temp); 
  mux JRegDst_mux(JRegDst, rf_rd1, alu_result, dm_rd, 0, jreg_dst);
  mux PC_Jump_mux(Jump, pc_temp, {pc_next_id[31:28], instr[25:0], 2'b00}, jreg_dst, 0, pc_new);
  
  ext EXT(EXTOp, instr[15:0], ext_result);
  
  be_ext beEXT(alu_result_mem[1:0], instr_mem[31:26], be);
  
  dmr_ext dmrEXT(alu_result_mem[1:0], instr_wb[31:26],dm_rd_wb, dm_rd_ext);
  
  
  pc PC(clk, PC_IFWrite, pc_new, pc_current);
  
  im IM(pc_current[11:2], im_rd);
  
  rf RF(RegWrite_wb, rs, rt, rf_wa_wb, rf_wd, rf_rd1, rf_rd2);

  alu ALU(alu_srcA, alu_srcB, ALUOp_ex, alu_result);
  
  dm DM(MemWrite_mem, alu_result_mem[11:2], be, dm_wd, dm_rd);
  
  if_id IF_ID(clk, PC_IFWrite, IF_flush, pc_next_if, im_rd, pc_next_id, instr);
    
  id_ex ID_EX(clk, stall, RegDst_id, ALUOp_id, ALUSrcA_id, ALUSrcB_id, MemRead_id, MemWrite_id, RegWrite_id, MemtoReg_id,
              rf_rd1, rf_rd2, shamt, ext_result, rs, rt, rd, instr, pc_next_id,
              RegDst_ex, ALUOp_ex, ALUSrcA_ex, ALUSrcB_ex, MemRead_ex, MemWrite_ex, RegWrite_ex, MemtoReg_ex,
              rf_rd1_ex, rf_rd2_ex, shamt_ex, ext_result_ex, rs_ex, rt_ex, rd_ex, instr_ex, pc_next_ex);
              
  ex_mem EX_MEM(clk, MemRead_ex, MemWrite_ex, RegWrite_ex, MemtoReg_ex, alu_result, forwardB_result, rf_wa, instr_ex,
                MemRead_mem, MemWrite_mem, RegWrite_mem, MemtoReg_mem, alu_result_mem, dm_wd, rf_wa_mem, instr_mem);
  
  
  mem_wb MEM_WB(clk, RegWrite_mem, MemtoReg_mem, dm_rd, alu_result_mem, rf_wa_mem, instr_mem,
                RegWrite_wb, MemtoReg_wb, dm_rd_wb, alu_result_wb, rf_wa_wb, instr_wb);
                
  
  forwarding FWD(rs, rt, rs_ex, rt_ex, rf_wa, rf_wa_mem, rf_wa_wb, Jump, MemRead_mem, RegWrite_mem, RegWrite_wb, ForwardA, ForwardB, JRegDst);
  hazard_detection HazardD(rs, rt, rf_wa, MemRead_ex, RegWrite_ex, PC_IFWrite, stall);
  
  branch_jump_ctrl B_J_CTRL(im_rd[31:26], instr[31:26], instr[20:16], rf_rd1, rf_rd2, Jump, Branch, IF_flush);
  
  ctrl CTRL(instr, RegDst_id, ALUOp_id, ALUSrcA_id, ALUSrcB_id, EXTOp, 
            MemRead_id, MemWrite_id, RegWrite_id, MemtoReg_id, Jump);
endmodule