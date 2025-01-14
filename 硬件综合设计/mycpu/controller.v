`timescale 1ns / 1ps

module controller(
	input wire clk,rst,
	// ID
	input wire[5:0] opD,functD,
	input wire [4:0] rsD,rtD,
	input wire equalD,
	output wire jumpD,jalD,jrD,balD,invalidD,pcsrcD,branchD,
	// EX
	input wire flushE,stallE,
	output wire memtoregE,alusrcE,regdstE,regwriteE,jalE,jrE,balE,
	output wire[7:0] alucontrolE,
	// MEM
	input wire flushM,
	output wire memtoregM,regwriteM,stall_divM,hilo_writeM,memenM,cp0weM,
	// WB
	input wire flushW,stallM,stallW,
	output wire memtoregW,regwriteW
    );
	wire [7:0] alucontrolD;
	wire memtoregD,memwriteD,alusrcD,regdstD,regwriteD,hilo_writeD,memenD,cp0weD;
	wire memwriteE,hilo_writeE,memenE,cp0weE,memwriteM;

	assign pcsrcD = branchD && equalD;

	maindec maindec0(
		.op(opD),
		.funct(functD),
		.rs(rsD),
		.rt(rtD),
		.memtoreg(memtoregD),
		.memwrite(memwriteD),
		.branch(branchD),
		.alusrc(alusrcD),
		.regdst(regdstD),
		.regwrite(regwriteD),
		.jump(jumpD),
		.hilo_write(hilo_writeD),
		.jal(jalD),
		.jr(jrD),
		.bal(balD),
		.memen(memenD),
		.cp0we(cp0weD),
		.invalid(invalidD)
		);

	aludec ad(
		.op(opD),
		.funct(functD),
		.rs(rsD),
		.alucontrol(alucontrolD)
		);

	flopenrc #(19) regE(
		clk,rst,~stallE,flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD,hilo_writeD,jalD,jrD,balD,memenD,cp0weD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE,hilo_writeE,jalE,jrE,balE,memenE,cp0weE}
	);
	flopenrc #(7) regM(
		clk,rst,~stallM,flushM,
		{memtoregE,memwriteE,regwriteE,hilo_writeE,stallE,memenE,cp0weE},
		{memtoregM,memwriteM,regwriteM,hilo_writeM,stall_divM,memenM,cp0weM}
	);
	flopenrc #(2) regW(
		clk,rst,~stallW,flushW,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
	);
endmodule
