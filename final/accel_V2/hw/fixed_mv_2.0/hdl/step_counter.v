`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2018 11:15:11 AM
// Design Name: 
// Module Name: step_counter
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


module step_counter #
(
    parameter integer COUNTER_WIDTH = 11,
    parameter integer STEP = 6
)
(
    input wire clk,
    input wire rstn,
    input wire cnt,
    input wire [COUNTER_WIDTH-1:0] max,
    output wire ov
    );

    reg  [COUNTER_WIDTH-1:0] counter;
    wire [COUNTER_WIDTH-1:0] a;
    wire [COUNTER_WIDTH-1:0] b;
    wire [COUNTER_WIDTH-1:0] next;

    assign a = (ov) ? {COUNTER_WIDTH{1'b0}} : counter[COUNTER_WIDTH-1:0];
    assign b = (cnt) ? STEP : {COUNTER_WIDTH{1'b0}};
    assign next = a + b;
    always @ (posedge clk or negedge rstn)
    begin
        if(1'b0 == rstn)
        begin
            counter <= {COUNTER_WIDTH{1'b0}};
        end
        else
        begin
            counter <= next;
        end
    end
    assign ov = counter >= max;

endmodule
