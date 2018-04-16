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


module testctrl(

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

    wire mbram_clk, mbram_en, vbram_clk, vbram_en, vbram_we;
    wire [11:0] mbram_addr;
    wire [9:0] vbram_addr;
    wire zero_in, last, rows_done, finish;

    reg running;
    reg [8:0] width;

    Controller # (
        .DELAY_MUL(2),
        .DELAY_ADD(1),
        .DELAY_ACC(3)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .running(running),
        .width(width),
        .mbram_clk(mbram_clk),
        .mbram_en(mbram_en),
        .mbram_addr(mbram_addr),
        .vbram_clk(vbram_clk),
        .vbram_en(vbram_en),
        .vbram_we(vbram_we),
        .vbram_addr(vbram_addr),
        .zero_in(zero_in),
        .last(last),
        .rows_done(rows_done),
        .finish(finish)
    );

    initial
      begin
        running = 0;
        width = 0;
        wait(rstn);
        #40
        running = 1;
        width = 13;
        repeat (80) begin
            @ (posedge clk)
            running = ~finish & running;
        end
        $finish;
      end


endmodule
