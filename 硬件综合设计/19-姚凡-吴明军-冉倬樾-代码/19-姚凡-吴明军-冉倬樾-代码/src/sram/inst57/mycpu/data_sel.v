`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/30 14:00:17 
// Design Name: 
// Module Name: data_sel
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

module data_sel(
input [31:0] pc,
input [31:0] addr, // ڴ  ַ
input [31:0] w_data,  //д    
input [31:0] r_data,  //      
input [5:0] op,
output reg [31:0] w_out,  //д    
output reg [31:0] r_out,
output reg [3:0] w_en,
output reg adesM,adelM,
output reg [31:0] bad_addr
    );
    always@(*)
    begin
        adesM <= 1'b0;
        adelM <= 1'b0;
        bad_addr <= pc;
        case(op)
            `EXE_LW: begin
                if(addr[1:0]!=2'b00) begin
                    adelM <= 1'b1;
                    bad_addr <= addr;
                end
            end
            `EXE_SW: begin
                if(addr[1:0]!=2'b00) begin
                    adesM <= 1'b1;
                    bad_addr <= addr;
                    
                end
            end
            `EXE_LH: begin
                if(addr[0]!=0) begin
                    adelM <= 1'b1;
                    bad_addr <= addr;
                end
            end
            `EXE_LHU: begin
                if(addr[0]!=0) begin
                    adelM <= 1'b1;
                    bad_addr <= addr;
                end
            end
            `EXE_SH: begin
                if(addr[0]!=0) begin
                    adesM <= 1'b1;
                    bad_addr <= addr;
                end
            end
        endcase
    end

    always@(*)
    if(adelM!=1'b1)
    begin
    case(op)
    `EXE_LB:begin
    case(addr[1:0])
      2'b00:r_out<={{24{r_data[7]}},r_data[7:0]};
      2'b01:r_out<={{24{r_data[15]}},r_data[15:8]};
      2'b10:r_out<={{24{r_data[23]}},r_data[23:16]};
      2'b11:r_out<={{24{r_data[31]}},r_data[31:24]};
      endcase
    end
    `EXE_LBU:begin
    case(addr[1:0])
      2'b00:r_out<={24'b0,r_data[7:0]};
      2'b01:r_out<={24'b0,r_data[15:8]};
      2'b10:r_out<={24'b0,r_data[23:16]};
      2'b11:r_out<={24'b0,r_data[31:24]};
      default:r_out<=r_data;
      endcase
    end
    `EXE_LH:begin
    case(addr[1:0])
      2'b00:r_out<={{16{r_data[15]}},r_data[15:0]};
      2'b10:r_out<={{16{r_data[31]}},r_data[31:16]};
      default:r_out<=r_data;
      endcase
    end
    `EXE_LHU:begin
    case(addr[1:0])
      2'b00:r_out<={16'b0,r_data[15:0]};
      2'b10:r_out<={16'b0,r_data[31:16]};
      default:r_out<=r_data;
      endcase
    end
    `EXE_LW:begin
    r_out<=r_data;
    end
    default:r_out<=r_data;
    endcase
    end
    
    always@(*)
    begin
    case(op)
    `EXE_SB:begin
        if(adesM==1'b1)
        w_en<=4'b0;
        else begin
      case(addr[1:0])
      2'b00:w_en<=4'b0001;
      2'b01:w_en<=4'b0010;
      2'b10:w_en<=4'b0100;
      2'b11:w_en<=4'b1000;
      endcase
      w_out<={4{w_data[7:0]}};
      end
    end
    
    `EXE_SH:begin
    if(adesM==1'b1)
    w_en<=4'b0;
    else begin
      case(addr[1:0])
      2'b00:w_en<=4'b0011;
      2'b10:w_en<=4'b1100;
      endcase
      w_out<={2{w_data[15:0]}};
      end
    end
    
    `EXE_SW:begin
    if(adesM==1'b1)
    w_en<=4'b0;
    else begin
    w_en<=4'b1111;
    w_out<=w_data;
    end
    end
    default:begin
    w_en<=4'b0000;
    w_out<=w_data;
    end
    endcase

    end
    
endmodule
