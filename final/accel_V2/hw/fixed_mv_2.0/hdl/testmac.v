`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2018 08:54:25 PM
// Design Name: 
// Module Name: testmac
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


module testmac(

    );

    reg clk = 0;
    always #5
    begin
        clk = ~clk;
    end

    reg sclr;
    initial
    begin
        sclr = 1'b1;
        #10
        sclr = 1'b0;
        #145
        sclr = 1'b1;
    end

    reg [24:0] a;
    reg [17:0] b;
    reg [47:0] pcin;
    wire [47:0] p;
    wire [47:0] pcout;

    MAC dut (
        .CLK(clk),
        .CE(1'b1),
        .SCLR(sclr),
        .A(a),
        .B(b),
        .PCIN(pcin),
        .P(p),
        .PCOUT(pcout)
    );

    initial
    begin
        wait(~sclr);
        @(posedge clk)
        a = 25'h0000002;
        b = 18'h00003;
        @(posedge clk)
        a = 25'h0000004;
        b = 18'h00005;
        @(posedge clk)
        a = 25'h0000000;
        b = 18'h00009;
        pcin = 48'h000000000000;
        @(posedge clk)
        a = 25'h1000001;
        b = 18'h00007;
        pcin = 48'h000000000006;
        @(posedge clk)
        a = 25'h0000010;
        b = 18'h20002;
        pcin = 48'h00000000001A;
        @(posedge clk)
        a = 25'd0;
        b = 18'd0;
        pcin = 48'd0;
        #50
        @(posedge clk)
        a = 25'h0000008;
        b = 18'h00002;
        @(posedge clk)
        a = 25'h0000080;
        b = 18'h00020;
        @(posedge clk)
        a = 25'h0000800;
        b = 18'h00200;
        pcin = 48'h000000000001;
        @(posedge clk)
        a = 25'h0000321;
        b = 18'h00123;
        pcin = 48'h000000000011;
        @(posedge clk)
        a = 25'h0002000;
        b = 18'h00001;
        pcin = 48'h000000000111;
        #50
        $finish;
    end

endmodule
