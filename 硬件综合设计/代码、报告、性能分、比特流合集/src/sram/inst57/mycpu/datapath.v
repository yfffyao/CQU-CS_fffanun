`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22 
// Design Name: 
// Module Name: datapath
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


module datapath(
	input wire clk,rst,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire pcsrcD,branchD,
	input wire jumpD,jrD,storeD,
	input wire invalidD,
	output wire equalD,
	output wire[5:0] opD,functD,rt2,rsD,
	//execute stage
	
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,
	input wire[7:0] alucontrolE,
	
	output wire flushE,stallE,
	//mem stage
	input wire cp0weM,
	input wire memtoregM,
	input wire regwriteM,
	input wire hilo_writeM,stall_divM,
	output wire[31:0] aluoutM,writedataM2,
	output wire[3:0] w_en,
	input wire[31:0] readdataM,
	output wire [31:0] excepttypeM,
	output flushM,
	
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,
	output flushW,
	output wire flush_except,
	output wire [31:0] debug_wb_pc,
    output wire [3 :0] debug_wb_rf_wen,
    output wire [4 :0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
    );
	
	//fetch stage
	wire stallF;
	//FD
	wire [31:0] pcnextFD1,pcnextFD,pcnextbrFD,pcplus4F,pcplus8F,pcbranchD;
	//decode stage
	wire [31:0] pcD,pcplus4D,pcplus8D,instrD;
	wire [1:0] forwardaD,forwardbD;
	wire [4:0] rtD,rdD,saD;
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	//execute stage
	wire storeE;
	wire [1:0] forwardaE,forwardbE;
	wire [31:0] pcE,pcplus8E;
	wire [4:0] rsE,rtE,rdE;
	wire [5:0] opE;
	wire [4:0] writeregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE,aluout2E;
	wire [4:0] saE;
	wire [63:0] hilo_inE;
	wire stall_divE;
	wire overflowE;
	//mem stage
	wire [4:0] writeregM;
	wire [63:0] hilo_inM;
	wire [63:0] hilo_outM;
	wire [5:0] opM;
	wire [31:0] readdataM2,writedataM;
	wire [4:0] rdM;
	wire [31:0] pcM;
	wire [31:0] bad_addrM;
	wire adesM,adelM;
	//writeback stage
	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW,resultW;
	wire [31:0] pcW;
    wire is_in_delayslotF,is_in_delayslotD,is_in_delayslotE,is_in_delayslotM;
    wire [31:0] data_o,count_o,compare_o,status_o,cause_o,epc_o, config_o,prid_o,badvaddr;	//  쳣
    wire [7:0] exceptF,exceptD,exceptE,exceptM;
    wire syscallD,breakD,eretD;
    wire [31:0] newpcM;
    wire flushF,flushD;
    wire forwardcp0E;
    wire [31:0] cp0dataE,cp0data2E;
	//hazard detection
	hazard h(
		//fetch stage
		stallF,flushF,
		//decode stage
		rsD,rtD,
		branchD,jumpD,
		forwardaD,forwardbD,
		stallD,flushD,
		//execute stage
		rsE,rtE,rdE,
		writeregE,
		regwriteE,
		memtoregE,
		stall_divE,
		forwardaE,forwardbE,
		flushE,stallE,
		forwardcp0E,
		//mem stage
		rdM,
		writeregM,
		regwriteM,
		memtoregM,
		cp0weM,
		excepttypeM,
		epc_o,
		flushM,
		newpcM,
		//write back stage
		writeregW,
		regwriteW,
		flush_except,
		flushW
		);

     assign debug_wb_pc          = pcW;
    assign debug_wb_rf_wen      = {4{regwriteW }};
    assign debug_wb_rf_wnum     = writeregW;
    assign debug_wb_rf_wdata    = resultW;
    
	//next PC logic (operates in fetch an decode)       źž     ֧    ת  
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);  // Ƿ  з ֧
	mux2 #(32) pcmux(pcnextbrFD,
		{pcplus4D[31:28],instrD[25:0],2'b00},
		jumpD,pcnextFD1);  //j  jal      ָ  Ƿ     ת  
	mux2 #(32) pcjump(pcnextFD1,srca2D,jrD,pcnextFD);
    pc #(32) pcf(clk,rst,~stallF,flushF,pcnextFD,newpcM,pcF);
    
	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);
	assign exceptF = (pcF[1:0] == 2'b00) ? 8'b00000000 : 8'b10000000;
    assign is_in_delayslotF = (jumpD|branchD);
	//fetch stage logic
//	pc #(32) pcreg(clk,rst,~stallF,pcnextFD,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	adder pcadd3(pcF,32'b1000,pcplus8F);
	//     ׶  ж syscall  break  eret
	assign syscallD = (opD == `EXE_SPECIAL_INST && functD == `EXE_SYSCALL);	
	assign breakD = (opD == `EXE_SPECIAL_INST && functD == `EXE_BREAK);
	assign eretD = (instrD == `EXE_ERET);
	//decode stage
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r3D(clk,rst,~stallD,flushD,pcplus8F,pcplus8D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(1) r4D(clk,rst,~stallD,flushD,is_in_delayslotF,is_in_delayslotD);
	flopenrc #(32) r5D(clk,rst,~stallD,flushD,pcF,pcD);
	flopenrc #(8) r6D(clk,rst,~stallD,flushD,exceptF,exceptD);
	signext se(instrD[15:0],instrD[29:28],signimmD);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);  //     ֧  ַ
	mux3 #(32) forwardamux(srcaD,aluoutE,aluoutM,forwardaD,srca2D);
	mux3 #(32) forwardbmux(srcbD,aluoutE,aluoutM,forwardbD,srcb2D);
	eqcmp comp(opD,rsD,instrD[20:16],srca2D,srcb2D,equalD);  // жϷ ֧    

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = (jumpD|storeD) ? 5'b11111:instrD[20:16];
	assign rt2=instrD[20:16];
	assign rdD = instrD[15:11];
	assign saD=instrD[10:6];

	//execute stage
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(5) r7E(clk,rst,~stallE,flushE,saD,saE);
	flopenrc #(6) r8E(clk,rst,~stallE,flushE,opD,opE);
	flopenrc #(32) r9E(clk,rst,~stallE,flushE,pcplus8D,pcplus8E);
	flopenrc #(1) r10E(clk,rst,~stallE,flushE,storeD,storeE);
	flopenrc #(1) r11E(clk,rst,~stallE,flushE,is_in_delayslotD,is_in_delayslotE);
	flopenrc #(32) r12E(clk,rst,~stallE,flushE,pcD,pcE);
	//  ж  쳣ָ  
	flopenrc #(8) r13E(clk,rst,~stallE,flushE,
		{exceptD[7],syscallD,breakD,eretD,invalidD,exceptD[2:0]},
		exceptE);
	mux2 #(32) forwardcp0mux(cp0dataE,aluoutM,forwardcp0E,cp0data2E);
		
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	alu alu(clk,rst,srca2E,srcb3E,alucontrolE,saE,hilo_outM,cp0data2E,hilo_inE,aluoutE,stall_divE,overflowE);
	mux2 #(32) pc8mux(aluoutE,pcplus8E,storeE,aluout2E);
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE);
	

	//mem stage
	floprc #(32) r1M(clk,rst,flushM,srcb2E,writedataM);
	floprc #(32) r2M(clk,rst,flushM,aluout2E,aluoutM);
	floprc #(5) r3M(clk,rst,flushM,writeregE,writeregM);
	floprc #(6) r4M(clk,rst,flushM,opE,opM);
	floprc #(64) r5M(clk,rst,flushM,hilo_inE,hilo_inM);
	floprc #(5) r6M(clk,rst,flushM,rdE,rdM);
	floprc #(1) r7M(clk,rst,flushM,is_in_delayslotE,is_in_delayslotM);
	floprc #(32) r8M(clk,rst,flushM,pcE,pcM);
	floprc #(8) r9M(clk,rst,flushM,{exceptE[7:3],overflowE,exceptE[1:0]},exceptM);
	 hilo_reg hilo(
		.clk(~clk),
		.rst(rst),
		.we(hilo_writeM&~stall_divM),
		.hi_i(hilo_inM[63:32]),
		.lo_i(hilo_inM[31:0]),
		.hi_o(hilo_outM[63:32]),
		.lo_o(hilo_outM[31:0])
	);
	data_sel sel_m(pcM,aluoutM,writedataM,readdataM,opM,writedataM2,readdataM2,w_en,adesM,adelM,bad_addrM);
    exception exp(
		.rst(rst),
		.ades(adesM),.adel(adelM),
		.except(exceptM),
		.cp0_status(status_o),
		.cp0_cause(cause_o),
		.excepttype(excepttypeM)
	);
    cp0_reg CP0(
		.clk(clk),
		.rst(rst),
		.we_i(cp0weM),
		.waddr_i(rdM),.raddr_i(rdE),
		.is_in_delayslot_i(is_in_delayslotM),
		.int_i(6'b000000),
		.data_i(aluoutM),
		.excepttype_i(excepttypeM),
        .current_inst_addr_i(pcM),
		.bad_addr_i(bad_addrM),
        .data_o(data_o),
		.count_o(count_o),
		.compare_o(compare_o),
		.status_o(status_o),
		.cause_o(cause_o),
        .epc_o(epc_o),
		.config_o(config_o),
		.prid_o(prid_o),
		.badvaddr(badvaddr),
		.timer_int_o(timer_int_o)
	);
	assign cp0dataE = data_o;
	//writeback stage
	floprc #(32) r1W(clk,rst,flushW,aluoutM,aluoutW);
	floprc #(32) r2W(clk,rst,flushW,readdataM2,readdataW);
	floprc #(5) r3W(clk,rst,flushW,writeregM,writeregW);
	floprc #(32) r4W(clk,rst,flushW,pcM,pcW);
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
endmodule
