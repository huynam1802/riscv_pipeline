module hazard_detection_unit (
  input               ID_EX_mem_read,
  input         [4:0] ID_EX_rd      ,
  input         [4:0] IF_ID_rs1     ,
  input         [4:0] IF_ID_rs2     ,
  output  logic       pc_write      ,
  output  logic       IF_ID_write   ,
  output  logic       ctrl_sel      
);

//----------------------------------------------------------------
//         Stalling
//----------------------------------------------------------------
always_comb begin : proc_stall
  if (ID_EX_mem_read) begin
    if (ID_EX_rd == IF_ID_rs1 | ID_EX_rd == IF_ID_rs2) begin
      pc_write    = 0;
      IF_ID_write = 0;
      ctrl_sel    = 0;
    end
  end else begin 
    pc_write    = 1;
    IF_ID_write = 1;
    ctrl_sel    = 1;
  end
end

endmodule : hazard_detection_unit