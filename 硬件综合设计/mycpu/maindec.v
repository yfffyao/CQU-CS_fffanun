`timescale 1ns / 1ps

`include"defines.vh"

module maindec(
        input wire [5:0] op,
        input wire [5:0] funct,
        input wire [4:0] rs,
        input wire [4:0] rt,

        output wire memtoreg,memwrite,
        output wire branch,alusrc,
        output wire regdst,regwrite,
        output wire jump,
        output wire hilo_write,    //是否写入hi_lo寄存器
        output wire jal,jr,bal,
        output wire memen,
        output wire cp0we,
        output reg invalid
        );

        reg [11:0] controls;

        assign cp0we=((op==`EXE_CP0)&(rs==`RS_MTC0))?1:0;

        assign {memtoreg,memwrite,
                branch,alusrc,
                regdst,regwrite,
                jump,hilo_write,
                jal,jr,bal,
                memen} = controls;
               
        always @(*) begin
                invalid <= 0;
                case(op)
                // 访存
                `EXE_LB:controls <= `CONTROLS_LB;
                `EXE_LBU:controls <= `CONTROLS_LBU;
                `EXE_LH:controls <= `CONTROLS_LH;
                `EXE_LHU:controls <= `CONTROLS_LHU;
                `EXE_LW:controls <= `CONTROLS_LW;
                `EXE_SB:controls <= `CONTROLS_SB;
                `EXE_SH:controls <= `CONTROLS_SH;
                `EXE_SW:controls <= `CONTROLS_SW;

                // 有立即数的逻辑指令
                `EXE_ANDI:controls <= `CONTROLS_ANDI;
                `EXE_ORI:controls <= `CONTROLS_ORI;
                `EXE_XORI:controls <= `CONTROLS_XORI;
                `EXE_LUI:controls <= `CONTROLS_LUI;

                // 有立即数的算数运算指令
                `EXE_SLTI:controls <= `CONTROLS_SLTI;
                `EXE_SLTIU:controls <= `CONTROLS_SLTIU;
                `EXE_ADDI:controls <= `CONTROLS_ADDI;
                `EXE_ADDIU:controls <= `CONTROLS_ADDIU;

                // 跳转指令
                `EXE_J: controls <= `CONTROLS_J;
                `EXE_JAL: controls <= `CONTROLS_JAL;
                `EXE_BEQ: controls <= `CONTROLS_BEQ;
                `EXE_BGTZ: controls <= `CONTROLS_BGTZ;
                `EXE_BLEZ: controls <= `CONTROLS_BLEZ;
                `EXE_BNE: controls <= `CONTROLS_BNE;

                // op = 6'b000000
                `EXE_SPECIAL_INST:case(funct)
                        // 逻辑运算
                        `EXE_AND:controls <= `CONTROLS_AND;
                        `EXE_OR:controls <= `CONTROLS_OR;
                        `EXE_XOR:controls <= `CONTROLS_XOR;
                        `EXE_NOR:controls <= `CONTROLS_NOR;
                        // 移位指令
                        `EXE_SLL:controls <= `CONTROLS_SLL;
                        `EXE_SLLV:controls <= `CONTROLS_SLLV;
                        `EXE_SRL:controls <= `CONTROLS_SRL;
                        `EXE_SRLV:controls <= `CONTROLS_SRLV;
                        `EXE_SRA:controls <= `CONTROLS_SRA;
                        `EXE_SRAV:controls <= `CONTROLS_SRAV;
                        // 数据移动指令
                        `EXE_MFHI:controls <= `CONTROLS_MFHI;
                        `EXE_MTHI:controls <= `CONTROLS_MTHI;
                        `EXE_MFLO:controls <= `CONTROLS_MFLO;
                        `EXE_MTLO:controls <= `CONTROLS_MTLO;
                        // 算数运算指令
                        `EXE_SLT:controls <= `CONTROLS_SLT;
                        `EXE_SLTU:controls <= `CONTROLS_SLTU;
                        `EXE_ADD:controls <= `CONTROLS_ADD;
                        `EXE_ADDU:controls <= `CONTROLS_ADDU;
                        `EXE_SUB:controls <= `CONTROLS_SUB;
                        `EXE_SUBU:controls <= `CONTROLS_SUBU;
                        `EXE_MULT:controls <= `CONTROLS_MULT;
                        `EXE_MULTU:controls <= `CONTROLS_MULTU;
                        `EXE_DIV:controls <= `CONTROLS_DIV;
                        `EXE_DIVU:controls <= `CONTROLS_DIVU;
                        // jr、jalr
                        `EXE_JR:controls <= `CONTROLS_JR;
                        `EXE_JALR:controls <= `CONTROLS_JALR;
                        // 自陷指令
                        `EXE_BREAK:controls <= `CONTROLS_BREAK;
                        `EXE_SYSCALL:controls <=`CONTROLS_SYSCALL;

                        default: begin
                                controls <= `CONTROLS_NOP;
                                invalid <= 1;
                        end
                        endcase
                `EXE_REGIMM_INST: case(rt)
                        //branch bltz,bltzal,bgez,bgezal
                        `EXE_BLTZ: controls <= `CONTROLS_BLTZ;
                        `EXE_BLTZAL: controls <= `CONTROLS_BLTZAL;
                        `EXE_BGEZ: controls <= `CONTROLS_BGEZ;
                        `EXE_BGEZAL: controls <= `CONTROLS_BGEZAL;
                        default:begin
                                controls <= `CONTROLS_NOP;
                                invalid <= 1;
                        end
                        endcase
                // 特权指令
                `EXE_CP0:case(rs)
                        `RS_MTC0: controls <= `CONTROLS_MTC0;
                        `RS_MFC0: controls <= `CONTROLS_MFC0;
                        `RS_ERET: controls <= `CONTROLS_ERET;
                        default: begin
                                controls <= `CONTROLS_NOP;
                                invalid <= 1;
                        end
                        endcase
                default: begin
                        controls <= `CONTROLS_NOP;
                        invalid <= 1;
                end
        endcase
        end
endmodule

