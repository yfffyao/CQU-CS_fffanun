module cpu_axi_interface
(
    input         clk,
    input         resetn, 

    //inst sram-like 
    input         inst_req     ,
    input         inst_wr      ,
    input  [1 :0] inst_size    ,
    input  [31:0] inst_addr    ,
    input  [31:0] inst_wdata   ,
    output [31:0] inst_rdata   ,
    output        inst_addr_ok ,
    output        inst_data_ok ,
    
    //data sram-like 
    input         data_req     ,
    input         data_wr      ,
    input  [1 :0] data_size    ,
    input  [31:0] data_addr    ,
    input  [31:0] data_wdata   ,
    output [31:0] data_rdata   ,
    output        data_addr_ok ,
    output        data_data_ok ,

    //axi
    //ar
    output [3 :0] arid         ,//读地址ID
    output [31:0] araddr       ,//读地址
    output [7 :0] arlen        ,//突发式读长度
    output [2 :0] arsize       ,//突发式读大小
    output [1 :0] arburst      ,//突发式读类型
    output [1 :0] arlock       ,//锁类型
    output [3 :0] arcache      ,//Cache类型
    output [2 :0] arprot       ,//保护类型
    output        arvalid      ,//读地址有效，信号一直保持，直到arready为高
    input         arready      ,//读地址就绪，指明设备已经准备好接受数据了
    //r           
    input  [3 :0] rid          ,//读ID tag，rid值必须与arid值匹配
    input  [31:0] rdata        ,//读数据
    input  [1 :0] rresp        ,//读响应，指明读传输的状态
    input         rlast        ,//读事务传送的最后一个数据
    input         rvalid       ,//读数据有效
    output        rready       ,//读数据就绪
    //aw          
    output [3 :0] awid         ,//写地址ID，写地址信号组的ID tag
    output [31:0] awaddr       ,//写地址
    output [7 :0] awlen        ,//突发式写的长度，此长度决定突发式写所传输的数据个数
    output [2 :0] awsize       ,//突发式写的大小
    output [1 :0] awburst      ,
    output [1 :0] awlock       ,//锁类型
    output [3 :0] awcache      ,//Cache类型
    output [2 :0] awprot       ,//保护类型
    output        awvalid      ,//写地址有效
    input         awready      ,//写地址就绪，指明设备已经准备好接受地址和控制信息了
    //w          
    output [3 :0] wid          ,//写ID tag，wid值必须与awid值匹配
    output [31:0] wdata        ,//写的数据
    output [3 :0] wstrb        ,//写阀门
    output        wlast        ,//写的最后一个数据
    output        wvalid       ,//写有效
    input         wready       ,//写就绪，指明设备已经准备好接受数据了
    //b           
    input  [3 :0] bid          ,//相应ID，其值必须与awid匹配
    input  [1 :0] bresp        ,//写响应，指明写事务的状态
    input         bvalid       ,//写响应有效
    output        bready        //接受响应就绪
);
    //addr
    reg do_req;
    reg do_req_or; //req is inst or data;1:data,0:inst
    reg        do_wr_r;
    reg [1 :0] do_size_r;
    reg [31:0] do_addr_r;
    reg [31:0] do_wdata_r;
    wire data_back;

    assign inst_addr_ok = !do_req&&!data_req;
    assign data_addr_ok = !do_req;
    always @(posedge clk)
    begin
        do_req     <= !resetn                       ? 1'b0 : 
                    (inst_req||data_req)&&!do_req ? 1'b1 :
                    data_back                     ? 1'b0 : do_req;
        do_req_or  <= !resetn ? 1'b0 : 
                    !do_req ? data_req : do_req_or;

        do_wr_r    <= data_req&&data_addr_ok ? data_wr :
                    inst_req&&inst_addr_ok ? inst_wr : do_wr_r;
        do_size_r  <= data_req&&data_addr_ok ? data_size :
                    inst_req&&inst_addr_ok ? inst_size : do_size_r;
        do_addr_r  <= data_req&&data_addr_ok ? data_addr :
                    inst_req&&inst_addr_ok ? inst_addr : do_addr_r;
        do_wdata_r <= data_req&&data_addr_ok ? data_wdata :
                    inst_req&&inst_addr_ok ? inst_wdata :do_wdata_r;
    end

    //inst sram-like
    assign inst_data_ok = do_req&&!do_req_or&&data_back;
    assign data_data_ok = do_req&& do_req_or&&data_back;
    assign inst_rdata   = rdata;
    assign data_rdata   = rdata;

    //---axi
    reg addr_rcv;
    reg wdata_rcv;

    assign data_back = addr_rcv && (rvalid&&rready||bvalid&&bready);
    always @(posedge clk)
    begin
        addr_rcv  <= !resetn          ? 1'b0 :
                    arvalid&&arready ? 1'b1 :
                    awvalid&&awready ? 1'b1 :
                    data_back        ? 1'b0 : addr_rcv;
        wdata_rcv <= !resetn        ? 1'b0 :
                    wvalid&&wready ? 1'b1 :
                    data_back      ? 1'b0 : wdata_rcv;
    end
    //ar
    assign arid    = 4'd0;
    assign araddr  = do_addr_r;
    assign arlen   = 8'd0;
    assign arsize  = do_size_r;
    assign arburst = 2'd0;
    assign arlock  = 2'd0;
    assign arcache = 4'd0;
    assign arprot  = 3'd0;
    assign arvalid = do_req&&!do_wr_r&&!addr_rcv;
    //r
    assign rready  = 1'b1;

    //aw
    assign awid    = 4'd0;
    assign awaddr  = do_addr_r;
    assign awlen   = 8'd0;
    assign awsize  = do_size_r;
    assign awburst = 2'd0;
    assign awlock  = 2'd0;
    assign awcache = 4'd0;
    assign awprot  = 3'd0;
    assign awvalid = do_req&&do_wr_r&&!addr_rcv;
    //w
    assign wid    = 4'd0;
    assign wdata  = do_wdata_r;
    assign wstrb  = do_size_r==2'd0 ? 4'b0001<<do_addr_r[1:0] :
                    do_size_r==2'd1 ? 4'b0011<<do_addr_r[1:0] : 4'b1111;
    assign wlast  = 1'd1;
    assign wvalid = do_req&&do_wr_r&&!wdata_rcv;
    //b
    assign bready  = 1'b1;

endmodule

