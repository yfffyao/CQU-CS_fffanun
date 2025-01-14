`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/22 10:23:13
// Design Name:  
// Module Name: hazard
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


module hazard(
	//fetch stage
	output wire stallF,flushF,
	//decode stage
	input wire[4:0] rsD,rtD,
	input wire branchD,jumpD,
	output wire[1:0] forwardaD,forwardbD,
	output wire stallD,flushD,
	//execute stage
	input wire[4:0] rsE,rtE,rdE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	input wire stall_divE,
	output reg[1:0] forwardaE,forwardbE,
	output wire flushE,stallE,
	output wire forwardcp0E,
	//mem stage
	input wire [4:0] rdM,
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,
	input wire cp0weM,
	input wire [31:0] excepttypeM,
	input wire [31:0] epc_o,
    output wire flushM,
    output reg [31:0] newpcM,
	//write back stage
	input wire[4:0] writeregW,
	input wire regwriteW,
	output wire flush_except,
	output wire flushW
    );

	wire lwstallD,branchstallD;

	//forwarding sources to D stage (branch equality)
	assign forwardaD = ((rsD != 0) && (rsD == writeregM) && regwriteM) ? 2'b10 :
                       ((rsD != 0) && (rsD == writeregE) && regwriteE) ? 2'b01 :
                       2'b00;
    assign forwardbD = ((rtD != 0) && (rtD == writeregM) && regwriteM) ? 2'b10 :
                       ((rtD != 0) && (rtD == writeregE) && regwriteE) ? 2'b01 :
                       2'b00;
	assign flush_except = (excepttypeM != 32'b0);
	assign forwardcp0E = ((rdE!=0)&(rdE == rdM)&(cp0weM))?1'b1:1'b0;
	assign  flushF = (flush_except);
	assign  flushD= (flush_except);
	//forwarding sources to E stage (ALU)

	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			/* code */
			if(rsE == writeregM & regwriteM) begin
				/* code */
				forwardaE = 2'b10;
			end else if(rsE == writeregW & regwriteW) begin
				/* code */
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) begin
			/* code */
			if(rtE == writeregM & regwriteM) begin
				/* code */
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				/* code */
				forwardbE = 2'b01;
			end
		end
	end

	//stalls
	assign lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	//assign #1 branchstallD = (branchD||jumpD) &&
		//		(regwriteE && 
			//	(writeregE == rsD || writeregE == rtD) |
				//memtoregM &&
				//(writeregM == rsD || writeregM == rtD));
	assign branchstallD = ((branchD||jumpD) && regwriteE && (writeregM == rsD || writeregM == rtD) || (branchD||jumpD) && memtoregM && (writeregM == rsD || writeregM == rtD));
	assign stallD = lwstallD | branchstallD|stall_divE;
	assign stallF = flush_except?1'b0:stallD;
	assign stallE = branchstallD | stall_divE;
		//stalling D stalls all previous stages
	assign flushE = lwstallD | branchstallD|flush_except;
	//assign flushE = ~(i_stall |d_stall)& (lwstallD ||jumpD||branchstall||flush_except);
	assign flushM = stall_divE|flush_except;
	assign flushW = flush_except;
		//stalling D flushes next stage
	// Note: not necessary to stall D stage on store
  	//       if source comes from load;
  	//       instead, another bypass network could
  	//       be added from W to M
  	//       ڵ ַͳһΪ32'hBFC00380
	always @(*) begin
        case (excepttypeM)
            32'h00000001,32'h00000004,32'h00000005,32'h00000008,
            32'h00000009,32'h0000000a,32'h0000000c,32'h0000000d: begin
                newpcM <= 32'hBFC00380;
            end
			// eret    epc д ŵĵ ַ
            32'h0000000e: newpcM <= epc_o;
            default     : newpcM <= 32'hBFC00380;
        endcase
    end
endmodule
