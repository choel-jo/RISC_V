`timescale 1ns / 1ps

`include "Define.sv"

module control_unit (
    input  logic [31:0] instr_code,         // ROM으로부터 받는 32bit 데이터
    output logic [3:0] alu_controls,        // alu컨트롤 신호 : 
    output logic        aluSrcMuxSel,
    output logic        reg_wr_en,
    output logic        d_wr_en,
    output logic        RegWdataSel,
    output logic [2:0] funct3_out,
    output logic        branch
);

    //    rom [0] = 32'h004182B3; //32'b0000_0000_0100_0001_1000_0010_1011_0011; // add x5, x3, x4
    wire  [6:0] funct7 = instr_code[31:25];
    wire  [2:0] funct3 = instr_code[14:12];
    wire  [6:0] opcode = instr_code[6:0];

    logic [5:0] controls;

    assign {RegWdataSel, aluSrcMuxSel, reg_wr_en, d_wr_en, branch} = controls;
    assign funct3_out = funct3;

    always_comb begin
        case (opcode)
            // RegWdataSel, aluSrcMuxsel, reg_wr_en, d_wr_en
            `OP_R_TYPE  : controls = 5'b00100;  // R-type
            `OP_S_TYPE  : controls = 5'b01010;  // S-type
            `OP_IL_TYPE : controls = 5'b11100;  // IL_type
            `OP_I_TYPE  : controls = 5'b01100;  // I_type
            `OP_B_TYPE  : controls = 5'b00001;  //Rs1과 Rs2와 연산하는 것이므로 alu_cnt는 0이 된다.
            default: controls = 5'b00000;
        endcase
    end


    always_comb begin
        case (opcode)
            // {function [5], function[2:0]} 
            `OP_R_TYPE: alu_controls = {funct7[5], funct3};  // R-type
            `OP_S_TYPE: alu_controls = `ADD;  // S-type 주소 계산 rs1 + imm
            `OP_IL_TYPE: alu_controls = `ADD;  // S-type 주소 계산 rs1 + imm
            `OP_I_TYPE: begin
                if({funct7[5], funct3} == 4'b1101)
                    alu_controls = {1'b1, funct3};
                else alu_controls = {funct7[5], funct3};  // S-type 주소 계산 rs1 + imm
            end
            `OP_B_TYPE : alu_controls = {1'b0, funct3}; // B_type
            default:    alu_controls = 4'bx;
        endcase
    end


endmodule
