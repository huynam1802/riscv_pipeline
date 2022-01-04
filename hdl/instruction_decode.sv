module instruction_decode (
  input               clk               , // Clock
  input               reset_n           , // Asynchronous reset active low
  input        [31:0] IF_ID_pc          ,
  input        [31:0] IF_ID_inst        ,
  input        [ 4:0] IF_ID_rs1         ,
  input        [ 4:0] IF_ID_rs2         ,
  input               MEM_WB_reg_write  ,
  input        [ 4:0] MEM_WB_rd         ,
  input        [31:0] wb_data           ,
  input        [ 2:0] imm_sel           ,
  input               mem_to_reg        ,
  input               reg_write         ,
  input               mem_write         ,
  input               mem_read          ,
  input               alu_src           ,
  input        [ 1:0] alu_op            ,
  input               ctrl_sel          ,
  input        [ 1:0] forward_comp1     ,
  input        [ 1:0] forward_comp2     ,
  input        [31:0] alu_out           ,
  input        [31:0] mem_data          ,
  input        [31:0] EX_MEM_alu_out    ,
  input               EX_MEM_mem_to_reg ,
  output logic [31:0] pc_branch         ,
  output logic        br_eq             ,
  output logic        ID_EX_mem_to_reg  ,
  output logic        ID_EX_reg_write   ,
  output logic        ID_EX_mem_write   ,
  output logic        ID_EX_mem_read    ,
  output logic        ID_EX_alu_src     ,
  output logic [ 1:0] ID_EX_alu_op      ,
  output logic [31:0] ID_EX_data1       ,
  output logic [31:0] ID_EX_data2       ,
  output logic [ 4:0] ID_EX_rs1         ,
  output logic [ 4:0] ID_EX_rs2         ,
  output logic [ 4:0] ID_EX_rd          ,
  output logic [31:0] ID_EX_imm_gen     ,
  output logic [ 3:0] ID_EX_inst_func   
  );

//----------------------------------------------------------------
//         Signal Declaration
//----------------------------------------------------------------
// logic [ 4:0] rs1           ;
// logic [ 4:0] rs2           ;
logic [31:0] imm_gen_out   ;
logic [31:0] reg_data1     ;
logic [31:0] reg_data2     ;
logic [31:0] data1         ;
logic [31:0] data2         ;
logic        out_mem_to_reg;
logic        out_reg_write ;
logic        out_mem_write ;
logic        out_mem_read  ;
logic        out_alu_src   ;
logic [ 1:0] out_alu_op    ;

localparam [2:0]  R = 3'b001,
                  I = 3'b010,
                  S = 3'b011,
                  B = 3'b100,
                  J = 3'b101;

//----------------------------------------------------------------
//         Registers
//----------------------------------------------------------------
logic [31:0] Register [0:31];
always_comb begin : proc_reg_data
  reg_data1 = Register[IF_ID_rs1];
  reg_data2 = Register[IF_ID_rs2];
end

always_ff @(posedge clk or negedge reset_n) begin : proc_
  for (int i = 0; i < 32; i++) begin
    if(~reset_n) begin
      Register[i] <= i;
    end
    else if(MEM_WB_reg_write) begin
      Register [MEM_WB_rd] <= wb_data;
    end
  end
end

//----------------------------------------------------------------
//         Branch
//----------------------------------------------------------------
always_comb begin : proc_branch
  // MUX compare 1
  case (forward_comp1)
    2'b01: data1 = alu_out;
    2'b10: data1 = EX_MEM_mem_to_reg ? mem_data : EX_MEM_alu_out;
    default : data1 = reg_data1;
  endcase
// MUX compare 1
  case (forward_comp2)
    2'b01: data2 = alu_out;
    2'b10: data2 = EX_MEM_mem_to_reg ? mem_data : EX_MEM_alu_out;
    default : data2 = reg_data2;
  endcase
  // 
  pc_branch = imm_gen_out + IF_ID_pc;
  br_eq     = (data1 == data2);
end

//----------------------------------------------------------------
//         Control output
//----------------------------------------------------------------
always_comb begin : proc_control_output
  if (ctrl_sel) begin
    out_mem_to_reg = mem_to_reg;
    out_reg_write  = reg_write ;
    out_mem_write  = mem_write ;
    out_mem_read   = mem_read  ;
    out_alu_src    = alu_src   ;
    out_alu_op     = alu_op    ;
  end else begin 
    out_mem_to_reg = 0;
    out_reg_write  = 0;
    out_mem_write  = 0;
    out_mem_read   = 0;
    out_alu_src    = 0;
    out_alu_op     = 0;
  end
end

//----------------------------------------------------------------
//         Immidiate Generate
//----------------------------------------------------------------
always_comb begin : proc_imm_gen
  case (imm_sel)
    R: begin
      imm_gen_out = 32'b0;
    end
    I: begin
      if (IF_ID_inst[31]) begin
        imm_gen_out = {21'b111111111111111111111, IF_ID_inst[31:20]};
      end
      else begin
        imm_gen_out = {21'b0, IF_ID_inst[31:20]};
      end
    end
    S: begin
      if (IF_ID_inst [31]) begin
        imm_gen_out = {21'b111111111111111111111, IF_ID_inst[31:25], IF_ID_inst[11:7]};
      end
      else begin
        imm_gen_out = {21'b0, IF_ID_inst[31:25], IF_ID_inst[11:7]};
      end
    end
    B: begin
      if (IF_ID_inst[31]) begin
        imm_gen_out = {19'b1111111111111111111, IF_ID_inst[31], IF_ID_inst[7], IF_ID_inst[30:25], IF_ID_inst[11:8], 1'b0};
      end
      else begin
        imm_gen_out = {19'b0, IF_ID_inst[31], IF_ID_inst[7], IF_ID_inst[30:25], IF_ID_inst[11:8], 1'b0};
        
      end
    end
    J: begin
      if (IF_ID_inst [31]) begin
        imm_gen_out = {12'b11111111111, IF_ID_inst[31], IF_ID_inst[19:12], IF_ID_inst[20], IF_ID_inst[30:21]};
      end
      else begin
        imm_gen_out = {12'b0, IF_ID_inst[31], IF_ID_inst[19:12], IF_ID_inst[20], IF_ID_inst[30:21]};
      end
    end
    default : imm_gen_out = 32'b0;
  endcase
end

//----------------------------------------------------------------
//         Register ID/EX
//----------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin : proc_ID_EX_register
  if(~reset_n) begin
    ID_EX_mem_to_reg <= 0;
    ID_EX_reg_write  <= 0;
    ID_EX_mem_write  <= 0;
    ID_EX_mem_read   <= 0;
    ID_EX_alu_src    <= 0;
    ID_EX_alu_op     <= 0;
    ID_EX_data1      <= 0;
    ID_EX_data2      <= 0;
    ID_EX_rs1        <= 0;
    ID_EX_rs2        <= 0;
    ID_EX_rd         <= 0;
    ID_EX_inst_func  <= 0;
    ID_EX_imm_gen    <= 0;
  end
  else begin
    ID_EX_mem_to_reg <= out_mem_to_reg                    ;
    ID_EX_reg_write  <= out_reg_write                     ;
    ID_EX_mem_write  <= out_mem_write                     ;
    ID_EX_mem_read   <= out_mem_read                      ;
    ID_EX_alu_src    <= out_alu_src                       ;
    ID_EX_alu_op     <= out_alu_op                        ;
    ID_EX_data1      <= data1                             ;
    ID_EX_data2      <= data2                             ;
    ID_EX_rs1        <= IF_ID_rs1                         ;
    ID_EX_rs2        <= IF_ID_rs2                         ;
    ID_EX_rd         <= IF_ID_inst[11:7]                  ;
    ID_EX_inst_func  <= {IF_ID_inst[30],IF_ID_inst[14:12]};
    ID_EX_imm_gen    <= imm_gen_out                       ;
  end
end

endmodule : instruction_decode