`timescale 1ns / 1ps

module mycpu_top(   
    input aclk,    
    input aresetn,   
    input arready, 
    input rlast,     
    input rvalid,    
    input awready,
    input wready, 
    input bvalid,  
    input [5:0] ext_int,   
    input [3:0] rid,  
    input [3:0] bid,       
    input [1:0] rresp,
    input [1:0] bresp,    
    input [31:0] rdata,  

    output arvalid,awvalid,
    output rready,wid,  
    output wlast, 
    output wvalid, 
    output bready,   
    output [3:0] arid,
    output [31:0] araddr, 
    output [3:0] arlen, 
    output [2:0] arsize,    
    output [1:0] arburst,
    output [1:0] arlock,
    output [3:0] arcache,   
    output [2:0] arprot,    
    output [3:0]awid,
    output [31:0] awaddr,  
    output [3:0] awlen,   
    output [2:0] awsize, 
    output [1:0] awburst,
    output [1:0] awlock,   
    output [3:0] awcache,    
    output [2:0] awprot,   
    output [31:0] wdata, 
    output [3:0] wstrb,
 
    input wire  [31:0] inst_vaddr,
    output wire [31:0] inst_paddr,
    input wire  [31:0] data_vaddr,
    output wire [31:0] data_paddr,

    output wire[31:0] debug_wb_pc,
    output wire[3:0] debug_wb_rf_wen,
    output wire[4:0] debug_wb_rf_wnum,
    output wire[31:0] debug_wb_rf_wdata,

    //是否经过dcache
    output wire no_dcache 
    );

    wire stallM,stallW;
    //sram signal
	//cpu inst sram
	wire        inst_sram_en;
	wire [3 :0] inst_sram_wen;
	wire [31:0] inst_sram_addr;
	wire [31:0] inst_sram_wdata;
	wire [31:0] inst_sram_rdata;
	//cpu data sram
	wire        data_sram_en,data_sram_write;
	wire [1 :0] data_sram_size;
	wire [3 :0] data_sram_wen;
	wire [31:0] data_sram_addr;
	wire [31:0] data_sram_wdata;
	wire [31:0] data_sram_rdata;

    // IF
    wire rst,clk;
    wire [31:0] pcF;
    wire [31:0] instrF;
    // ID
    wire pcsrcD,branchD;
    wire jumpD;
    wire equalD;
    wire[5:0] opD,functD;
    wire [4:0] rsD,rtD;
    wire jalD,jrD,balD;
    wire invalidD;
    // EX
    wire memtoregE;
    wire alusrcE,regdstE;
    wire regwriteE;
    wire[7:0] alucontrolE;
    wire flushE;
    wire stallE;
    wire jalE,jrE,balE;
    // MEM
    wire cp0weM;
    wire memtoregM;
    wire regwriteM;
    wire flushM;
    wire[31:0] aluoutM;
    wire [31:0] final_writedM;
    wire [3:0] memsel;
    wire[31:0] readdataM;
    wire hilo_writeM;
    wire stall_divM;
    wire [31:0] excepttypeM,excepttypeW;
    wire memenM;
    // WB
    wire memtoregW;
    wire regwriteW;
    wire flushW;
    wire [31:0] pcW;
    wire [4:0] writeregW;
    wire [31:0] resultW;
    
    wire i_stall;
    wire d_stall;
    wire inst_req;
    wire inst_wr;
    wire [1:0] inst_size;
    wire [31:0] inst_addr;
    wire [31:0] inst_wdata;
    wire inst_addr_ok;
    wire inst_data_ok;
    wire [31:0] inst_rdata;
    wire longest_stall;

    assign  clk = aclk;
	assign  rst = ~aresetn;
	
	assign	inst_sram_en		= ~flush_except;
	assign	inst_sram_wen		= 4'b0000;  // 指令存储器只读不写，恒为4'b0000
	assign	inst_sram_wdata		= 32'b0;    // 写数据，指令存储器只读不写恒�?32'b0
	assign	instrF				= inst_sram_rdata;

    assign  data_sram_size = (memenM==4'b0001||memenM==4'b0010||memenM==4'b0100||memenM==4'b1000)?2'b00:(memenM==4'b0011||memenM==4'b1100)?2'b01:2'b10;
	assign  data_sram_write = (memenM==4'b0)? 1'b0:1'b1; // 0 read, 1 write
    assign	data_sram_en		= memenM&~(|excepttypeM);   // 只有在访存指令的时�?�才能置�?1
	assign	data_sram_wen		= memsel;   // 按照访存控制的字节信�?
	assign	data_sram_wdata		= final_writedM;    // 写数�?
	assign	readdataM			= data_sram_rdata;

	assign	debug_wb_pc			= pcW;
	assign	debug_wb_rf_wen		= {4{regwriteW & ~i_stall &~d_stall}};
	assign	debug_wb_rf_wnum	= writeregW;
	assign	debug_wb_rf_wdata	= resultW;

    i_sram_to_sram_like i_sram_to_sram_like_0(
        .clk(aclk), 
        .rst(~aresetn),
        //sram
        .inst_sram_en(inst_sram_en),
        .inst_sram_addr(inst_sram_addr),
        .inst_sram_rdata(inst_sram_rdata),
        .i_stall(i_stall),
        //sram like
        .inst_req(inst_req), 
        .inst_wr(inst_wr),
        .inst_size(inst_size),
        .inst_addr(inst_addr),
        .inst_wdata(inst_wdata),
        .inst_addr_ok(inst_addr_ok),
        .inst_data_ok(inst_data_ok),
        .inst_rdata(inst_rdata),

        .longest_stall(longest_stall)
    );

    wire data_req;
    wire data_wr;
    wire [1:0] data_size;
    wire [31:0] data_addr;
    wire [31:0] data_wdata;
    wire [31:0] data_rdata;
    wire data_addr_ok;
    wire data_data_ok;
    wire        conf_data_req  ;
    wire [31:0] conf_data_addr ;
    wire        conf_data_wr   ;
    wire [1:0]  conf_data_size ;
    wire [31:0] conf_data_wdata;
    wire [31:0] conf_data_rdata;
    wire        conf_data_addr_ok;
    wire        conf_data_data_ok;
    wire        ram_data_req  ;
    wire [31:0] ram_data_addr ;
    wire        ram_data_wr   ;
    wire [1:0]  ram_data_size ;
    wire [31:0] ram_data_wdata;
    wire [31:0] ram_data_rdata;
    wire        ram_data_addr_ok;
    wire        ram_data_data_ok;
    wire        wrap_data_req  ;
wire [31:0] wrap_data_addr ;
wire        wrap_data_wr   ;
wire [1:0]  wrap_data_size ;
wire [31:0] wrap_data_wdata;
wire [31:0] wrap_data_rdata;
wire        wrap_data_addr_ok;
wire        wrap_data_data_ok;
wire        cache_inst_req  ;
wire [31:0] cache_inst_addr ;
wire        cache_inst_wr   ;
wire [1:0]  cache_inst_size ;
wire [31:0] cache_inst_wdata;
wire [31:0] cache_inst_rdata;
wire        cache_inst_addr_ok;
wire        cache_inst_data_ok;

wire        cache_data_req  ;
wire [31:0] cache_data_addr ;
wire        cache_data_wr   ;
wire [1:0]  cache_data_size ;
wire [31:0] cache_data_wdata;
wire [31:0] cache_data_rdata;
wire        cache_data_addr_ok;
wire        cache_data_data_ok;

wire [31:0] cpu_data_addr;
wire [31:0] cpu_inst_addr;

    d_sram_to_sram_like d_sram_to_sram_like_0(
        .clk(aclk), 
        .rst(~aresetn),
        .flush((|excepttypeM)|(|excepttypeW)), // use excepetion type
        //sram
        .data_sram_en(data_sram_en),
        .data_sram_addr(data_sram_addr),
        .data_sram_rdata(data_sram_rdata),
        .data_sram_wen(data_sram_wen),
        .data_sram_wdata(data_sram_wdata),
        .d_stall(d_stall),
        //sram like
        .data_req(data_req), 
        .data_wr(data_wr),
        .data_size(data_size),
        .data_addr(data_addr),   
        .data_wdata(data_wdata),
        .data_rdata(data_rdata),
        .data_addr_ok(data_addr_ok),
        .data_data_ok(data_data_ok),
        .longest_stall(longest_stall)
    );

    controller con(
        .clk(aclk), 
        .rst(~aresetn),
        .opD(opD),
        .functD(functD),
        .rsD(rsD),
        .rtD(rtD),
        .pcsrcD(pcsrcD),
        .branchD(branchD),
        .equalD(equalD),
        .jumpD(jumpD),
        .jalD(jalD),
        .jrD(jrD),
        .balD(balD),
        .invalidD(invalidD),
        .flushE(flushE),
        .stallE(stallE),
        .memtoregE(memtoregE),
        .alusrcE(alusrcE),
        .regdstE(regdstE),
        .regwriteE(regwriteE),
        .alucontrolE(alucontrolE),
        .jalE(jalE),
        .jrE(jrE),
        .balE(balE),
        .flushM(flushM),
        .memtoregM(memtoregM),
        .regwriteM(regwriteM),
        .stall_divM(stall_divM),
        .hilo_writeM(hilo_writeM),
        .memenM(memenM),
        .cp0weM(cp0weM),
        .flushW(flushW),
        .memtoregW(memtoregW),
        .regwriteW(regwriteW),
        .stallM(stallM),
        .stallW(stallW)
    );

    datapath dp(
        .clk(aclk), 
        .rst(~aresetn),
        .pcF(pcF),
        .instrF(instrF),
        .pcsrcD(pcsrcD),
        .branchD(branchD),
        .jumpD(jumpD),
        .equalD(equalD),
        .opD(opD),
        .functD(functD),
        .rsD(rsD),
        .rtD(rtD),
        .jalD(jalD),
        .jrD(jrD),
        .balD(balD),
        .invalidD(invalidD),
        .memtoregE(memtoregE),
        .alusrcE(alusrcE),
        .regdstE(regdstE),
        .regwriteE(regwriteE),
        .alucontrolE(alucontrolE),
        .flushE(flushE),
        .stallE(stallE),
        .jalE(jalE),
        .jrE(jrE),
        .balE(balE),
        .cp0weM(cp0weM),
        .memtoregM(memtoregM),
        .regwriteM(regwriteM),
        .flushM(flushM),
        .aluoutM(aluoutM),
        .final_writedM(final_writedM),
        .memsel(memsel),
        .readdataM(readdataM),
        .hilo_writeM(hilo_writeM),
        .stall_divM(stall_divM),
        .excepttypeM(excepttypeM),
        .excepttypeW(excepttypeW),
        .memtoregW(memtoregW),
        .regwriteW(regwriteW),
        .flushW(flushW),
        .pcW(pcW),
        .writeregW(writeregW),
        .resultW(resultW),
        .longest_stall(longest_stall),
        .i_stall(i_stall),
        .d_stall(d_stall),
        .stallM(stallM),
        .stallW(stallW),
        .flush_except(flush_except)
    );
   
    mmu mm (
        .inst_vaddr(inst_addr),
        .inst_paddr(cpu_inst_addr),
        .data_vaddr(data_addr),
        .data_paddr(cpu_data_addr),
        .no_dcache(no_dcache)    //是否经过d cache
    );
    

    bridge_1x2 bridge_1x2(
    .no_dcache        (no_dcache    ),

    .cpu_data_req     (data_req  ),
    .cpu_data_wr      (data_wr   ),
    .cpu_data_addr    (cpu_data_addr ),
    .cpu_data_wdata   (data_wdata),
    .cpu_data_size    (data_size ),
    .cpu_data_rdata   (data_rdata),
    .cpu_data_addr_ok (data_addr_ok),
    .cpu_data_data_ok (data_data_ok),

    .ram_data_req     (ram_data_req  ),
    .ram_data_wr      (ram_data_wr   ),
    .ram_data_addr    (ram_data_addr ),
    .ram_data_wdata   (ram_data_wdata),
    .ram_data_size    (ram_data_size ),
    .ram_data_rdata   (ram_data_rdata),
    .ram_data_addr_ok (ram_data_addr_ok),
    .ram_data_data_ok (ram_data_data_ok),

    .conf_data_req     (conf_data_req  ),
    .conf_data_wr      (conf_data_wr   ),
    .conf_data_addr    (conf_data_addr ),
    .conf_data_wdata   (conf_data_wdata),
    .conf_data_size    (conf_data_size ),
    .conf_data_rdata   (conf_data_rdata),
    .conf_data_addr_ok (conf_data_addr_ok),
    .conf_data_data_ok (conf_data_data_ok)
);

    bridge_2x1 bridge_2x1(
    .no_dcache        (no_dcache    ),

    .ram_data_req     (cache_data_req  ),
    .ram_data_wr      (cache_data_wr   ),
    .ram_data_addr    (cache_data_addr ),
    .ram_data_wdata   (cache_data_wdata),
    .ram_data_size    (cache_data_size ),
    .ram_data_rdata   (cache_data_rdata),
    .ram_data_addr_ok (cache_data_addr_ok),
    .ram_data_data_ok (cache_data_data_ok),

    .conf_data_req     (conf_data_req  ),
    .conf_data_wr      (conf_data_wr   ),
    .conf_data_addr    (conf_data_addr ),
    .conf_data_wdata   (conf_data_wdata),
    .conf_data_size    (conf_data_size ),
    .conf_data_rdata   (conf_data_rdata),
    .conf_data_addr_ok (conf_data_addr_ok),
    .conf_data_data_ok (conf_data_data_ok),

    .wrap_data_req     (wrap_data_req  ),
    .wrap_data_wr      (wrap_data_wr   ),
    .wrap_data_addr    (wrap_data_addr ),
    .wrap_data_wdata   (wrap_data_wdata),
    .wrap_data_size    (wrap_data_size ),
    .wrap_data_rdata   (wrap_data_rdata),
    .wrap_data_addr_ok (wrap_data_addr_ok),
    .wrap_data_data_ok (wrap_data_data_ok)
);
cache cache(
    .clk(clk), .rst(rst),
    .cpu_inst_req     (cpu_inst_req  ),
    .cpu_inst_wr      (cpu_inst_wr   ),
    .cpu_inst_addr    (cpu_inst_addr ),
    .cpu_inst_size    (cpu_inst_size ),
    .cpu_inst_wdata   (cpu_inst_wdata),
    .cpu_inst_rdata   (cpu_inst_rdata),
    .cpu_inst_addr_ok (cpu_inst_addr_ok),
    .cpu_inst_data_ok (cpu_inst_data_ok),

    .cpu_data_req     (ram_data_req  ),
    .cpu_data_wr      (ram_data_wr   ),
    .cpu_data_addr    (ram_data_addr ),
    .cpu_data_wdata   (ram_data_wdata),
    .cpu_data_size    (ram_data_size ),
    .cpu_data_rdata   (ram_data_rdata),
    .cpu_data_addr_ok (ram_data_addr_ok),
    .cpu_data_data_ok (ram_data_data_ok),

    .cache_inst_req     (cache_inst_req  ),
    .cache_inst_wr      (cache_inst_wr   ),
    .cache_inst_addr    (cache_inst_addr ),
    .cache_inst_size    (cache_inst_size ),
    .cache_inst_wdata   (cache_inst_wdata),
    .cache_inst_rdata   (cache_inst_rdata),
    .cache_inst_addr_ok (cache_inst_addr_ok),
    .cache_inst_data_ok (cache_inst_data_ok),

    .cache_data_req     (cache_data_req  ),
    .cache_data_wr      (cache_data_wr   ),
    .cache_data_addr    (cache_data_addr ),
    .cache_data_wdata   (cache_data_wdata),
    .cache_data_size    (cache_data_size ),
    .cache_data_rdata   (cache_data_rdata),
    .cache_data_addr_ok (cache_data_addr_ok),
    .cache_data_data_ok (cache_data_data_ok)
);
    cpu_axi_interface cpu_axi_interface(
    .clk(clk),
    .resetn(~rst),

    .inst_req       (cache_inst_req  ),
    .inst_wr        (cache_inst_wr   ),
    .inst_size      (cache_inst_size ),
    .inst_addr      (cache_inst_addr ),
    .inst_wdata     (cache_inst_wdata),
    .inst_rdata     (cache_inst_rdata),
    .inst_addr_ok   (cache_inst_addr_ok),
    .inst_data_ok   (cache_inst_data_ok),

    .data_req       (wrap_data_req  ),
    .data_wr        (wrap_data_wr   ),
    .data_size      (wrap_data_size ),
    .data_addr      (wrap_data_addr ),
    .data_wdata     (wrap_data_wdata ),
    .data_rdata     (wrap_data_rdata),
    .data_addr_ok   (wrap_data_addr_ok),
    .data_data_ok   (wrap_data_data_ok),

    .arid(arid),
    .araddr(araddr),
    .arlen(arlen),
    .arsize(arsize),
    .arburst(arburst),
    .arlock(arlock),
    .arcache(arcache),
    .arprot(arprot),
    .arvalid(arvalid),
    .arready(arready),

    .rid(rid),
    .rdata(rdata),
    .rresp(rresp),
    .rlast(rlast),
    .rvalid(rvalid),
    .rready(rready),

    .awid(awid),
    .awaddr(awaddr),
    .awlen(awlen),
    .awsize(awsize),
    .awburst(awburst),
    .awlock(awlock),
    .awcache(awcache),
    .awprot(awprot),
    .awvalid(awvalid),
    .awready(awready),

    .wid(wid),
    .wdata(wdata),
    .wstrb(wstrb),
    .wlast(wlast),
    .wvalid(wvalid),
    .wready(wready),

    .bid(bid),
    .bresp(bresp),
    .bvalid(bvalid),
    .bready(bready)
);
    
endmodule



