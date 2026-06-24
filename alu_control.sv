// ALU control: turns funct3 (+ the funct7 bit5 "alt function" bit) into
// the 4-bit alu_op that the ALU understands.
//
// IMPORTANT subtlety: instr[30] (funct7 bit 5) only means "subtract instead
// of add" for R-type instructions (ADD vs SUB). For I-type instructions
// (e.g. ADDI), bits[30:20] are just part of the immediate value, NOT a
// funct7 field -- so a negative ADDI immediate must NOT be misread as SUB.
// We fix this by only honoring instr[30] when opcode is actually R-type.
module alu_control (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic       funct7_b5,
    output logic [3:0] alu_op
);
    localparam logic [6:0] OPCODE_RTYPE = 7'b0110011;

    logic alt_func;
    assign alt_func = funct7_b5 & (opcode == OPCODE_RTYPE);

    always_comb begin
        case (funct3)
            3'b000:  alu_op = alt_func ? 4'b0110 : 4'b0010; // SUB : ADD/ADDI
            3'b111:  alu_op = 4'b0000;                       // AND/ANDI
            3'b110:  alu_op = 4'b0001;                       // OR/ORI
            3'b100:  alu_op = 4'b0100;                       // XOR
            3'b010:  alu_op = 4'b0111;                       // SLT
            default: alu_op = 4'b0010;                       // default to ADD
        endcase
    end
endmodule
