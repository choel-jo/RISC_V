`timescale 1ns / 1ps
module RV32I_TOP (
    input logic clk,
    input logic reset
);
    logic [31:0] instr_code, instr_rAddr;
    logic [31:0] dAddr, dWData, dRdata;
    logic d_wr_en;
    logic [2:0] funct3;

    RV321_Core U_RV321_CPU (.*,
    .dRdata(dRdata));
    instr_mem U_Instr_Mem (.*);
    data_mem U_Data_Mem (
        .clk(clk),
        .d_wr_en(d_wr_en),
        .dAddr(dAddr),
        .dWData(dWData),
        .funct3(funct3),
        .dRdata(dRdata)
    );
endmodule

module RV321_Core (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr_code,
    input  logic [31:0] dRdata,
    output logic [31:0] instr_rAddr,
    output logic        d_wr_en,
    output logic [31:0] dAddr,
    output logic [31:0] dWData,
    output logic [ 2:0] funct3
);
    logic [3:0] alu_controls;
    logic reg_wr_en, w_aluSrcMuxSel, w_RegWdataSel;

    control_unit U_Control_Unit (
        .instr_code  (instr_code),
        .alu_controls(alu_controls),
        .reg_wr_en   (reg_wr_en),
        .aluSrcMuxSel(w_aluSrcMuxSel),
        .d_wr_en     (d_wr_en),
        .RegWdataSel (w_RegWdataSel),
        .funct3_out  (funct3),
        .branch     (branch)
    );
    datapath U_Data_Path (
        .clk         (clk),
        .reset       (reset),
        .instr_code  (instr_code),
        .alu_controls(alu_controls),
        .reg_wr_en   (reg_wr_en),
        .aluSrcMuxSel(w_aluSrcMuxSel),
        .RegWdataSel (w_RegWdataSel),
        .dRdata      (dRdata),
        .instr_rAddr (instr_rAddr),
        .dAddr       (dAddr),
        .dWData      (dWData),
        .branch      (branch)
    );
endmodule
