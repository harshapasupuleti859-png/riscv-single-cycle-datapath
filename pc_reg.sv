// Program Counter register
// Phase 1: no branches/jumps yet, so pc_next is always pc+4 (computed in top module)
module pc_reg (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] pc_next,
    output logic [31:0] pc_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc_out <= 32'h0000_0000;
        else
            pc_out <= pc_next;
    end
endmodule
