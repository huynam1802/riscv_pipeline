module memory_access (
  input               clk               ,  // Clock
  input               reset_n           ,  // Asynchronous reset active low
  input               EX_MEM_mem_to_reg ,
  input               EX_MEM_reg_write  ,
  input               EX_MEM_mem_read   ,
  input               EX_MEM_mem_write  ,
  input        [31:0] EX_MEM_alu_out    ,
  input        [31:0] EX_MEM_dataB      ,
  input        [ 4:0] EX_MEM_rd         ,
  output logic        MEM_WB_reg_write  ,
  output logic        MEM_WB_mem_to_reg ,
  output logic [31:0] MEM_WB_mem_data   ,
  output logic [31:0] MEM_WB_alu_out    ,
  output logic [ 4:0] MEM_WB_rd         ,
  output logic [31:0] mem_data          
);

//----------------------------------------------------------------
//         Signal Declaration
//----------------------------------------------------------------


//----------------------------------------------------------------
//         Data Memory
//----------------------------------------------------------------
logic [31:0] Data_Memory[0:128];

always_ff @(posedge clk or negedge reset_n) begin : proc_
  for (int i = 0; i < 128; i++) begin
    if(~reset_n) begin
      Data_Memory[i] <= i;
    end
    else if (EX_MEM_mem_write) begin
      Data_Memory[EX_MEM_alu_out[6:0]] <= EX_MEM_dataB;
    end
    else Data_Memory[i] <= Data_Memory[i];
    // if(EX_MEM_mem_write) begin
    //   Data_Memory[EX_MEM_alu_out[9:0]] <= EX_MEM_dataB;
    // end

  end
end

always_comb begin : proc_data_read
  if (EX_MEM_mem_read) begin
    mem_data = Data_Memory[EX_MEM_alu_out[6:0]];
  end else  mem_data = 0;
end
//----------------------------------------------------------------
//         Register MEM/WB
//----------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin : proc_mem_wb_register
  if(~reset_n) begin
    MEM_WB_reg_write  <= 0;
    MEM_WB_mem_to_reg <= 0;
    MEM_WB_mem_data   <= 0;
    MEM_WB_alu_out    <= 0;
    MEM_WB_rd         <= 0;
  end 
  else begin
    MEM_WB_reg_write  <= EX_MEM_reg_write ;
    MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;
    MEM_WB_mem_data   <= mem_data         ;
    MEM_WB_alu_out    <= EX_MEM_alu_out   ;
    MEM_WB_rd         <= EX_MEM_rd        ;
  end
end

endmodule : memory_access