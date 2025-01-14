`timescale 1ns / 1ps

`include"defines.vh"
module alu(
    input wire clk,rst,
    input wire [31:0] a,b,
    input wire [7:0] alucontrol,
    input wire [4:0] sa,
    
    input wire [63:0] hilo_in,
    input wire [31:0] cp0data,

    output reg [31:0] result,
    output reg [63:0] hilo_out,
    output wire overflow,
    output reg stall_div
    );

    //乘法
    wire [31:0] mult_a,mult_b;
    reg [63:0] mul_result;
    // 如果是有符号乘法且是负数则取补码
    assign mult_a = ((alucontrol==`EXE_MULT_OP)&&(a[31]==1'b1))?(~a+1):a;
    assign mult_b = ((alucontrol==`EXE_MULT_OP)&&(b[31]==1'b1))?(~b+1):b;

    //除法
    reg start_div,div_sign;
    wire div_ready;
    wire [63:0] div_result;
    div module_div (
        .clk(clk),
        .rst(rst),
        .sign(div_sign),
        .a(a),
        .b(b),
        .start_i(start_div),
        .annul_i(1'b0),
        .result(div_result),
        .ready_out(div_ready)
    );

    always @(*) begin
        start_div <= 1'b0;
        div_sign <= 1'b0;
        stall_div <=1'b0;
        case(alucontrol)
            // 逻辑运算
            `EXE_AND_OP: result <= a & b;
            `EXE_OR_OP: result <= a | b;
            `EXE_XOR_OP: result <= a ^ b;
            `EXE_NOR_OP: result <= ~(a|b);
            `EXE_ANDI_OP: result <= a & b;
            `EXE_ORI_OP: result <= a | b;
            `EXE_XORI_OP: result <= a ^ b;
            `EXE_LUI_OP: result <= {b[15:0],16'b0};
            // 移位
            `EXE_SLL_OP: result <= b << sa;
            `EXE_SRL_OP: result <= b >> sa;
            `EXE_SRA_OP: result <= $signed(b) >>> sa[4:0];
            
            `EXE_SLLV_OP: result <= b << a[4:0];
            `EXE_SRLV_OP: result <= b >> a[4:0];
            `EXE_SRAV_OP: result <= $signed(b) >>> a[4:0];
            
           
            // 计算访存虚地�?
            `EXE_LB_OP: result <= a + b;
            `EXE_LBU_OP: result <= a + b;
            `EXE_LH_OP: result <= a + b;
            `EXE_LHU_OP: result <= a + b;
            `EXE_LW_OP: result <= a + b;
            `EXE_SB_OP: result <= a + b;
            `EXE_SH_OP: result <= a + b;
            `EXE_SW_OP: result <= a + b;
            // 算术运算
            `EXE_ADD_OP: result <= a + b;
            `EXE_ADDU_OP: result <= a + b;
            `EXE_ADDI_OP: result <= a + b;
            `EXE_ADDIU_OP: result <= a + b;
            `EXE_SUB_OP: result <= a - b;
            `EXE_SUBU_OP: result <= a - b;
            `EXE_SLT_OP: result <= $signed(a) < $signed(b);
            `EXE_SLTI_OP: begin 
                if(a[31]==1'b0)begin
                    if(b[31]==1'b1)begin result <= 1'b0;end
                    else if(a < b)begin result <= 1'b1;end
                    else begin result <= 1'b0;end
                end
                else begin
                    if(b[31]==1'b0)begin result <= 1'b1;end
                    else if(a < b)begin result <= 1'b1;end
                    else begin result <= 1'b0;end
                end
            end
            `EXE_SLTU_OP: result <= a < b;
            `EXE_SLTIU_OP: result <= a < b;
            // 乘法
            `EXE_MULT_OP: mul_result <= (a[31]^b[31] == 1'b1) ? ~(mult_a*mult_b)+1 : mult_a*mult_b;
            `EXE_MULTU_OP: mul_result <= a * b;
            // 除法的参数设�?
            `EXE_DIV_OP: begin
                if(div_ready == 1'b0) begin
                    start_div <= 1'b1;
                    div_sign <= 1'b1;
                    stall_div <=1'b1;
                end
                else if (div_ready == 1'b1) begin
                    start_div <= 1'b0;
                    div_sign <= 1'b1;
                    stall_div <=1'b0;
                end
                else begin
                    start_div <= 1'b0;
                    div_sign <= 1'b0;
                    stall_div <=1'b0;
                end
            end
            `EXE_DIVU_OP: begin
                if(div_ready == 1'b0) begin
                    start_div <= 1'b1;
                    div_sign <= 1'b0;
                    stall_div <=1'b1;
                end
                else if (div_ready == 1'b1) begin
                    start_div <= 1'b0;
                    div_sign <= 1'b0;
                    stall_div <=1'b0;
                end
                else begin
                    start_div <= 1'b0;
                    div_sign <= 1'b0;
                    stall_div <=1'b0;
                end
            end
            // 数据移动
            `EXE_MFHI_OP: result <= hilo_in[63:32];
            `EXE_MFLO_OP: result <= hilo_in[31:0];
            // 特权指令
            `EXE_MFC0_OP: result <= cp0data;
            `EXE_MTC0_OP: result <= b;
            default : result <= 32'b0;
        endcase
    end

    // 乘除法部分的赋�??
    always @(*) begin
        case(alucontrol)
            `EXE_MULT_OP,`EXE_MULTU_OP: hilo_out <= mul_result;
            `EXE_DIV_OP,`EXE_DIVU_OP: hilo_out <= div_result;
            `EXE_MTHI_OP: hilo_out <= {a[31:0],{hilo_in[31:0]}};
            `EXE_MTLO_OP: hilo_out <= {{hilo_in[63:32]},a[31:0]};
        endcase
    end
    
   // 只有add,addi,sub指令考虑溢出
    assign overflow = ((alucontrol==`EXE_ADD_OP)|(alucontrol==`EXE_ADDI_OP))?((a[31] & b[31] & ~result[31] )|( ~a[31] & ~b[31] & result[31])):
                        (alucontrol==`EXE_SUB_OP)?((a[31] & ~b[31]& ~result[31])| (~a[31] & b[31] & result[31])):
                        1'b0;

endmodule