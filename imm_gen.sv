// Immediate generator
// Phase 1 only needs the I-type immediate (used by ADDI/ANDI/ORI).
// We'll extend this with S-type/B-type/U-type/J-type immediates in Phase 2.
module imm_gen (
    input  logic [31:0] instr,
    output logic [31:0] imm_out
);
    // I-type immediate lives in instr[31:20], sign-extended to 32 bits
    assign imm_out = {{20{instr[31]}}, instr[31:20]};
endmodule
