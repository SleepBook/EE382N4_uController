`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2018 12:50:55 PM
// Design Name: 
// Module Name: FP_dly
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


module FP_dly #
(
    parameter integer DELAY	= 12
)
(
    input clk,
    input wire [32:0] in,
    output wire [32:0] out
);

    reg [31:0] dly [DELAY-1:0];

    always @ (posedge clk)
    begin
        dly[0] <= in;
    end

    genvar idx;
    generate
    for (idx = 1; idx < DELAY; idx = idx + 1)
    begin
        always @ (posedge clk)
        begin
            dly[idx] <= dly[idx-1];
        end
    end
    endgenerate

    assign out = dly[DELAY-1];

endmodule
