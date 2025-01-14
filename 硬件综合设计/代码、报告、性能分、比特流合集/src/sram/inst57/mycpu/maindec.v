`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//  
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: maindec
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

module maindec(
	input wire[5:0] op,
	input wire [5:0] funct,rt2,
	input wire [4:0] rs,

    output wire cp0we,
	output wire memtoreg,memwrite,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump,store,jr,hilo_write,
	output wire[1:0] aluop,
	output reg invalid
    );
	reg[11:0] controls;
	assign cp0we=((op==`EXE_CP0)&(rs==`RS_MTC0))?1:0;

	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,store,jr,hilo_write,aluop} = controls;
	always @(*) begin
	   invalid <= 0;
		case (op)
			 `EXE_LB:controls <= 12'b101001000000;
			 `EXE_LBU:controls <= 12'b101001000000;
			 `EXE_LH:controls <= 12'b101001000000;
			 `EXE_LHU:controls <= 12'b101001000000;
			 `EXE_LW:controls <= 12'b101001000000;
			 `EXE_SB:controls <= 12'b001010000000;
			 `EXE_SH:controls <= 12'b001010000000;
			 `EXE_SW:controls <= 12'b001010000000;
			
			
			`EXE_BEQ:controls <= 12'b000100000001;//BEQ,src  branch  equal  ͬ    
			`EXE_BNE:controls <= 12'b000100000001;
			`EXE_BGTZ:controls <= 12'b000100000001;
			`EXE_BLEZ:controls <= 12'b000100000001;
			6'b000001:case(rt2)
			`EXE_BLTZ:controls <= 12'b000100000001;
			`EXE_BLTZAL:controls <= 12'b100100010001;
			`EXE_BGEZ:controls <= 12'b000100000001;
			`EXE_BGEZAL:controls <= 12'b100100010001;
			default: begin
			   controls <= 12'b000000000000;
			   invalid <= 1;
			   end//illegal op
			endcase
			
			`EXE_J:controls <= 12'b000000100000;//J
			`EXE_JAL:controls <= 12'b100000110000;
			
			
			6'b001100:controls <= 12'b101000000010;//andi
			6'b001110:controls <= 12'b101000000010;//xori
			6'b001111:controls <= 12'b101000000010;//lui
			6'b001101:controls <= 12'b101000000010;//ori
				
			 `EXE_ADDI:controls <= 12'b101000000010;
             `EXE_ADDIU:controls <= 12'b101000000010;
             `EXE_SLTI:controls <= 12'b101000000010;
             `EXE_SLTIU:controls <= 12'b101000000010;
			
			
			6'b000000:case(funct)
			  `EXE_AND:controls <= 12'b110000000010;//R-TYRE
			  `EXE_OR:controls <= 12'b110000000010;
			  `EXE_XOR:controls <= 12'b110000000010;
			  `EXE_NOR:controls <= 12'b110000000010;
			   //      ƶ ָ  
              `EXE_MFHI:controls <= 12'b110000000010;
              `EXE_MTHI:controls <= 12'b000000000110;
              `EXE_MFLO:controls <= 12'b110000000010;
              `EXE_MTLO:controls <= 12'b000000000110;
              
              //    ָ                                              
              `EXE_ADD:controls <= 12'b110000000010;              
              `EXE_ADDU:controls <= 12'b110000000010;
              `EXE_SUB:controls <= 12'b110000000010;  
              `EXE_SUBU:controls <=12'b110000000010;
              `EXE_SLT:controls <= 12'b110000000010;  
              `EXE_SLTU:controls <= 12'b110000000010;
              
              `EXE_SLL:controls <= 12'b110000000001;
              `EXE_SRL:controls <= 12'b110000000001;
			  `EXE_SRA:controls <= 12'b110000000001;
			  `EXE_SLLV:controls <= 12'b110000000001;
			  `EXE_SRLV:controls <= 12'b110000000001;
			  `EXE_SRAV:controls <= 12'b110000000001;


              `EXE_MULT:controls <= 12'b000000000110;
              `EXE_MULTU:controls <= 12'b000000000110;
              `EXE_DIV:controls <= 12'b000000000110;  
              `EXE_DIVU:controls <= 12'b000000000110;           
                 //     ָ  
               `EXE_BREAK:controls <= 12'b000000000000;
               `EXE_SYSCALL:controls <=12'b000000000000;
              
			  
			  `EXE_JR:controls <= 12'b000000101000;
			  `EXE_JALR:controls <= 12'b110000111000;

			  default: begin
			   controls <= 12'b000000000000;
			   invalid <= 1;
			   end//illegal op
		endcase
		`EXE_CP0:case(rs)
                      `RS_MTC0: controls <= 12'b000000000000;
                      `RS_MFC0: controls <= 12'b100000000000;
                      `RS_ERET: controls <= 12'b000000000000;
                        default: begin
			            controls <= 12'b000000000000;
			             invalid <= 1;
			            end//illegal op
		endcase
		default: begin
			   controls <= 12'b000000000000;
			   invalid <= 1;
			   end//illegal op
		endcase
	end
endmodule
