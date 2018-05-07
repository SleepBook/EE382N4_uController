`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2018 04:36:36 PM
// Design Name: 
// Module Name: dly
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


module dly # (
    parameter integer DATA_WIDTH = 18,
    parameter integer CYC_DLY = 1
)
(
    input wire clk,
    input wire rstn,
    input wire [DATA_WIDTH-1:0] din,
    output wire [DATA_WIDTH-1:0] dout
    );

    reg [DATA_WIDTH-1:0] dlys [CYC_DLY-1:0];

    always @ (posedge clk)
    begin
        if(1'b0 == rstn)
        begin
            dlys[0][DATA_WIDTH-1:0] <= {DATA_WIDTH{1'b0}};
        end
        else
        begin
            dlys[0][DATA_WIDTH-1:0] <= din[DATA_WIDTH-1:0];
        end
    end
    genvar i;
    generate
    for(i = 1; i < CYC_DLY; i = i + 1)
    begin
        always @ (posedge clk)
        begin
            if(1'b0 == rstn)
            begin
                dlys[i][DATA_WIDTH-1:0] <= {DATA_WIDTH{1'b0}};
            end
            else
            begin
                dlys[i][DATA_WIDTH-1:0] <= dlys[i-1][DATA_WIDTH-1:0];
            end
        end
    end
    endgenerate
    assign dout = dlys[CYC_DLY-1][DATA_WIDTH-1:0];

endmodule
