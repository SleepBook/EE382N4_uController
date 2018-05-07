`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2018 09:25:06 PM
// Design Name: 
// Module Name: testctrl
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


module testctrl # (
    parameter integer IDX_WIDTH_FOR_NODES = 3,
    parameter integer NUM_NODES = 2 ** IDX_WIDTH_FOR_NODES,
    parameter integer DELAY_BUF = 1,
    parameter integer DELAY_MAC = 3,
    parameter integer DELAY_CIN = 1,
    parameter integer DELAY_SEL = 1
)
(
    );

    reg clk = 0;
    always #5 clk = ~clk;
    reg rstn = 0;
    initial
    begin
        rstn = 0;
        #20
        rstn = 1;
    end

    wire mbram_clk, mbram_en;
    wire vbram0_clk, vbram0_en, vbram0_we;
    wire vbram1_clk, vbram1_en, vbram1_we;
    wire [11:0] mbram_addr;
    wire [9:0] vbram0_addr;
    wire [9:0] vbram1_addr;

    wire [NUM_NODES-1:0] sclrs;
    wire [1:0] asel;
    wire [NUM_NODES-1:0] csels;
    wire [IDX_WIDTH_FOR_NODES-1:0] ressel;
    wire [1:0] dinsel;
    wire finish;

    reg running;
    reg [8:0] width;
    reg [15:0] iteration;

    Controller # (
        .IDX_WIDTH_FOR_NODES(IDX_WIDTH_FOR_NODES),
        .NUM_NODES(NUM_NODES),
        .DELAY_BUF(DELAY_BUF),
        .DELAY_MAC(DELAY_MAC),
        .DELAY_CIN(DELAY_CIN),
        .DELAY_SEL(DELAY_SEL)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .running(running),
        .width(width),
        .iteration(iteration),
        .mbram_clk(mbram_clk),
        .mbram_en(mbram_en),
        .mbram_addr(mbram_addr),
        .vbram0_clk(vbram0_clk),
        .vbram0_en(vbram0_en),
        .vbram0_we(vbram0_we),
        .vbram0_addr(vbram0_addr),
        .vbram1_clk(vbram1_clk),
        .vbram1_en(vbram1_en),
        .vbram1_we(vbram1_we),
        .vbram1_addr(vbram1_addr),
        .sclrs(sclrs),  // clear mac in a node independently
        .asel(asel),  // select ain for the first node
        .csels(csels),  // select c for a node independently
        .ressel(ressel),  // select a result of one node to bram
        .dinsel(dinsel),  // select din to brams
        .finish(finish)
    );

    initial
      begin
        running <= 0;
        width <= 0;
        iteration <= 0;
        wait(rstn);
        #40
        //@ (posedge clk)
        //running <= 1;
        //width <= 17;
        //iteration <= 1;
        //repeat (120) begin
        //    @ (posedge clk)
        //    running <= ~finish & running;
        //end
        @ (posedge clk)
        //running = 1;
        //width = 28;
        //iteration = 1;
        //repeat (80) begin
        //    @ (posedge clk)
        //    running = ~finish & running;
        //end
        @ (posedge clk)
        running <= 1;
        width <= 17;
        iteration <= 3;
        repeat (180) begin
            @ (posedge clk)
            running <= ~finish & running;
        end
        @ (posedge clk)
        running <= 1;
        width <= 24;
        iteration <= 3;
        repeat (280) begin
            @ (posedge clk)
            running <= ~finish & running;
        end
        $finish;
      end


endmodule
