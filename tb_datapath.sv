`timescale 1ns/1ps

// Self-checking testbench for the Phase 1 single-cycle datapath.
// Program under test (program.hex), in RISC-V assembly:
//
//   addi x1, x0, 5        x1  = 5
//   addi x2, x0, 10       x2  = 10
//   add  x3, x1, x2       x3  = 15
//   sub  x4, x2, x1       x4  = 5
//   and  x5, x1, x2       x5  = 0
//   or   x6, x1, x2       x6  = 15
//   xor  x7, x1, x2       x7  = 15
//   slt  x8, x1, x2       x8  = 1
//   addi x9, x0, -3       x9  = -3   (tests sign-extension)
//   andi x10, x1, 3       x10 = 1
//   ori  x11, x1, 8       x11 = 13

module tb_datapath;

    logic clk;
    logic rst_n;
    int   errors;

    datapath_top DUT (
        .clk   (clk),
        .rst_n (rst_n)
    );

    // 10ns clock period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic check(int reg_num, logic [31:0] expected, string name);
        logic [31:0] actual;
        actual = DUT.RF.regs[reg_num];
        if (actual !== expected) begin
            $display("FAIL: %-20s x%0d = %0d (0x%08h)  expected %0d (0x%08h)",
                      name, reg_num, actual, actual, expected, expected);
            errors++;
        end else begin
            $display("PASS: %-20s x%0d = %0d", name, reg_num, actual);
        end
    endtask

    initial begin
        errors = 0;
        rst_n  = 1'b0;
        repeat (2) @(posedge clk);
        rst_n  = 1'b1;

        // single-cycle core -> 1 instruction per clock; 11 instructions + margin
        repeat (15) @(posedge clk);

        $display("\n--- Register file check ---");
        check(1,  32'd5,           "addi x1,x0,5");
        check(2,  32'd10,          "addi x2,x0,10");
        check(3,  32'd15,          "add x3,x1,x2");
        check(4,  32'd5,           "sub x4,x2,x1");
        check(5,  32'd0,           "and x5,x1,x2");
        check(6,  32'd15,          "or x6,x1,x2");
        check(7,  32'd15,          "xor x7,x1,x2");
        check(8,  32'd1,           "slt x8,x1,x2");
        check(9,  32'hFFFF_FFFD,   "addi x9,x0,-3");
        check(10, 32'd1,           "andi x10,x1,3");
        check(11, 32'd13,          "ori x11,x1,8");

        if (errors == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** %0d TEST(S) FAILED ***\n", errors);

        $finish;
    end

endmodule
