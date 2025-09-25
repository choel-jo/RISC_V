`timescale 1ns / 1ps

// ROM
module instr_mem (
    input  logic [31:0] instr_rAddr,
    output logic [31:0] instr_code
);
    logic [31:0] rom[0:63];

    
    initial begin
        // rom [0] = 32'h004182B3; //32'b0000_0000_0100_0001_1000_0010_1011_0011; // add x5, x3, x4
        // rom [1] = 32'h409403B3; //32'b0100_0000_1001_0100_0000_0011_1011_0011; // sub x7, x3, x4
        // // 32'b imm[7](7bit) _rs2(5bit) _ rs1(5bit) _ funct(3bit) _ imm(5bit) _ opcode(7'b0100011)
        // rom [3] = 32'h00e00223;     // sb x14, 4(x0) 0000000_01110_00000_000_00100_0100011 / imm = 4
        // rom [4] = 32'h01701423;     // sh x23, 8(x0) 0000000_10111_00000_001_01000_0100011 / rs2 = 10111 / rs1 = 00000
        // rom[5] = 32'h01802623;  // sw x24, 12(x0)

        // IL-Type
        // 32'b00000001100_00010_010_00101_0000011;

       //rom [0] = 32'h00C1_2283;     // LW x5, 12(x2) 000000001100_00010_010_00101_0000011 / imm = 6 / rs1 = 2 / rs2 = 12 / LW동작
        // X5에 있는 값을 x2의 +8위치에 저장

        rom [0] = 32'h00C3_0213; //addi x8, x6, 12 -> rs1의 값과 imm을 더해서 rd에 저장한다.
        /*
        1. ADDI
            1) 32'b000000001100(imm)_00110(rs1)_000(func3)_00100(rd)_0010011(opcode) 
            2) imm = 12 (1100)
            3) rs1 = 6
            4) funct3 = 000
            5) rd = 8
            6) opcode = I=type(1100100)
        - 예상 저장값 = 18
        - 예상 저장위치 = x4
        */

        rom [1] = 32'h00C3_2213; //addi x8, x6, 12 -> rs1의 값과 imm을 더해서 rd에 저장한다.
        /*
        2. SLTI
            1) 32'b000000001100(imm)_00110(rs1)_010(func3)_00100(rd)_0010011(opcode) 
            2) imm = 12 (100101)
            3) rs1 = 6
            4) funct3 = 010
            5) rd = 4
            6) opcode = I=type(1100100)
            7) 동작 : rd = (rs1 < imm) ? 1 : 0 -> rs1이랑 imm이랑 비교해서 imm이 더 크면 1 저장
        - 예상 저장값 = 1
        - 예상 저장위치 = x4
        */

        rom [2] = 32'h00C3_3213; //SLTIU r = (rd1 < imm) ? 1: 0
        /*
        3. SLTIU
            1) 32'b000000001100(imm)_00110(rs1)_011(func3)_00100(rd)_0010011(opcode)
            2) imm = 12 (1100)
            3) rs1 = 6
            4) funct3 = 011
            5) rd = 4
            6) opcode = I=type(1100100)
        - 예상 저장값 = 18
        - 예상 저장위치 = x4
        */

        rom [3] = 32'h00C3_4213; // XORI rd = rs1 ^ imm
        /*
        4. XORI
            1) 32'b000000001100(imm)_00110(rs1)_100(func3)_00100(rd)_0010011(opcode)   
            2) imm = 12 (1100)
            3) rs1 = 6
            4) funct3 = 100
            5) rd = 4
            6) opcode = I=type(1100100)
        - 예상 저장값 = 18
        - 예상 저장위치 = x4
        */

        rom [4] = 32'h00C3_6213; // ORI : rd = rs1 | imm
        /*
        5. ORI
            1) 32'b000000001100(imm)_00110(rs1)_110(func3)_00100(rd)_0010011(opcode)
            2) imm = 12 (1100)
            3) rs1 = 6
            4) funct3 = 110
            5) rd = 4
            6) opcode = I=type(1100100)
        - 예상 저장값 = 14
        - 예상 저장위치 = x4
        */

        rom [5] = 32'h00C3_7213; //ANDI rd = rs1 & imm
        /*
        6. ANDI
            1) 32'b000000001100(imm)_00110(rs1)_111(func3)_00100(rd)_0010011(opcode) 
            2) imm = 12 (1100)
            3) rs1 = 6
            4) funct3 = 111
            5) rd = 4
            6) opcode = I=type(1100100)
        - 예상 저장값 = 4
        - 예상 저장위치 = x4
        */
    
    end
    assign instr_code = rom[instr_rAddr[31:2]];
endmodule

/*
명령어	funct3	저장 크기	예시 동작
SB	000	1 Byte (8bit)	Mem[addr] = rs2[7:0]
SH	001	2 Byte (16bit)	Mem[addr..addr+1] = rs2[15:0]
SW	010	4 Byte (32bit)	Mem[addr..addr+3] = rs2[31:0]
*/

/*
SLTI :  32'b000000001110(imm)_00110(rs1)_010(func3)_01000(rd)_0010011(opcode)
SLTIU : 32'b000000001110(imm)_00110(rs1)_011(func3)_01000(rd)_0010011(opcode)
XORI :  32'b101001001110(imm)_00110(rs1)_100(func3)_01000(rd)_0010011(opcode)
ORI :   32'b010100001110(imm)_00110(rs1)_110(func3)_01000(rd)_0010011(opcode)
ANDI :  32'b010001011010(imm)_00110(rs1)_111(func3)_01000(rd)_0010011(opcode)

SLLI :  32'b0000000_00000(shamt)_00110(rs1)_001(func3)_01000(rd)_0010011(opcode)
SRLI :  32'b0000000_00000(shamt)_00110(rs1)_101(func3)_01000(rd)_0010011(opcode)
SRAI :  32'b0100000_00000(shamt)_00110(rs1)_111(func3)_01000(rd)_0010011(opcode)

*/
