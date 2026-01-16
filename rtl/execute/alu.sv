// ============================================================
// RV32I ALU (Beginner-friendly)
// ============================================================
// Inputs:
//   A, B      : 32-bit operands
//   alu_ctrl  : selects the operation
//
// Outputs:
//   result    : 32-bit result
//   zero      : 1 if result == 0 (useful for BEQ later)
// ============================================================

module alu (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [3:0]  alu_ctrl,

    output logic [31:0] result,
    output logic        zero
);

    // ------------------------------------------------------------
    // ALU operation codes (we will also reuse these in ALU control)
    // ------------------------------------------------------------
    localparam logic [3:0]
        ALU_ADD = 4'd0,
        ALU_SUB = 4'd1,
        ALU_AND = 4'd2,
        ALU_OR  = 4'd3,
        ALU_XOR = 4'd4,
        ALU_SLT = 4'd5,  // signed set-less-than
        ALU_SLL = 4'd6,  // shift left logical
        ALU_SRL = 4'd7;  // shift right logical

    // ------------------------------------------------------------
    // Combinational ALU logic: changes immediately with inputs
    // ------------------------------------------------------------
    always_comb begin
        // Default (safe): output 0 if unknown operation
        result = 32'b0;

        case (alu_ctrl)
            ALU_ADD: result = A + B;
            ALU_SUB: result = A - B;
            ALU_AND: result = A & B;
            ALU_OR : result = A | B;
            ALU_XOR: result = A ^ B;

            // Signed comparison: cast to signed before comparing
            ALU_SLT: result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;

            // Shifts: use only lower 5 bits of B (RV32 shift amount)
            ALU_SLL: result = A << B[4:0];
            ALU_SRL: result = A >> B[4:0];

            default: result = 32'b0;
        endcase
    end

    // zero flag is just "result == 0"
    always_comb begin
        zero = (result == 32'b0);
    end

endmodule
