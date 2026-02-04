module instruction_memory(resetn, read_addr, instr_out);

    input resetn;
    input logic [31:0] read_addr;
    output reg [31:0] instr_out;

    // memory size
    parameter MEM_SIZE = 256;
    reg [31:0] mem[0:MEM_SIZE-1]; // 256 registers of 32 bits

    assign instr_out = mem[read_addr >> 2]; // assign instruction to what is at the memory in the read_addr
    integer k;
    
    always @ (negedge resetn)
    begin
        for (k = 0; k < MEM_SIZE; k = k + 1) begin
        mem[k] <= 32'h00000000;
        end
    end

endmodule



