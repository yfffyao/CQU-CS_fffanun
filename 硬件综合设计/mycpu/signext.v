`timescale 1ns / 1ps

module signext(
    input wire [15:0] a,
    input wire [1:0] typeM,
    output wire [31:0] y
    );
    
    assign y = (typeM == 2'b11)?{{16{1'b0}},a} : {{16{a[15]}},a};

endmodule
