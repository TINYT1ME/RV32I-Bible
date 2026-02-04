module if_id_pipeline(clk, resetn, pc_in, im_in, pc_pl_out, instr_pl_out);

    input clk;
    input resetn;
    input logic [31:0] pc_in;
    input logic [31:0] im_in;

    output reg [31:0] pc_pl_out;
    output reg [31:0] instr_pl_out;

    always @(posedge clk) begin
        pc_pl_out <= pc_in;
        instr_pl_out <= im_in;
    end

endmodule