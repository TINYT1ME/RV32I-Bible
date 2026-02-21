// ============================================================
// RV32I Branch Unit
// ============================================================
// Decides whether a branch should be taken based on rs1, rs2,
// funct3, and a branch enable signal.
// ============================================================

module branch_unit (
    input  logic        branch,     
    input  logic [2:0]  funct3,       
    input  logic [31:0] rs1_val,      
    input  logic [31:0] rs2_val,      
    output logic        take_branch   
);

    always_comb begin
        
        take_branch = 1'b0;

        if (branch) begin
            case (funct3)
                3'b000: begin
                    // BEQ
                    take_branch = (rs1_val == rs2_val);
                end

                3'b001: begin
                    // BNE
                    take_branch = (rs1_val != rs2_val);
                end

                3'b100: begin
                    // BLT (signed)
                    take_branch = ($signed(rs1_val) < $signed(rs2_val));
                end

                3'b101: begin
                    // BGE (signed)
                    take_branch = ($signed(rs1_val) >= $signed(rs2_val));
                end

                default: begin
                    take_branch = 1'b0;
                end
            endcase
        end
    end

endmodule
