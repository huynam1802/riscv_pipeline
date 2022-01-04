module riscv_pipeline_top (
  input clk,    // Clock
  input reset_n  // Asynchronous reset active low
);

//-------------------------------
//         Signal Declaration
//-------------------------------
logic [31:0]  pc_branch         ;
logic         pc_write          ;
logic         pc_src            ;
logic [31:0]  IF_ID_inst        ;
logic [31:0]  IF_ID_pc          ;
logic         IF_ID_write       ;
logic         MEM_WB_reg_write  ;
logic [31:0]  wb_data           ;
logic         reg_write         ;
logic         mem_write         ;
logic         mem_read          ;
logic         alu_src           ;
logic [ 1:0]  alu_op            ;
logic         ctrl_sel          ;
logic [ 1:0]  forward_comp1     ;
logic [ 1:0]  forward_comp2     ;
logic [31:0]  alu_out           ;
logic [31:0]  mem_data          ;
logic         br_eq             ;
logic         ID_EX_mem_to_reg  ;
logic         ID_EX_reg_write   ;
logic         ID_EX_mem_write   ;
logic         ID_EX_mem_read    ;
logic         ID_EX_alu_src     ;
logic [ 1:0]  ID_EX_alu_op      ;
logic [31:0]  ID_EX_data1       ;
logic [31:0]  ID_EX_data2       ;
logic [ 4:0]  ID_EX_rs1         ;
logic [ 4:0]  ID_EX_rs2         ;
logic [ 4:0]  ID_EX_rd          ;
logic [31:0]  ID_EX_imm_gen     ;
logic [ 3:0]  ID_EX_inst_func   ;
logic [ 1:0]  forward_a         ;
logic [ 1:0]  forward_b         ;
logic [31:0]  EX_MEM_alu_out    ;
logic         EX_MEM_mem_to_reg ;
logic         EX_MEM_reg_write  ;
logic         EX_MEM_mem_write  ;
logic         EX_MEM_mem_read   ;
logic [31:0]  EX_MEM_dataB      ;
logic [ 4:0]  EX_MEM_rd         ;
logic         MEM_WB_mem_to_reg ;
logic [31:0]  MEM_WB_mem_data   ;
logic [31:0]  MEM_WB_alu_out    ;
logic [ 4:0]  MEM_WB_rd         ;
logic         branch            ;
logic         mem_to_reg        ;
logic [ 2:0]  imm_sel           ;

//-----------------------------------
//         Module Instruction Fetch
//-----------------------------------
instruction_fetch instruction_fetch(
  .clk        (clk        ),
  .reset_n    (reset_n    ),
  .pc_branch  (pc_branch  ),
  .pc_write   (pc_write   ),
  .branch     (branch     ),
  .br_eq      (br_eq      ),
  .pc_src     (pc_src     ),
  .IF_ID_write(IF_ID_write),
  .IF_ID_pc   (IF_ID_pc   ),
  .IF_flush   (IF_flush   ),
  .IF_ID_inst (IF_ID_inst )
  );

//-------------------------------------
//         Module Instruction Decode
//-------------------------------------
instruction_decode instruction_decode(
  .clk             (clk              ),
  .reset_n         (reset_n          ),
  .IF_ID_pc        (IF_ID_pc         ),
  .IF_ID_inst      (IF_ID_inst       ),
  .IF_ID_rs1       (IF_ID_inst[19:15]),
  .IF_ID_rs2       (IF_ID_inst[24:20]),
  .MEM_WB_reg_write(MEM_WB_reg_write ),
  .MEM_WB_rd       (MEM_WB_rd        ),
  .wb_data         (wb_data          ),
  .imm_sel         (imm_sel          ),
  .mem_to_reg      (mem_to_reg       ),
  .reg_write       (reg_write        ),
  .mem_write       (mem_write        ),
  .mem_read        (mem_read         ),
  .alu_src         (alu_src          ),
  .alu_op          (alu_op           ),
  .ctrl_sel        (ctrl_sel         ),
  .forward_comp1   (forward_comp1    ),
  .forward_comp2   (forward_comp2    ),
  .alu_out         (alu_out          ),
  .mem_data        (mem_data         ),
  .EX_MEM_alu_out   (EX_MEM_alu_out),
  .EX_MEM_mem_to_reg(EX_MEM_mem_to_reg),
  .pc_branch       (pc_branch        ),
  .br_eq           (br_eq            ),
  .ID_EX_mem_to_reg(ID_EX_mem_to_reg ),
  .ID_EX_reg_write (ID_EX_reg_write  ),
  .ID_EX_mem_write (ID_EX_mem_write  ),
  .ID_EX_mem_read  (ID_EX_mem_read   ),
  .ID_EX_alu_src   (ID_EX_alu_src    ),
  .ID_EX_alu_op    (ID_EX_alu_op     ),
  .ID_EX_data1     (ID_EX_data1      ),
  .ID_EX_data2     (ID_EX_data2      ),
  .ID_EX_rs1       (ID_EX_rs1        ),
  .ID_EX_rs2       (ID_EX_rs2        ),
  .ID_EX_rd        (ID_EX_rd         ),
  .ID_EX_imm_gen   (ID_EX_imm_gen    ),
  .ID_EX_inst_func (ID_EX_inst_func  )
  );

//--------------------------------------
//         Module Execute
//--------------------------------------
execute execute(
  .clk              (clk              ),
  .reset_n          (reset_n          ),
  .ID_EX_mem_to_reg (ID_EX_mem_to_reg ),
  .ID_EX_reg_write  (ID_EX_reg_write  ),
  .ID_EX_mem_write  (ID_EX_mem_write  ),
  .ID_EX_mem_read   (ID_EX_mem_read   ),
  .ID_EX_alu_src    (ID_EX_alu_src    ),
  .ID_EX_alu_op     (ID_EX_alu_op     ),
  .ID_EX_data1      (ID_EX_data1      ),
  .ID_EX_data2      (ID_EX_data2      ),
  .ID_EX_imm_gen    (ID_EX_imm_gen    ),
  .ID_EX_rs1        (ID_EX_rs1        ),
  .ID_EX_rs2        (ID_EX_rs2        ),
  .ID_EX_rd         (ID_EX_rd         ),
  .ID_EX_inst_func  (ID_EX_inst_func  ),
  .forward_a        (forward_a        ),
  .forward_b        (forward_b        ),
  .wb_data          (wb_data          ),
  .EX_MEM_alu_out   (EX_MEM_alu_out   ),
  .EX_MEM_mem_to_reg(EX_MEM_mem_to_reg),
  .EX_MEM_reg_write (EX_MEM_reg_write ),
  .EX_MEM_mem_write (EX_MEM_mem_write ),
  .EX_MEM_mem_read  (EX_MEM_mem_read  ),
  .EX_MEM_dataB     (EX_MEM_dataB     ),
  .EX_MEM_rd        (EX_MEM_rd        ),
  .alu_out          (alu_out          )
  );

//--------------------------------------
//         Module Memory Access
//--------------------------------------
memory_access memory_access(
  .clk              (clk              ),
  .reset_n          (reset_n          ),
  .EX_MEM_mem_to_reg(EX_MEM_mem_to_reg),
  .EX_MEM_reg_write (EX_MEM_reg_write) ,
  .EX_MEM_mem_read  (EX_MEM_mem_read  ),
  .EX_MEM_mem_write (EX_MEM_mem_write ),
  .EX_MEM_alu_out   (EX_MEM_alu_out   ),
  .EX_MEM_dataB     (EX_MEM_dataB     ),
  .EX_MEM_rd        (EX_MEM_rd        ),
  .MEM_WB_reg_write (MEM_WB_reg_write ),
  .MEM_WB_mem_to_reg(MEM_WB_mem_to_reg),
  .MEM_WB_mem_data  (MEM_WB_mem_data  ),
  .MEM_WB_alu_out   (MEM_WB_alu_out   ),
  .MEM_WB_rd        (MEM_WB_rd        ),
  .mem_data         (mem_data         )
  );

//--------------------------------------
//         Module Register Write
//--------------------------------------
register_write register_write(
  .MEM_WB_mem_to_reg(MEM_WB_mem_to_reg),
  .MEM_WB_mem_data  (MEM_WB_mem_data  ),
  .MEM_WB_alu_out   (MEM_WB_alu_out   ),
  .wb_data          (wb_data          )
  );

//-------------------------------
//         Module Control
//-------------------------------
control control(
  .IF_ID_inst       (IF_ID_inst),
  .br_eq            (br_eq     ),
  .alu_op           (alu_op    ),
  .alu_src          (alu_src   ),
  .branch           (branch    ),
  .pc_src           (pc_src    ),
  .IF_flush         (IF_flush  ),
  .mem_read         (mem_read  ),
  .mem_write        (mem_write ),
  .reg_write        (reg_write ),
  .mem_to_reg       (mem_to_reg),
  .imm_sel          (imm_sel   )
  );

//-----------------------------------
//         Module Forwarding Unit
//-----------------------------------
forwarding_unit forwarding_unit(
  .ID_EX_rs1       (ID_EX_rs1       ),
  .ID_EX_rs2       (ID_EX_rs2       ),
  .ID_EX_rd        (ID_EX_rd        ),
  .IF_ID_rs1       (IF_ID_inst[19:15]       ),
  .IF_ID_rs2       (IF_ID_inst[24:20]       ),
  .MEM_WB_rd       (MEM_WB_rd       ),
  .EX_MEM_rd       (EX_MEM_rd       ),
  .EX_MEM_reg_write(EX_MEM_reg_write),
  .MEM_WB_reg_write(MEM_WB_reg_write),
  .ID_EX_reg_write (ID_EX_reg_write ),
  .branch          (branch          ),
  .forward_a       (forward_a       ),
  .forward_b       (forward_b       ),
  .forward_comp1   (forward_comp1   ),
  .forward_comp2   (forward_comp2   )
  );

//------------------------------------------
//         Module Hazrd Detection Unit
//------------------------------------------
hazard_detection_unit hazard_detection_unit(
  .ID_EX_mem_read(ID_EX_mem_read),
  .ID_EX_rd      (ID_EX_rd      ),
  .IF_ID_rs1     (IF_ID_inst[19:15]     ),
  .IF_ID_rs2     (IF_ID_inst[24:20]     ),
  .pc_write      (pc_write      ),
  .IF_ID_write   (IF_ID_write   ),
  .ctrl_sel      (ctrl_sel      )
  );

endmodule : riscv_pipeline_top