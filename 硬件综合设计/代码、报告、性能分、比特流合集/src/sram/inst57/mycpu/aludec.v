`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:27:24
// Design Name: 
// Module Name: aludec 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include"defines.vh"

module aludec(  //alucontrol数量太多，3位不够
    input wire[5:0] op,
	input wire[5:0] funct,
	input wire[1:0] aluop,
	input wire[5:0] rsD,
	output reg[7:0] alucontrol
    );
	always @(*) begin
	case (op)
	        6'b001100:alucontrol <= `EXE_ANDI_OP;//andi
			6'b001110:alucontrol <= `EXE_XORI_OP;//xori
			6'b001111:alucontrol <= `EXE_LUI_OP;//lui
			6'b001101:alucontrol <= `EXE_ORI_OP;//ori
			
			 `EXE_LB:alucontrol <= `EXE_LB_OP;
			 `EXE_LBU:alucontrol <= `EXE_LBU_OP;
			 `EXE_LH:alucontrol <= `EXE_LH_OP;
			 `EXE_LHU:alucontrol <= `EXE_LHU_OP;
			 `EXE_LW:alucontrol <= `EXE_LW_OP;
			 `EXE_SB:alucontrol <= `EXE_SB_OP;
			 `EXE_SH:alucontrol <= `EXE_SH_OP;
			 `EXE_SW:alucontrol <= `EXE_SW_OP;
			 
			 `EXE_ADDI:alucontrol <= `EXE_ADDI_OP;
			 `EXE_ADDIU:alucontrol <= `EXE_ADDIU_OP;
			 `EXE_SLTI:alucontrol <= `EXE_SLTI_OP;
			 `EXE_SLTIU:alucontrol <= `EXE_SLTIU_OP;
			
			6'b000000:case(funct)
			  `EXE_AND:alucontrol <= `EXE_AND_OP; 
				`EXE_OR:alucontrol <= `EXE_OR_OP; 
				`EXE_XOR :alucontrol <= `EXE_XOR_OP; 
				`EXE_NOR:alucontrol <= `EXE_NOR_OP;
				`EXE_SLL:alucontrol <= `EXE_SLL_OP;
				`EXE_SRL:alucontrol <= `EXE_SRL_OP;
				`EXE_SRA:alucontrol <= `EXE_SRA_OP;
				`EXE_SLLV:alucontrol <= `EXE_SLLV_OP;
				`EXE_SRLV:alucontrol <= `EXE_SRLV_OP;
				`EXE_SRAV:alucontrol <= `EXE_SRAV_OP;
				// 数据移动指令
                `EXE_MFHI:alucontrol <= `EXE_MFHI_OP;
                `EXE_MTHI:alucontrol <= `EXE_MTHI_OP;
                `EXE_MFLO:alucontrol <= `EXE_MFLO_OP;
                `EXE_MTLO:alucontrol <= `EXE_MTLO_OP;
                //算数
				`EXE_ADD:alucontrol <= `EXE_ADD_OP;
                `EXE_ADDU:alucontrol <= `EXE_ADDU_OP;
                `EXE_SUB:alucontrol <= `EXE_SUB_OP;
                `EXE_SUBU:alucontrol <= `EXE_SUBU_OP; 
                `EXE_SLT:alucontrol <= `EXE_SLT_OP;
                `EXE_SLTU:alucontrol <= `EXE_SLTU_OP;
                `EXE_MULT:alucontrol <= `EXE_MULT_OP;
                `EXE_MULTU:alucontrol <= `EXE_MULTU_OP;
                `EXE_DIV:alucontrol <= `EXE_DIV_OP;
                `EXE_DIVU:alucontrol <= `EXE_DIVU_OP;
		      default:  alucontrol <= 8'b00000000;
			
			endcase
			`EXE_CP0: case(rsD)
                  `RS_MTC0: alucontrol <= `EXE_MTC0_OP;
                  `RS_MFC0: alucontrol <= `EXE_MFC0_OP;
                  `RS_ERET: alucontrol <= `EXE_ERET_OP;
                  default: alucontrol <=8'b00000000;
        endcase
			default:alucontrol <= 8'b00000000;
			endcase
		/*case (aluop)
			2'b00: alucontrol <= 3'b010;//add (for lw/sw/addi)
			2'b01: alucontrol <= 3'b110;//sub (for beq)
			default : case (funct)
				6'b100000:alucontrol <= 3'b010; //add
				6'b100010:alucontrol <= 3'b110; //sub
				6'b100100:alucontrol <= 3'b000; //and
				6'b100101:alucontrol <= 3'b001; //or
				6'b101010:alucontrol <= 3'b111; //slt
				default:  alucontrol <= 3'b000;
			*//*default:case(op)
			6'b001100:alucontrol <= 3'b000;
			6'b001110:alucontrol <= 3'b000;
			6'b001111:alucontrol <= 3'b000;
			6'b001101:alucontrol <= 3'b001;
			default:case(funct)*//*
			endcase
		endcase*/
	
	end
endmodule
