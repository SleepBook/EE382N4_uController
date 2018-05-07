`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2018 08:54:25 PM
// Design Name: 
// Module Name: testmesh
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


module testmesh # (
    parameter integer IDX_WIDTH_FOR_NODES = 2,
    parameter integer NUM_NODES = 2 ** IDX_WIDTH_FOR_NODES
)
(

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

    reg sclrs [NUM_NODES-1:0];

    reg [24:0] init;
    reg [17:0] mbram_dout [NUM_NODES-1:0];
    reg [1:0] asel;
    reg csels [NUM_NODES-1:0];
    reg [IDX_WIDTH_FOR_NODES-1:0] ressel;
    reg [1:0] dinsel;
    reg [24:0] vbram_dout[1:0];

    wire [24:0] vbram_din [1:0];

    mesh # (
        .IDX_WIDTH_FOR_NODES(IDX_WIDTH_FOR_NODES)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .sclrs({sclrs[3],sclrs[2],sclrs[1],sclrs[0]}),
        .init(init),
        .asel(asel),
        .csels({csels[3],csels[2],csels[1],csels[0]}),
        .ressel(ressel),
        .dinsel(dinsel),
        .mbram_dout({mbram_dout[3][17:0],mbram_dout[2][17:0],mbram_dout[1][17:0],mbram_dout[0][17:0]}),
        .vbram0_dout(vbram_dout[0][24:0]),
        .vbram1_dout(vbram_dout[1][24:0]),
        .vbram0_din(vbram_din[0]),
        .vbram1_din(vbram_din[1])
    );

    reg [17:0] row0 [7:0];
    reg [17:0] row1 [7:0];
    reg [17:0] row2 [7:0];
    reg [17:0] row3 [7:0];
    reg [17:0] row4 [7:0];
    reg [17:0] row5 [7:0];
    reg [17:0] row6 [7:0];
    reg [17:0] row7 [7:0];
    
    initial
    begin
        row0[0] = 18'h00001;
        row1[0] = 18'h00002;
        row2[0] = 18'h00003;
        row3[0] = 18'h00004;

        row0[1] = 18'h00010;
        row1[1] = 18'h00020;
        row2[1] = 18'h00030;
        row3[1] = 18'h00040;

        row0[2] = 18'h00040;
        row1[2] = 18'h00030;
        row2[2] = 18'h00020;
        row3[2] = 18'h00010;

        row0[3] = 18'h00004;
        row1[3] = 18'h00003;
        row2[3] = 18'h00002;
        row3[3] = 18'h00001;

        row0[4] = 18'h00003;
        row1[4] = 18'h00004;
        row2[4] = 18'h00001;
        row3[4] = 18'h00002;

        row0[5] = 18'h00030;
        row1[5] = 18'h00040;
        row2[5] = 18'h00010;
        row3[5] = 18'h00020;

        row0[6] = 18'h00020;
        row1[6] = 18'h00010;
        row2[6] = 18'h00040;
        row3[6] = 18'h00030;

        row0[7] = 18'h00002;
        row1[7] = 18'h00001;
        row2[7] = 18'h00004;
        row3[7] = 18'h00003;

        row4[0] = 18'h00009;
        row5[0] = 18'h00008;
        row6[0] = 18'h00007;
        row7[0] = 18'h00006;

        row4[1] = 18'h00008;
        row5[1] = 18'h00000;
        row6[1] = 18'h00007;
        row7[1] = 18'h00006;

        row4[2] = 18'h00006;
        row5[2] = 18'h00007;
        row6[2] = 18'h00000;
        row7[2] = 18'h00008;

        row4[3] = 18'h00000;
        row5[3] = 18'h00006;
        row6[3] = 18'h00008;
        row7[3] = 18'h00009;

        row4[4] = 18'h00016;
        row5[4] = 18'h00027;
        row6[4] = 18'h00038;
        row7[4] = 18'h00049;

        row4[5] = 18'h00061;
        row5[5] = 18'h00072;
        row6[5] = 18'h00083;
        row7[5] = 18'h00094;

        row4[6] = 18'h00091;
        row5[6] = 18'h00082;
        row6[6] = 18'h00073;
        row7[6] = 18'h00064;

        row4[7] = 18'h00094;
        row5[7] = 18'h00083;
        row6[7] = 18'h00072;
        row7[7] = 18'h00061;
    end

    initial
    begin
        wait(~rstn)
        @(posedge clk)
        sclrs[0] = 1'b1;  // clear all nodes
        sclrs[1] = 1'b1;  // clear all nodes
        sclrs[2] = 1'b1;  // clear all nodes
        sclrs[3] = 1'b1;  // clear all nodes
        csels[0] = 1'b0;  // dosn't matter at this time actually
        csels[1] = 1'b0;  // dosn't matter at this time actually
        csels[2] = 1'b0;  // dosn't matter at this time actually
        csels[3] = 1'b0;  // dosn't matter at this time actually
        @(posedge clk)
        sclrs[0] = 1'b0;  // put the first node into computations
        sclrs[1] = 1'b1;  // put the first node into computations
        sclrs[2] = 1'b1;  // put the first node into computations
        sclrs[3] = 1'b1;  // put the first node into computations
        asel = 2'b10;  // use init as ain
        init = 25'h0000002;
        mbram_dout[0] = row0[0];  // first column of matrix
        mbram_dout[1] = row1[0];  // first column of matrix
        mbram_dout[2] = row2[0];  // first column of matrix
        mbram_dout[3] = row3[0];  // first column of matrix
        @(posedge clk)  // first latch into MAC
        sclrs[0] = 1'b0;  // put second node into computations as well
        sclrs[1] = 1'b0;  // put second node into computations as well
        sclrs[2] = 1'b1;  // put second node into computations as well
        sclrs[3] = 1'b1;  // put second node into computations as well
        mbram_dout[0] = row0[1];  // second column of matrix
        mbram_dout[1] = row1[1];  // second column of matrix
        mbram_dout[2] = row2[1];  // second column of matrix
        mbram_dout[3] = row3[1];  // second column of matrix
        @(posedge clk)
        sclrs[0] = 1'b0;  // put third node into computations as well
        sclrs[1] = 1'b0;  // put third node into computations as well
        sclrs[2] = 1'b0;  // put third node into computations as well
        sclrs[3] = 1'b1;  // put third node into computations as well
        mbram_dout[0] = row0[2];  // third column of matrix
        mbram_dout[1] = row1[2];  // third column of matrix
        mbram_dout[2] = row2[2];  // third column of matrix
        mbram_dout[3] = row3[2];  // third column of matrix
        csels[0] = 1'b0;  // use 0 to start
        @(posedge clk)
        sclrs[0] = 1'b0;  // put all nodes into computations
        sclrs[1] = 1'b0;  // put all nodes into computations
        sclrs[2] = 1'b0;  // put all nodes into computations
        sclrs[3] = 1'b0;  // put all nodes into computations
        mbram_dout[0] = row0[3];  // forth column of matrix
        mbram_dout[1] = row1[3];  // forth column of matrix
        mbram_dout[2] = row2[3];  // forth column of matrix
        mbram_dout[3] = row3[3];  // forth column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b0;  // use 0 to start
        @(posedge clk)
        mbram_dout[0] = row0[4];  // fifth column of matrix
        mbram_dout[1] = row1[4];  // fifth column of matrix
        mbram_dout[2] = row2[4];  // fifth column of matrix
        mbram_dout[3] = row3[4];  // fifth column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b0;  // use 0 to start
        @(posedge clk)
        mbram_dout[0] = row0[5];  // sixth column of matrix
        mbram_dout[1] = row1[5];  // sixth column of matrix
        mbram_dout[2] = row2[5];  // sixth column of matrix
        mbram_dout[3] = row3[5];  // sixth column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b0;  // use 0 to start
        @(posedge clk)
        mbram_dout[0] = row0[6];  // seventh column of matrix
        mbram_dout[1] = row1[6];  // seventh column of matrix
        mbram_dout[2] = row2[6];  // seventh column of matrix
        mbram_dout[3] = row3[6];  // seventh column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(posedge clk)
        mbram_dout[0] = row0[7];  // eighth column of matrix
        mbram_dout[1] = row1[7];  // eighth column of matrix
        mbram_dout[2] = row2[7];  // eighth column of matrix
        mbram_dout[3] = row3[7];  // eighth column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(posedge clk)
        mbram_dout[0] = row4[0];  // first column of matrix
        mbram_dout[1] = row5[0];  // first column of matrix
        mbram_dout[2] = row6[0];  // first column of matrix
        mbram_dout[3] = row7[0];  // first column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(posedge clk)
        mbram_dout[0] = row4[1];  // second column of matrix
        mbram_dout[1] = row5[1];  // second column of matrix
        mbram_dout[2] = row6[1];  // second column of matrix
        mbram_dout[3] = row7[1];  // second column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(posedge clk)
        mbram_dout[0] = row4[2];  // third column of matrix
        mbram_dout[1] = row5[2];  // third column of matrix
        mbram_dout[2] = row6[2];  // third column of matrix
        mbram_dout[3] = row7[2];  // third column of matrix
        csels[0] = 1'b0;  // how to restart from 0?
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(posedge clk)
        mbram_dout[0] = row4[3];  // forth column of matrix
        mbram_dout[1] = row5[3];  // forth column of matrix
        mbram_dout[2] = row6[3];  // forth column of matrix
        mbram_dout[3] = row7[3];  // forth column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b0;  // how to restart from 0?
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(negedge clk)
        ressel = 2'b00;  // first element of the new vector has been buffered
        dinsel = 2'b00;  // first element of the new vector has been selected
        @(posedge clk)
        mbram_dout[0] = row4[4];  // fifth column of matrix
        mbram_dout[1] = row5[4];  // fifth column of matrix
        mbram_dout[2] = row6[4];  // fifth column of matrix
        mbram_dout[3] = row7[4];  // fifth column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b0;  // how to restart from 0?
        csels[3] = 1'b1;  // accumulate
        @(negedge clk)
        ressel = 2'b01;  // second element of the new vector has been buffered
        dinsel = 2'b00;  // second element of the new vector has been selected
        @(posedge clk)
        mbram_dout[0] = row4[5];  // sixth column of matrix
        mbram_dout[1] = row5[5];  // sixth column of matrix
        mbram_dout[2] = row6[5];  // sixth column of matrix
        mbram_dout[3] = row7[5];  // sixth column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b0;  // how to restart from 0?
        @(negedge clk)
        ressel = 2'b10;  // third element of the new vector has been buffered
        dinsel = 2'b00;  // third element of the new vector has been selected
        @(posedge clk)
        mbram_dout[0] = row4[6];  // seventh column of matrix
        mbram_dout[1] = row5[6];  // seventh column of matrix
        mbram_dout[2] = row6[6];  // seventh column of matrix
        mbram_dout[3] = row7[6];  // seventh column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(negedge clk)
        ressel = 2'b11;  // forth element of the new vector has been buffered
        dinsel = 2'b00;  // forth element of the new vector has been selected
        @(posedge clk)
        mbram_dout[0] = row4[7];  // eighth column of matrix
        mbram_dout[1] = row5[7];  // eighth column of matrix
        mbram_dout[2] = row6[7];  // eighth column of matrix
        mbram_dout[3] = row7[7];  // eighth column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(negedge clk)
        ressel = 2'b00;  // shouldn't matter since no new result
        dinsel = 2'b00;  // shouldn't matter since no new result
        @(posedge clk)
        init = 25'h1234567;  // shouldn't matter now
        asel = 2'b01;  // use the first node's result stored in the vbram1
        vbram_dout[1] = 25'h0000154;  // 340
        mbram_dout[0] = row0[0];  // first column of matrix
        mbram_dout[1] = row1[0];  // first column of matrix
        mbram_dout[2] = row2[0];  // first column of matrix
        mbram_dout[3] = row3[0];  // first column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(negedge clk)
        ressel = 2'b00;  // shouldn't matter since no new result
        dinsel = 2'b00;  // shouldn't matter since no new result
        @(posedge clk)
        init = 25'h0654321;  // shouldn't matter now
        asel = 2'b01;  // use the second node's result stored in the vbram1
        vbram_dout[1] = 25'h0000154;  // 340
        mbram_dout[0] = row0[1];  // second column of matrix
        mbram_dout[1] = row1[1];  // second column of matrix
        mbram_dout[2] = row2[1];  // second column of matrix
        mbram_dout[3] = row3[1];  // second column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(negedge clk)
        ressel = 2'b00;  // shouldn't matter since no new result
        dinsel = 2'b00;  // shouldn't matter since no new result
        @(posedge clk)
        vbram_dout[1] = 25'h0000154;  // 340, third result
        mbram_dout[0] = row0[2];  // third column of matrix
        mbram_dout[1] = row1[2];  // third column of matrix
        mbram_dout[2] = row2[2];  // third column of matrix
        mbram_dout[3] = row3[2];  // third column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(negedge clk)
        ressel = 2'b00;  // shouldn't matter since no new result
        dinsel = 2'b00;  // shouldn't matter since no new result
        @(posedge clk)
        vbram_dout[1] = 25'h0000154;  // 340, forth result
        mbram_dout[0] = row0[3];  // forth column of matrix
        mbram_dout[1] = row1[3];  // forth column of matrix
        mbram_dout[2] = row2[3];  // forth column of matrix
        mbram_dout[3] = row3[3];  // forth column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(negedge clk)
        ressel = 2'b00;  // fifth element of the new vector has been buffered
        dinsel = 2'b00;  // fifth element of the new vector has been selected
        @(posedge clk)
        asel = 2'b01;  // use the second node's result stored in the vbram1
        vbram_dout[1] = 25'h1FC0444;  // -261052
        mbram_dout[0] = 18'h00010;  // second column of matrix
        mbram_dout[1] = 18'h00020;  // second column of matrix
        mbram_dout[2] = 18'h00030;  // second column of matrix
        mbram_dout[3] = 18'h00040;  // second column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(negedge clk)
        ressel = 2'b11;  // forth element of the new vector has been buffered
        dinsel = 2'b00;  // third element of the new vector gonna to be selected
        @(posedge clk)
        sclrs[0] = 1'b0;  // put all nodes into computations
        sclrs[1] = 1'b0;  // put all nodes into computations
        sclrs[2] = 1'b0;  // put all nodes into computations
        sclrs[3] = 1'b0;  // put all nodes into computations
        asel = 2'b01;  // use the third node's result stored in the vbram1
        vbram_dout[1] = 25'h1FE0666;  // -129434
        mbram_dout[0] = 18'h00100;  // thrid column of matrix
        mbram_dout[1] = 18'h00200;  // thrid column of matrix
        mbram_dout[2] = 18'h00300;  // thrid column of matrix
        mbram_dout[3] = 18'h00400;  // thrid column of matrix
        csels[0] = 1'b0;  // restart from 0
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(negedge clk)
        ressel = 2'b00;  // fifth element of the new vector has been buffered
        dinsel = 2'b00;  // fifth element of the new vector gonna to be selected
        @(posedge clk)
        sclrs[0] = 1'b0;  // put all nodes into computations
        sclrs[1] = 1'b0;  // put all nodes into computations
        sclrs[2] = 1'b0;  // put all nodes into computations
        sclrs[3] = 1'b0;  // put all nodes into computations
        asel = 2'b01;  // use the forth node's result stored in the vbram1
        vbram_dout[0] = 25'h0000890;  // 2192
        mbram_dout[0] = 18'h10000;  // forth column of matrix
        mbram_dout[1] = 18'h20000;  // forth column of matrix
        mbram_dout[2] = 18'h30000;  // forth column of matrix
        mbram_dout[3] = 18'h00004;  // forth column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b0;  // restart from 0
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(negedge clk)
        ressel = 2'b00;  // doesn't matter since no new result
        dinsel = 2'b10;  // copy the fifth node's result into vbram1
        @(posedge clk)
        sclrs[0] = 1'b0;  // put all nodes into computations
        sclrs[1] = 1'b0;  // put all nodes into computations
        sclrs[2] = 1'b0;  // put all nodes into computations
        sclrs[3] = 1'b0;  // put all nodes into computations
        asel = 2'b00;  // use the fifth node's result stored in the vbram0
        vbram_dout[1] = 25'h000091A;  // 2330
        mbram_dout[0] = 18'h00012;  // fifth column of matrix
        mbram_dout[1] = 18'h00023;  // fifth column of matrix
        mbram_dout[2] = 18'h00034;  // fifth column of matrix
        mbram_dout[3] = 18'h00045;  // fifth column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b0;  // restart from 0
        csels[3] = 1'b1;  // accumulate
        @(negedge clk)
        ressel = 2'b00;  // doesn't matter since no new result
        dinsel = 2'b00;  // doesn't matter since no new result
        @(posedge clk)
        sclrs[0] = 1'b0;  // put all nodes into computations
        sclrs[1] = 1'b0;  // put all nodes into computations
        sclrs[2] = 1'b0;  // put all nodes into computations
        sclrs[3] = 1'b0;  // put all nodes into computations
        asel = 2'b00;  // use the first node's result stored in the vbram1
        vbram_dout[1] = 25'h0020222;  // 131618
        mbram_dout[0] = 18'h00001;  // first column of matrix
        mbram_dout[1] = 18'h00002;  // first column of matrix
        mbram_dout[2] = 18'h00003;  // first column of matrix
        mbram_dout[3] = 18'h00004;  // first column of matrix
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b0;  // restart from 0
        @(negedge clk)
        ressel = 2'b00;  //
        dinsel = 2'b00;  //
        @(posedge clk)
        sclrs[0] = 1'b1;  // clear all nodes
        sclrs[1] = 1'b1;  // clear all nodes
        sclrs[2] = 1'b1;  // clear all nodes
        sclrs[3] = 1'b1;  // clear all nodes
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b1;  // accumulate
        @(negedge clk)
        ressel = 2'b00;
        dinsel = 2'b00;
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        #10
        $finish;
    end

endmodule
