module cpu_top(clk, resetn, pc_out, instr_out);

    input clk;
    input resetn;
    output reg [31:0] pc_out;
    output reg [31:0] instr_out;

    // PC
    program_counter pc_inst(.clk(clk),
    .resetn(resetn),
    .pc_out(pc_out));

    // IM
    instruction_memory im_inst(.resetn(resetn),
    .read_addr(pc_out),
    .instr_out(instr_out));

    // waveform directory
    initial begin
        $dumpfile("../waveforms/cpu_top.vcd");
        $dumpvars(0, cpu_top);
    end
endmodule