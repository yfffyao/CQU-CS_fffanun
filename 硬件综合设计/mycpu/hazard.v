`timescale 1ns / 1ps


module hazard(
		// IF
		output wire flushF,stallF,
		// ID
		input wire [4:0] rsD,rtD,
		input wire branchD,
		input wire balD,jumpD,
		output wire [1:0] forwardaD,forwardbD,
		output wire flushD,stallD,
		// EX
		input wire [4:0] rsE,rtE,writeregE,rdE,
		input wire regwriteE,memtoregE,
		output wire [1:0] forwardaE,forwardbE,
		input wire stall_divE,
		output wire flushE,stallE,
		output wire forwardcp0E,
		// MEM
		input wire [4:0] rdM,
		input wire [4:0] writeregM,
		input wire regwriteM,memtoregM,
		input wire cp0weM,
		input wire [31:0] excepttypeM,
		input wire [31:0] epc_o,
		output wire flushM,
		output reg [31:0] newpcM,
		// WB
		input wire [4:0] writeregW,
		input wire regwriteW,
		output wire flushW,

		output wire longest_stall,
		input wire i_stall,d_stall,
		output wire stallM,stallW,
		output wire flush_except
		);

	wire lwstallD;
	wire branchflushD;
	wire branchstall;

	//数据前推至ID
	assign forwardaD = ((rsD != 0) && (rsD == writeregM) && regwriteM) ? 2'b10 :
                       ((rsD != 0) && (rsD == writeregE) && regwriteE) ? 2'b01 :
                       2'b00;
    assign forwardbD = ((rtD != 0) && (rtD == writeregM) && regwriteM) ? 2'b10 :
                       ((rtD != 0) && (rtD == writeregE) && regwriteE) ? 2'b01 :
                       2'b00;

	//数据前推至EX
	assign forwardaE = ((rsE != 0) && (rsE == writeregM) && regwriteM) ? 2'b10 :
                       ((rsE != 0) && (rsE == writeregW) && regwriteW) ? 2'b01 :
                       2'b00;
    assign forwardbE = ((rtE != 0) && (rtE == writeregM) && regwriteM) ? 2'b10 :
                       ((rtE != 0) && (rtE == writeregW) && regwriteW) ? 2'b01 :
                       2'b00;

	assign flush_except = (excepttypeM != 32'b0);
	assign forwardcp0E = ((rdE!=0)&(rdE == rdM)&(cp0weM))?1'b1:1'b0;
    assign lwstallD = ((rsD == rtE) || (rtD == rtE)) && memtoregE;
	assign branchflushD = branchD && !balD;
	assign branchstall = ((branchD||jumpD) && regwriteE && (writeregE == rsD || writeregE == rtD) || (branchD||jumpD) && memtoregM && (writeregM == rsD || writeregM == rtD));
	assign flushF = ~(i_stall |d_stall) & (flush_except);
	assign flushD = ~(i_stall |d_stall)& (flush_except);
	assign flushE = ~(i_stall |d_stall)& (lwstallD ||jumpD||branchstall||flush_except);

	assign stallF = (i_stall |d_stall) | (flush_except?1'b0:(lwstallD|stall_divE|branchstall));
	assign stallD = (i_stall |d_stall) |(lwstallD | branchstall | stall_divE|i_stall |d_stall);
	assign stallE = (i_stall |d_stall) |(stall_divE|branchstall);
	assign flushM = ~(i_stall |d_stall)& (stall_divE|flush_except);
	
	assign flushW = ~(i_stall |d_stall) & flush_except;
	assign stallM = (i_stall |d_stall) ;
	assign stallW = (i_stall |d_stall) ;
	assign longest_stall = stall_divE| i_stall |d_stall;

	// 例外入口地址统一为32'hBFC00380
	always @(*) begin
        case (excepttypeM)
            32'h00000001,32'h00000004,32'h00000005,32'h00000008,
            32'h00000009,32'h0000000a,32'h0000000c,32'h0000000d: begin
                newpcM <= 32'hBFC00380;
            end
			// eret跳回epc中存放的地址
            32'h0000000e: newpcM <= epc_o;
            default     : newpcM <= 32'hBFC00380;
        endcase
    end
endmodule