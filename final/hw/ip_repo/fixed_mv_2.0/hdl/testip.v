`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2018 09:25:06 PM
// Design Name: 
// Module Name: testip
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


module testip(

    );

    reg s00_axi_aclk = 0;
    always #5 s00_axi_aclk = ~s00_axi_aclk;
    reg s00_axi_aresetn = 0;
    initial
    begin
        s00_axi_aresetn = 0;
        #20
        s00_axi_aresetn = 1;
    end

    wire mbram_clk, mbram_en;
    wire vbram0_clk, vbram0_en, vbram0_we;
    wire vbram1_clk, vbram1_en, vbram1_we;
    wire [11:0] mbram_addr;
    wire [9:0] vbram0_addr;
    wire [17:0] vbram0_din;
    wire [9:0] vbram1_addr;
    wire [17:0] vbram1_din;

    wire s00_axi_awready;
    wire s00_axi_wready;
    wire [1:0] s00_axi_bresp;
    wire s00_axi_bvalid;
    wire s00_axi_arready;
    wire [31:0] s00_axi_rdata;
    wire s00_axi_rresp;
    wire s00_axi_rvalid;

    reg [31:0] s00_axi_araddr = 0;
    reg s00_axi_arvalid = 0;
    reg s00_axi_rready = 0;

    task axi_lite_read;
        input [31:0] addr;
        begin
            $display ("%g AXI-Lite read with address: %h", $time, addr);
            @ (posedge s00_axi_aclk)
            s00_axi_araddr = addr;
            s00_axi_arvalid = 1;
            s00_axi_rready = 1;
            //@ (posedge s00_axi_aclk)
            //@ (posedge s00_axi_aclk)
            //@ (posedge s00_axi_aclk)
            wait(s00_axi_arready);
            // arready should be set
            //@ (posedge s00_axi_aclk)
            wait(s00_axi_rvalid)
            // rvalid should be set
            s00_axi_araddr = 0;
            s00_axi_arvalid = 0;
            @ (posedge s00_axi_aclk)
            // should latch data
            s00_axi_rready = 0;
        end
    endtask

    reg [31:0] s00_axi_awaddr = 0;
    reg s00_axi_awvalid = 0;
    reg [31:0] s00_axi_wdata = 0;
    reg s00_axi_wvalid = 0;
    reg s00_axi_bready = 0;

    task axi_lite_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            $display ("%g AXI-Lite write with address: %h, data: %h", $time, addr, data);
            @ (posedge s00_axi_aclk)
            s00_axi_awaddr = addr;
            s00_axi_awvalid = 1;
            s00_axi_wdata = data;
            s00_axi_wvalid = 1;
            s00_axi_bready = 1;
            //@ (posedge s00_axi_aclk)
            //@ (posedge s00_axi_aclk)
            //@ (posedge s00_axi_aclk)
            wait(s00_axi_awready & s00_axi_wready);
            // awready and wready should be set
            //@ (posedge s00_axi_aclk)
            wait(s00_axi_bvalid);
            // slave should latch the data
            // bvalid should be set
            s00_axi_awaddr = 0;
            s00_axi_awvalid = 0;
            s00_axi_wdata = 0;
            @ (posedge s00_axi_aclk)
            s00_axi_bready = 0;
        end
    endtask


    reg [143:0] mbram_dout = 0;
    reg [17:0] vbram0_dout = 0;
    reg [17:0] vbram1_dout = 0;

	fixed_mv_v2_0 #
	(
        .IDX_WIDTH_FOR_NODES(3),
        .MBRAM_ADDR_WIDTH(12),
        .VBRAM_ADDR_WIDTH(10),
        .WIDTH_WIDTH(9),
        .ITERATION_WIDTH(16),
		.C_S00_AXI_DATA_WIDTH(32),
		.C_S00_AXI_ADDR_WIDTH(4)
	) dut (
		// Users to add ports here
        .mbram_clk(mbram_clk),
        .mbram_en(mbram_en),
        .mbram_addr(mbram_addr),
        .mbram_dout(mbram_dout), // matrix bram data read out
        .vbram0_clk(vbram0_clk),
        .vbram0_en(vbram0_en),
        .vbram0_we(vbram0_we),
        .vbram0_addr(vbram0_addr),
        .vbram0_din(vbram0_din),  // vector bram data write in
        .vbram0_dout(vbram0_dout), // vector bram data read out
        .vbram1_clk(vbram1_clk),
        .vbram1_en(vbram1_en),
        .vbram1_we(vbram1_we),
        .vbram1_addr(vbram1_addr),
        .vbram1_din(vbram1_din),  // vector bram data write in
        .vbram1_dout(vbram1_dout), // vector bram data read out

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
        .s00_axi_aclk(s00_axi_aclk),
        .s00_axi_aresetn(s00_axi_aresetn),
        .s00_axi_awaddr(s00_axi_awaddr),
        .s00_axi_awprot(2'b00),  // not used
        .s00_axi_awvalid(s00_axi_awvalid),
        .s00_axi_awready(s00_axi_awready),
        .s00_axi_wdata(s00_axi_wdata),
        .s00_axi_wstrb(4'b1111),  // always write a 32-bit register
        .s00_axi_wvalid(s00_axi_wvalid),
        .s00_axi_wready(s00_axi_wready),
        .s00_axi_bresp(s00_axi_bresp),
        .s00_axi_bvalid(s00_axi_bvalid),
        .s00_axi_bready(s00_axi_bready),
        .s00_axi_araddr(s00_axi_araddr),
        .s00_axi_arprot(2'b00),  // not used
        .s00_axi_arvalid(s00_axi_arvalid),
        .s00_axi_arready(s00_axi_arready),
        .s00_axi_rdata(s00_axi_rdata),
        .s00_axi_rresp(s00_axi_rresp),
        .s00_axi_rvalid(s00_axi_rvalid),
        .s00_axi_rready(s00_axi_rready)
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
    //reg [17:0] row17 [16:0];
    //reg [17:0] row18 [16:0];
    //reg [17:0] row19 [16:0];
    //reg [17:0] row20 [16:0];
    //reg [17:0] row21 [16:0];
    //reg [17:0] row22 [16:0];
    //reg [17:0] row23 [16:0];
    
    reg [17:0] res0 [16:0];
    reg [17:0] res1 [16:0];


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

        res0[3] = 18'h02159; res0[2] = 18'h0219F; res0[1] = 18'h00787; res0[0] = 18'h00787;
        res0[7] = 18'h00B2F; res0[6] = 18'h03ADB; res0[5] = 18'h01F7D; res0[4] = 18'h02330;
        res0[11] = 18'h01C3B; res0[10] = 18'h009DA; res0[9] = 18'h01A69; res0[8] = 18'h0105B;
        res0[15] = 18'h02885; res0[14] = 18'h028AD; res0[13] = 18'h01B39; res0[12] = 18'h010B6;
        res0[16] = 18'h05730;

        res1[3] = 18'h01F03; res1[2] = 18'h030F1; res1[1] = 18'h00C85; res1[0] = 18'h00CB5;
        res1[7] = 18'h0109A; res1[6] = 18'h05113; res1[5] = 18'h01E3C; res1[4] = 18'h023BB;
        res1[11] = 18'h01CEA; res1[10] = 18'h008B2; res1[9] = 18'h01577; res1[8] = 18'h00FEE;
        res1[15] = 18'h03631; res1[14] = 18'h02AE7; res1[13] = 18'h01A9E; res1[12] = 18'h01084;
        res1[16] = 18'h04173;
    end

    always @ (posedge mbram_clk)
    begin
        case(mbram_addr)
            12'h000: mbram_dout<={row07[0],row06[0],row05[0],row04[0],row03[0],row02[0],row01[0],row00[0]};
            12'h001: mbram_dout<={row07[1],row06[1],row05[1],row04[1],row03[1],row02[1],row01[1],row00[1]};
            12'h002: mbram_dout<={row07[2],row06[2],row05[2],row04[2],row03[2],row02[2],row01[2],row00[2]};
            12'h003: mbram_dout<={row07[3],row06[3],row05[3],row04[3],row03[3],row02[3],row01[3],row00[3]};
            12'h004: mbram_dout<={row07[4],row06[4],row05[4],row04[4],row03[4],row02[4],row01[4],row00[4]};
            12'h005: mbram_dout<={row07[5],row06[5],row05[5],row04[5],row03[5],row02[5],row01[5],row00[5]};
            12'h006: mbram_dout<={row07[6],row06[6],row05[6],row04[6],row03[6],row02[6],row01[6],row00[6]};
            12'h007: mbram_dout<={row07[7],row06[7],row05[7],row04[7],row03[7],row02[7],row01[7],row00[7]};
            12'h008: mbram_dout<={row07[8],row06[8],row05[8],row04[8],row03[8],row02[8],row01[8],row00[8]};
            12'h009: mbram_dout<={row07[9],row06[9],row05[9],row04[9],row03[9],row02[9],row01[9],row00[9]};
            12'h00A: mbram_dout<={row07[10],row06[10],row05[10],row04[10],row03[10],row02[10],row01[10],row00[10]};
            12'h00B: mbram_dout<={row07[11],row06[11],row05[11],row04[11],row03[11],row02[11],row01[11],row00[11]};
            12'h00C: mbram_dout<={row07[12],row06[12],row05[12],row04[12],row03[12],row02[12],row01[12],row00[12]};
            12'h00D: mbram_dout<={row07[13],row06[13],row05[13],row04[13],row03[13],row02[13],row01[13],row00[13]};
            12'h00E: mbram_dout<={row07[14],row06[14],row05[14],row04[14],row03[14],row02[14],row01[14],row00[14]};
            12'h00F: mbram_dout<={row07[15],row06[15],row05[15],row04[15],row03[15],row02[15],row01[15],row00[15]};
            12'h010: mbram_dout<={row07[16],row06[16],row05[16],row04[16],row03[16],row02[16],row01[16],row00[16]};
            12'h011: mbram_dout<={row15[0],row14[0],row13[0],row12[0],row11[0],row10[0],row09[0],row08[0]};
            12'h012: mbram_dout<={row15[1],row14[1],row13[1],row12[1],row11[1],row10[1],row09[1],row08[1]};
            12'h013: mbram_dout<={row15[2],row14[2],row13[2],row12[2],row11[2],row10[2],row09[2],row08[2]};
            12'h014: mbram_dout<={row15[3],row14[3],row13[3],row12[3],row11[3],row10[3],row09[3],row08[3]};
            12'h015: mbram_dout<={row15[4],row14[4],row13[4],row12[4],row11[4],row10[4],row09[4],row08[4]};
            12'h016: mbram_dout<={row15[5],row14[5],row13[5],row12[5],row11[5],row10[5],row09[5],row08[5]};
            12'h017: mbram_dout<={row15[6],row14[6],row13[6],row12[6],row11[6],row10[6],row09[6],row08[6]};
            12'h018: mbram_dout<={row15[7],row14[7],row13[7],row12[7],row11[7],row10[7],row09[7],row08[7]};
            12'h019: mbram_dout<={row15[8],row14[8],row13[8],row12[8],row11[8],row10[8],row09[8],row08[8]};
            12'h01A: mbram_dout<={row15[9],row14[9],row13[9],row12[9],row11[9],row10[9],row09[9],row08[9]};
            12'h01B: mbram_dout<={row15[10],row14[10],row13[10],row12[10],row11[10],row10[10],row09[10],row08[10]};
            12'h01C: mbram_dout<={row15[11],row14[11],row13[11],row12[11],row11[11],row10[11],row09[11],row08[11]};
            12'h01D: mbram_dout<={row15[12],row14[12],row13[12],row12[12],row11[12],row10[12],row09[12],row08[12]};
            12'h01E: mbram_dout<={row15[13],row14[13],row13[13],row12[13],row11[13],row10[13],row09[13],row08[13]};
            12'h01F: mbram_dout<={row15[14],row14[14],row13[14],row12[14],row11[14],row10[14],row09[14],row08[14]};
            12'h020: mbram_dout<={row15[15],row14[15],row13[15],row12[15],row11[15],row10[15],row09[15],row08[15]};
            12'h021: mbram_dout<={row15[16],row14[16],row13[16],row12[16],row11[16],row10[16],row09[16],row08[16]};
            12'h022: mbram_dout<={{7{18'h00000}}, row16[0]};
            12'h023: mbram_dout<={{7{18'h00000}}, row16[1]};
            12'h024: mbram_dout<={{7{18'h00000}}, row16[2]};
            12'h025: mbram_dout<={{7{18'h00000}}, row16[3]};
            12'h026: mbram_dout<={{7{18'h00000}}, row16[4]};
            12'h027: mbram_dout<={{7{18'h00000}}, row16[5]};
            12'h028: mbram_dout<={{7{18'h00000}}, row16[6]};
            12'h029: mbram_dout<={{7{18'h00000}}, row16[7]};
            12'h02A: mbram_dout<={{7{18'h00000}}, row16[8]};
            12'h02B: mbram_dout<={{7{18'h00000}}, row16[9]};
            12'h02C: mbram_dout<={{7{18'h00000}}, row16[10]};
            12'h02D: mbram_dout<={{7{18'h00000}}, row16[11]};
            12'h02E: mbram_dout<={{7{18'h00000}}, row16[12]};
            12'h02F: mbram_dout<={{7{18'h00000}}, row16[13]};
            12'h030: mbram_dout<={{7{18'h00000}}, row16[14]};
            12'h031: mbram_dout<={{7{18'h00000}}, row16[15]};
            12'h032: mbram_dout<={{7{18'h00000}}, row16[16]};
            default: mbram_dout <= {8{18'h00000}};
        endcase
    end

    always @ (posedge vbram0_clk)
    begin
        vbram0_dout <= res0[vbram0_addr];
    end

    always @ (posedge vbram1_clk)
    begin
        vbram1_dout <= res1[vbram1_addr];
    end

    initial
      begin
        wait(s00_axi_aresetn);
        #50
        axi_lite_write(4, 32'h00001E1E);  // initial value
        axi_lite_write(0, 32'h00010111);
        #1000
        //subvector[0] = {6{32'h419C0000}};
        //subvector[1] = {32'h43730000, 32'h43680000, 32'h435F0000, 32'h435D8000, 32'h43508000, 32'h43490000};
        //subvector[2] = {{5{32'h00000000}}, 32'h40500000};
        //axi_lite_write(0, 32'h000100D1);
        axi_lite_write(0, 32'h00020111);
        #1400
        axi_lite_write(0, 32'h00030111);
        #2000
        $finish;
      end


endmodule
