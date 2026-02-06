// Immediate generator
//--------------------------------------
// What does this do?
// 1. Extract the immediate value from the instruction.
// 2. Output the immediate value.
// Pretty much a map ImmEncoding.png -> ImmTypes.png
//--------------------------------------
module immgen (
  input  logic [31:0] instr,
  output logic [31:0] imm
);
  logic [6:0] opcode;
  assign opcode = instr[6:0];

  // Refer to ImmEncoding.png or RISC-V ISA Manual 2.3
  // All opcodes that require the immgen
  localparam logic [6:0]
    OP_JALR   = 7'b1100111,   // I-type: JALR
    OP_LOAD   = 7'b0000011,   // I-type: LB, LH, LW, LBU, LHU
    OP_OPIMM  = 7'b0010011,   // I-type: ADDI, SLTI, XORI, ORI, SLLI, SRLI, SRAI
    OP_LUI    = 7'b0110111,   // U-type: LUI
    OP_AUIPC  = 7'b0010111,   // U-type: AUIPC
    OP_JAL    = 7'b1101111,   // J-type: JAL
    OP_BRANCH = 7'b1100011,   // B-type: BEQ, BNE, BLT, BGE, BLTU, BGEU
    OP_STORE  = 7'b0100011,   // S-type: SB, SH, SW
    OP_OP     = 7'b0110011;   // R-type: no immediate (default 0)

  // We are looking to do 2 things here:
  // 1. Extract the sign bit from the instruction
  // 2. Extract the immediate value from the instruction
  // Refer to ImmTypes.png or RISC-V ISA Manual 2.3
  always_comb begin
    unique case (opcode)
      //----------------------------------------------------------------------
      // I-type
      // Used for: OPIMM (ALU imm), LOAD (addr offset), JALR (target offset).
      // This one is easy, we just take the 12-bit immediate field and sign extend it
      //----------------------------------------------------------------------
      // Instruction bit layout
      // We use this -> [31] Sign bit (20{instr[31]}) we fill the rest of the bits on the left with this bit 20
      // We use this -> [31:20] 12-bit immediate field (instr[31:20])
      // [19:15] rs1 (dont care)
      // [14:12] funct3 (dont care)
      // [11:7]  rd (dont care)
      // [6:0]   opcode (dont care)
      //----------------------------------------------------------------------
      // Output: 32-bit immediate
      // [20 * instr[31] | instr[31:20]]
      //----------------------------------------------------------------------
      OP_OPIMM, OP_LOAD, OP_JALR: begin
        imm = {{20{instr[31]}}, instr[31:20]};
      end

      //----------------------------------------------------------------------
      // S-type
      // Used for: SB, SH, SW
      // Immediate is split in the instruction so rs1/rs2 stay in fixed positions
      // we take the two parts from the instruction and combine them.
      //----------------------------------------------------------------------
      // Instruction bit layout
      // We use this -> [31] Sign bit
      // We use this -> [31:25] High 7 bits of 12 bit immediate field
      // [24:20] rs2 (dont care)
      // [19:15] rs1 (dont care)
      // [14:12] funct3 (dont care)
      // We use this -> [11:7] Low 5 bits of 12 bit immediate field
      // [6:0] opcode (dont care)
      //----------------------------------------------------------------------
      // Output: 32-bit immediate
      // [20 * instr[31] | imm[11:5] | imm[4:0]]
      //----------------------------------------------------------------------
      OP_STORE: begin
        imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
      end

      //----------------------------------------------------------------------
      // B-type
      // Used for: BEQ, BNE, BLT, BGE, BLTU, BGEU (branch offset = PC + sign_ext(imm)).
      //----------------------------------------------------------------------
      // Instruction bit layout
      // We use this -> [31]
      // We use this -> [30:25]
      // [24:20] rs2 (dont care)
      // [19:15] rs1 (dont care)
      // [14:12] funct3 (dont care)
      // We use this -> [11:8]
      // We use this -> [7]
      // [6:0]   opcode (dont care)
      //----------------------------------------------------------------------
      // Output: 32-bit immediate
      // [19 * instr[31] | instr[30:25] | instr[7] | instr[30:25] | instr[11:8] | 0]
      //----------------------------------------------------------------------
      OP_BRANCH: begin
        imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
      end

      //----------------------------------------------------------------------
      // U-type
      // Used for: LUI (load upper imm), AUIPC (PC + upper imm).
      //----------------------------------------------------------------------
      // Instruction bit layout
      // We use this -> [31:12] 20-bit immediate field (becomes upper 20 bits of output)
      // [11:7] rd (dont care)
      // [6:0] opcode (dont care)
      //----------------------------------------------------------------------
      // Output: 32-bit immediate
      // [instr[31:12] | 12 * 0]
      //----------------------------------------------------------------------
      OP_LUI, OP_AUIPC: begin
        imm = {instr[31:12], 12'b0};
      end

      //----------------------------------------------------------------------
      // J-type
      // Used for: JAL (jump and link). Jump target = PC + sign_ext(imm).
      //----------------------------------------------------------------------
      // Instruction bit layout (instr) — which bits we use to build the immediate:
      // We use this -> [31] Sign bit
      // We use this -> [30:21]
      // We use this -> [20]
      // We use this -> [19:12]
      // [11:7] rd (dont care)
      // [6:0] opcode (dont care)
      //----------------------------------------------------------------------
      // Output: 32-bit immediate
      // [11 * instr[31] | instr[31] | instr[19:12] | instr[20] | instr[30:21] | 0]
      //----------------------------------------------------------------------
      OP_JAL: begin
        imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
      end

      // Default case/R-type
      // No immediate, so we output 0
      //----------------------------------------------------------------------
      // Output: 32-bit immediate
      // [32 * 0]
      //----------------------------------------------------------------------
      default: imm = 32'b0;
    endcase
  end
endmodule