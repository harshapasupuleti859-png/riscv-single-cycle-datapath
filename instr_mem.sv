// Instruction memory (read-only for the core; "loaded" like a ROM)
// addr is a byte address (word-aligned); we index by addr[31:2] to get the word.
module instr_mem #(
    parameter int MEM_DEPTH = 256
)(
    input  logic [31:0] addr,
    output logic [31:0] instr
);
    logic [31:0] mem [0:MEM_DEPTH-1];

    initial begin
        // Pre-fill with canonical RISC-V NOP (addi x0,x0,0 = 0x00000013)
        // so that any instructions fetched past the end of our program are
        // harmless no-ops instead of unknown 'x' values.
        for (int i = 0; i < MEM_DEPTH; i++)
            mem[i] = 32'h0000_0013;

        // Overwrite the first N words with our actual test program.
        // $readmemh only writes as many lines as the file contains,
        // so everything past it stays NOP from the loop above.
        $readmemh("program.hex", mem);
    end

    assign instr = mem[addr[31:2]];
endmodule
