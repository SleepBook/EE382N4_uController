`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2018 09:25:06 PM
// Design Name: 
// Module Name: testcnt
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


module testcnt # (
    parameter integer BRAM_WIDTH = 2304,
    parameter integer AXI_WIDTH = 32
)(

    );

    localparam NUM_REGS = (BRAM_WIDTH % AXI_WIDTH) ? (BRAM_WIDTH / AXI_WIDTH + 1) : (BRAM_WIDTH / AXI_WIDTH);

    reg clk = 0;
    always #5 clk = ~clk;

    reg rstn = 0;
    initial
    begin
        rstn = 0;
        #20
        rstn = 1;
        #200
        rstn = 0;
        #10
        rstn = 1;
    end

    wire ov;

    reg cnt;
    reg [11:0] max;

    step_counter step_counter_dut (
        .clk(clk),
        .rstn(rstn),
        .cnt(cnt),
        .max(max),
        .ov(ov)
    );

    initial
      begin
        max = 12'h00D;
        wait(rstn);
        cnt = 1;
        #40
        cnt = 0;
        #10
        cnt = 1;
        #20
        cnt = 0;
        #10
        max = 12'h03C;
        cnt = 1;
        #320
        $finish;
      end


endmodule
