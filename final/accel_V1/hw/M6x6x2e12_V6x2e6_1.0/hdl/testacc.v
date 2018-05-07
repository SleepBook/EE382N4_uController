`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2018 09:25:06 PM
// Design Name: 
// Module Name: testacc
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


module testacc(

    );

    reg clk = 0;
    always #5 clk = ~clk;

    wire [31:0] result_tdata;
    wire result_tvalid;
    wire a_tready;
    wire result_tlast;

    reg [31:0] a_tdata;
    reg a_tvalid;
    reg a_tlast;

    FP_acc FP_acc_dut (
        .aclk(clk),
        .s_axis_a_tdata(a_tdata),
        .s_axis_a_tvalid(a_tvalid),
        .s_axis_a_tlast(a_tlast),
        .s_axis_a_tready(a_tready),
        .m_axis_result_tdata(result_tdata),
        .m_axis_result_tvalid(result_tvalid),
        .m_axis_result_tready(1'b1),
        .m_axis_result_tlast(result_tlast)
    );

    initial
      begin
        a_tvalid = 1'b0;
        a_tlast = 1'b1;
        a_tdata = 32'h0A50EFBE;
        #20
        a_tdata = 32'h00000000;
        #20
        @(negedge clk)
        a_tdata = 32'h3F810000;  // 1.00781
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h3F816239;  // 1.01081
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h3F828F5C;  // 1.02
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h3F800347;  // 1.0001
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h38D1B717;  // 0.0001
        a_tlast = 1'b1;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h42D00000;  // 104
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h42560000;  // 53.5
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h424C0000;  // 51
        a_tlast = 1'b1;
        a_tvalid = 1'b1;

        @(negedge clk)
        a_tdata = 32'h00000001;  // 32'h00000001
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00000002;  // 32'h00000003
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00000004;  // 32'h00000007
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00000008;  // 32'h0000000F
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00000010;  // 32'h0000001F
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00000020;  // 32'h0000003F
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00000040;  // 32'h0000007F
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00000080;  // 32'h000000FF
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00000100;  // 32'h000001FF
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00000200;  // 32'h000003FF
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00000400;  // 32'h000007FF
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00000800;  // 32'h00000FFF
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00001000;  // 32'h00001FFF
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00002000;  // 32'h00003FFF
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00004000;  // 32'h00007FFF
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00008000;  // 32'h0000FFFF
        a_tlast = 1'b0;
        a_tvalid = 1'b1;
        @(negedge clk)
        a_tdata = 32'h00010000;  // 32'h0001FFFF
        a_tlast = 1'b0; 
        a_tvalid = 1'b1;
        @(negedge clk)  
        a_tdata = 32'h00020000;  // 32'h0003FFFF
        a_tlast = 1'b0; 
        a_tvalid = 1'b1;
        @(negedge clk)  
        a_tdata = 32'h00040000;  // 32'h0007FFFF
        a_tlast = 1'b0; 
        a_tvalid = 1'b1;
        @(negedge clk)  
        a_tdata = 32'h00080000;  // 32'h000FFFFF
        a_tlast = 1'b0; 
        a_tvalid = 1'b1;
        @(negedge clk)  
        a_tdata = 32'h00100000;  // 32'h001FFFFF
        a_tlast = 1'b0; 
        a_tvalid = 1'b1;
        @(negedge clk)  
        a_tdata = 32'h00200000;  // 32'h003FFFFF
        a_tlast = 1'b0; 
        a_tvalid = 1'b1;
        @(negedge clk)  
        a_tdata = 32'h00400000;  // 32'h007FFFFF
        a_tlast = 1'b0;  
        a_tvalid = 1'b1; 
        @(negedge clk)   
        a_tdata = 32'h00800000;  // 32'h00FFFFFF
        a_tlast = 1'b0; 
        a_tvalid = 1'b1;
        @(negedge clk)  
        a_tdata = 32'h01000000;  // 32'h01FFFFFF
        a_tlast = 1'b0;  
        a_tvalid = 1'b1; 
        @(negedge clk)   
        a_tdata = 32'h02000000;  // 32'h03FFFFFF
        a_tlast = 1'b0; 
        a_tvalid = 1'b1;
        @(negedge clk)  
        a_tdata = 32'h04000000;  // 32'h07FFFFFF
        a_tlast = 1'b0; 
        a_tvalid = 1'b1;
        @(negedge clk)  
        a_tdata = 32'h08000000;  // 32'h0FFFFFFF
        a_tlast = 1'b0; 
        a_tvalid = 1'b1;
        @(negedge clk)  
        a_tdata = 32'h10000000;  // 32'h1FFFFFFF
        a_tlast = 1'b0; 
        a_tvalid = 1'b1;
        @(negedge clk)  
        a_tdata = 32'h20000000;  // 32'h3FFFFFFF
        a_tlast = 1'b0; 
        a_tvalid = 1'b1;
        @(negedge clk)  
        a_tdata = 32'h40000000;  // 32'h7FFFFFFF
        a_tlast = 1'b1;  
        a_tvalid = 1'b1; 
        @(negedge clk)   
        a_tdata = 32'h80000000;  // 32'hFFFFFFFF
        a_tlast = 1'b0;
        a_tvalid = 1'b0;
        #400
        $finish;
      end


endmodule
