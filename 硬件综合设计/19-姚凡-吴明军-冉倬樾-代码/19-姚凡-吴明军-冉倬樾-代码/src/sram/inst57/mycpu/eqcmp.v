`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//  
// Create Date: 2017/11/23 22:57:01
// Design Name: 
// Module Name: eqcmp
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

module eqcmp(
    input [5:0] op,
    input [4:0] rs,
    input [4:0] rt,
	input wire [31:0] a,b,
	output reg y
    );
    always @(*) begin
    case(op)
    `EXE_BEQ:begin
    if(rs==5'b0&&rt==5'b0)  //b
    y<=1'b1;
    else if(a==b) y<=1'b1;
    else y<=1'b0;
    end
    
    `EXE_BNE:begin
    if(a!=b) y<=1'b1;
    else y<=1'b0;
    end
    
    `EXE_BGTZ:begin
    y = ((a[31] == 0) && (a != 32'b0)) ? 1:0;
    end
    
    `EXE_BLEZ:begin
    y = ((a[31] == 1) || (a == 32'b0)) ? 1:0;
    end
    
    6'b000001:case(rt)
    `EXE_BLTZ:begin
   y = (a[31] == 1) ? 1:0;
    end
    
    `EXE_BLTZAL:begin
    y = (a[31] == 1) ? 1:0;
    end
    
    `EXE_BGEZ:begin
    y = (a[31] == 0) ? 1:0;
    end
    
    `EXE_BGEZAL:begin
    if(rs==5'b00000) y<=1'b1;  //bal
    else y = (a[31] == 0) ? 1:0;
    end
    endcase
    
    default:y<=1'b0;
    endcase
    end
    
endmodule
