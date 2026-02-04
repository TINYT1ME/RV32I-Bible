// Control unit
//--------------------------------------
// What does this do?
// 1. Decode the instruction (opcode, funct3, funct7).
// 2. Drive control signals for the datapath (reg write, memory, ALU, branch/jump).
// Refer to RISC-V ISA Manual 2.2 (instruction formats) and 2.4–2.6 (instruction descriptions).
//--------------------------------------

module control (
  input  logic [31:0] instr,

  output logic        reg_write,
  output logic        mem_read,
  output logic        mem_write,
  output logic        mem_to_reg,
  output logic        branch,
  output logic        jump,       // JAL: pc = pc + J-imm
  output logic        jump_reg,   // JALR: pc = (rs1 + I-imm) & ~1
  output logic        alu_src_imm,

  output logic [3:0]  alu_op,     // ALU operation (see localparams below)
  output logic [2:0]  br_type,    // funct3 for branches (BEQ, BNE, BLT, BGE, BLTU, BGEU)
  output logic [2:0]  ls_funct3   // funct3 for loads/stores (size, signedness)
);

  // We extract these fields from the instruction (same idea as immgen: one input, decode inside).
  logic [6:0] opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;

  assign opcode = instr[6:0];
  assign funct3 = instr[14:12];
  assign funct7 = instr[31:25];

  // Refer to RISC-V ISA Manual 2.2. Base opcodes for RV32I.
  localparam logic [6:0]
    OP_LUI    = 7'b0110111,   // U-type: LUI
    OP_AUIPC  = 7'b0010111,   // U-type: AUIPC
    OP_JAL    = 7'b1101111,   // J-type: JAL
    OP_JALR   = 7'b1100111,   // I-type: JALR
    OP_BRANCH = 7'b1100011,   // B-type: BEQ, BNE, BLT, BGE, BLTU, BGEU
    OP_LOAD   = 7'b0000011,   // I-type: LB, LH, LW, LBU, LHU
    OP_STORE  = 7'b0100011,   // S-type: SB, SH, SW
    OP_OPIMM  = 7'b0010011,   // I-type: ADDI, SLTI, XORI, ORI, SLLI, SRLI, SRAI
    OP_OP     = 7'b0110011;   // R-type: ADD, SUB, AND, OR, etc.

  // ALU operation select. Datapath uses this to choose add/sub/logic/shift.
  localparam logic [3:0]
    ALU_ADD    = 4'd0,
    ALU_SUB    = 4'd1,
    ALU_AND    = 4'd2,
    ALU_OR     = 4'd3,
    ALU_XOR    = 4'd4,
    ALU_SLT    = 4'd5,
    ALU_SLTU   = 4'd6,
    ALU_SLL    = 4'd7,
    ALU_SRL    = 4'd8,
    ALU_SRA    = 4'd9,
    ALU_COPY_B = 4'd10;       // copy B input to result (for LUI: rd = imm)

  // We set control signals from the opcode (and for R-type/OPIMM, from funct3/funct7).
  // Defaults first so we never infer latches; then we override per opcode.
  always_comb begin
    // Default: no write, no memory, no branch/jump, ALU adds, use rs2 not imm.
    reg_write   = 1'b0;
    mem_read    = 1'b0;
    mem_write   = 1'b0;
    mem_to_reg  = 1'b0;
    branch      = 1'b0;
    jump        = 1'b0;
    jump_reg    = 1'b0;
    alu_src_imm = 1'b0;
    alu_op      = ALU_ADD;
    br_type     = funct3;
    ls_funct3   = funct3;

    unique case (opcode)
      //----------------------------------------------------------------------
      // U-type: LUI (Load Upper Immediate)
      // Used for: LUI. rd = imm (upper 20 bits of instr << 12). No ALU math,
      // we just want the immediate in rd; datapath uses ALU “copy B” so result = imm.
      //----------------------------------------------------------------------
      // We set:
      //   reg_write   = 1  -> write result to rd
      //   alu_src_imm = 1  -> ALU B = imm (from immgen)
      //   alu_op      = ALU_COPY_B -> result = B (the imm)
      //----------------------------------------------------------------------
      OP_LUI: begin
        reg_write   = 1'b1;
        alu_src_imm = 1'b1;
        alu_op      = ALU_COPY_B;
      end

      //----------------------------------------------------------------------
      // U-type: AUIPC (Add Upper Immediate to PC)
      // Used for: AUIPC. rd = pc + imm. Datapath must feed PC as ALU A, imm as B.
      //----------------------------------------------------------------------
      // We set:
      //   reg_write   = 1  -> write result to rd
      //   alu_src_imm = 1  -> ALU B = imm
      //   alu_op      = ALU_ADD -> result = A + B (pc + imm)
      //----------------------------------------------------------------------
      OP_AUIPC: begin
        reg_write   = 1'b1;
        alu_src_imm = 1'b1;
        alu_op      = ALU_ADD;
      end

      //----------------------------------------------------------------------
      // J-type: JAL (Jump and Link)
      // Used for: JAL. rd = pc+4, pc = pc + J-imm. Save return address, then jump.
      //----------------------------------------------------------------------
      // We set:
      //   reg_write = 1 -> write pc+4 to rd (datapath supplies pc+4 when jump=1)
      //   jump      = 1 -> pc = pc + J-imm (datapath uses immgen J-type imm)
      //----------------------------------------------------------------------
      OP_JAL: begin
        reg_write = 1'b1;
        jump      = 1'b1;
      end

      //----------------------------------------------------------------------
      // I-type: JALR (Jump and Link Register)
      // Used for: JALR. rd = pc+4, pc = (rs1 + I-imm) & ~1. ALU computes rs1 + imm.
      //----------------------------------------------------------------------
      // We set:
      //   reg_write   = 1  -> write pc+4 to rd (datapath supplies pc+4 when jump_reg=1)
      //   jump_reg    = 1  -> pc = (ALU result) & ~1
      //   alu_src_imm = 1  -> ALU B = I-imm
      //   alu_op      = ALU_ADD -> result = rs1 + imm (jump target)
      //----------------------------------------------------------------------
      OP_JALR: begin
        reg_write   = 1'b1;
        jump_reg    = 1'b1;
        alu_src_imm = 1'b1;
        alu_op      = ALU_ADD;
      end

      //----------------------------------------------------------------------
      // B-type: branches (BEQ, BNE, BLT, BGE, BLTU, BGEU)
      // Used for: conditional branches. Compare rs1 vs rs2; which comparison is in funct3 (br_type).
      // Datapath typically does rs1 - rs2 (ALU_SUB) and uses br_type to decide taken/not taken.
      //----------------------------------------------------------------------
      // We set:
      //   branch  = 1     -> this is a branch (evaluate condition)
      //   br_type = funct3 -> already set in defaults (BEQ=000, BNE=001, BLT=100, …)
      //   alu_op  = ALU_SUB -> datapath uses subtract for compare (optional; some designs use br_type only)
      //----------------------------------------------------------------------
      OP_BRANCH: begin
        branch = 1'b1;
        alu_op = ALU_SUB;
      end

      //----------------------------------------------------------------------
      // I-type: LOAD (LB, LH, LW, LBU, LHU)
      // Used for: rd = Mem[rs1 + I-imm]. Size and signedness come from funct3 (ls_funct3).
      //----------------------------------------------------------------------
      // We set:
      //   mem_read    = 1  -> read memory at address (rs1 + imm)
      //   mem_to_reg  = 1  -> rd = data from memory (not ALU result)
      //   reg_write   = 1  -> write that value to rd
      //   alu_src_imm = 1  -> ALU B = I-imm so address = rs1 + imm
      //   alu_op      = ALU_ADD -> address = rs1 + imm
      //   ls_funct3   = funct3 -> already set in defaults (byte/half/word, signed/unsigned)
      //----------------------------------------------------------------------
      OP_LOAD: begin
        mem_read    = 1'b1;
        mem_to_reg  = 1'b1;
        reg_write   = 1'b1;
        alu_src_imm = 1'b1;
        alu_op      = ALU_ADD;
      end

      //----------------------------------------------------------------------
      // S-type: STORE (SB, SH, SW)
      // Used for: Mem[rs1 + S-imm] = rs2. Size in funct3 (ls_funct3).
      //----------------------------------------------------------------------
      // We set:
      //   mem_write   = 1  -> write memory at address (rs1 + imm)
      //   alu_src_imm = 1  -> ALU B = S-imm so address = rs1 + imm
      //   alu_op      = ALU_ADD -> address = rs1 + imm
      //   ls_funct3   = funct3 -> already set in defaults (byte/half/word)
      //----------------------------------------------------------------------
      OP_STORE: begin
        mem_write   = 1'b1;
        alu_src_imm = 1'b1;
        alu_op      = ALU_ADD;
      end

      //----------------------------------------------------------------------
      // I-type: OPIMM (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
      // Used for: rd = rs1 op I-imm. ALU op from funct3; SRLI vs SRAI from funct7[5].
      //----------------------------------------------------------------------
      // We set:
      //   reg_write   = 1  -> write ALU result to rd
      //   alu_src_imm = 1  -> ALU B = I-imm
      //   alu_op      = from funct3 (and funct7 for 3'b101 -> SRLI vs SRAI)
      //----------------------------------------------------------------------
      OP_OPIMM: begin
        reg_write   = 1'b1;
        alu_src_imm = 1'b1;
        unique case (funct3)
          3'b000: alu_op = ALU_ADD;
          3'b001: alu_op = ALU_SLL;
          3'b010: alu_op = ALU_SLT;
          3'b011: alu_op = ALU_SLTU;
          3'b100: alu_op = ALU_XOR;
          3'b101: alu_op = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
          3'b110: alu_op = ALU_OR;
          3'b111: alu_op = ALU_AND;
          default: alu_op = ALU_ADD;
        endcase
      end

      //----------------------------------------------------------------------
      // R-type: OP (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
      // Used for: rd = rs1 op rs2. ALU op from funct3; ADD vs SUB and SRL vs SRA from funct7[5].
      //----------------------------------------------------------------------
      // We set:
      //   reg_write   = 1   -> write ALU result to rd
      //   alu_src_imm = 0   -> ALU B = rs2 (not imm)
      //   alu_op      = from funct3 and funct7 (SUB when funct3=000 and funct7=0100000; SRA when 101 + 0100000)
      //----------------------------------------------------------------------
      OP_OP: begin
        reg_write   = 1'b1;
        alu_src_imm = 1'b0;
        unique case (funct3)
          3'b000: alu_op = (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD;
          3'b001: alu_op = ALU_SLL;
          3'b010: alu_op = ALU_SLT;
          3'b011: alu_op = ALU_SLTU;
          3'b100: alu_op = ALU_XOR;
          3'b101: alu_op = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
          3'b110: alu_op = ALU_OR;
          3'b111: alu_op = ALU_AND;
          default: alu_op = ALU_ADD;
        endcase
      end

      //----------------------------------------------------------------------
      // Default: illegal or unsupported opcode
      // We keep all defaults: no reg write, no memory, no branch/jump. Safe no-op.
      //----------------------------------------------------------------------
      default: begin
      end
    endcase
  end
endmodule
