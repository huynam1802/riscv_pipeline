module control (
  input         [31:0] IF_ID_inst        , 
  input                br_eq             , 
  output  logic [ 1:0] alu_op            , 
  output  logic        alu_src           , 
  output  logic        branch            , 
  output  logic        pc_src            ,
  output  logic        IF_flush          ,
  output  logic        mem_read          , 
  output  logic        mem_write         , 
  output  logic        reg_write         , 
  output  logic        mem_to_reg        , 
  output  logic [ 2:0] imm_sel             
);

logic [6:0] IF_ID_inst_opcode;
logic [3:0] IF_ID_inst_func;
assign  pc_src            = branch & br_eq;
assign  IF_flush          = branch & br_eq;
assign  IF_ID_inst_opcode = IF_ID_inst [6:0];
assign  IF_ID_inst_func   = {IF_ID_inst[30],IF_ID_inst[14:12]};

//----------------------------------------------------------------
//         Opcopde
//----------------------------------------------------------------
localparam  R_OPCODE = 7'b0110011,
            I_OPCODE = 7'b0000011,
            ADD_I    = 7'b0010011,
            S_OPCODE = 7'b0100011,
            B_OPCODE = 7'b1100011;

localparam [2:0]  R = 3'b001,
                  I = 3'b010,
                  S = 3'b011,
                  B = 3'b100,
                  J = 3'b101;

//----------------------------------------------------------------
//         All signal ouput of control module depend on the opcode
//----------------------------------------------------------------
always_comb begin : proc_control_output_compute
  case (IF_ID_inst_opcode)
  R_OPCODE: begin
    alu_op      = 2'b10;
    alu_src     = 0;
    branch      = 0;
    mem_read    = 0;
    mem_write   = 0;
    reg_write   = 1;
    mem_to_reg  = 0;
    imm_sel     = R;
  end
  I_OPCODE: begin
    alu_op      = 2'b00;
    alu_src     = 1;
    branch      = 0;
    mem_read    = 1;
    mem_write   = 0;
    reg_write   = 1;
    case (IF_ID_inst_func[2:0])
    010:  mem_to_reg = 1;
    000:  mem_to_reg = 0;
      default : mem_to_reg = 1;
    endcase
    imm_sel     = I;
  end
  ADD_I: begin
    alu_op      = 2'b00;
    alu_src     = 1;
    branch      = 0;
    mem_read    = 0;
    mem_write   = 0;
    reg_write   = 1;
    case (IF_ID_inst_func[2:0])
    010:  mem_to_reg = 1;
    000:  mem_to_reg = 0;
      default : mem_to_reg = 1;
    endcase
    imm_sel     = I;
  end
  S_OPCODE: begin
    alu_op      = 2'b00;
    alu_src     = 1;
    branch      = 0;
    mem_read    = 0;
    mem_write   = 1;
    reg_write   = 0;
    mem_to_reg  = 0;
    imm_sel     = S;
  end
  B_OPCODE: begin
    alu_op      = 2'b01;
    alu_src     = 0;
    branch      = 1;
    mem_read    = 0;
    mem_write   = 0;
    reg_write   = 0;
    mem_to_reg  = 0;
    imm_sel     = B;
  end
    default : begin 
      alu_op      = 0;
      alu_src     = 0;
      branch      = 0;
      mem_read    = 0;
      mem_write   = 0;
      reg_write   = 0;
      mem_to_reg  = 0;
      imm_sel     = 0;
    end
  endcase
end

endmodule : control