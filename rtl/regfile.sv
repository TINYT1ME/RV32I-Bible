// Register file
// 32 * 32-bit registers, x0 hardwired to zero
//--------------------------------------
// What does this do?
// 1. Read from 2 registers (rs1 and rs2), output rs1_data and rs2_data. x0 always reads as 0
// 2. Write to 1 register (rd) on rising clock when wr_en, with wdata. x0 is never written (kept at 0)
// 3. On reset (rst_n low), clear all 32 registers to 0
// Pretty much lots of registers with x0 hardwired to 0
//--------------------------------------
// RegFile.png is just a reference to the manual(2.1)
module regfile (
  input  logic        clk,
  input  logic        rst_n,

  input  logic  [4:0] rs1, // read address 1 (5 bits so 2^5 = 32 registers)
  input  logic  [4:0] rs2, // read address 2
  input  logic  [4:0] rd, // write address (destination)
  input  logic [31:0] wdata, // write data
  input  logic        wr_en, // write enable

  output logic [31:0] rs1_data, // data from register at rs1
  output logic [31:0] rs2_data  // data from register at rs2
);
  logic [31:0] regs [31:0];

  // Read ports are combinatorial
  // If rs1 or rs2 is 0 we output 0 (x0 is hardwired to zero), else we output regs[rs1] or regs[rs2]
  always_comb begin
    rs1_data = (rs1 == 5'd0) ? 32'b0 : regs[rs1];
    rs2_data = (rs2 == 5'd0) ? 32'b0 : regs[rs2];
  end

  // Write happens on rising edge of clock
  // On reset we clear all registers to 0. Otherwise if wr_en is high and rd is not 0 we write wdata to regs[rd]
  // We always keep x0 at 0 even if something weird happens
  integer i;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 0; i < 32; i++) regs[i] <= 32'b0;
    end else begin
      if (wr_en && (rd != 5'd0)) begin
        regs[rd] <= wdata;
      end

      regs[5'd0] <= 32'b0;
    end
  end
endmodule