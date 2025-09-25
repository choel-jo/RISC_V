`timescale 1ns / 1ps
module data_mem (
    input  logic        clk,
    input  logic        d_wr_en,            //1이면 쓰기동작, 0이면 읽기동작
    input  logic [31:0] dAddr,              // 메모리주소(여기선 워드 단위 주소로 사용됨)
    input  logic [31:0] dWData,            // 메모리에 쓸 데이터(Rs2값)
    input  logic [ 2:0] funct3,             // 명령어 구분
    output logic [31:0] dRdata              // 메모리에서 읽은 데이터(rd에 들어감)
);

    logic [31:0] data_mem[0:15];            //RAM메모리
    logic [31:0] current_data;              // 현재 데이터

    initial begin
        for (int i = 0 ; i < 16 ; i++ ) begin
            data_mem[i] = i + 32'h8765_4321;
        end
    end

    always_comb begin
        if (d_wr_en) begin
            current_data = data_mem[dAddr];
            case (funct3)    
                3'b010 : dRdata = {data_mem[dAddr+3], data_mem[dAddr+2], data_mem[dAddr+1], data_mem[dAddr]}; // LW;
                default: dRdata = 32'b0;
            endcase
        end
    end
    assign dRdata = data_mem[dAddr];
endmodule

/*
always_comb begin
    case (funct3)
        3'b000: dRdata = {{24{data_mem[dAddr][7]}}, data_mem[dAddr]}; // LB
        3'b100: dRdata = {24'b0, data_mem[dAddr]};                    // LBU
        3'b001: dRdata = {{16{data_mem[dAddr+1][7]}}, data_mem[dAddr+1], data_mem[dAddr]}; // LH
        3'b101: dRdata = {16'b0, data_mem[dAddr+1], data_mem[dAddr]};                     // LHU
        3'b010: dRdata = {data_mem[dAddr+3], data_mem[dAddr+2], data_mem[dAddr+1], data_mem[dAddr]}; // LW
        default: dRdata = 32'b0;
    endcase
end

LW는 쓰기 동작이 아니라 읽기 동작이므로 always_ff 안에 넣으면 안 됨

assign dRdata = data_mem[dAddr]; 같은 방식으로 읽기 전용 로직을 작성해야 함

메모리를 워드 단위로 둘 수도 있지만, 실제 CPU와 맞추려면 바이트 배열로 선언해서 주소를 바이트 단위로 쓰는 게 더 자연스럽다.
*/
