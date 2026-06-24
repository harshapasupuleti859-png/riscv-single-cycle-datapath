// Single-cycle RV32I datapath -- Phase 1
// Supports: R-type {ADD, SUB, AND, OR, XOR, SLT}
//           I-type  {ADDI, ANDI, ORI}
// Loads, stores, branches, jumps are NOT yet implemented (that's Phase 2).
module datapath_top (
    input  logic clk,
    input  logic rst_n
);
    logic [31:0] pc, pc_next, instr;
    logic [31:0] rs1_data, rs2_data, alu_b, alu_result, imm_ext, wb_data;
    logic        reg_write, alu_src, zero;
    logic [3:0]  alu_op;

    // Phase 1: every instruction is sequential, so PC always just moves on by 4
    assign pc_next = pc + 32'd4;

    pc_reg PC (
        .clk     (clk),
        .rst_n   (rst_n),
        .pc_next (pc_next),
        .pc_out  (pc)
    );

    instr_mem IMEM (
        .addr  (pc),
        .instr (instr)
    );

    control_unit CU (
        .opcode    (instr[6:0]),
        .reg_write (reg_write),
        .alu_src   (alu_src)
    );

    alu_control ALUCTRL (
        .opcode    (instr[6:0]),
        .funct3    (instr[14:12]),
        .funct7_b5 (instr[30]),
        .alu_op    (alu_op)
    );

    imm_gen IMM (
        .instr   (instr),
        .imm_out (imm_ext)
    );

    reg_file RF (
        .clk       (clk),
        .rst_n     (rst_n),
        .reg_write (reg_write),
        .rs1_addr  (instr[19:15]),
        .rs2_addr  (instr[24:20]),
        .rd_addr   (instr[11:7]),
        .rd_data   (wb_data),
        .rs1_data  (rs1_data),
        .rs2_data  (rs2_data)
    );

    assign alu_b = alu_src ? imm_ext : rs2_data;

    alu ALU (
        .a      (rs1_data),
        .b      (alu_b),
        .alu_op (alu_op),
        .result (alu_result),
        .zero   (zero)
    );

    // Phase 1: no loads yet, so the ALU result is always what gets written back
    assign wb_data = alu_result;

endmodule
