// ============================================================
// RV32I ALU Control
// ============================================================
// Inputs:
//   alu_op  : tells us what instruction class we are in
//            2'b00 = ADD (loads/stores/address calc)
//            2'b01 = SUB (branches like BEQ/BNE)
//            2'b10 = use funct3/funct7 (R-type/I-type arithmetic)
//
//   funct3, funct7 : instruction fields from RV32I
//
// Output:
//   alu_ctrl : 4-bit ALU operation code (matches alu.sv)
// ============================================================

module alu_control (
    input  logic [1:0] alu_op,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [3:0] alu_ctrl
);

    // Must match alu.sv
    localparam logic [3:0]
        ALU_ADD = 4'd0,
        ALU_SUB = 4'd1,
        ALU_AND = 4'd2,
        ALU_OR  = 4'd3,
        ALU_XOR = 4'd4,
        ALU_SLT = 4'd5,
        ALU_SLL = 4'd6,
        ALU_SRL = 4'd7;

    always_comb begin
        // Default safe value
        alu_ctrl = ALU_ADD;

        case (alu_op)
            2'b00: begin
                // Loads/stores/address calc: always ADD
                alu_ctrl = ALU_ADD;
            end

            2'b01: begin
                // Branch compare usually uses SUB for equality
                alu_ctrl = ALU_SUB;
            end

            2'b10: begin
                // R-type or I-type arithmetic: decode funct3/funct7
                case (funct3)
                    3'b000: begin
                        // ADD or SUB (SUB only for R-type with funct7=0100000)
                        if (funct7 == 7'b0100000)
                            alu_ctrl = ALU_SUB;
                        else
                            alu_ctrl = ALU_ADD;
                    end

                    3'b111: alu_ctrl = ALU_AND;
                    3'b110: alu_ctrl = ALU_OR;
                    3'b100: alu_ctrl = ALU_XOR;
                    3'b010: alu_ctrl = ALU_SLT;
                    3'b001: alu_ctrl = ALU_SLL;
                    3'b101: alu_ctrl = ALU_SRL;

                    default: alu_ctrl = ALU_ADD;
                endcase
            end

            default: alu_ctrl = ALU_ADD;
        endcase
    end

endmodule
