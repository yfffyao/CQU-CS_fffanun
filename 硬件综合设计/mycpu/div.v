`include "defines2.vh"

module div(
	input wire clk,
	input wire rst,
	input wire sign,		// 是否为有符号除法
	input wire[31:0] a,		// 被除数
	input wire[31:0] b,		// 除数
	input wire start_i,		// 开始信号
	input wire annul_i,		// 取消信号
	
	output reg[63:0] result,
	output reg ready_out
);

	wire[32:0] div_temp;
	wire[31:0] tmp_a,tmp_b;
	reg[1:0] state;
	reg[5:0] cnt;
	reg[64:0] dividend;
	reg[31:0] divisor;	 
	reg tmp_sign1,tmp_sign2;

	assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};

	// 如果操作数是负数则取补码
	assign tmp_a= (sign == 1'b1 && a[31] == 1'b1) ? (~a + 1):a;
        assign tmp_b= (sign == 1'b1 && b[31] == 1'b1) ? (~b + 1):b;

	always @ (posedge clk) 
	begin
		if (rst == `RstEnable) begin
			state <= `DivFree;
			ready_out <= `DivResultNotReady;
			result <= {`ZeroWord,`ZeroWord};
		end 
		else begin
		  	case (state)
				// DivFree复位状态，表示除法器空闲
		  		`DivFree: begin
		  			if(start_i == `DivStart && annul_i == 1'b0) begin
		  				if(b == `ZeroWord) begin
		  					state <= `DivByZero;
		  				end 
		  				else begin
		  					state <= `DivOn;
		  					cnt <= 6'b000000;
		  					dividend <= {`ZeroWord,`ZeroWord};
            	  			dividend[32:1] <= tmp_a;
            	  			divisor <= tmp_b;
							tmp_sign1<=a[31];
							tmp_sign2<=b[31];
            	 		end
          			end 
          			else 
          			begin
						ready_out <= `DivResultNotReady;
						result <= {`ZeroWord,`ZeroWord};
				  	end          	
		  		end
				// DivByZero表示除数是0
		  		`DivByZero: begin
         			dividend <= {`ZeroWord,`ZeroWord};
          			state <= `DivEnd;		 		
		  		end
				// DivOn表示除法进行中
		  		`DivOn: begin
		  			if(annul_i == 1'b0) begin
		  				if(cnt != 6'b100000) begin
            	   			if(div_temp[32] == 1'b1) begin
            	      			dividend <= {dividend[63:0] , 1'b0};
            	   			end 
            	   			else begin
            	      			dividend <= {div_temp[31:0] , dividend[31:0] , 1'b1};
            	   			end
            	   			cnt <= cnt + 1;
            	 		end 
            	 		else begin
	            	    	if((sign == 1'b1) && ((tmp_sign1 ^ tmp_sign2) == 1'b1)) begin
	            	    	   dividend[31:0] <= (~dividend[31:0] + 1);
	            	    	end
	            	    	if((sign == 1'b1) && ((tmp_sign1 ^ dividend[64]) == 1'b1)) begin              
	            	       		dividend[64:33] <= (~dividend[64:33] + 1);
	            	    	end
	            	    	state <= `DivEnd;
	            	    	cnt <= 6'b000000;             	
            	 		end
		  			end 
					// annul_i==1表示取消除法运算
		  			else begin
		  				state <= `DivFree;
		  			end	
		  		end
				// DivEnd表示除法运算结束
		  		`DivEnd: begin
        			result <= {dividend[64:33], dividend[31:0]};  
          			ready_out <= `DivResultReady;
          			if(start_i == `DivStop) begin
          				state <= `DivFree;
						ready_out <= `DivResultNotReady;
						result <= {`ZeroWord,`ZeroWord};       	
          			end		  	
		  		end
		  	endcase
		end
	end
endmodule