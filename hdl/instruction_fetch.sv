module instruction_fetch (
  input                 clk         ,
  input                 reset_n     ,
  input         [31:0]  pc_branch   ,
  input                 pc_write    ,
  input                 branch      ,
  input                 pc_src      ,
  input                 br_eq       ,
  input                 IF_ID_write ,
  input                 IF_flush    ,
  output logic  [31:0]  IF_ID_pc    ,
  output logic  [31:0]  IF_ID_inst  
);

//----------------------------------------------------------------
//         Signal Declaration
//----------------------------------------------------------------
logic [31:0] pc_next;
logic [31:0] pc_value;
logic [31:0] pc_ff; // pc flip flop
logic [31:0] pc_out;
logic [31:0] inst;

//----------------------------------------------------------------
//         PC selection
//----------------------------------------------------------------
always_comb begin : proc_pc_selection
  pc_next  = pc_ff + 32'h0004;
  pc_value   = pc_src ? pc_branch : pc_next;
  pc_out       = pc_write ? pc_value : pc_ff;
end

//----------------------------------------------------------------
//         PC Flip-Flop
//----------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin : proc_pc_ff
  if(~reset_n) begin
    pc_ff <= 0;
  end 
  else if(pc_write) begin
    pc_ff <= pc_value;
  end
  else begin
    pc_ff <= pc_ff;
  end
end

//----------------------------------------------------------------
//         Instruction Memory
//----------------------------------------------------------------

localparam [31:0] NONE    = 32'h0000, // Nothing
                  INST1   = 32'h0004, // add  x10, x5, x1         --> 0000000_00001_01010_000_01010_0110011
                  INST2   = 32'h0008, // sub  x9,  x4, x3         --> 0100000_00011_00100_000_01001_0110011
                  INST3   = 32'h000C, // addi x15, x1, -50        --> 111111001110_00001_000_01111_0010011
                  INST4   = 32'h0010, // lw   x20, 10(x2)         --> 000000001010_00010_010_10100_0000011
                  INST5   = 32'h0014, // sw   x14, 8(x2)          --> 0000000_01110_00010_010_01000_0100011
                  INST6   = 32'h0018, // sub  x12,x20,x8          --> 0100000_01000_10100_000_01010_0110011
                  INST7   = 32'h001C, // addi x8,  x12, 10        --> 000000001010_01100_000_01000_0010011
                  INST8   = 32'h0020, // beq  x6,  x6, offset(8)  --> 0_000000_00110_00110_000_0100_0_1100011
                  INST9   = 32'h0024, // sw   x24, 60(x5)         --> 0000001_11001_00111_010_11100_0100011
                  INST10  = 32'h0028, // sub  x22, x30, x8        --> 0100000_01000_11110_000_10110_011011
                  INST11  = 32'h002C, // and  x26, x24, x22       --> 0000000_10110_11000_111_11010_011011
                  INST12  = 32'h0030, // addi x21, x21, 1         --> 000000000001_10101_000_10101_0010011
                  INST13  = 32'h0034, // lw   x1,  120(x10)       --> 000001011000_01010_010_00001_0000011
                  INST14  = 32'h0038, // add  x1,  x1, x21        --> 0000000_10101_00001_000_00001_0110011
                  INST15  = 32'h003C, // sw   x1,  120(x10)       --> 0000011_00001_01010_010_11000_0100011
                  INST16  = 32'h0040; // add  x15, x25, x14       --> 0000000_01110_11001_000_01111_0110011
always_comb begin : proc_instruction_memory
  case (pc_out)
    NONE    : inst = 32'b00000000000000000000000000000000;
    INST1   : inst = 32'b0000000_00001_01010_000_01010_0110011;
    INST2   : inst = 32'b0100000_00011_00100_000_01001_0110011;
    INST3   : inst = 32'b111111001110_00001_000_01111_0010011;
    INST4   : inst = 32'b000000001010_00010_010_10100_0000011;
    INST5   : inst = 32'b0000000_01110_00010_010_01000_0100011;
    INST6   : inst = 32'b0100000_01000_10100_000_01010_0110011;
    INST7   : inst = 32'b000000001010_01100_000_01000_0010011;
    INST8   : inst = 32'b0_000000_00110_00110_000_0100_0_1100011;
    INST9   : inst = 32'b0000001_11001_00111_010_11100_0100011;
    INST10  : inst = 32'b0100000_01000_11110_000_10110_011011;
    INST11  : inst = 32'b0000000_10110_11000_111_11010_011011;
    INST12  : inst = 32'b000000000001_10101_000_10101_0010011;
    INST13  : inst = 32'b000001011000_01010_010_00001_0000011;
    INST14  : inst = 32'b0000000_10101_00001_000_00001_0110011;
    INST15  : inst = 32'b0000011_00001_01010_010_11000_0100011;
    INST16  : inst = 32'b0000000_01110_11001_000_01111_0110011;
    default : inst = 32'b0;
  endcase
end

//----------------------------------------------------------------
//         Register IF/ID
//----------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin : proc_IF_ID_Register
  if(~reset_n) begin
     IF_ID_pc   <= 0;
     IF_ID_inst <= 0;
  end 
  else if(IF_flush) begin
    //Flush Register
    IF_ID_pc   <= 0;
    IF_ID_inst <= 0;
  end
  else if (~IF_ID_write) begin
    IF_ID_pc   <= IF_ID_pc;
    IF_ID_inst <= IF_ID_inst;
  end
  else begin
    IF_ID_pc   <= pc_out  ;
    IF_ID_inst <= inst;
  end
end

endmodule : instruction_fetch