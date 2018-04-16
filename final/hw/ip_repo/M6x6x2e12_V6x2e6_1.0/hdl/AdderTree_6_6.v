`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2018 12:14:00 PM
// Design Name: 
// Module Name: AdderTree_6_6
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


module AdderTree_6_6(
    input clk,
    output wire valid,
    input [1151:0] M1152,
    output [191:0] S192
    );

    wire [5:0] valids;
    assign valid = &valids;

    genvar idx;
    generate
    for (idx = 0; idx < 6; idx = idx + 1)
    begin
        AdderTree_1_6 adder_tree (
            .clk(clk),
            .valid(valids[idx]),
            .R192(
                {
                    M1152[(idx*32)+192*5 +: 32],
                    M1152[(idx*32)+192*4 +: 32],
                    M1152[(idx*32)+192*3 +: 32],
                    M1152[(idx*32)+192*2 +: 32],
                    M1152[(idx*32)+192*1 +: 32],
                    M1152[(idx*32)+192*0 +: 32]
                }),
            .S32(S192[(idx*32) +: 32])
        );
    end
    endgenerate

endmodule
