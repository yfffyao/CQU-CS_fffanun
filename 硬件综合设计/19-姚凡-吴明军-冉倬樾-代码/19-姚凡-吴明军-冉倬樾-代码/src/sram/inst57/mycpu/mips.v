`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//  
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
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


module mips(
	input wire clk,rst,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire memwriteM,
	output wire[31:0] aluoutM,writedataM,
	output wire[3:0] w_en,
	input wire[31:0] readdataM ,
	output wire [31:0] excepttypeM,
    output wire flush_except,
    output [31:0] debug_wb_pc     ,
    output [3:0] debug_wb_rf_wen  ,
    output [4:0] debug_wb_rf_wnum ,
    output [31:0] debug_wb_rf_wdata
    );
	
	wire [5:0] opD,functD,rt2,rsD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM,regwriteW,hilo_writeM,cp0weM,storeD,branchD,jumpD,jrD,invalidD;
	wire [7:0] alucontrolE;
	wire flushE,equalD,stallE;
	wire flushM,flushW;

	controller c(
		clk,rst,
		//decode stage
		opD,functD,rt2,rsD,
		pcsrcD,branchD,equalD,jumpD,jrD,storeD,invalidD,
		
		//execute stage
		flushE,stallE,
		memtoregE,alusrcE,
		regdstE,regwriteE,	
		alucontrolE,

		//mem stage
		flushM,memtoregM,memwriteM,
		regwriteM,hilo_writeM,stall_divM,cp0weM,
		//write back stage
		flushW,memtoregW,regwriteW
		);
	datapath dp(
		clk,rst,
		//fetch stage
		pcF,
		instrF,
		//decode stage
		pcsrcD,branchD,
		jumpD,jrD,storeD,invalidD,
		equalD,
		opD,functD,rt2,rsD,
		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,
		alucontrolE,
		
		flushE,stallE,
		//mem stage
		cp0weM,
		memtoregM,
		regwriteM,hilo_writeM,stall_divM,
		aluoutM,writedataM,
		w_en,
		readdataM,excepttypeM,flushM,
		//writeback stage
		memtoregW,
		regwriteW,
		flushW,
		flush_except,
		debug_wb_pc,  
        debug_wb_rf_wen,  
        debug_wb_rf_wnum,  
        debug_wb_rf_wdata  
	    );
	
endmodule
