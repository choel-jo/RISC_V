`timescale 1ns / 1ps

module tb_RV32I();
    logic clk = 0, reset = 1;

    RV32I_TOP dut(.*);

    always #5 clk = ~clk;

    initial begin
        #10;
        reset = 0;
        #100;
        $stop;
    end
endmodule
