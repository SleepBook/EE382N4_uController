`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2018 12:30:13 PM
// Design Name: 
// Module Name: AdderTree_1_6
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


module AdderTree_1_6(
    input clk,
    output valid,
    input [191:0] R192,
    output [31:0] S32
    );

    wire [4:0] valids;
    wire [31:0] sum01;
    wire [31:0] sum23;
    wire [31:0] sum45;
    wire [31:0] sum03;
    wire [31:0] dly45;

    assign valid = &valids;
    // level 0
    FP_add add01(
        .aclk(clk),
        .s_axis_a_tdata(R192[32*0 +: 32]), 
        .s_axis_b_tdata(R192[32*1 +: 32]),
        .s_axis_a_tvalid(1'b1),
        .s_axis_b_tvalid(1'b1),
        .s_axis_a_tready(),
        .s_axis_b_tready(),
        .m_axis_result_tdata(sum01),
        .m_axis_result_tvalid(valids[0]),
        .m_axis_result_tready(1'b1)
    );
    FP_add add23(
        .aclk(clk),
        .s_axis_a_tdata(R192[32*2 +: 32]), 
        .s_axis_b_tdata(R192[32*3 +: 32]),
        .s_axis_a_tvalid(1'b1),
        .s_axis_b_tvalid(1'b1),
        .s_axis_a_tready(),
        .s_axis_b_tready(),
        .m_axis_result_tdata(sum23),
        .m_axis_result_tvalid(valids[2]),
        .m_axis_result_tready(1'b1)
    );
    FP_add add45(
        .aclk(clk),
        .s_axis_a_tdata(R192[32*4 +: 32]), 
        .s_axis_b_tdata(R192[32*5 +: 32]),
        .s_axis_a_tvalid(1'b1),
        .s_axis_b_tvalid(1'b1),
        .s_axis_a_tready(),
        .s_axis_b_tready(),
        .m_axis_result_tdata(sum45),
        .m_axis_result_tvalid(valids[4]),
        .m_axis_result_tready(1'b1)
    );
    // level 1
    FP_add add03(
        .aclk(clk),
        .s_axis_a_tdata(sum01), 
        .s_axis_b_tdata(sum23),
        .s_axis_a_tvalid(1'b1),
        .s_axis_b_tvalid(1'b1),
        .s_axis_a_tready(),
        .s_axis_b_tready(),
        .m_axis_result_tdata(sum03),
        .m_axis_result_tvalid(valids[1]),
        .m_axis_result_tready(1'b1)
    );
    FP_dly # (
        .DELAY(12)
    ) dly(
        .clk(clk),
        .in(sum45),
        .out(dly45)
    );
    // level 2
    FP_add add05(
        .aclk(clk),
        .s_axis_a_tdata(sum03), 
        .s_axis_b_tdata(dly45),
        .s_axis_a_tvalid(1'b1),
        .s_axis_b_tvalid(1'b1),
        .s_axis_a_tready(),
        .s_axis_b_tready(),
        .m_axis_result_tdata(S32),
        .m_axis_result_tvalid(valids[3]),
        .m_axis_result_tready(1'b1)
    );


endmodule
