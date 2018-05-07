`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2018 10:52:09 PM
// Design Name: 
// Module Name: MVmul_6_6
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


module MVmul_6_6(
    input wire clk,
    output wire valid,
    input wire [1151:0] M1152,
    input wire [191:0] V192,
    output wire [1151:0] P1152
    );

    genvar idx;
    generate
    for (idx = 0; idx < 36; idx = idx + 1)
    begin
        FP_mul FP_mul_inst (
            .aclk(clk),
            .s_axis_a_tdata(M1152[(idx*32) +: 32]),  // M1151[(idx*32)+31 : (idx*32)]
            .s_axis_b_tdata(V192[((idx/6)*32) +: 32]),  // V192[((idx/12)*32)+31 : ((idx/12)*32)]
            .s_axis_a_tvalid(1'b1),
            .s_axis_b_tvalid(1'b1),
            .s_axis_a_tready(),
            .s_axis_b_tready(),
            .m_axis_result_tdata(P1152[(idx*32) +: 32]),
            .m_axis_result_tvalid(valid),
            .m_axis_result_tready(1'b1)
        );
    end
    endgenerate

endmodule
