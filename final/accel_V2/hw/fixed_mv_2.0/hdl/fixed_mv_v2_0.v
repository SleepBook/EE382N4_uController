
`timescale 1 ns / 1 ps

	module fixed_mv_v2_0 #
	(
		// Users to add parameters here
        parameter integer IDX_WIDTH_FOR_NODES = 6,
        parameter integer NUM_NODES = 2 ** IDX_WIDTH_FOR_NODES,
        parameter integer MBRAM_ADDR_WIDTH = 12,
        parameter integer VBRAM_ADDR_WIDTH = 10,
        parameter integer WIDTH_WIDTH = 9,  // bit width of the input width
        parameter integer ITERATION_WIDTH = 16,  // bit width of the input iteration

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
        output wire mbram_clk,  // matrix bram clock
        output wire mbram_en,   // matrix bram enable
        output wire [MBRAM_ADDR_WIDTH-1 : 0] mbram_addr, // matrix bram address
        input  wire [18*NUM_NODES-1:0] mbram_dout,  // matrix rows in
        output wire vbram0_clk,  // vector bram clock
        output wire vbram0_en,   // vector bram enable
        output wire [VBRAM_ADDR_WIDTH-1 : 0]  vbram0_addr, // vector bram address
        input  wire [17 : 0] vbram0_dout,  // data output from vbram0
        output wire [0 : 0]  vbram0_we,   // vector bram write enable
        output wire [17 : 0] vbram0_din,  // data input to vbram0
        output wire vbram1_clk,  // vector bram clock
        output wire vbram1_en,   // vector bram enable
        output wire [VBRAM_ADDR_WIDTH-1 : 0]  vbram1_addr, // vector bram address
        input  wire [17 : 0] vbram1_dout,  // data output from vbram1
        output wire [0 : 0]  vbram1_we,   // vector bram write enable
        output wire [17 : 0] vbram1_din,  // data input to vbram1


		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
// Instantiation of Axi Bus Interface S00_AXI
	fixed_mv_v2_0_S00_AXI # ( 
        .IDX_WIDTH_FOR_NODES(IDX_WIDTH_FOR_NODES),
        .MBRAM_ADDR_WIDTH(MBRAM_ADDR_WIDTH),
        .VBRAM_ADDR_WIDTH(VBRAM_ADDR_WIDTH),
        .WIDTH_WIDTH(WIDTH_WIDTH),
        .ITERATION_WIDTH(ITERATION_WIDTH),
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) fixed_mv_v2_0_S00_AXI_inst (
        .mbram_clk(mbram_clk),  // matrix bram clock
        .mbram_en(mbram_en),   // matrix bram enable
        .mbram_addr(mbram_addr), // matrix bram address
        .vbram0_clk(vbram0_clk),  // vector bram clock
        .vbram0_en(vbram0_en),   // vector bram enable
        .vbram0_we(vbram0_we),   // vector bram write enable
        .vbram0_addr(vbram0_addr), // vector bram address
        .vbram1_clk(vbram1_clk),  // vector bram clock
        .vbram1_en(vbram1_en),   // vector bram enable
        .vbram1_we(vbram1_we),   // vector bram write enable
        .vbram1_addr(vbram1_addr), // vector bram address
        .mbram_dout(mbram_dout),  // matrix rows in
        .vbram0_dout(vbram0_dout),  // data output from vbram0
        .vbram1_dout(vbram1_dout),  // data output from vbram1
        .vbram0_din(vbram0_din),  // data input to vbram0
        .vbram1_din(vbram1_din),  // data input to vbram1
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule
