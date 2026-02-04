module program_counter(clk, resetn, pc_out);

    input clk;
    input resetn;

    output reg [31:0] pc_out;

    logic [31:0] next_pc;

    always @ (posedge clk)
    begin
        if(!resetn)
            pc_out <= 0;
        else
            pc_out <= next_pc;
    end
    assign next_pc = pc_out + 4;

endmodule