// Arithmetic Logic Unit
// alu_op encoding is our own internal convention (set by alu_control.sv):
//   0000 = AND   0001 = OR    0010 = ADD
//   0100 = XOR   0110 = SUB   0111 = SLT (signed less-than)
module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  alu_op,
    output logic [31:0] result,
    output logic        zero
);
    always_comb begin
        case (alu_op)
            4'b0000: result = a & b;
            4'b0001: result = a | b;
            4'b0010: result = a + b;
            4'b0100: result = a ^ b;
            4'b0110: result = a - b;
            4'b0111: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            default: result = 32'd0;
        endcase
    end

    assign zero = (result == 32'd0);
endmodule
