// RV32I register file
// x0 is architecturally hardwired to zero: reads of x0 always return 0,
// and writes to x0 are silently dropped.
module reg_file (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        reg_write,
    input  logic [4:0]  rs1_addr,
    input  logic [4:0]  rs2_addr,
    input  logic [4:0]  rd_addr,
    input  logic [31:0] rd_data,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);
    logic [31:0] regs [1:31];  // x1..x31 (x0 not stored)

    // Combinational reads
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : regs[rs2_addr];

    // Synchronous write
    always_ff @(posedge clk) begin
        if (reg_write && rd_addr != 5'd0)
            regs[rd_addr] <= rd_data;
    end
endmodule
