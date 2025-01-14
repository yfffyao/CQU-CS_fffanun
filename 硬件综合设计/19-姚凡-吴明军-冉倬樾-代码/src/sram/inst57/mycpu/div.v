//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 leishangwen@163.com                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    // //
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Module:  div
// File:    div.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description:     ģ  
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.vh"

module div(
	input wire clk,
	input wire rst,
	input wire sign,		//  Ƿ Ϊ з  ų   
	input wire[31:0] a,		//       
	input wire[31:0] b,		//     
	input wire start_i,		//   ʼ ź 
	input wire annul_i,		// ȡ   ź 
	
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

	//           Ǹ     ȡ    
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
				// DivFree  λ״̬    ʾ          
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
				// DivByZero  ʾ      0
		  		`DivByZero: begin
         			dividend <= {`ZeroWord,`ZeroWord};
          			state <= `DivEnd;		 		
		  		end
				// DivOn  ʾ          
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
					// annul_i==1  ʾȡ          
		  			else begin
		  				state <= `DivFree;
		  			end	
		  		end
				// DivEnd  ʾ           
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