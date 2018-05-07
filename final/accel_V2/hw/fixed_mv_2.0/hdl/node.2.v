`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2018 08:39:55 PM
// Design Name: 
// Module Name: node
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


module node(
    input wire clk,
    input wire rstn,
    input wire ce,
    input wire sclr,
    input wire subtract,
    input wire [24:0] ain,  // let vector use this
    input wire [17:0] bin,  // let matrix use this
    input wire csel,
    output wire [24:0] aout,
    output wire [24:0] res
    );

    // input buffers
    reg [24:0] bufa;
    reg [17:0] bufb;
    assign aout = bufa;
    always @ (posedge clk)
    begin
        if(1'b0 == rstn)
        begin
            bufa <= 25'd0;
            bufb <= 18'd0;
        end
        else
        begin
            bufa <= ain;
            bufb <= bin;
        end
    end

    // coresel
    //reg coresel;
    //always @ (posedge clk)
    //begin
    //    if(1'b0 == rstn)
    //    begin
    //        coresel <= 0;
    //    end
    //    else
    //    begin
    //        coresel <= ~coresel;
    //    end
    //end

    // DSP MAC cores
    wire [47:0] p0, pcout0;
    wire [47:0] p1, pcout1;
    wire [47:0] cmux0;
    wire [47:0] cmux1;
    assign cmux0 = csel ? pcout1[47:0] : 48'd0;
    assign cmux1 = csel ? pcout0[47:0] : 48'd0;
    MAC dspcore0 (
        .CLK(clk),
        .CE(ce),
        .SCLR(sclr),
        .A(bufa),
        .B(bufb),
        .PCIN(cmux0[47:0]),
        .SUBTRACT(subtract),
        .P(p0),
        .PCOUT(pcout0)
    );
    MAC dspcore1 (
        .CLK(clk),
        .CE(ce),
        .SCLR(sclr),
        .A(bufa),
        .B(bufb),
        .PCIN(cmux1[47:0]),
        .SUBTRACT(subtract),
        .P(p1),
        .PCOUT(pcout1)
    );

    assign res = {p0[47], p0[40:17]};  // MSB should always be 0

endmodule
