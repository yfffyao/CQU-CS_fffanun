`timescale 1ns / 1ps

module mux2 #(parameter WIDTH=32)(
    input[(WIDTH-1):0] a,b,
    input s,
    output[(WIDTH-1):0] y
 );
 
 assign y = s ? b:a;
endmodule