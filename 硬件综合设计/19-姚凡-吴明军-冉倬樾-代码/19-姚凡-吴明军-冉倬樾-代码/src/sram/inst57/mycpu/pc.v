`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/26 21:25:26 
// Design Name: 
// Module Name: pc
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


module pc #(parameter WIDTH = 8)(
	input wire clk,rst,en,clr,
	input wire[WIDTH-1:0] d,
	input wire[WIDTH-1:0] t,
	output reg[WIDTH-1:0] q
    );
	always @(posedge clk,posedge rst) begin
		 if(rst) begin
        q <= 32'hbfc0_0000;
    end else if (clr) begin
        q <= t;
    end else if (en) begin
        q <= d;
    end
	end
endmodule