`timescale 1ns / 1ps

module flopenrc #(parameter WIDTH = 8)(
	input wire clk,rst,en,clr,
	input wire [WIDTH-1:0] d,
	output reg [WIDTH-1:0] q
	);
	
	always @(posedge clk,posedge rst) begin
		if(rst) begin
			q <= 0;
			end
		else if(clr) begin
			q <= 0;
		end
		else if(en) begin
			q <= d;
		end
	end	
	
endmodule
