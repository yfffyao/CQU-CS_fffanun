`timescale 1ns / 1ps

`include"defines.vh"
module datapath(
	input wire clk,rst,
	// IF
	input wire[31:0] instrF,
	output wire[31:0] pcF,
	// ID
	input wire pcsrcD,branchD,jumpD,jalD,jrD,balD,
	input wire invalidD,
	output wire equalD,
	output wire[5:0] opD,functD,
	output wire [4:0] rsD,rtD,
	// EX
	input wire memtoregE,alusrcE,regdstE,regwriteE,jalE,jrE,balE,
	input wire[7:0] alucontrolE,
	output wire flushE,stallE,
	// MEM
	input wire cp0weM, memtoregM,regwriteM,
	input wire hilo_writeM,stall_divM,
	input wire[31:0] readdataM,
	output wire flushM,
	output wire [3:0] memsel,
	output wire[31:0] final_writedM,aluoutM,	//aluoutM = writedataM
	output wire [31:0] excepttypeM,
	// WB
	input wire memtoregW,regwriteW,
	input wire i_stall,d_stall,
	output wire flushW,
	output wire longest_stall,stallM,stallW,
	output wire [4:0] writeregW,
	output wire [31:0] pcW,resultW,
	output wire [31:0] excepttypeW,
	output wire flush_except
    );
	
	// IF
	wire stallF;
	// FD
	wire [31:0] pcplus4F,pcnextFD,pcnextbrFD,pcbranchD,pcjump;  
	// ID
	wire [31:0] pcD,pcplus4D,pcplus8D;
	wire [31:0] instrD;
	wire [1:0] forwardaD,forwardbD;
	wire [4:0] rdD;
	wire [4:0] saD;
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	// EX
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] saE;
	wire [4:0] writeregE,writereg2E;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE,aluout2E;
	wire [31:0] pcplus8E;
	wire [63:0] hilo_inE;
	wire [5:0] opE;
	wire [31:0] pcE;
	// MEM
	wire [4:0] writeregM;
	wire [63:0] hilo_inM;
	wire [63:0] hilo_outM;
	wire [5:0] opM;
	wire [31:0] pcM;
	wire [31:0] writedataM,final_readdM;
	// WB
	wire [31:0] aluoutW,readdataW;
	
	wire [31:0] data_o,count_o,compare_o,status_o,cause_o,epc_o, config_o,prid_o,badvaddr;	// 异常
	wire timer_int_o;
	wire [31:0] cp0dataE,cp0data2E;
	wire forwardcp0E;
	wire [4:0] rdM;
	wire [7:0] exceptF,exceptD,exceptE,exceptM;
	wire is_in_delayslotF,is_in_delayslotD,is_in_delayslotE,is_in_delayslotM;
	wire syscallD,breakD,eretD;
	wire overflowE;
	wire [31:0] bad_addrM;
	wire adesM,adelM;
	wire flushF;
	wire [31:0] newpcM;
	wire stall_divE;

	//冒险预测
	hazard h(
		// IF
		.flushF(flushF),.stallF(stallF),
		//ID
		.rsD(rsD),
		.rtD(rtD),
		.branchD(branchD),
		.balD(balD),
		.jumpD(jumpD),
		.forwardaD(forwardaD),
		.forwardbD(forwardbD),
		.flushD(flushD),.stallD(stallD),
		// EX
		.rsE(rsE),
		.rtE(rtE),
		.writeregE(writeregE),
		.rdE(rdE),
		.regwriteE(regwriteE),
		.memtoregE(memtoregE),
		.forwardaE(forwardaE),
		.forwardbE(forwardbE),
		.stall_divE(stall_divE),
		.flushE(flushE),.stallE(stallE),
		.forwardcp0E(forwardcp0E),
		// MEM
		.rdM(rdM),
		.writeregM(writeregM),
		.regwriteM(regwriteM),
		.memtoregM(memtoregM),
		.cp0weM(cp0weM),
		.excepttypeM(excepttypeM),
		.epc_o(epc_o),
		.flushM(flushM),
		.newpcM(newpcM),
		// WB
		.writeregW(writeregW),
		.regwriteW(regwriteW),
		.flushW(flushW),
		.longest_stall(longest_stall),
		.i_stall(i_stall),
		.d_stall(d_stall),
		.stallM(stallM),
		.stallW(stallW),
		.flush_except(flush_except)
	);

	// IF
	adder pcadd1(pcF,32'b100,pcplus4F);// pc+4
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);	// 选择加四或branch
	mux2 #(32) pcmux(pcnextbrFD,{pcplus4D[31:28],instrD[25:0],2'b00},jumpD|jalD,pcjump);// 是否jump
	mux2 #(32) pcjr(pcjump,srca2D,jrD,pcnextFD);
	pcflop #(32) pcf(clk,rst,~stallF,flushF,pcnextFD,newpcM,pcF);

	regfile rf(~clk,regwriteW & ~i_stall & ~d_stall ,rsD,rtD,writeregW,resultW,srcaD,srcbD);

	assign exceptF = (pcF[1:0] == 2'b00) ? 8'b00000000 : 8'b10000000;	// 处理PC最后两位是否对齐
	assign is_in_delayslotF = (jumpD|jalD|jrD|branchD);
	
	// ID阶段
	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign saD = instrD[10:6];
	
	// 译码阶段判断syscall、break、eret
	assign syscallD = (opD == `EXE_SPECIAL_INST && functD == `EXE_SYSCALL);	
	assign breakD = (opD == `EXE_SPECIAL_INST && functD == `EXE_BREAK);
	assign eretD = (instrD == `EXE_ERET);

	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,~stallD,flushD,pcF,pcD);
	flopenrc #(8) r4D(clk,rst,~stallD,flushD,exceptF,exceptD);
	flopenrc #(1) r5D(clk,rst,~stallD,flushD,is_in_delayslotF,is_in_delayslotD);
	signext signext0(instrD[15:0],instrD[29:28],signimmD);
	sl2 imm(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);//branch
	adder pcadd3(pcplus4D,32'b100,pcplus8D);//pc+8

	// 数据前推
	mux3 #(32) forwardamux(srcaD,aluoutE,aluoutM,forwardaD,srca2D);
	mux3 #(32) forwardbmux(srcbD,aluoutE,aluoutM,forwardbD,srcb2D);

	eqcmp comp0(srca2D,srcb2D,opD,rtD,equalD);
	
	// EX阶段
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(5) r7E(clk,rst,~stallE,flushE,saD,saE);
	flopenrc #(32) r8E(clk,rst,~stallE,flushE,pcplus8D,pcplus8E);	// pc+8
	flopenrc #(32) r9E(clk,rst,~stallE,flushE,pcD,pcE);
	flopenrc #(6) r10E(clk,rst,~stallE,flushE,opD,opE);
	flopenrc #(1) r11E(clk,rst,~stallE,flushE,is_in_delayslotD,is_in_delayslotE);

	// 判断异常指令
	flopenrc #(8) r12E(clk,rst,~stallE,flushE,
		{exceptD[7],syscallD,breakD,eretD,invalidD,exceptD[2:0]},
		exceptE);

	mux2 #(32) forwardcp0mux(cp0dataE,aluoutM,forwardcp0E,cp0data2E);

	// 数据前推
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);

	alu alu(
		.clk(clk),
		.rst(rst),
		.a(srca2E),
		.b(srcb3E),
		.alucontrol(alucontrolE),
		.sa(saE),
		.hilo_in(hilo_outM),
		.cp0data(cp0data2E),
		.result(aluoutE),
		.hilo_out(hilo_inE),
		.overflow(overflowE),
		.stall_div(stall_divE)
		);

	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE);
	mux2 #(5) wrmux2(writeregE,5'b11111,jalE|balE,writereg2E);
	mux2 #(32) wrmux3(aluoutE,pcplus8E,jalE|jrE|balE,aluout2E);

	// MEM阶段
	flopenrc #(32) r1M(clk,rst,~stallM,flushM,srcb2E,writedataM);
	flopenrc #(32) r2M(clk,rst,~stallM,flushM,aluout2E,aluoutM);
	flopenrc #(5) r3M(clk,rst,~stallM,flushM,writereg2E,writeregM);

	flopenrc #(64) r4M(clk,rst,~stallM,flushM,hilo_inE,hilo_inM);
	flopenrc #(32) r5M(clk,rst,~stallM,flushM,pcE,pcM);
	flopenrc #(6) r6M(clk,rst,~stallM,flushM,opE,opM);
	flopenrc #(6) r7M(clk,rst,~stallM,flushM,rdE,rdM);
	flopenrc #(1) r8M(clk,rst,~stallM,flushM,is_in_delayslotE,is_in_delayslotM);
	flopenrc #(8) r9M(clk,rst,~stallM,flushM,{exceptE[7:3],overflowE,exceptE[1:0]},exceptM);

	hilo_reg hilo(
		.clk(~clk),
		.rst(rst),
		.we(hilo_writeM&~stall_divM),
		.hi_in(hilo_inM[63:32]),
		.lo_in(hilo_inM[31:0]),
		.hi_out(hilo_outM[63:32]),
		.lo_out(hilo_outM[31:0])
	);

	mem_sel lm(
		.pc(pcM),
		.addr(aluoutM),
		.op(opM),
		.readdata(readdataM),
		.writedata(writedataM),
		.final_readd(final_readdM),
		.final_writed(final_writedM),
		.memsel(memsel),
		.adesM(adesM),
		.adelM(adelM),
		.bad_addr(bad_addrM)
	);

	exception exp(
		.rst(rst),
		.ades(adesM),.adel(adelM),
		.except(exceptM),
		.cp0_status(status_o),
		.cp0_cause(cause_o),
		.excepttype(excepttypeM)
	);

	cp0_reg CP0(
		.clk(clk),.rst(rst),
		.we_i(cp0weM & ~i_stall & ~d_stall),
		.waddr_i(rdM),.raddr_i(rdE),
		.stall(i_stall | d_stall),
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

	// WB阶段
	flopenrc #(32) r1W(clk,rst,~stallW,flushW,aluoutM,aluoutW);
	flopenrc #(32) r2W(clk,rst,~stallW,flushW,final_readdM,readdataW);
	flopenrc #(5) r3W(clk,rst,~stallW,flushW,writeregM,writeregW);
	flopenrc #(32) r4W(clk,rst,~stallW,flushW,pcM,pcW);
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
	flopenrc #(32) r5W(clk,rst,~stallW,flushW,excepttypeM,excepttypeW);

endmodule