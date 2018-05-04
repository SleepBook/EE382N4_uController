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

    wire mbram_clk, mbram_en, vbram_clk, vbram_en, vbram_we;
    wire [11:0] mbram_addr;
    wire [9:0] vbram_addr;
    wire [191:0] vbram_din;

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


    reg [1151:0] mbram_dout = 0;
    reg [191:0] vbram_dout = 0;

	M6x6x2e12_V6x2e6_v1_0 #
	(
		.C_S00_AXI_DATA_WIDTH(32),
		.C_S00_AXI_ADDR_WIDTH(4)
	) dut (
		// Users to add ports here
        .mbram_clk(mbram_clk),
        .mbram_en(mbram_en),
        .mbram_addr(mbram_addr),
        .mbram_dout(mbram_dout), // matrix bram data read out
        .vbram_clk(vbram_clk),
        .vbram_en(vbram_en),
        .vbram_we(vbram_we),
        .vbram_addr(vbram_addr),
        .vbram_din(vbram_din),  // vector bram data write in
        .vbram_dout(vbram_dout), // vector bram data read out

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


    reg [1151:0] submatrix[8:0];
    reg [191:0] subvector[2:0];
    initial
    begin
        subvector[0] = { 6{32'h3F000000}};
        subvector[1] = { 6{32'h3F000000}};
        subvector[2] = {{5{32'h00000000}}, 32'h3F000000 };
        submatrix[0] = {
            {
              32'h3E000000,  // 0.125
              32'h410A0000,  // 8.625
              32'h40E80000,  // 7.25
              32'h3FC00000,  // 1.5
              32'h3F000000,  // 0.5
              32'h3FA00000   // 1.25
            },
            {
              32'h410A0000,  // 8.625
              32'h40E80000,  // 7.25
              32'h3FC00000,  // 1.5
              32'h3F000000,  // 0.5
              32'h3FA00000,  // 1.25
              32'h3E000000   // 0.125
            },
            {
              32'h40E80000,  // 7.25
              32'h3FC00000,  // 1.5
              32'h3F000000,  // 0.5
              32'h3FA00000,  // 1.25
              32'h3E000000,  // 0.125
              32'h410A0000   // 8.625
            },
            {
              32'h3FC00000,  // 1.5
              32'h3F000000,  // 0.5
              32'h3FA00000,  // 1.25
              32'h3E000000,  // 0.125
              32'h410A0000,  // 8.625
              32'h40E80000   // 7.25
            },
            {
              32'h3F000000,  // 0.5
              32'h3FA00000,  // 1.25
              32'h3E000000,  // 0.125
              32'h410A0000,  // 8.625
              32'h40E80000,  // 7.25
              32'h3FC00000   // 1.5
            },
            {
              32'h3FA00000,  // 1.25
              32'h3E000000,  // 0.125
              32'h410A0000,  // 8.625
              32'h40E80000,  // 7.25
              32'h3FC00000,  // 1.5
              32'h3F000000   // 0.5
            }
        };
        submatrix[1] = {
            {
              32'h3FA00000,  // 1.25
              32'h3E000000,  // 0.125
              32'h410A0000,  // 8.625
              32'h40E80000,  // 7.25
              32'h3FC00000,  // 1.5
              32'h3F000000   // 0.5
            },
            {
              32'h3E000000,  // 0.125
              32'h410A0000,  // 8.625
              32'h40E80000,  // 7.25
              32'h3FC00000,  // 1.5
              32'h3F000000,  // 0.5
              32'h3FA00000   // 1.25
            },
            {
              32'h410A0000,  // 8.625
              32'h40E80000,  // 7.25
              32'h3FC00000,  // 1.5
              32'h3F000000,  // 0.5
              32'h3FA00000,  // 1.25
              32'h3E000000   // 0.125
            },
            {
              32'h40E80000,  // 7.25
              32'h3FC00000,  // 1.5
              32'h3F000000,  // 0.5
              32'h3FA00000,  // 1.25
              32'h3E000000,  // 0.125
              32'h410A0000   // 8.625
            },
            {
              32'h3FC00000,  // 1.5
              32'h3F000000,  // 0.5
              32'h3FA00000,  // 1.25
              32'h3E000000,  // 0.125
              32'h410A0000,  // 8.625
              32'h40E80000   // 7.25
            },
            {
              32'h3F000000,  // 0.5
              32'h3FA00000,  // 1.25
              32'h3E000000,  // 0.125
              32'h410A0000,  // 8.625
              32'h40E80000,  // 7.25
              32'h3FC00000   // 1.5
            }
        };
        submatrix[2] = {
            {30{32'h00000000 }}, // all 0s
            {6{ 32'h3F000000 }}  // 0.5
        };
        submatrix[3] = {
            {
              32'h42100000,  // 36
              32'h420C0000,  // 35
              32'h42080000,  // 34
              32'h42040000,  // 33
              32'h42000000,  // 32
              32'h41F80000   // 31
            },
            {
              32'h41F00000,  // 30
              32'h41E80000,  // 29
              32'h41E00000,  // 28
              32'h41D80000,  // 27
              32'h41D00000,  // 26
              32'h41C80000   // 25
            },
            {
              32'h41C00000,  // 24
              32'h41B80000,  // 23
              32'h41B00000,  // 22
              32'h41A80000,  // 21
              32'h41A00000,  // 20
              32'h41980000   // 19
            },
            {
              32'h41900000,  // 18
              32'h41880000,  // 17
              32'h41800000,  // 16
              32'h41700000,  // 15
              32'h41600000,  // 14
              32'h41500000   // 13
            },
            {
              32'h41400000,  // 12
              32'h41300000,  // 11
              32'h41200000,  // 10
              32'h41100000,  // 9
              32'h41000000,  // 8
              32'h40E00000   // 7
            },
            {
              32'h40C00000,  // 6
              32'h40A00000,  // 5
              32'h40800000,  // 4
              32'h40400000,  // 3
              32'h40000000,  // 2
              32'h3F800000   // 1
            }
        };
        submatrix[4] = {
            {
              32'h41F80000,  // 31
              32'h42000000,  // 32
              32'h42040000,  // 33
              32'h42080000,  // 34
              32'h420C0000,  // 35
              32'h42100000   // 36
            },
            {
              32'h41E80000,  // 29
              32'h41F00000,  // 30
              32'h41D80000,  // 27
              32'h41E00000,  // 28
              32'h41C80000,  // 25
              32'h41D00000   // 26
            },
            {
              32'h41A80000,  // 21
              32'h41A00000,  // 20
              32'h41980000,  // 19
              32'h41C00000,  // 24
              32'h41B80000,  // 23
              32'h41B00000   // 22
            },
            {
              32'h41900000,  // 18
              32'h41880000,  // 17
              32'h41800000,  // 16
              32'h41700000,  // 15
              32'h41600000,  // 14
              32'h41500000   // 13
            },
            {
              32'h41400000,  // 12
              32'h41300000,  // 11
              32'h41200000,  // 10
              32'h41100000,  // 9
              32'h41000000,  // 8
              32'h40E00000   // 7
            },
            {
              32'h40C00000,  // 6
              32'h40A00000,  // 5
              32'h40800000,  // 4
              32'h40400000,  // 3
              32'h40000000,  // 2
              32'h3F800000   // 1
            }
        };
        submatrix[5] = {
            {30{32'h00000000 }}, // all 0s
            {
              32'h43730000,  // 243
              32'h436B0000,  // 235
              32'h435F0000,  // 223
              32'h435E0000,  // 222
              32'h43500000,  // 208
              32'h43490000   // 201
            }  // 0.5
        };
        submatrix[6] = {
            {6{
              {5{32'h000000000}},
              32'h3F000000  // 0.5
            }}
        };
        submatrix[7] = {
            {6{
              {5{32'h000000000}},
              32'h3F000000  // 0.5
            }}
        };
        submatrix[8] = {
            {35{32'h00000000}},
            32'h3F000000
        };
    end

    always @ (posedge mbram_clk)
    begin
        case(mbram_addr)
            12'h000: mbram_dout <= submatrix[0];
            12'h001: mbram_dout <= submatrix[1];
            12'h002: mbram_dout <= submatrix[2];
            12'h003: mbram_dout <= submatrix[3];
            12'h004: mbram_dout <= submatrix[4];
            12'h005: mbram_dout <= submatrix[5];
            12'h006: mbram_dout <= submatrix[6];
            12'h007: mbram_dout <= submatrix[7];
            12'h008: mbram_dout <= submatrix[8];
            default: mbram_dout <= {36{32'h00000000}};
        endcase
    end

    always @ (posedge vbram_clk)
    begin
        case(vbram_addr)
            10'h000: vbram_dout <= subvector[0];
            10'h001: vbram_dout <= subvector[1];
            10'h002: vbram_dout <= subvector[2];
            default: vbram_dout <= {36{32'h00000000}};
        endcase
    end

    initial
      begin
        wait(s00_axi_aresetn);
        #500
        axi_lite_write(0, 32'h000100D1);
        #1200
        subvector[0] = {6{32'h419C0000}};
        subvector[1] = {32'h43730000, 32'h43680000, 32'h435F0000, 32'h435D8000, 32'h43508000, 32'h43490000};
        subvector[2] = {{5{32'h00000000}}, 32'h40500000};
        axi_lite_write(0, 32'h000100D1);
        #1200
        $finish;
      end


endmodule
