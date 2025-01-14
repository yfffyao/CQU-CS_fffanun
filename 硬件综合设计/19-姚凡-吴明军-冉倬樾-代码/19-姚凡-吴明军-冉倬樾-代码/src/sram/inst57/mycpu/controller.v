`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller 
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


module controller(
	input wire clk,rst,
	//decode stage
	input wire[5:0] opD,functD,rt2,rsD,
	output wire pcsrcD,branchD,equalD,jumpD,jrD,storeD,invalidD,
	
	//execute stage
	input wire flushE,stallE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,
	output wire[7:0] alucontrolE,

	//mem stage
	input flushM,
	output wire memtoregM,memwriteM,
				regwriteM,hilo_writeM,stall_divM,cp0weM,	
	//write back stage
	input flushW,
	output wire memtoregW,regwriteW

    );
	
	//decode stage
	wire[1:0] aluopD;
	wire memtoregD,memwriteD,alusrcD,
		regdstD,regwriteD,hilo_writeD,cp0weD;
	wire[7:0] alucontrolD;

	//execute stage
	wire memwriteE,hilo_writeE,cp0weE;

	maindec md(
		opD,
		functD,rt2,
		rsD,
		cp0weD,
		memtoregD,memwriteD,
		branchD,alusrcD,
		regdstD,regwriteD,
		jumpD,storeD,jrD,hilo_writeD,
		aluopD,
		invalidD
		);
	aludec ad(opD,functD,aluopD,rsD,alucontrolD);

	assign pcsrcD = branchD & equalD;

	//pipeline registers
	flopenrc #(17) regE(
		clk,
		rst,
		~stallE,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD,hilo_writeD,cp0weD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE,hilo_writeE,cp0weE}
		);
	floprc #(9) regM(
		clk,rst,flushM,
		{memtoregE,memwriteE,regwriteE,hilo_writeE,stallE,cp0weE},
		{memtoregM,memwriteM,regwriteM,hilo_writeM,stall_divM,cp0weM}
		);
	floprc #(8) regW(
		clk,rst,flushW,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule
