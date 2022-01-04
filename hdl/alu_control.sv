module alu_control (
  input           [1:0] alu_op,
  input                 inst_30,
  input           [2:0] inst_14_12,
  output  logic   [3:0] alu_control
);

localparam  ADD = 4'b0010,
            SUB = 4'b0110,
            AND = 4'b0000,
            OR  = 4'b0001;

localparam  LW_SW   = 2'b00,
            BEQ     = 2'b01,
            R_TYPE  = 2'b10;

always_comb begin : proc_alu_control
  case (alu_op)
  LW_SW:  alu_control = ADD;
  BEQ:    alu_control = SUB;//data1 - data2 == 0
  R_TYPE: case ({inst_30,inst_14_12})
          4'b0000:  alu_control = ADD;
          4'b1000:  alu_control = SUB;
          4'b0111:  alu_control = AND;
          4'b0110:  alu_control = OR;
          default : alu_control = 4'b1111;
  endcase
    default : alu_control = 4'b1111;
  endcase
end

endmodule