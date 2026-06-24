// Main control unit
// Phase 1 only has two opcodes: R-type and I-type (arithmetic).
// We'll add MemRead/MemWrite/Branch control bits in Phase 2 once
// loads, stores and branches show up.
module control_unit (
    input  logic [6:0] opcode,
    output logic       reg_write,
    output logic       alu_src     // 0 = ALU's 2nd operand is rs2, 1 = immediate
);
    localparam logic [6:0] OPCODE_RTYPE = 7'b0110011;
    localparam logic [6:0] OPCODE_ITYPE = 7'b0010011;

    always_comb begin
        case (opcode)
            OPCODE_RTYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;
            end
            OPCODE_ITYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
            end
            default: begin
                reg_write = 1'b0;
                alu_src   = 1'b0;
            end
        endcase
    end
endmodule
