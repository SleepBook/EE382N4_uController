`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2018 01:26:31 PM
// Design Name: 
// Module Name: Acc_6
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


module Acc_6(
    input clk,
    input last,
    output valid,
    input [191:0] V192,
    output [191:0] A192
    );

    genvar idx;
    generate
    for (idx = 0; idx < 6; idx = idx + 1)
    begin
        FP_acc FP_acc_inst (
            .aclk(clk),
            .s_axis_a_tdata(V192[(idx*32) +: 32]),
            .s_axis_a_tvalid(1'b1),
            .s_axis_a_tlast(last),
            .s_axis_a_tready(),
            .m_axis_result_tdata(A192[(idx*32) +: 32]),
            .m_axis_result_tvalid(valid),
            .m_axis_result_tready(1'b1)
        );
    end
    endgenerate
endmodule
