`timescale 1ns / 1ps

`include "define.sv"

module datapath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr_code,
    input  logic [ 3:0] alu_controls,
    input  logic        reg_wr_en,
    input  logic        aluSrcMuxSel,
    input  logic        RegWdataSel,
    input  logic        branch,
    input  logic [31:0] dRdata,
    output logic [31:0] instr_rAddr,
    output logic [31:0] dAddr,
    output logic [31:0] dWData
);

    logic [31:0] w_regfile_rd1, w_regfile_rd2, w_alu_result;
    logic [31:0]
        w_imm_ext, w_aluSrcMux_out, w_RegWdataout, w_pc_MuxOut, w_pc_Next;
    logic pc_MuxSel, btaken;

    assign dAddr = w_alu_result;
    assign dWData = w_regfile_rd2;
    assign pc_MuxSel = branch & btaken;

    mux_2x1 U_PC_MUX (
        .sel(pc_MuxSel),
        .x0 (32'd4),       // 0 : 4
        .x1 (w_imm_ext),   // 1 : imm_ext
        .y  (w_pc_MuxOut)  // to ALU R2
    );

    pc_adder U_PC_ADDER (
        .a  (instr_rAddr),
        .b  (w_pc_MuxOut),
        .sum(w_pc_Next)
    );

    program_counter U_PC (
        .clk    (clk),
        .reset  (reset),
        .pc_Next(w_pc_Next),
        .pc     (instr_rAddr)
    );

    register_file U_REG_FILE (
        .clk      (clk),
        .RA1      (instr_code[19:15]),  // read address 1
        .RA2      (instr_code[24:20]),  // read address 2
        .WA       (instr_code[11:7]),   // write address
        .reg_wr_en(reg_wr_en),          // write enable
        .WData    (w_RegWdataout),      // write data
        .RD1      (w_regfile_rd1),      // read data 1
        .RD2      (w_regfile_rd2)       // read data 2
    );
    
    mux_2x1 U_RegWdataMux (
        .sel(RegWdataSel),
        .x0 (w_alu_result),  // 0 : regFile R2
        .x1 (dRdata),        // 1 : imm[31:0]
        .y  (w_RegWdataout)  // to ALU R2
    );

    ALU U_ALU (
        .a           (w_regfile_rd1),
        .b           (w_aluSrcMux_out),
        .alu_controls(alu_controls),
        .alu_result  (w_alu_result),
        .btaken      (btaken)
    );

    mux_2x1 U_AluSrcMux (
        .sel(aluSrcMuxSel),
        .x0 (w_regfile_rd2),   // 0 : regFile R2
        .x1 (w_imm_ext),       // 1 : imm[31:0]
        .y  (w_aluSrcMux_out)  // to ALU R2
    );

    extend U_Extend (
        .instr_code(instr_code),
        .imm_Ext   (w_imm_ext)
    );
endmodule

module program_counter (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] pc_Next,
    output logic [31:0] pc
);

    register U_PC_REG (
        .clk(clk),
        .reset(reset),
        .d(pc_Next),
        .q(pc)
    );
endmodule
module register (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] d,
    output logic [31:0] q
);

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else begin
            q <= d;
        end
    end

endmodule

module register_file (
    input  logic        clk,
    input  logic [ 4:0] RA1,        // read address 1
    input  logic [ 4:0] RA2,        // read address 2
    input  logic [ 4:0] WA,         // write address
    input  logic        reg_wr_en,  // write enable
    input  logic [31:0] WData,      // write data
    output logic [31:0] RD1,        // read data 1
    output logic [31:0] RD2         // read data 2
);

    logic [31:0] reg_file[0:31];  // 32bit 32개.

    initial begin
        reg_file[0]  = 32'd0;
        reg_file[1]  = 32'd1;
        reg_file[2]  = 32'd2;
        reg_file[3]  = 32'd3;
        reg_file[4]  = 32'd4;
        reg_file[5]  = 32'd5;
        reg_file[6]  = 32'd6;
        reg_file[7]  = 32'd7;
        reg_file[8]  = 32'd8;
        reg_file[9]  = 32'd9;
        reg_file[10] = 32'd10;
        reg_file[11] = 32'd11;
        reg_file[12] = 32'd12;
        reg_file[13] = 32'd13;
        reg_file[14] = 32'd14;
        reg_file[15] = 32'd15;
        reg_file[16] = 32'd16;
        reg_file[17] = 32'd17;
        reg_file[18] = 32'd18;
    end

    always_ff @(posedge clk) begin
        if (reg_wr_en) begin
            reg_file[WA] <= WData;
        end
    end

    assign RD1 = (RA1 != 0) ? reg_file[RA1] : 0;
    assign RD2 = (RA2 != 0) ? reg_file[RA2] : 0;

endmodule

module ALU (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [ 3:0] alu_controls,
    output logic [31:0] alu_result,
    output logic        btaken
);
    always_comb begin
        case (alu_controls)
            `ADD: alu_result = a + b;
            `SUB: alu_result = a - b;
            `SLL: alu_result = a << b[4:0];
            `SRL: alu_result = a >> b[4:0];  // 0으로 extend
            `SRA: alu_result = $signed(a) >>> b[4:0];  // [31] extend by signed 
            `SLT: alu_result = $signed(a) < $signed(b) ? 1 : 0;
            `SLTU: alu_result = a < b ? 1 : 0;
            `XOR: alu_result = a ^ b;
            `OR: alu_result = a | b;
            `AND: alu_result = a & b;
            default: alu_result = 32'bx;
        endcase
    end

    // branch
    always_comb begin
        case (alu_controls[2:0])
            `BEQ: btaken = ($signed(a) == $signed(b));
            `BNE: btaken = ($signed(a) != $signed(b));
            `BLT: btaken = ($signed(a) < $signed(b));
            `BGE: btaken = ($signed(a) >= $signed(b));
            `BLTU: btaken = ($unsigned(a) < $unsigned(b));
            `BGEU: btaken = ($unsigned(a) >= $unsigned(b));
            default: btaken = 1'b0;
        endcase
    end

endmodule

module extend (
    input  logic [31:0] instr_code,
    output logic [31:0] imm_Ext
);

    wire [6:0] opcode = instr_code[6:0];
    wire [2:0] funct3 = instr_code[14:12];

    always_comb begin
        case (opcode)
            `OP_R_TYPE: imm_Ext = 32'bx;
            // 20 literal 1b'0, imm[11:5] 7bit, imm[4:0] 5bit
            `OP_S_TYPE:
            imm_Ext = {
                {20{instr_code[31]}}, instr_code[31:25], instr_code[11:7]
            };
            `OP_IL_TYPE: imm_Ext = {{20{instr_code[31]}}, instr_code[31:20]};
            `OP_I_TYPE: begin
                // 011 3인 경우만 signed extend 하고 나머지는 
                if (funct3 == 3'b011) imm_Ext = {{20'b0}, instr_code[31:20]};
                else imm_Ext = {{20{instr_code[31]}}, instr_code[31:20]};
            end
            `OP_B_TYPE:
            imm_Ext = {
                {20{instr_code[31]}},
                instr_code[31],
                instr_code[7],
                instr_code[30:25],
                instr_code[11:8],
                1'b0
            };
            default: imm_Ext = 32'bx;
        endcase
    end
endmodule

module mux_2x1 (
    input               sel,
    input  logic [31:0] x0,   // 0 : regFile R2
    input  logic [31:0] x1,   // 1 : imm[31:0]
    output logic [31:0] y     // to ALU R2
);

    assign y = sel ? x1 : x0;
endmodule

module pc_adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] sum
);
    assign sum = a + b;
endmodule
