`timescale 1ns / 1ps

`include"defines.vh"

module eqcmp(
	input wire [31:0] a,b,
	input wire [5:0] op,
	input wire [4:0] rt,
	output wire y
    );

	assign y = (op==`EXE_BEQ)?(a==b):	//beq
				(op==`EXE_BNE)?(a!=b):	//bne
				(op==`EXE_BGTZ)?((a[31]==1'b0)&&(a!=`ZeroWord)):	//bgtz 大于零跳转
				(op==`EXE_BLEZ)?((a[31]==1'b1)||(a==`ZeroWord)):	//blez 小于等于零跳转
				((op==`EXE_REGIMM_INST) && ((rt==`EXE_BGEZ)||(rt==`EXE_BGEZAL)) )?( (a[31]==1'b0) || (a==`ZeroWord) ):	//bgez地址为rs的通用寄存器的值大于等于0，那么发生转移
				//bgezal 地址为rs的通用寄存器的值大于等于0，那么发生转移，并且将转移指令后面第2条指令的地址作为返回地址，保存到通用寄存器$31
				((op==`EXE_REGIMM_INST) && ((rt==`EXE_BLTZ)||(rt==`EXE_BLTZAL)) )?( (a[31]==1'b1)):1'b0;	//bltz地址为rs的通用寄存器的值小于0，那么发生转移
				//bltazl地址为rs的通用寄存器的值小于0，那么发生转移，并且将转移指令后面第2条指令的地址作为返回地址，保存到通用寄存器$31
		
endmodule
