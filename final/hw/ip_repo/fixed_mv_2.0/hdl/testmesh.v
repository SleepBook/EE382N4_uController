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
    parameter integer IDX_WIDTH_FOR_NODES = 3,
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

    reg [17:0] init;
    reg [17:0] mbram_dout [NUM_NODES-1:0];
    reg [1:0] asel;
    reg csels [NUM_NODES-1:0];
    reg [IDX_WIDTH_FOR_NODES-1:0] ressel;
    reg [1:0] dinsel;
    reg [17:0] vbram_dout[1:0];

    wire [17:0] vbram_din [1:0];

    mesh # (
        .IDX_WIDTH_FOR_NODES(IDX_WIDTH_FOR_NODES)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .sclrs({sclrs[7],sclrs[6],sclrs[5],sclrs[4],sclrs[3],sclrs[2],sclrs[1],sclrs[0]}),
        .init(init),
        .asel(asel),
        .csels({csels[7],csels[6],csels[5],csels[4],csels[3],csels[2],csels[1],csels[0]}),
        .ressel(ressel),
        .dinsel(dinsel),
        .mbram_dout({mbram_dout[7][17:0],
                     mbram_dout[6][17:0],
                     mbram_dout[5][17:0],
                     mbram_dout[4][17:0],
                     mbram_dout[3][17:0],
                     mbram_dout[2][17:0],
                     mbram_dout[1][17:0],
                     mbram_dout[0][17:0]}),
        .vbram0_dout(vbram_dout[0][17:0]),
        .vbram1_dout(vbram_dout[1][17:0]),
        .vbram0_din(vbram_din[0][17:0]),
        .vbram1_din(vbram_din[1][17:0])
    );

    reg [17:0] row00 [16:0];
    reg [17:0] row01 [16:0];
    reg [17:0] row02 [16:0];
    reg [17:0] row03 [16:0];
    reg [17:0] row04 [16:0];
    reg [17:0] row05 [16:0];
    reg [17:0] row06 [16:0];
    reg [17:0] row07 [16:0];
    reg [17:0] row08 [16:0];
    reg [17:0] row09 [16:0];
    reg [17:0] row10 [16:0];
    reg [17:0] row11 [16:0];
    reg [17:0] row12 [16:0];
    reg [17:0] row13 [16:0];
    reg [17:0] row14 [16:0];
    reg [17:0] row15 [16:0];
    reg [17:0] row16 [16:0];
    reg [17:0] row17 [16:0];
    reg [17:0] row18 [16:0];
    reg [17:0] row19 [16:0];
    reg [17:0] row20 [16:0];
    reg [17:0] row21 [16:0];
    reg [17:0] row22 [16:0];
    reg [17:0] row23 [16:0];
    
    initial
    begin
        row00[3] = 18'h00484; row00[2] = 18'h00484; row00[1] = 18'h00484; row00[0] = 18'h01E1E;
        row01[3] = 18'h00484; row01[2] = 18'h00484; row01[1] = 18'h00484; row01[0] = 18'h01E1E;
        row02[3] = 18'h034DF; row02[2] = 18'h00484; row02[1] = 18'h05B8E; row02[0] = 18'h01E1E;
        row03[3] = 18'h00484; row03[2] = 18'h00484; row03[1] = 18'h05B8E; row03[0] = 18'h01E1E;
        row04[3] = 18'h034DF; row04[2] = 18'h042B0; row04[1] = 18'h05B8E; row04[0] = 18'h01E1E;
        row05[3] = 18'h034DF; row05[2] = 18'h00484; row05[1] = 18'h05B8E; row05[0] = 18'h01E1E;
        row06[3] = 18'h034DF; row06[2] = 18'h00484; row06[1] = 18'h05B8E; row06[0] = 18'h01E1E;
        row07[3] = 18'h00484; row07[2] = 18'h042B0; row07[1] = 18'h00484; row07[0] = 18'h01E1E;

        row00[7] = 18'h00484; row00[6] = 18'h01E1E; row00[5] = 18'h00484; row00[4] = 18'h00484;
        row01[7] = 18'h00484; row01[6] = 18'h01E1E; row01[5] = 18'h00484; row01[4] = 18'h00484;
        row02[7] = 18'h00484; row02[6] = 18'h01E1E; row02[5] = 18'h00484; row02[4] = 18'h03AEA;
        row03[7] = 18'h02C14; row03[6] = 18'h01E1E; row03[5] = 18'h00484; row03[4] = 18'h03AEA;
        row04[7] = 18'h02C14; row04[6] = 18'h01E1E; row04[5] = 18'h00484; row04[4] = 18'h00484;
        row05[7] = 18'h00484; row05[6] = 18'h01E1E; row05[5] = 18'h00484; row05[4] = 18'h03AEA;
        row06[7] = 18'h00484; row06[6] = 18'h01E1E; row06[5] = 18'h00484; row06[4] = 18'h03AEA;
        row07[7] = 18'h00484; row07[6] = 18'h01E1E; row07[5] = 18'h00484; row07[4] = 18'h00484;

        row00[11] = 18'h00484; row00[10] = 18'h00484; row00[9] = 18'h00484; row00[8] = 18'h00484;
        row01[11] = 18'h00484; row01[10] = 18'h00484; row01[9] = 18'h00484; row01[8] = 18'h00484;
        row02[11] = 18'h00484; row02[10] = 18'h00484; row02[9] = 18'h00484; row02[8] = 18'h00484;
        row03[11] = 18'h07151; row03[10] = 18'h00484; row03[9] = 18'h00484; row03[8] = 18'h042B0;
        row04[11] = 18'h00484; row04[10] = 18'h00484; row04[9] = 18'h042B0; row04[8] = 18'h042B0;
        row05[11] = 18'h07151; row05[10] = 18'h00484; row05[9] = 18'h00484; row05[8] = 18'h00484;
        row06[11] = 18'h00484; row06[10] = 18'h00484; row06[9] = 18'h042B0; row06[8] = 18'h042B0;
        row07[11] = 18'h00484; row07[10] = 18'h00484; row07[9] = 18'h00484; row07[8] = 18'h00484;

        row00[15] = 18'h00484; row00[14] = 18'h00484; row00[13] = 18'h00484; row00[12] = 18'h00484;
        row01[15] = 18'h00484; row01[14] = 18'h00484; row01[13] = 18'h00484; row01[12] = 18'h00484;
        row02[15] = 18'h00484; row02[14] = 18'h00484; row02[13] = 18'h00484; row02[12] = 18'h07151;
        row03[15] = 18'h00484; row03[14] = 18'h00484; row03[13] = 18'h05B8E; row03[12] = 18'h00484;
        row04[15] = 18'h00484; row04[14] = 18'h07151; row04[13] = 18'h00484; row04[12] = 18'h00484;
        row05[15] = 18'h00484; row05[14] = 18'h00484; row05[13] = 18'h00484; row05[12] = 18'h07151;
        row06[15] = 18'h0DE1E; row06[14] = 18'h07151; row06[13] = 18'h05B8E; row06[12] = 18'h00484;
        row07[15] = 18'h00484; row07[14] = 18'h00484; row07[13] = 18'h00484; row07[12] = 18'h00484;

        row00[16] = 18'h00484;
        row01[16] = 18'h00484;
        row02[16] = 18'h09595;
        row03[16] = 18'h00484;
        row04[16] = 18'h00484;
        row05[16] = 18'h00484;
        row06[16] = 18'h09595;
        row07[16] = 18'h00484;

        row08[3] = 18'h034DF; row08[2] = 18'h042B0; row08[1] = 18'h00484; row08[0] = 18'h01E1E;
        row09[3] = 18'h034DF; row09[2] = 18'h042B0; row09[1] = 18'h00484; row09[0] = 18'h01E1E;
        row10[3] = 18'h00484; row10[2] = 18'h00484; row10[1] = 18'h00484; row10[0] = 18'h01E1E;
        row11[3] = 18'h00484; row11[2] = 18'h00484; row11[1] = 18'h00484; row11[0] = 18'h01E1E;
        row12[3] = 18'h00484; row12[2] = 18'h042B0; row12[1] = 18'h00484; row12[0] = 18'h01E1E;
        row13[3] = 18'h00484; row13[2] = 18'h042B0; row13[1] = 18'h00484; row13[0] = 18'h01E1E;
        row14[3] = 18'h034DF; row14[2] = 18'h00484; row14[1] = 18'h00484; row14[0] = 18'h01E1E;
        row15[3] = 18'h034DF; row15[2] = 18'h042B0; row15[1] = 18'h00484; row15[0] = 18'h01E1E;

        row08[7] = 18'h02C14; row08[6] = 18'h01E1E; row08[5] = 18'h00484; row08[4] = 18'h00484;
        row09[7] = 18'h02C14; row09[6] = 18'h01E1E; row09[5] = 18'h00484; row09[4] = 18'h00484;
        row10[7] = 18'h02C14; row10[6] = 18'h01E1E; row10[5] = 18'h00484; row10[4] = 18'h00484;
        row11[7] = 18'h02C14; row11[6] = 18'h01E1E; row11[5] = 18'h00484; row11[4] = 18'h03AEA;
        row12[7] = 18'h02C14; row12[6] = 18'h01E1E; row12[5] = 18'h00484; row12[4] = 18'h03AEA;
        row13[7] = 18'h02C14; row13[6] = 18'h01E1E; row13[5] = 18'h00484; row13[4] = 18'h00484;
        row14[7] = 18'h02C14; row14[6] = 18'h01E1E; row14[5] = 18'h00484; row14[4] = 18'h00484;
        row15[7] = 18'h02C14; row15[6] = 18'h01E1E; row15[5] = 18'h00484; row15[4] = 18'h03AEA;

        row08[11] = 18'h00484; row08[10] = 18'h00484; row08[9] = 18'h00484; row08[8] = 18'h00484;
        row09[11] = 18'h00484; row09[10] = 18'h00484; row09[9] = 18'h00484; row09[8] = 18'h042B0;
        row10[11] = 18'h00484; row10[10] = 18'h00484; row10[9] = 18'h00484; row10[8] = 18'h00484;
        row11[11] = 18'h00484; row11[10] = 18'h00484; row11[9] = 18'h042B0; row11[8] = 18'h00484;
        row12[11] = 18'h00484; row12[10] = 18'h00484; row12[9] = 18'h00484; row12[8] = 18'h00484;
        row13[11] = 18'h00484; row13[10] = 18'h00484; row13[9] = 18'h042B0; row13[8] = 18'h042B0;
        row14[11] = 18'h07151; row14[10] = 18'h00484; row14[9] = 18'h042B0; row14[8] = 18'h00484;
        row15[11] = 18'h00484; row15[10] = 18'h00484; row15[9] = 18'h042B0; row15[8] = 18'h042B0;

        row08[15] = 18'h00484; row08[14] = 18'h00484; row08[13] = 18'h00484; row08[12] = 18'h00484;
        row09[15] = 18'h00484; row09[14] = 18'h00484; row09[13] = 18'h00484; row09[12] = 18'h07151;
        row10[15] = 18'h00484; row10[14] = 18'h00484; row10[13] = 18'h00484; row10[12] = 18'h00484;
        row11[15] = 18'h00484; row11[14] = 18'h07151; row11[13] = 18'h05B8E; row11[12] = 18'h00484;
        row12[15] = 18'h00484; row12[14] = 18'h00484; row12[13] = 18'h00484; row12[12] = 18'h00484;
        row13[15] = 18'h00484; row13[14] = 18'h07151; row13[13] = 18'h00484; row13[12] = 18'h00484;
        row14[15] = 18'h0DE1E; row14[14] = 18'h00484; row14[13] = 18'h05B8E; row14[12] = 18'h00484;
        row15[15] = 18'h00484; row15[14] = 18'h00484; row15[13] = 18'h05B8E; row15[12] = 18'h00484;

        row08[16] = 18'h00484;
        row09[16] = 18'h00484;
        row10[16] = 18'h00484;
        row11[16] = 18'h00484;
        row12[16] = 18'h00484;
        row13[16] = 18'h00484;
        row14[16] = 18'h00484;
        row15[16] = 18'h09595;

        row16[3] = 18'h034DF; row16[2] = 18'h00484; row16[1] = 18'h00484; row16[0] = 18'h01E1E;
        row16[7] = 18'h02C14; row16[6] = 18'h01E1E; row16[5] = 18'h1B787; row16[4] = 18'h03AEA;
        row16[11] = 18'h07151; row16[10] = 18'h1B787; row16[9] = 18'h042B0; row16[8] = 18'h042B0;
        row16[15] = 18'h00484; row16[14] = 18'h00484; row16[13] = 18'h00484; row16[12] = 18'h07151;
        row16[16] = 18'h00484;

    end

    initial
    begin
        wait(~rstn)

        // cycle 0
        @(posedge clk)
        sclrs[0] = 1'b1;  // clear all nodes
        sclrs[1] = 1'b1;  // clear all nodes
        sclrs[2] = 1'b1;  // clear all nodes
        sclrs[3] = 1'b1;  // clear all nodes
        sclrs[4] = 1'b1;  // clear all nodes
        sclrs[5] = 1'b1;  // clear all nodes
        sclrs[6] = 1'b1;  // clear all nodes
        sclrs[7] = 1'b1;  // clear all nodes
        csels[0] = 1'b0;  // dosn't matter at this time actually
        csels[1] = 1'b0;  // dosn't matter at this time actually
        csels[2] = 1'b0;  // dosn't matter at this time actually
        csels[3] = 1'b0;  // dosn't matter at this time actually
        csels[4] = 1'b0;  // dosn't matter at this time actually
        csels[5] = 1'b0;  // dosn't matter at this time actually
        csels[6] = 1'b0;  // dosn't matter at this time actually
        csels[7] = 1'b0;  // dosn't matter at this time actually
        init = 18'h01E1E;

        // cycle 1
        @(posedge clk)
        sclrs[0] = 1'b0;  // put the first node into computations
        sclrs[1] = 1'b1;  // put the first node into computations
        sclrs[2] = 1'b1;  // put the first node into computations
        sclrs[3] = 1'b1;  // put the first node into computations
        sclrs[4] = 1'b1;  // put the first node into computations
        sclrs[5] = 1'b1;  // put the first node into computations
        sclrs[6] = 1'b1;  // put the first node into computations
        sclrs[7] = 1'b1;  // put the first node into computations
        asel = 2'b10;  // use init as ain
        mbram_dout[0] = row00[0];  // first column of matrix
        mbram_dout[1] = row01[0];  // first column of matrix
        mbram_dout[2] = row02[0];  // first column of matrix
        mbram_dout[3] = row03[0];  // first column of matrix
        mbram_dout[4] = row04[0];  // first column of matrix
        mbram_dout[5] = row05[0];  // first column of matrix
        mbram_dout[6] = row06[0];  // first column of matrix
        mbram_dout[7] = row07[0];  // first column of matrix

        // cycle 2
        @(posedge clk)
        sclrs[1] = 1'b0;  // put second node into computations as well
        sclrs[2] = 1'b1;  // put second node into computations as well
        sclrs[3] = 1'b1;  // put second node into computations as well
        sclrs[4] = 1'b1;  // put second node into computations as well
        sclrs[5] = 1'b1;  // put second node into computations as well
        sclrs[6] = 1'b1;  // put second node into computations as well
        sclrs[7] = 1'b1;  // put second node into computations as well
        mbram_dout[0] = row00[1];  // second column of matrix
        mbram_dout[1] = row01[1];  // second column of matrix
        mbram_dout[2] = row02[1];  // second column of matrix
        mbram_dout[3] = row03[1];  // second column of matrix
        mbram_dout[4] = row04[1];  // second column of matrix
        mbram_dout[5] = row05[1];  // second column of matrix
        mbram_dout[6] = row06[1];  // second column of matrix
        mbram_dout[7] = row07[1];  // second column of matrix

        // cycle 3
        @(posedge clk)
        sclrs[2] = 1'b0;  // put third node into computations as well
        sclrs[3] = 1'b1;  // put third node into computations as well
        sclrs[4] = 1'b1;  // put thrid node into computations as well
        sclrs[5] = 1'b1;  // put thrid node into computations as well
        sclrs[6] = 1'b1;  // put thrid node into computations as well
        sclrs[7] = 1'b1;  // put thrid node into computations as well
        csels[0] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row00[2];  // third column of matrix
        mbram_dout[1] = row01[2];  // third column of matrix
        mbram_dout[2] = row02[2];  // third column of matrix
        mbram_dout[3] = row03[2];  // third column of matrix
        mbram_dout[4] = row04[2];  // third column of matrix
        mbram_dout[5] = row05[2];  // third column of matrix
        mbram_dout[6] = row06[2];  // third column of matrix
        mbram_dout[7] = row07[2];  // third column of matrix

        // cycle 4
        @(posedge clk)
        sclrs[3] = 1'b0;  // put forth node into computations as well
        sclrs[4] = 1'b1;  // put forth node into computations as well
        sclrs[5] = 1'b1;  // put forth node into computations as well
        sclrs[6] = 1'b1;  // put forth node into computations as well
        sclrs[7] = 1'b1;  // put forth node into computations as well
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row00[3];  // forth column of matrix
        mbram_dout[1] = row01[3];  // forth column of matrix
        mbram_dout[2] = row02[3];  // forth column of matrix
        mbram_dout[3] = row03[3];  // forth column of matrix
        mbram_dout[4] = row04[3];  // forth column of matrix
        mbram_dout[5] = row05[3];  // forth column of matrix
        mbram_dout[6] = row06[3];  // forth column of matrix
        mbram_dout[7] = row07[3];  // forth column of matrix

        // cycle 5
        @(posedge clk)
        sclrs[4] = 1'b0;  // put fifth node into computations as well
        sclrs[5] = 1'b1;  // put fifth node into computations as well
        sclrs[6] = 1'b1;  // put fifth node into computations as well
        sclrs[7] = 1'b1;  // put fifth node into computations as well
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row00[4];  // fifth column of matrix
        mbram_dout[1] = row01[4];  // fifth column of matrix
        mbram_dout[2] = row02[4];  // fifth column of matrix
        mbram_dout[3] = row03[4];  // fifth column of matrix
        mbram_dout[4] = row04[4];  // fifth column of matrix
        mbram_dout[5] = row05[4];  // fifth column of matrix
        mbram_dout[6] = row06[4];  // fifth column of matrix
        mbram_dout[7] = row07[4];  // fifth column of matrix

        // cycle 6
        @(posedge clk)
        sclrs[5] = 1'b0;  // put sixth node into computations as well
        sclrs[6] = 1'b1;  // put sixth node into computations as well
        sclrs[7] = 1'b1;  // put sixth node into computations as well
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row00[5];  // sixth column of matrix
        mbram_dout[1] = row01[5];  // sixth column of matrix
        mbram_dout[2] = row02[5];  // sixth column of matrix
        mbram_dout[3] = row03[5];  // sixth column of matrix
        mbram_dout[4] = row04[5];  // sixth column of matrix
        mbram_dout[5] = row05[5];  // sixth column of matrix
        mbram_dout[6] = row06[5];  // sixth column of matrix
        mbram_dout[7] = row07[5];  // sixth column of matrix

        // cycle 7
        @(posedge clk)
        sclrs[6] = 1'b0;  // put seventh node into computations as well
        sclrs[7] = 1'b1;  // put seventh node into computations as well
        csels[3] = 1'b1;  // accumulate
        csels[4] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row00[6];  // seventh column of matrix
        mbram_dout[1] = row01[6];  // seventh column of matrix
        mbram_dout[2] = row02[6];  // seventh column of matrix
        mbram_dout[3] = row03[6];  // seventh column of matrix
        mbram_dout[4] = row04[6];  // seventh column of matrix
        mbram_dout[5] = row05[6];  // seventh column of matrix
        mbram_dout[6] = row06[6];  // seventh column of matrix
        mbram_dout[7] = row07[6];  // seventh column of matrix

        // cycle 8
        @(posedge clk)
        sclrs[7] = 1'b0;  // put all nodes into computations
        csels[4] = 1'b1;  // accumulate
        csels[5] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row00[7];  // eighth column of matrix
        mbram_dout[1] = row01[7];  // eighth column of matrix
        mbram_dout[2] = row02[7];  // eighth column of matrix
        mbram_dout[3] = row03[7];  // eighth column of matrix
        mbram_dout[4] = row04[7];  // eighth column of matrix
        mbram_dout[5] = row05[7];  // eighth column of matrix
        mbram_dout[6] = row06[7];  // eighth column of matrix
        mbram_dout[7] = row07[7];  // eighth column of matrix

        // cycle 9
        @(posedge clk)
        csels[5] = 1'b1;  // accumulate
        csels[6] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row00[8];  // ninth column of matrix
        mbram_dout[1] = row01[8];  // ninth column of matrix
        mbram_dout[2] = row02[8];  // ninth column of matrix
        mbram_dout[3] = row03[8];  // ninth column of matrix
        mbram_dout[4] = row04[8];  // ninth column of matrix
        mbram_dout[5] = row05[8];  // ninth column of matrix
        mbram_dout[6] = row06[8];  // ninth column of matrix
        mbram_dout[7] = row07[8];  // ninth column of matrix

        // cycle 10
        @(posedge clk)
        csels[6] = 1'b1;  // accumulate
        csels[7] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row00[9];  // tenth column of matrix
        mbram_dout[1] = row01[9];  // tenth column of matrix
        mbram_dout[2] = row02[9];  // tenth column of matrix
        mbram_dout[3] = row03[9];  // tenth column of matrix
        mbram_dout[4] = row04[9];  // tenth column of matrix
        mbram_dout[5] = row05[9];  // tenth column of matrix
        mbram_dout[6] = row06[9];  // tenth column of matrix
        mbram_dout[7] = row07[9];  // tenth column of matrix

        // cycle 11
        @(posedge clk)
        csels[7] = 1'b1;  // accumulate
        mbram_dout[0] = row00[10];  // eleventh column of matrix
        mbram_dout[1] = row01[10];  // eleventh column of matrix
        mbram_dout[2] = row02[10];  // eleventh column of matrix
        mbram_dout[3] = row03[10];  // eleventh column of matrix
        mbram_dout[4] = row04[10];  // eleventh column of matrix
        mbram_dout[5] = row05[10];  // eleventh column of matrix
        mbram_dout[6] = row06[10];  // eleventh column of matrix
        mbram_dout[7] = row07[10];  // eleventh column of matrix

        // cycle 12
        @(posedge clk)
        mbram_dout[0] = row00[11];  // twelfth column of matrix
        mbram_dout[1] = row01[11];  // twelfth column of matrix
        mbram_dout[2] = row02[11];  // twelfth column of matrix
        mbram_dout[3] = row03[11];  // twelfth column of matrix
        mbram_dout[4] = row04[11];  // twelfth column of matrix
        mbram_dout[5] = row05[11];  // twelfth column of matrix
        mbram_dout[6] = row06[11];  // twelfth column of matrix
        mbram_dout[7] = row07[11];  // twelfth column of matrix

        // cycle 13
        @(posedge clk)
        mbram_dout[0] = row00[12];  // thirteenth column of matrix
        mbram_dout[1] = row01[12];  // thirteenth column of matrix
        mbram_dout[2] = row02[12];  // thirteenth column of matrix
        mbram_dout[3] = row03[12];  // thirteenth column of matrix
        mbram_dout[4] = row04[12];  // thirteenth column of matrix
        mbram_dout[5] = row05[12];  // thirteenth column of matrix
        mbram_dout[6] = row06[12];  // thirteenth column of matrix
        mbram_dout[7] = row07[12];  // thirteenth column of matrix

        // cycle 14
        @(posedge clk)
        mbram_dout[0] = row00[13];  // fourteenth column of matrix
        mbram_dout[1] = row01[13];  // fourteenth column of matrix
        mbram_dout[2] = row02[13];  // fourteenth column of matrix
        mbram_dout[3] = row03[13];  // fourteenth column of matrix
        mbram_dout[4] = row04[13];  // fourteenth column of matrix
        mbram_dout[5] = row05[13];  // fourteenth column of matrix
        mbram_dout[6] = row06[13];  // fourteenth column of matrix
        mbram_dout[7] = row07[13];  // fourteenth column of matrix

        // cycle 15
        @(posedge clk)
        mbram_dout[0] = row00[14];  // fifteenth column of matrix
        mbram_dout[1] = row01[14];  // fifteenth column of matrix
        mbram_dout[2] = row02[14];  // fifteenth column of matrix
        mbram_dout[3] = row03[14];  // fifteenth column of matrix
        mbram_dout[4] = row04[14];  // fifteenth column of matrix
        mbram_dout[5] = row05[14];  // fifteenth column of matrix
        mbram_dout[6] = row06[14];  // fifteenth column of matrix
        mbram_dout[7] = row07[14];  // fifteenth column of matrix

        // cycle 16
        @(posedge clk)
        mbram_dout[0] = row00[15];  // sixteenth column of matrix
        mbram_dout[1] = row01[15];  // sixteenth column of matrix
        mbram_dout[2] = row02[15];  // sixteenth column of matrix
        mbram_dout[3] = row03[15];  // sixteenth column of matrix
        mbram_dout[4] = row04[15];  // sixteenth column of matrix
        mbram_dout[5] = row05[15];  // sixteenth column of matrix
        mbram_dout[6] = row06[15];  // sixteenth column of matrix
        mbram_dout[7] = row07[15];  // sixteenth column of matrix

        // cycle 17
        @(posedge clk)
        mbram_dout[0] = row00[16];  // seventeenth column of matrix
        mbram_dout[1] = row01[16];  // seventeenth column of matrix
        mbram_dout[2] = row02[16];  // seventeenth column of matrix
        mbram_dout[3] = row03[16];  // seventeenth column of matrix
        mbram_dout[4] = row04[16];  // seventeenth column of matrix
        mbram_dout[5] = row05[16];  // seventeenth column of matrix
        mbram_dout[6] = row06[16];  // seventeenth column of matrix
        mbram_dout[7] = row07[16];  // seventeenth column of matrix

        // cycle 18
        @(posedge clk)
        mbram_dout[0] = row08[0];  // first column of matrix
        mbram_dout[1] = row09[0];  // first column of matrix
        mbram_dout[2] = row10[0];  // first column of matrix
        mbram_dout[3] = row11[0];  // first column of matrix
        mbram_dout[4] = row12[0];  // first column of matrix
        mbram_dout[5] = row13[0];  // first column of matrix
        mbram_dout[6] = row14[0];  // first column of matrix
        mbram_dout[7] = row15[0];  // first column of matrix

        // cycle 19
        @(posedge clk)
        mbram_dout[0] = row08[1];  // second column of matrix
        mbram_dout[1] = row09[1];  // second column of matrix
        mbram_dout[2] = row10[1];  // second column of matrix
        mbram_dout[3] = row11[1];  // second column of matrix
        mbram_dout[4] = row12[1];  // second column of matrix
        mbram_dout[5] = row13[1];  // second column of matrix
        mbram_dout[6] = row14[1];  // second column of matrix
        mbram_dout[7] = row15[1];  // second column of matrix

        // cycle 20
        @(posedge clk)
        csels[0] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row08[2];  // third column of matrix
        mbram_dout[1] = row09[2];  // third column of matrix
        mbram_dout[2] = row10[2];  // third column of matrix
        mbram_dout[3] = row11[2];  // third column of matrix
        mbram_dout[4] = row12[2];  // third column of matrix
        mbram_dout[5] = row13[2];  // third column of matrix
        mbram_dout[6] = row14[2];  // third column of matrix
        mbram_dout[7] = row15[2];  // third column of matrix

        // cycle 21
        @(posedge clk)
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row08[3];  // forth column of matrix
        mbram_dout[1] = row09[3];  // forth column of matrix
        mbram_dout[2] = row10[3];  // forth column of matrix
        mbram_dout[3] = row11[3];  // forth column of matrix
        mbram_dout[4] = row12[3];  // forth column of matrix
        mbram_dout[5] = row13[3];  // forth column of matrix
        mbram_dout[6] = row14[3];  // forth column of matrix
        mbram_dout[7] = row15[3];  // forth column of matrix
        ressel = 3'b000;  //  first result has been buffered
        @(negedge clk)
        dinsel = 2'b00;  // first result has been selected

        // cycle 22
        @(posedge clk)
        csels[1] = 1'b1;  // accumulate
        csels[2] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row08[4];  // fifth column of matrix
        mbram_dout[1] = row09[4];  // fifth column of matrix
        mbram_dout[2] = row10[4];  // fifth column of matrix
        mbram_dout[3] = row11[4];  // fifth column of matrix
        mbram_dout[4] = row12[4];  // fifth column of matrix
        mbram_dout[5] = row13[4];  // fifth column of matrix
        mbram_dout[6] = row14[4];  // fifth column of matrix
        mbram_dout[7] = row15[4];  // fifth column of matrix
        ressel = 3'b001;  //  second result has been buffered

        // cycle 23
        @(posedge clk)
        csels[2] = 1'b1;  // accumulate
        csels[3] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row08[5];  // sixth column of matrix
        mbram_dout[1] = row09[5];  // sixth column of matrix
        mbram_dout[2] = row10[5];  // sixth column of matrix
        mbram_dout[3] = row11[5];  // sixth column of matrix
        mbram_dout[4] = row12[5];  // sixth column of matrix
        mbram_dout[5] = row13[5];  // sixth column of matrix
        mbram_dout[6] = row14[5];  // sixth column of matrix
        mbram_dout[7] = row15[5];  // sixth column of matrix
        ressel = 3'b010;  //  third result has been buffered

        // cycle 24
        @(posedge clk)
        csels[3] = 1'b1;  // accumulate
        csels[4] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row08[6];  // seventh column of matrix
        mbram_dout[1] = row09[6];  // seventh column of matrix
        mbram_dout[2] = row10[6];  // seventh column of matrix
        mbram_dout[3] = row11[6];  // seventh column of matrix
        mbram_dout[4] = row12[6];  // seventh column of matrix
        mbram_dout[5] = row13[6];  // seventh column of matrix
        mbram_dout[6] = row14[6];  // seventh column of matrix
        mbram_dout[7] = row15[6];  // seventh column of matrix
        ressel = 3'b011;  //  forth result has been buffered

        // cycle 25
        @(posedge clk)
        csels[4] = 1'b1;  // accumulate
        csels[5] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row08[7];  // eighth column of matrix
        mbram_dout[1] = row09[7];  // eighth column of matrix
        mbram_dout[2] = row10[7];  // eighth column of matrix
        mbram_dout[3] = row11[7];  // eighth column of matrix
        mbram_dout[4] = row12[7];  // eighth column of matrix
        mbram_dout[5] = row13[7];  // eighth column of matrix
        mbram_dout[6] = row14[7];  // eighth column of matrix
        mbram_dout[7] = row15[7];  // eighth column of matrix
        ressel = 3'b100;  //  fifth result has been buffered

        // cycle 26
        @(posedge clk)
        csels[5] = 1'b1;  // accumulate
        csels[6] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row08[8];  // ninth column of matrix
        mbram_dout[1] = row09[8];  // ninth column of matrix
        mbram_dout[2] = row10[8];  // ninth column of matrix
        mbram_dout[3] = row11[8];  // ninth column of matrix
        mbram_dout[4] = row12[8];  // ninth column of matrix
        mbram_dout[5] = row13[8];  // ninth column of matrix
        mbram_dout[6] = row14[8];  // ninth column of matrix
        mbram_dout[7] = row15[8];  // ninth column of matrix
        ressel = 3'b101;  //  sixth result has been buffered

        // cycle 27
        @(posedge clk)
        csels[6] = 1'b1;  // accumulate
        csels[7] = 1'b0;  // accumulation starts from 0
        mbram_dout[0] = row08[9];  // tenth column of matrix
        mbram_dout[1] = row09[9];  // tenth column of matrix
        mbram_dout[2] = row10[9];  // tenth column of matrix
        mbram_dout[3] = row11[9];  // tenth column of matrix
        mbram_dout[4] = row12[9];  // tenth column of matrix
        mbram_dout[5] = row13[9];  // tenth column of matrix
        mbram_dout[6] = row14[9];  // tenth column of matrix
        mbram_dout[7] = row15[9];  // tenth column of matrix
        ressel = 3'b110;  //  seventh result has been buffered

        // cycle 28
        @(posedge clk)
        csels[7] = 1'b1;  // accumulate
        mbram_dout[0] = row08[10];  // eleventh column of matrix
        mbram_dout[1] = row09[10];  // eleventh column of matrix
        mbram_dout[2] = row10[10];  // eleventh column of matrix
        mbram_dout[3] = row11[10];  // eleventh column of matrix
        mbram_dout[4] = row12[10];  // eleventh column of matrix
        mbram_dout[5] = row13[10];  // eleventh column of matrix
        mbram_dout[6] = row14[10];  // eleventh column of matrix
        mbram_dout[7] = row15[10];  // eleventh column of matrix
        ressel = 3'b111;  //  eighth result has been buffered

        // cycle 29
        @(posedge clk)
        mbram_dout[0] = row08[11];  // twelfth column of matrix
        mbram_dout[1] = row09[11];  // twelfth column of matrix
        mbram_dout[2] = row10[11];  // twelfth column of matrix
        mbram_dout[3] = row11[11];  // twelfth column of matrix
        mbram_dout[4] = row12[11];  // twelfth column of matrix
        mbram_dout[5] = row13[11];  // twelfth column of matrix
        mbram_dout[6] = row14[11];  // twelfth column of matrix
        mbram_dout[7] = row15[11];  // twelfth column of matrix
        ressel = 3'b000;  //  doesn't matter since no new result

        // cycle 30
        @(posedge clk)
        mbram_dout[0] = row08[12];  // thirteenth column of matrix
        mbram_dout[1] = row09[12];  // thirteenth column of matrix
        mbram_dout[2] = row10[12];  // thirteenth column of matrix
        mbram_dout[3] = row11[12];  // thirteenth column of matrix
        mbram_dout[4] = row12[12];  // thirteenth column of matrix
        mbram_dout[5] = row13[12];  // thirteenth column of matrix
        mbram_dout[6] = row14[12];  // thirteenth column of matrix
        mbram_dout[7] = row15[12];  // thirteenth column of matrix

        // cycle 31
        @(posedge clk)
        mbram_dout[0] = row08[13];  // fourteenth column of matrix
        mbram_dout[1] = row09[13];  // fourteenth column of matrix
        mbram_dout[2] = row10[13];  // fourteenth column of matrix
        mbram_dout[3] = row11[13];  // fourteenth column of matrix
        mbram_dout[4] = row12[13];  // fourteenth column of matrix
        mbram_dout[5] = row13[13];  // fourteenth column of matrix
        mbram_dout[6] = row14[13];  // fourteenth column of matrix
        mbram_dout[7] = row15[13];  // fourteenth column of matrix

        // cycle 32
        @(posedge clk)
        mbram_dout[0] = row08[14];  // fifteenth column of matrix
        mbram_dout[1] = row09[14];  // fifteenth column of matrix
        mbram_dout[2] = row10[14];  // fifteenth column of matrix
        mbram_dout[3] = row11[14];  // fifteenth column of matrix
        mbram_dout[4] = row12[14];  // fifteenth column of matrix
        mbram_dout[5] = row13[14];  // fifteenth column of matrix
        mbram_dout[6] = row14[14];  // fifteenth column of matrix
        mbram_dout[7] = row15[14];  // fifteenth column of matrix

        // cycle 33
        @(posedge clk)
        mbram_dout[0] = row08[15];  // sixteenth column of matrix
        mbram_dout[1] = row09[15];  // sixteenth column of matrix
        mbram_dout[2] = row10[15];  // sixteenth column of matrix
        mbram_dout[3] = row11[15];  // sixteenth column of matrix
        mbram_dout[4] = row12[15];  // sixteenth column of matrix
        mbram_dout[5] = row13[15];  // sixteenth column of matrix
        mbram_dout[6] = row14[15];  // sixteenth column of matrix
        mbram_dout[7] = row15[15];  // sixteenth column of matrix

        // cycle 34
        @(posedge clk)
        mbram_dout[0] = row08[16];  // seventeenth column of matrix
        mbram_dout[1] = row09[16];  // seventeenth column of matrix
        mbram_dout[2] = row10[16];  // seventeenth column of matrix
        mbram_dout[3] = row11[16];  // seventeenth column of matrix
        mbram_dout[4] = row12[16];  // seventeenth column of matrix
        mbram_dout[5] = row13[16];  // seventeenth column of matrix
        mbram_dout[6] = row14[16];  // seventeenth column of matrix
        mbram_dout[7] = row15[16];  // seventeenth column of matrix

        // cycle 35
        @(posedge clk)
        mbram_dout[0] = row16[0];  // first column of matrix
        mbram_dout[1] = row17[0];  // first column of matrix
        mbram_dout[2] = row18[0];  // first column of matrix
        mbram_dout[3] = row19[0];  // first column of matrix
        mbram_dout[4] = row20[0];  // first column of matrix
        mbram_dout[5] = row21[0];  // first column of matrix
        mbram_dout[6] = row22[0];  // first column of matrix
        mbram_dout[7] = row23[0];  // first column of matrix

        // cycle 36
        @(posedge clk)
        mbram_dout[0] = row16[1];  // second column of matrix
        mbram_dout[1] = row17[1];  // second column of matrix
        mbram_dout[2] = row18[1];  // second column of matrix
        mbram_dout[3] = row19[1];  // second column of matrix
        mbram_dout[4] = row20[1];  // second column of matrix
        mbram_dout[5] = row21[1];  // second column of matrix
        mbram_dout[6] = row22[1];  // second column of matrix
        mbram_dout[7] = row23[1];  // second column of matrix

        // cycle 37
        @(posedge clk)
        csels[0] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row16[2];  // third column of matrix
        mbram_dout[1] = row17[2];  // third column of matrix
        mbram_dout[2] = row18[2];  // third column of matrix
        mbram_dout[3] = row19[2];  // third column of matrix
        mbram_dout[4] = row20[2];  // third column of matrix
        mbram_dout[5] = row21[2];  // third column of matrix
        mbram_dout[6] = row22[2];  // third column of matrix
        mbram_dout[7] = row23[2];  // third column of matrix

        // cycle 38
        @(posedge clk)
        csels[0] = 1'b1;  // accumulation
        csels[1] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row16[3];  // forth column of matrix
        mbram_dout[1] = row17[3];  // forth column of matrix
        mbram_dout[2] = row18[3];  // forth column of matrix
        mbram_dout[3] = row19[3];  // forth column of matrix
        mbram_dout[4] = row20[3];  // forth column of matrix
        mbram_dout[5] = row21[3];  // forth column of matrix
        mbram_dout[6] = row22[3];  // forth column of matrix
        mbram_dout[7] = row23[3];  // forth column of matrix
        ressel = 3'b000;  // the ninth result has been bufferred
        @(negedge clk)
        dinsel = 2'b00;  // the ninth result has been selected

        // cycle 39
        @(posedge clk)
        csels[1] = 1'b1;  // accumulation
        csels[2] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row16[4];  // fifth column of matrix
        mbram_dout[1] = row17[4];  // fifth column of matrix
        mbram_dout[2] = row18[4];  // fifth column of matrix
        mbram_dout[3] = row19[4];  // fifth column of matrix
        mbram_dout[4] = row20[4];  // fifth column of matrix
        mbram_dout[5] = row21[4];  // fifth column of matrix
        mbram_dout[6] = row22[4];  // fifth column of matrix
        mbram_dout[7] = row23[4];  // fifth column of matrix
        ressel = 3'b001;  // the tenth result has been bufferred

        // cycle 40
        @(posedge clk)
        csels[2] = 1'b1;  // accumulation
        csels[3] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row16[5];  // sixth column of matrix
        mbram_dout[1] = row17[5];  // sixth column of matrix
        mbram_dout[2] = row18[5];  // sixth column of matrix
        mbram_dout[3] = row19[5];  // sixth column of matrix
        mbram_dout[4] = row20[5];  // sixth column of matrix
        mbram_dout[5] = row21[5];  // sixth column of matrix
        mbram_dout[6] = row22[5];  // sixth column of matrix
        mbram_dout[7] = row23[5];  // sixth column of matrix
        ressel = 3'b010;  // the eleventh result has been bufferred

        // cycle 41
        @(posedge clk)
        csels[3] = 1'b1;  // accumulation
        csels[4] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row16[6];  // seventh column of matrix
        mbram_dout[1] = row17[6];  // seventh column of matrix
        mbram_dout[2] = row18[6];  // seventh column of matrix
        mbram_dout[3] = row19[6];  // seventh column of matrix
        mbram_dout[4] = row20[6];  // seventh column of matrix
        mbram_dout[5] = row21[6];  // seventh column of matrix
        mbram_dout[6] = row22[6];  // seventh column of matrix
        mbram_dout[7] = row23[6];  // seventh column of matrix
        ressel = 3'b011;  // the eleventh result has been bufferred

        // cycle 42
        @(posedge clk)
        csels[4] = 1'b1;  // accumulation
        csels[5] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row16[7];  // eighth column of matrix
        mbram_dout[1] = row17[7];  // eighth column of matrix
        mbram_dout[2] = row18[7];  // eighth column of matrix
        mbram_dout[3] = row19[7];  // eighth column of matrix
        mbram_dout[4] = row20[7];  // eighth column of matrix
        mbram_dout[5] = row21[7];  // eighth column of matrix
        mbram_dout[6] = row22[7];  // eighth column of matrix
        mbram_dout[7] = row23[7];  // eighth column of matrix
        ressel = 3'b100;  // the twelfth result has been bufferred

        // cycle 43
        @(posedge clk)
        csels[5] = 1'b1;  // accumulation
        csels[6] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row16[8];  // ninth column of matrix
        mbram_dout[1] = row17[8];  // ninth column of matrix
        mbram_dout[2] = row18[8];  // ninth column of matrix
        mbram_dout[3] = row19[8];  // ninth column of matrix
        mbram_dout[4] = row20[8];  // ninth column of matrix
        mbram_dout[5] = row21[8];  // ninth column of matrix
        mbram_dout[6] = row22[8];  // ninth column of matrix
        mbram_dout[7] = row23[8];  // ninth column of matrix
        ressel = 3'b101;  // the tirteenth result has been bufferred

        // cycle 44
        @(posedge clk)
        csels[6] = 1'b1;  // accumulation
        csels[7] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row16[9];  // tenth column of matrix
        mbram_dout[1] = row17[9];  // tenth column of matrix
        mbram_dout[2] = row18[9];  // tenth column of matrix
        mbram_dout[3] = row19[9];  // tenth column of matrix
        mbram_dout[4] = row20[9];  // tenth column of matrix
        mbram_dout[5] = row21[9];  // tenth column of matrix
        mbram_dout[6] = row22[9];  // tenth column of matrix
        mbram_dout[7] = row23[9];  // tenth column of matrix
        ressel = 3'b110;  // the fourteenth result has been bufferred

        // cycle 45
        @(posedge clk)
        csels[7] = 1'b1;  // accumulation
        mbram_dout[0] = row16[10];  // eleventh column of matrix
        mbram_dout[1] = row17[10];  // eleventh column of matrix
        mbram_dout[2] = row18[10];  // eleventh column of matrix
        mbram_dout[3] = row19[10];  // eleventh column of matrix
        mbram_dout[4] = row20[10];  // eleventh column of matrix
        mbram_dout[5] = row21[10];  // eleventh column of matrix
        mbram_dout[6] = row22[10];  // eleventh column of matrix
        mbram_dout[7] = row23[10];  // eleventh column of matrix
        ressel = 3'b111;  // the fifteenth result has been bufferred

        // cycle 46
        @(posedge clk)
        mbram_dout[0] = row16[11];  // twelfth column of matrix
        mbram_dout[1] = row17[11];  // twelfth column of matrix
        mbram_dout[2] = row18[11];  // twelfth column of matrix
        mbram_dout[3] = row19[11];  // twelfth column of matrix
        mbram_dout[4] = row20[11];  // twelfth column of matrix
        mbram_dout[5] = row21[11];  // twelfth column of matrix
        mbram_dout[6] = row22[11];  // twelfth column of matrix
        mbram_dout[7] = row23[11];  // twelfth column of matrix
        ressel = 3'b000;  // shouldn't matter since no new result

        // cycle 47
        @(posedge clk)
        mbram_dout[0] = row16[12];  // thirteenth column of matrix
        mbram_dout[1] = row17[12];  // thirteenth column of matrix
        mbram_dout[2] = row18[12];  // thirteenth column of matrix
        mbram_dout[3] = row19[12];  // thirteenth column of matrix
        mbram_dout[4] = row20[12];  // thirteenth column of matrix
        mbram_dout[5] = row21[12];  // thirteenth column of matrix
        mbram_dout[6] = row22[12];  // thirteenth column of matrix
        mbram_dout[7] = row23[12];  // thirteenth column of matrix

        // cycle 48
        @(posedge clk)
        mbram_dout[0] = row16[13];  // fourteenth column of matrix
        mbram_dout[1] = row17[13];  // fourteenth column of matrix
        mbram_dout[2] = row18[13];  // fourteenth column of matrix
        mbram_dout[3] = row19[13];  // fourteenth column of matrix
        mbram_dout[4] = row20[13];  // fourteenth column of matrix
        mbram_dout[5] = row21[13];  // fourteenth column of matrix
        mbram_dout[6] = row22[13];  // fourteenth column of matrix
        mbram_dout[7] = row23[13];  // fourteenth column of matrix

        // cycle 49
        @(posedge clk)
        mbram_dout[0] = row16[14];  // fifteenth column of matrix
        mbram_dout[1] = row17[14];  // fifteenth column of matrix
        mbram_dout[2] = row18[14];  // fifteenth column of matrix
        mbram_dout[3] = row19[14];  // fifteenth column of matrix
        mbram_dout[4] = row20[14];  // fifteenth column of matrix
        mbram_dout[5] = row21[14];  // fifteenth column of matrix
        mbram_dout[6] = row22[14];  // fifteenth column of matrix
        mbram_dout[7] = row23[14];  // fifteenth column of matrix

        // cycle 50
        @(posedge clk)
        mbram_dout[0] = row16[15];  // sixteenth column of matrix
        mbram_dout[1] = row17[15];  // sixteenth column of matrix
        mbram_dout[2] = row18[15];  // sixteenth column of matrix
        mbram_dout[3] = row19[15];  // sixteenth column of matrix
        mbram_dout[4] = row20[15];  // sixteenth column of matrix
        mbram_dout[5] = row21[15];  // sixteenth column of matrix
        mbram_dout[6] = row22[15];  // sixteenth column of matrix
        mbram_dout[7] = row23[15];  // sixteenth column of matrix

        // cycle 51
        @(posedge clk)
        mbram_dout[0] = row16[16];  // seventeenth column of matrix
        mbram_dout[1] = row17[16];  // seventeenth column of matrix
        mbram_dout[2] = row18[16];  // seventeenth column of matrix
        mbram_dout[3] = row19[16];  // seventeenth column of matrix
        mbram_dout[4] = row20[16];  // seventeenth column of matrix
        mbram_dout[5] = row21[16];  // seventeenth column of matrix
        mbram_dout[6] = row22[16];  // seventeenth column of matrix
        mbram_dout[7] = row23[16];  // seventeenth column of matrix

        // cycle 52
        @(posedge clk)
        mbram_dout[0] = row00[0];  // first column of matrix
        mbram_dout[1] = row01[0];  // first column of matrix
        mbram_dout[2] = row02[0];  // first column of matrix
        mbram_dout[3] = row03[0];  // first column of matrix
        mbram_dout[4] = row04[0];  // first column of matrix
        mbram_dout[5] = row05[0];  // first column of matrix
        mbram_dout[6] = row06[0];  // first column of matrix
        mbram_dout[7] = row07[0];  // first column of matrix
        vbram_dout[0] = 25'h0000134;  // first result stored in vbram0
        asel = 2'b00;  // switch to use the bram output as vector

        // cycle 53
        @(posedge clk)
        mbram_dout[0] = row00[1];  // second column of matrix
        mbram_dout[1] = row01[1];  // second column of matrix
        mbram_dout[2] = row02[1];  // second column of matrix
        mbram_dout[3] = row03[1];  // second column of matrix
        mbram_dout[4] = row04[1];  // second column of matrix
        mbram_dout[5] = row05[1];  // second column of matrix
        mbram_dout[6] = row06[1];  // second column of matrix
        mbram_dout[7] = row07[1];  // second column of matrix
        vbram_dout[0] = 25'h000024C;  // second result stored in vbram0

        // cycle 54
        @(posedge clk)
        csels[0] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row00[2];  // third column of matrix
        mbram_dout[1] = row01[2];  // third column of matrix
        mbram_dout[2] = row02[2];  // third column of matrix
        mbram_dout[3] = row03[2];  // third column of matrix
        mbram_dout[4] = row04[2];  // third column of matrix
        mbram_dout[5] = row05[2];  // third column of matrix
        mbram_dout[6] = row06[2];  // third column of matrix
        mbram_dout[7] = row07[2];  // third column of matrix
        vbram_dout[0] = 25'h00002EC;  // third result stored in vbram0

        // cycle 55
        @(posedge clk)
        csels[0] = 1'b1;  // accumulation
        csels[1] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row00[3];  // forth column of matrix
        mbram_dout[1] = row01[3];  // forth column of matrix
        mbram_dout[2] = row02[3];  // forth column of matrix
        mbram_dout[3] = row03[3];  // forth column of matrix
        mbram_dout[4] = row04[3];  // forth column of matrix
        mbram_dout[5] = row05[3];  // forth column of matrix
        mbram_dout[6] = row06[3];  // forth column of matrix
        mbram_dout[7] = row07[3];  // forth column of matrix
        vbram_dout[0] = 25'h00001AA;  // forth result stored in vbram0
        ressel = 3'b000;  // seventeenth result has been buffered
        @(negedge clk)
        dinsel = 2'b00;  // store the seventeenth result into vbram1

        // cycle 56
        @(posedge clk)
        csels[1] = 1'b1;  // accumulation
        csels[2] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row00[4];  // fifth column of matrix
        mbram_dout[1] = row01[4];  // fifth column of matrix
        mbram_dout[2] = row02[4];  // fifth column of matrix
        mbram_dout[3] = row03[4];  // fifth column of matrix
        mbram_dout[4] = row04[4];  // fifth column of matrix
        mbram_dout[5] = row05[4];  // fifth column of matrix
        mbram_dout[6] = row06[4];  // fifth column of matrix
        mbram_dout[7] = row07[4];  // fifth column of matrix
        vbram_dout[0] = 25'h00001FE;  // fifth result stored in vbram0
        ressel = 3'b001;  // actually doesn't matter since it's dummy result

        // cycle 57
        @(posedge clk)
        csels[2] = 1'b1;  // accumulation
        csels[3] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row00[5];  // sixth column of matrix
        mbram_dout[1] = row01[5];  // sixth column of matrix
        mbram_dout[2] = row02[5];  // sixth column of matrix
        mbram_dout[3] = row03[5];  // sixth column of matrix
        mbram_dout[4] = row04[5];  // sixth column of matrix
        mbram_dout[5] = row05[5];  // sixth column of matrix
        mbram_dout[6] = row06[5];  // sixth column of matrix
        mbram_dout[7] = row07[5];  // sixth column of matrix
        vbram_dout[0] = 25'h000032A;  // sixth result stored in vbram0
        ressel = 3'b010;  // actually doesn't matter since it's dummy result

        // cycle 58
        @(posedge clk)
        csels[3] = 1'b1;  // accumulation
        csels[4] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row00[6];  // seventh column of matrix
        mbram_dout[1] = row01[6];  // seventh column of matrix
        mbram_dout[2] = row02[6];  // seventh column of matrix
        mbram_dout[3] = row03[6];  // seventh column of matrix
        mbram_dout[4] = row04[6];  // seventh column of matrix
        mbram_dout[5] = row05[6];  // seventh column of matrix
        mbram_dout[6] = row06[6];  // seventh column of matrix
        mbram_dout[7] = row07[6];  // seventh column of matrix
        vbram_dout[0] = 25'h00003CC;  // seventh result stored in vbram0
        ressel = 3'b011;  // actually doesn't matter since it's dummy result

        // cycle 59
        @(posedge clk)
        csels[4] = 1'b1;  // accumulation
        csels[5] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row00[7];  // eighth column of matrix
        mbram_dout[1] = row01[7];  // eighth column of matrix
        mbram_dout[2] = row02[7];  // eighth column of matrix
        mbram_dout[3] = row03[7];  // eighth column of matrix
        mbram_dout[4] = row04[7];  // eighth column of matrix
        mbram_dout[5] = row05[7];  // eighth column of matrix
        mbram_dout[6] = row06[7];  // eighth column of matrix
        mbram_dout[7] = row07[7];  // eighth column of matrix
        vbram_dout[0] = 25'h000025C;  // eighth result stored in vbram0
        ressel = 3'b100;  // actually doesn't matter since it's dummy result

        // cycle 60
        @(posedge clk)
        csels[5] = 1'b1;  // accumulation
        csels[6] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row00[8];  // ninth column of matrix
        mbram_dout[1] = row01[8];  // ninth column of matrix
        mbram_dout[2] = row02[8];  // ninth column of matrix
        mbram_dout[3] = row03[8];  // ninth column of matrix
        mbram_dout[4] = row04[8];  // ninth column of matrix
        mbram_dout[5] = row05[8];  // ninth column of matrix
        mbram_dout[6] = row06[8];  // ninth column of matrix
        mbram_dout[7] = row07[8];  // ninth column of matrix
        vbram_dout[0] = 25'h0000202;  // ninth result stored in vbram0
        ressel = 3'b101;  // actually doesn't matter since it's dummy result

        // cycle 61
        @(posedge clk)
        csels[6] = 1'b1;  // accumulation
        csels[7] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row00[9];  // tenth column of matrix
        mbram_dout[1] = row01[9];  // tenth column of matrix
        mbram_dout[2] = row02[9];  // tenth column of matrix
        mbram_dout[3] = row03[9];  // tenth column of matrix
        mbram_dout[4] = row04[9];  // tenth column of matrix
        mbram_dout[5] = row05[9];  // tenth column of matrix
        mbram_dout[6] = row06[9];  // tenth column of matrix
        mbram_dout[7] = row07[9];  // tenth column of matrix
        vbram_dout[0] = 25'h000021E;  // tenth result stored in vbram0
        ressel = 3'b110;  // actually doesn't matter since it's dummy result


        // cycle 62
        @(posedge clk)
        csels[7] = 1'b1;  // accumulation
        mbram_dout[0] = row00[10];  // eleventh column of matrix
        mbram_dout[1] = row01[10];  // eleventh column of matrix
        mbram_dout[2] = row02[10];  // eleventh column of matrix
        mbram_dout[3] = row03[10];  // eleventh column of matrix
        mbram_dout[4] = row04[10];  // eleventh column of matrix
        mbram_dout[5] = row05[10];  // eleventh column of matrix
        mbram_dout[6] = row06[10];  // eleventh column of matrix
        mbram_dout[7] = row07[10];  // eleventh column of matrix
        vbram_dout[0] = 25'h00001DA;  // eleventh result stored in vbram0
        ressel = 3'b111;  // actually doesn't matter since it's dummy result

        // cycle 63
        @(posedge clk)
        mbram_dout[0] = row00[11];  // twelfth column of matrix
        mbram_dout[1] = row01[11];  // twelfth column of matrix
        mbram_dout[2] = row02[11];  // twelfth column of matrix
        mbram_dout[3] = row03[11];  // twelfth column of matrix
        mbram_dout[4] = row04[11];  // twelfth column of matrix
        mbram_dout[5] = row05[11];  // twelfth column of matrix
        mbram_dout[6] = row06[11];  // twelfth column of matrix
        mbram_dout[7] = row07[11];  // twelfth column of matrix
        vbram_dout[0] = 25'h00001EE;  // twelfth result stored in vbram0
        ressel = 3'b000;  // actually doesn't matter since no new result

        // cycle 64
        @(posedge clk)
        mbram_dout[0] = row00[12];  // thirteenth column of matrix
        mbram_dout[1] = row01[12];  // thirteenth column of matrix
        mbram_dout[2] = row02[12];  // thirteenth column of matrix
        mbram_dout[3] = row03[12];  // thirteenth column of matrix
        mbram_dout[4] = row04[12];  // thirteenth column of matrix
        mbram_dout[5] = row05[12];  // thirteenth column of matrix
        mbram_dout[6] = row06[12];  // thirteenth column of matrix
        mbram_dout[7] = row07[12];  // thirteenth column of matrix
        vbram_dout[0] = 25'h000020C;  // thirteenth result stored in vbram0

        // cycle 65
        @(posedge clk)
        mbram_dout[0] = row00[13];  // fourteenth column of matrix
        mbram_dout[1] = row01[13];  // fourteenth column of matrix
        mbram_dout[2] = row02[13];  // fourteenth column of matrix
        mbram_dout[3] = row03[13];  // fourteenth column of matrix
        mbram_dout[4] = row04[13];  // fourteenth column of matrix
        mbram_dout[5] = row05[13];  // fourteenth column of matrix
        mbram_dout[6] = row06[13];  // fourteenth column of matrix
        mbram_dout[7] = row07[13];  // fourteenth column of matrix
        vbram_dout[0] = 25'h00001EE;  // fourteenth result stored in vbram0

        // cycle 66
        @(posedge clk)
        mbram_dout[0] = row00[14];  // fifteenth column of matrix
        mbram_dout[1] = row01[14];  // fifteenth column of matrix
        mbram_dout[2] = row02[14];  // fifteenth column of matrix
        mbram_dout[3] = row03[14];  // fifteenth column of matrix
        mbram_dout[4] = row04[14];  // fifteenth column of matrix
        mbram_dout[5] = row05[14];  // fifteenth column of matrix
        mbram_dout[6] = row06[14];  // fifteenth column of matrix
        mbram_dout[7] = row07[14];  // fifteenth column of matrix
        vbram_dout[0] = 25'h0000216;  // fifteenth result stored in vbram0

        // cycle 67
        @(posedge clk)
        mbram_dout[0] = row00[15];  // sixteenth column of matrix
        mbram_dout[1] = row01[15];  // sixteenth column of matrix
        mbram_dout[2] = row02[15];  // sixteenth column of matrix
        mbram_dout[3] = row03[15];  // sixteenth column of matrix
        mbram_dout[4] = row04[15];  // sixteenth column of matrix
        mbram_dout[5] = row05[15];  // sixteenth column of matrix
        mbram_dout[6] = row06[15];  // sixteenth column of matrix
        mbram_dout[7] = row07[15];  // sixteenth column of matrix
        vbram_dout[0] = 25'h0000212;  // sixteenth result stored in vbram0
        vbram_dout[1] = 25'h0002EEC;  // seventeenth result from vbram1
        @(negedge clk)
        dinsel = 2'b01;  // vbram0 stores seventeenth result from vbram1

        // cycle 68
        @(posedge clk)
        mbram_dout[0] = row00[16];  // seventeenth column of matrix
        mbram_dout[1] = row01[16];  // seventeenth column of matrix
        mbram_dout[2] = row02[16];  // seventeenth column of matrix
        mbram_dout[3] = row03[16];  // seventeenth column of matrix
        mbram_dout[4] = row04[16];  // seventeenth column of matrix
        mbram_dout[5] = row05[16];  // seventeenth column of matrix
        mbram_dout[6] = row06[16];  // seventeenth column of matrix
        mbram_dout[7] = row07[16];  // seventeenth column of matrix
        vbram_dout[0] = 25'h0002EEC;  // seventeenth writing into vbram0
        @(negedge clk)
        dinsel = 2'b00;

        // cycle 69
        @(posedge clk)
        mbram_dout[0] = row08[0];  // first column of matrix
        mbram_dout[1] = row09[0];  // first column of matrix
        mbram_dout[2] = row10[0];  // first column of matrix
        mbram_dout[3] = row11[0];  // first column of matrix
        mbram_dout[4] = row12[0];  // first column of matrix
        mbram_dout[5] = row13[0];  // first column of matrix
        mbram_dout[6] = row14[0];  // first column of matrix
        mbram_dout[7] = row15[0];  // first column of matrix
        vbram_dout[0] = 25'h0000134;  // first result stored in vbram0

        // cycle 70
        @(posedge clk)
        mbram_dout[0] = row08[1];  // second column of matrix
        mbram_dout[1] = row09[1];  // second column of matrix
        mbram_dout[2] = row10[1];  // second column of matrix
        mbram_dout[3] = row11[1];  // second column of matrix
        mbram_dout[4] = row12[1];  // second column of matrix
        mbram_dout[5] = row13[1];  // second column of matrix
        mbram_dout[6] = row14[1];  // second column of matrix
        mbram_dout[7] = row15[1];  // second column of matrix
        vbram_dout[0] = 25'h000024C;  // second result stored in vbram0

        // cycle 71
        @(posedge clk)
        csels[0] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row08[2];  // third column of matrix
        mbram_dout[1] = row09[2];  // third column of matrix
        mbram_dout[2] = row10[2];  // third column of matrix
        mbram_dout[3] = row11[2];  // third column of matrix
        mbram_dout[4] = row12[2];  // third column of matrix
        mbram_dout[5] = row13[2];  // third column of matrix
        mbram_dout[6] = row14[2];  // third column of matrix
        mbram_dout[7] = row15[2];  // third column of matrix
        vbram_dout[0] = 25'h00002EC;  // third result stored in vbram0

        // cycle 72
        @(posedge clk)
        csels[0] = 1'b1;  // accumulate
        csels[1] = 1'b0;  // restart accumulation from 0
        mbram_dout[0] = row08[3];  // forth column of matrix
        mbram_dout[1] = row09[3];  // forth column of matrix
        mbram_dout[2] = row10[3];  // forth column of matrix
        mbram_dout[3] = row11[3];  // forth column of matrix
        mbram_dout[4] = row12[3];  // forth column of matrix
        mbram_dout[5] = row13[3];  // forth column of matrix
        mbram_dout[6] = row14[3];  // forth column of matrix
        mbram_dout[7] = row15[3];  // forth column of matrix
        vbram_dout[0] = 25'h00001AA;  // forth result stored in vbram0
        ressel = 3'b000;  // first result has been buffered
        @(negedge clk)
        dinsel = 2'b00;

        /*
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
        */
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        #10
        $finish;
    end

endmodule
