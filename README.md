# RV32I Single-Cycle Datapath — Phase 1

Part of a larger project to build a 5-stage pipelined RV32I RISC-V core in
SystemVerilog. Phase 1 is the single-cycle version: get the fetch → decode →
execute → write-back loop *correct* before introducing pipelining.

## What's implemented

| Type   | Instructions                       |
|--------|-------------------------------------|
| R-type | ADD, SUB, AND, OR, XOR, SLT          |
| I-type | ADDI, ANDI, ORI                      |

Not yet implemented (coming in Phase 2): loads/stores, branches, jumps,
shifts, U-type instructions. The datapath is intentionally minimal right now
so the fetch/decode/execute/write-back path is rock solid before we add
pipeline registers and hazard logic on top of it.

## File structure

```
pc_reg.sv        Program counter register (pc <= pc+4 each cycle, no branches yet)
instr_mem.sv     Instruction memory, loaded from program.hex via $readmemh
reg_file.sv      32x32-bit register file, x0 hardwired to zero
imm_gen.sv       Sign-extends the I-type 12-bit immediate to 32 bits
alu.sv           ALU: AND / OR / ADD / SUB / XOR / SLT
alu_control.sv   Decodes funct3 (+ funct7 bit 5) into the ALU's internal op code
control_unit.sv  Decodes opcode into RegWrite / ALUSrc
datapath_top.sv  Wires everything above into the full datapath
program.hex      Hand-assembled RV32I test program (machine code, one word/line)
tb_datapath.sv   Self-checking testbench — runs program.hex and verifies every register
```

## The one subtlety worth understanding

`instr[30]` (funct7 bit 5) means "subtract instead of add" for R-type ADD/SUB
— but for I-type instructions like ADDI, bits [30:20] are just part of the
immediate value, not a funct7 field. A negative ADDI immediate (e.g. `addi
x9, x0, -3`) sets that same bit to 1. If you naively use `instr[30]` as a
universal "do subtract" flag, ADDI with a negative immediate silently turns
into a subtract instead of an add — a classic single-cycle CPU bug.

`alu_control.sv` fixes this by only honoring `instr[30]` when the opcode is
actually R-type:

```systemverilog
assign alt_func = funct7_b5 & (opcode == OPCODE_RTYPE);
```

The testbench specifically includes `addi x9, x0, -3` to catch a regression
here.

## Test program (program.hex)

```asm
addi x1, x0, 5        x1  = 5
addi x2, x0, 10       x2  = 10
add  x3, x1, x2       x3  = 15
sub  x4, x2, x1       x4  = 5
and  x5, x1, x2       x5  = 0
or   x6, x1, x2       x6  = 15
xor  x7, x1, x2       x7  = 15
slt  x8, x1, x2       x8  = 1
addi x9, x0, -3       x9  = -3   (sign-extension check)
andi x10, x1, 3       x10 = 1
ori  x11, x1, 8       x11 = 13
```

## How to run

**Local (Icarus Verilog):**
```bash
iverilog -g2012 -o sim.vvp pc_reg.sv instr_mem.sv reg_file.sv imm_gen.sv \
    alu.sv alu_control.sv control_unit.sv datapath_top.sv tb_datapath.sv
vvp sim.vvp
```

**EDA Playground:** create a new project, set the testbench to `tb_datapath.sv`
and the design files to the rest, simulator = Icarus Verilog 12+, and run.
Make sure `program.hex` is added as one of the project files (EDA Playground
reads it like any other uploaded file).

## Verified result

```
--- Register file check ---
PASS: addi x1,x0,5         x1 = 5
PASS: addi x2,x0,10        x2 = 10
PASS: add x3,x1,x2         x3 = 15
PASS: sub x4,x2,x1         x4 = 5
PASS: and x5,x1,x2         x5 = 0
PASS: or x6,x1,x2          x6 = 15
PASS: xor x7,x1,x2         x7 = 15
PASS: slt x8,x1,x2         x8 = 1
PASS: addi x9,x0,-3        x9 = 4294967293   (= 0xFFFFFFFD = -3 in two's complement)
PASS: andi x10,x1,3        x10 = 1
PASS: ori x11,x1,8         x11 = 13

*** ALL TESTS PASSED ***
```

## Next: Phase 2

Add S-type/B-type/J-type/U-type immediates, a data memory, branch
comparison logic, and PC-relative addressing for loads/stores, branches
and jumps.
