`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:52:16
// Design Name:  
// Module Name: alu
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
`include"defines.vh"

module alu(
    input wire clk,rst,
	input wire[31:0] a,b,
	input wire[7:0] op,
	input wire[4:0] sa,
	input wire[63:0] hilo_in,
	input wire[31:0] cp0data,
	output reg[63:0] hilo_out,
	output reg[31:0] y,
	output reg stall_div,
	output wire overflow,
	output wire zero
    );

    wire [31:0]mult_a,mult_b;
    reg [63:0] mult_result;
    assign mult_a=((op == `EXE_MULT_OP) && (a[31] == 1'b1)) ? (~a + 1): a;
    assign mult_b=((op == `EXE_MULT_OP) && (b[31] == 1'b1)) ? (~b + 1): b;

    reg signed_div,start_div;
    wire div_ready;
    wire [63:0] div_result;
    div div(clk,rst,signed_div,a,b,start_div,1'b0,div_result,div_ready);

	
	always @(*) begin
		start_div <= 1'b0;
        signed_div <= 1'b0;
        stall_div <=1'b0;
		case (op)
		    `EXE_AND_OP: y <= a & b;
            `EXE_OR_OP: y <= a | b;
			
			`EXE_ANDI_OP:y<=a&b;
			`EXE_XORI_OP:y<=a^b;
			`EXE_LUI_OP:y<={b[15:0],16'b0};
			`EXE_ORI_OP:y<=a|b;
			`EXE_AND_OP: y <= a & b;
            `EXE_OR_OP: y <= a | b;
            `EXE_XOR_OP:y <= a ^ b;
            `EXE_NOR_OP: y <= ~(a|b);
            `EXE_SLL_OP:y <= b << sa;
            `EXE_SRL_OP:y <= b >> sa;
            `EXE_SRA_OP: y <= $signed(b) >>> sa[4:0];
            `EXE_SLLV_OP: y <= b << a[4:0];
            `EXE_SRLV_OP: y <= b >> a[4:0];
            `EXE_SRAV_OP: y <= $signed(b) >>> a[4:0];
            
            `EXE_LB_OP: y <= a + b;
            `EXE_LBU_OP: y <= a + b;
            `EXE_LH_OP: y <= a + b;
            `EXE_LHU_OP: y <= a + b;
            `EXE_LW_OP: y <= a + b;
            `EXE_SB_OP: y <= a + b;
            `EXE_SH_OP: y <= a + b;
            `EXE_SW_OP: y <= a + b;
            
            //      ƶ 
            `EXE_MFHI_OP: y <= hilo_in[63:32];
            `EXE_MFLO_OP: y <= hilo_in[31:0];
            `EXE_MTHI_OP: hilo_out <= {a[31:0],{hilo_in[31:0]}};
            `EXE_MTLO_OP: hilo_out <= {{hilo_in[63:32]},a[31:0]};
            //  Ȩָ  
            `EXE_MFC0_OP: y <= cp0data;
            `EXE_MTC0_OP: y <= b;
            //    
            `EXE_ADD_OP: y <= a + b;
            `EXE_ADDU_OP: y <= a + b;
            `EXE_SUB_OP: y <= a - b;
            `EXE_SUBU_OP: y <= a - b;
            `EXE_SLT_OP: y <= $signed(a) < $signed(b);
            `EXE_SLTU_OP: y <= a < b;
            `EXE_ADDI_OP: y <= a + b;
            `EXE_ADDIU_OP: y <= a + b;
            `EXE_SLTIU_OP: y <= a < b;
            `EXE_SLTI_OP: 
              begin 
                if(a[31]==1'b0)begin
                    if(b[31]==1'b1) begin y <= 1'b0;end
                    else if(a < b) begin y <= 1'b1;end
                    else begin y <= 1'b0;end
                end
                else begin
                    if(b[31]==1'b0) begin y <= 1'b1;end
                    else if(a < b) begin y <= 1'b1;end
                    else begin y <= 1'b0;end
                end
              end
            `EXE_MULT_OP: mult_result <= (a[31] ^ b[31] == 1'b1)? ~(mult_a * mult_b) + 1 : mult_a * mult_b;
	        `EXE_MULTU_OP : mult_result <= mult_a * mult_b;
            `EXE_DIV_OP: begin
                if(div_ready == 1'b0) begin
                    start_div <= 1'b1;
                    signed_div <= 1'b1;
                    stall_div <=1'b1;
                end
                else if (div_ready == 1'b1) begin
                    start_div <= 1'b0;
                    signed_div <= 1'b1;
                    stall_div <=1'b0;
                end
                else begin
                    start_div <= 1'b0;
                    signed_div <= 1'b0;
                    stall_div <=1'b0;
                end
            end
            `EXE_DIVU_OP: begin
                if(div_ready == 1'b0) begin
                    start_div <= 1'b1;
                    signed_div <= 1'b0;
                    stall_div <=1'b1;
                end
                else if (div_ready == 1'b1) begin
                    start_div <= 1'b0;
                    signed_div <= 1'b0;
                    stall_div <=1'b0;
                end
                else begin
                    start_div <= 1'b0;
                    signed_div <= 1'b0;
                    stall_div <=1'b0;
                end
            end

			default : y <= 32'b0;
		endcase	
	end
	always @(*) begin
	  case(op)
       `EXE_DIVU_OP,`EXE_DIV_OP: hilo_out<= div_result;
	   `EXE_MULT_OP,`EXE_MULTU_OP: hilo_out<= mult_result;
	   endcase
	end

	/*always @(*) begin
		case (op[1:0])
			2'b00: y <= a & bout;
			2'b01: y <= a | bout;
			2'b10: y <= s;
			2'b11: y <= s[31];
			default : y <= 32'b0;
		endcase	
	end*/
	assign zero = (y == 32'b0);

	/*always @(*) begin
		case (op[2:1])
			2'b01:overflow <= a[31] & b[31] & ~s[31] |
							~a[31] & ~b[31] & s[31];
			2'b11:overflow <= ~a[31] & b[31] & s[31] |
							a[31] & ~b[31] & ~s[31];
			default : overflow <= 1'b0;
		endcase	
	end*/
	 // ֻ  add,addi,subָ      
    assign overflow = ((op==`EXE_ADD_OP)|(op==`EXE_ADDI_OP))
                        ?((a[31] & b[31] & ~y[31] )|( ~a[31] & ~b[31] & y[31])):(op==`EXE_SUB_OP)
                        ?((a[31] & ~b[31]& ~y[31])| (~a[31] & b[31] & y[31])):1'b0;
endmodule
