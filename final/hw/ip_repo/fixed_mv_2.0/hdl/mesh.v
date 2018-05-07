`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2018 03:10:05 PM
// Design Name: 
// Module Name: mesh
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


module mesh # (
    parameter integer IDX_WIDTH_FOR_NODES = 6,
    parameter integer NUM_NODES = 2 ** IDX_WIDTH_FOR_NODES
)
(
    input clk,
    input rstn,
    //input [NUM_NODES-1:0] sclrs,  // clear mac in a node independently
    input [17:0] init,  // initial value of vector
    input [1:0] asel,  // select ain for the first node
    input [NUM_NODES-1:0] csels,  // select c for a node independently
    input [IDX_WIDTH_FOR_NODES-1:0] ressel,  // select a result of one node to bram
    input [1:0] dinsel,  // select din to brams
    input [18*NUM_NODES-1:0] mbram_dout,  // matrix rows in
    input [17:0] vbram0_dout,  // data output from vbram0
    input [17:0] vbram1_dout,  // data output from vbram1
    output [17:0] vbram0_din,  // data input to vbram0
    output [17:0] vbram1_din   // data input to vbram1
    );

    // delay lanes
    wire [17:0] bdly [NUM_NODES-1:0];  // bins after delay
    assign bdly[0][17:0] = mbram_dout[17:0];  // no need to delay the first one
    genvar i;
    generate
    for(i = 1; i < NUM_NODES; i = i + 1)
    begin
        dly # (
            .DATA_WIDTH(18),
            .CYC_DLY(i)
        ) dly_inst (
            .clk(clk),
            .rstn(rstn),
            .din(mbram_dout[18*i +: 18]),
            .dout(bdly[i][17:0])
        );
    end
    endgenerate

    // nodes
    wire [17:0] ress [NUM_NODES-1:0];  // results of nodes
    wire [17:0] aout2in [NUM_NODES:0];  // connect aout of last node to ain of next
    wire [17:0] vbram_dout_selected;
    wire [17:0] ain_selected;
    assign vbram_dout_selected = asel[0] ? vbram1_dout[17:0] : vbram0_dout[17:0];
    assign ain_selected = asel[1] ? init[17:0] : vbram_dout_selected[17:0];
    assign aout2in[0][17:0] = ain_selected[17:0];  // sign-extend
    generate
    for(i = 0; i < NUM_NODES; i = i + 1)
    begin
        node node_in_mesh (
            .clk(clk),
            //.ce(1'b1),
            .rstn(rstn),
            //.sclr(sclrs[i]),
            .subtract(1'b0),
            .ain(aout2in[i][17:0]),
            .bin(bdly[i][17:0]),
            .csel(csels[i]),
            .aout(aout2in[i+1][17:0]),
            .res(ress[i][17:0])
        );
    end
    endgenerate

    // BIG mux to select results of nodes to use
    reg [17:0] res_bufs [NUM_NODES-1:0];  // buffered results of nodes
    generate
    for(i = 0; i < NUM_NODES; i = i + 1)
    begin
        always @ (posedge clk)
        begin
            res_bufs[i] <= ress[i][17:0];
        end
    end
    endgenerate
    reg [17:0] res_selected;  // this is the data to bram
    always @ (negedge clk)  // so prepare on falling edges
    begin
        res_selected <= res_bufs[ressel][17:0];
    end
    assign vbram0_din = dinsel[0] ? vbram1_dout : res_selected;
    assign vbram1_din = dinsel[1] ? vbram0_dout : res_selected;

endmodule
