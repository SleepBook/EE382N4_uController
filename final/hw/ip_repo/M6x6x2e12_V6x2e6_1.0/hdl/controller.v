`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2018 12:50:55 PM
// Design Name: 
// Module Name: Controller
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


module Controller #
(
    parameter integer DELAY_MUL	= 9,
    parameter integer DELAY_ADD = 12,
    parameter integer DELAY_ACC = 38
)
(
    input  wire clk,
    input  wire rstn,
    input  wire running,
    input  wire [8:0] width,
    output wire mbram_clk,  // matrix bram clock
    output wire mbram_en,   // matrix bram enable
    output wire [0 : 0] mbram_we,   // matrix bram write enable
    output wire [11 : 0] mbram_addr, // matrix bram address
    output wire vbram_clk,  // vector bram clock
    output wire vbram_en,   // vector bram enable
    output wire [0 : 0] vbram_we,   // vector bram write enable
    output wire [9 : 0] vbram_addr, // vector bram address
    output wire zero_in,  // feed zeros into buffer
    output wire last,  // last in row
    output wire rows_done,  // rows accumulation done, to latch result to write back
    output wire finish  // finish MV
);
	localparam integer DELAY_TOTAL = 1 + DELAY_MUL + DELAY_ADD*3 + DELAY_ACC;

    reg [8:0] acc_cnt;
    reg [8:0] rows_cnt;
    reg [DELAY_TOTAL-1:0] dly;
    reg [2:0] state;  // 000: moveon, 001: rowdone, 100: zeroin, 110: zeroin&writeback

    // Condition Signals from Comparers
    assign exceed = acc_cnt >= width;
    assign last = exceed | ~(|acc_cnt);  // keep cleaning accumulator if acc_cnt == 0
    assign finish = rows_cnt >= width;
    // Pipeline Delay Bar
    always @ (posedge clk)
    begin
        if(1'b0 == rstn)
        begin
            dly <= {DELAY_TOTAL{1'b0}};
        end
        else
        begin
            dly <= {~state[2]&running, dly[DELAY_TOTAL-1:DELAY_ACC+1], exceed&running, dly[DELAY_ACC-1:1]};
        end
    end
    // FSM
    assign zero_in = state[2];
    assign rows_done = state[0];
    always @ (posedge clk)
    begin
        if(1'b0 == rstn)
        begin
            state <= 3'b100;
        end
        else
        begin
            case(state)
                3'b100:
                    state <= {~running, 1'b0, dly[1]};
                3'b000:
                    state <= {~running, 1'b0, dly[1]};
                3'b001:
                    state <= 3'b110;
                3'b101:
                    state <= 3'b110;
                3'b110:
                    state <= {finish | ~running, 2'b00};
                default:
                    state <= 3'b100;
            endcase
        end
    end
    //DELAY_TOTAL: 8   DELAY_ACC:3   width: 13
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //slv0[0]:   | 1 ========================================================>
    //state: 100 | 100 | 000 | 000 | 000 | 000 | 000 | 000 | 000 | 000 | 000 |
    //dly:   00  | 00  | 00  | 80  | c0  | e0  | f0  | f8  | f8  | f8  | fc  |
    //acc_cnt:   |  0  |  0  |  0  |  0  |  0  |  0  |  6  | 12  | 18  |  6  |
    //                       1     2     3     4     5     6     7     8     9
    //buf:    |     |     |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8
    //                   rd0   rd1   rd2   rd3   rd4   rd5   rd6   rd7   rd8
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //slv0[0]:   > 1 ==============================> | 0 ====================>
    //state: 000 | 000 | 001 | 110 | 000 | 001 | 110 | 000 | 001 | 110 | 100 |
    //dly:   fc  | fa  | f9  | 7c  | ba  | d9  | ec  | 7a  | b9  | d8  | a8  |
    //acc_cnt:   | 12  | 18  |  6  | 12  | 18  |  0  |  0  |  0  |  0  |  0  |
    //           9
    //buf:    |  8  |  9  | 10  | 11  | 12  | 13  | 14  | 15  | 16  | 17  |
    //       rd8   rd9   rd10        rd11  rd12        rd13  rd14
    //                      wr0               wr1               wr14

    // accumulation counter
    always @ (posedge clk)
    begin
        if(1'b0 == rstn)
        begin
            acc_cnt <= 0;
        end
        else
        begin
            casex({running, exceed, finish, dly[DELAY_ACC+1]})
                4'b10x0: acc_cnt <= acc_cnt;
                4'b10x1: acc_cnt <= acc_cnt + 6;
                4'b1101: acc_cnt <= 6;
                4'b1100: acc_cnt <= 0;
                4'b1110: acc_cnt <= 0;
                4'b1111: acc_cnt <= 0;
                4'b0xxx: acc_cnt <= 0;
                default: acc_cnt <= 0;
            endcase
        end
    end
    // rows counter
    always @ (posedge clk)
    begin
        if(1'b0 == rstn)
        begin
            rows_cnt <= 0;
        end
        else
        begin
            casex({running, exceed, finish})
                3'b10x : rows_cnt <= rows_cnt;
                3'b110 : rows_cnt <= rows_cnt + 6;
                3'b111 : rows_cnt <= 0;
                3'b0xx : rows_cnt <= 0;
                default: rows_cnt <= 0;
            endcase
        end
    end

    //DELAY_TOTAL: 8   DELAY_ACC:3   width: 13
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //slv0[0]:   | 1 ========================================================>
    //state: 100 | 100 | 000 | 000 | 000 | 000 | 000 | 000 | 000 | 000 | 000 |
    //en:        | 1 ========================================================>
    //addr:     00  | 00  | 01  | 02  | 03  | 04  | 05  | 06  | 07  | 08  | 09
    //dout:   xx  | xx  | 00  | 01  | 02  | 03  | 04  | 05  | 06  | 07  | 08  |
    //we:     |  0  |  0  |  0  |  0  |  0  |  0  |  0  |  0  |  0  |  0  |  0
    //                   rd0   rd1   rd2   rd3   rd4   rd5   rd6   rd7   rd8
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //slv0[0]:   > 1 ==============================> | 0 ====================>
    //state: 000 | 000 | 001 | 110 | 000 | 001 | 110 | 000 | 001 | 110 | 100 |
    //en:        > 1 ================================================> | 0   |
    //addr:     09  | 10  | F0  | 11  | 12  | F1  | 13  | 14  | F2  | 16  | 00  |
    //dout:   08  | 09  | 00  | 01  | 02  | 03  | 04  | 05  | 06  | 07  | 08  |
    //we:     |  0  |  0  |  1  |  0  |  0  |  1  |  0  |  0  |  1  |  0  |  0
    //       rd8   rd9   rd10        rd11  rd12        rd13  rd14
    //                      wr0               wr1               wr2

    // BRAM Interface
    assign mbram_clk = clk;
    assign vbram_clk = clk;
    assign mbram_en = running;
    assign vbram_en = running | (|dly);  // any 1 left in dly need writeback
    // Write Enable
    reg we;
    assign vbram_we = we;
    always @ (negedge clk)  // half cycle later
    begin
        we <= state[0];  // always write after row_done
    end
    // Address
    reg [11:0] mraddr;  // matrix bram read only
    reg [9:0] vraddr, vwaddr;
    reg [8:0] rd_cnt;
    wire rdv_last;
    assign mbram_addr = mraddr[11:0];
    assign vbram_addr = ({10{we}} & vwaddr[9:0]) | ({10{~we}} & vraddr[9:0]);
    always @ (negedge clk)
    begin
        if(1'b0 == rstn)
        begin
            mraddr <= 12'd0;
        end
        else
        begin
            casex(state)
                3'b00x:
                    mraddr <= mraddr + 1;
                3'b1xx:
                    if(running)
                    begin
                        mraddr <= mraddr;
                    end
                    else
                    begin
                        mraddr <= 12'd0;
                    end
                default:
                    mraddr <= 12'b0;
            endcase
        end
    end
    always @ (negedge clk)
    begin
        if(1'b0 == rstn)
        begin
            vraddr <= 10'd0;
        end
        else
        begin
            casex({state, rdv_last})
                4'b0000:
                    vraddr <= vraddr + 1;
                4'b0001:
                    vraddr <= 10'd0;
                4'b1x0x:
                    if(running)
                    begin
                        vraddr <= vraddr;
                    end
                    else
                    begin
                        vraddr <= 10'd0;
                    end
                4'bxx1x:
                    vraddr <= 10'd0;
                default:
                    vraddr <= 10'd0;
            endcase
        end
    end
    always @ (negedge clk)
    begin
        if(1'b0 == rstn)
        begin
            vwaddr <= 10'h200;
        end
        else
        begin
            casex({vbram_en, vbram_we})
                2'b11:
                    vwaddr <= vwaddr + 1;
                2'b0x:
                    vwaddr <= 10'h200;
                2'b10:
                    vwaddr <= vwaddr;
                default:
                    vwaddr <= 10'h200;
            endcase
        end
    end
    // read counter
    assign rdv_last = rd_cnt >= width;
    always @ (posedge clk)
    begin
        if(1'b0 == rstn)
        begin
            rd_cnt <= 6;
        end
        else
        begin
            casex({running, state[2], rdv_last})
                3'bxx1 : rd_cnt <= 6;
                3'b110 : rd_cnt <= rd_cnt;
                3'b100 : rd_cnt <= rd_cnt + 6;
                3'b0x0 : rd_cnt <= 6;
                default: rd_cnt <= 6;
            endcase
        end
    end

endmodule
