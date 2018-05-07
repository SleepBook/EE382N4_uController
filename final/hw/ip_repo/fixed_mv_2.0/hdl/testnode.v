`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2018 08:54:25 PM
// Design Name: 
// Module Name: testnode
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


module testnode(

    );

    reg clk = 0;
    always #5
    begin
        clk = ~clk;
    end

    reg rstn;
    initial
    begin
        rstn = 1'b0;
        #10
        rstn = 1'b1;
    end

    reg sclr;
    initial
    begin
        sclr = 1'b1;
        #45
        sclr = 1'b0;
        //#145
        //sclr = 1'b1;
    end

    reg [24:0] ain;
    reg [17:0] bin;
    reg csel;

    wire [24:0] aout;
    wire [24:0] res;

    node dut (
        .clk(clk),
        .rstn(rstn),
        .ce(1'b1),
        .sclr(sclr),
        .subtract(1'b0),
        .ain(ain),
        .bin(bin),
        .csel(csel),
        .aout(aout),
        .res(res)
    );

    initial
    begin
        wait(~rstn)
        wait(~sclr);
        //@(posedge clk)
        ain = 25'h000AAAA;  // 0.333328
        bin = 18'h04000;  // 0.125
        csel = 1'b0;
        @(posedge clk)
        ain = 25'h000AAAA;
        bin = 18'h02020;  // 0.0627441
        @(posedge clk)
        ain = 25'h000AAAA;
        bin = 18'h02017;  // 0.0626755
        csel = 1'b1;  // start accumulation
        @(posedge clk)
        ain = 25'h0008000;  // 0.5
        bin = 18'h18000;  // 0.75
        @(posedge clk)
        ain = 25'h0008000;
        bin = 18'h14000;  // 0.625
        @(posedge clk)
        ain = 25'd0;
        bin = 18'd0;
        csel = 1'b0;  // restart accumulation
        @(posedge clk)
        csel = 1'b1;  // accumulate
        @(posedge clk)
        csel = 1'b0;  // restart
        @(posedge clk)
        #20
        //@(posedge clk)
        //ain = 25'h0000008;
        //bin = 18'h00002;
        //@(posedge clk)
        //ain = 25'h0000080;
        //bin = 18'h00020;
        //@(posedge clk)
        //ain = 25'h0000800;
        //bin = 18'h00200;
        //csel = 1'b1;
        //@(posedge clk)
        //ain = 25'h0000321;
        //bin = 18'h00123;
        //@(posedge clk)
        //ain = 25'h0002000;
        //bin = 18'h00001;
        //csel = 1'b0;  // only accumulate two
        //#50
        $finish;
    end

endmodule
