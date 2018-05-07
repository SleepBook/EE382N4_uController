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
    parameter integer IDX_WIDTH_FOR_NODES = 6,
    parameter integer NUM_NODES = 2 ** IDX_WIDTH_FOR_NODES,
    parameter integer DELAY_BUF = 1,
    parameter integer DELAY_MAC = 1,
    parameter integer DELAY_CIN = 1,
    parameter integer DELAY_SEL = 1,
    parameter integer DELAY_BRAM = 1,
    parameter integer MBRAM_ADDR_WIDTH = 12,
    parameter integer VBRAM_ADDR_WIDTH = 10,
    parameter integer WIDTH_WIDTH = 9,  // bit width of the input width
    parameter integer ITERATION_WIDTH = 16  // bit width of the input iteration
)
(
    input  wire clk,
    input  wire rstn,
    input  wire running,
    input  wire [WIDTH_WIDTH-1:0] width,  // 2*NUM_NODES+1 ~
    input  wire [ITERATION_WIDTH-1:0] iteration,  // 1~65535
    output wire mbram_clk,  // matrix bram clock
    output wire mbram_en,   // matrix bram enable
    output wire [MBRAM_ADDR_WIDTH-1 : 0] mbram_addr, // matrix bram address
    output wire vbram0_clk,  // vector bram clock
    output wire vbram0_en,   // vector bram enable
    output wire [0 : 0] vbram0_we,   // vector bram write enable
    output wire [VBRAM_ADDR_WIDTH-1 : 0] vbram0_addr, // vector bram address
    output wire vbram1_clk,  // vector bram clock
    output wire vbram1_en,   // vector bram enable
    output wire [0 : 0] vbram1_we,   // vector bram write enable
    output wire [VBRAM_ADDR_WIDTH-1 : 0] vbram1_addr, // vector bram address
    output wire [NUM_NODES-1:0] sclrs,  // clear mac in a node independently
    output wire [1:0] asel,  // select ain for the first node
    output wire [NUM_NODES-1:0] csels,  // select c for a node independently
    output wire [IDX_WIDTH_FOR_NODES-1:0] ressel,  // select a result of one node to bram
    output wire [1:0] dinsel,  // select din to brams
    output wire finish
);
	localparam integer DELAY_NODE = DELAY_BUF + DELAY_MAC + DELAY_SEL;
	localparam integer DELAY_TOTAL = DELAY_BRAM + NUM_NODES + DELAY_NODE - 1;

    wire valid;  // signal for whether this cycle should feed in data or not
    wire ov;  // pulses every time 6 rows reach the end
    wire over;  // pulses every iteration ends
    wire overfed;  // pulses upon data needed in all iterations are fed in
    reg [DELAY_TOTAL-1:0] valids;  // mark the validness of data in each stage
    reg [DELAY_TOTAL-1:0] ovs;  // mark the last data of rows in each stage
    reg [DELAY_TOTAL-1:0] overs;  // mark the last submatrix of an iteration in each stage
    reg [DELAY_TOTAL-1:0] overfeds;  // delay to output the finish signal
    reg stopfeeding;  // self-locked overfed, indicating having fed in enough data

    // alias
    wire [DELAY_NODE-1:0] valids_n [NUM_NODES-1:0];
    wire [DELAY_NODE-1:0] ovs_n [NUM_NODES-1:0];
    wire [DELAY_NODE-1:0] overs_n [NUM_NODES-1:0];
    wire [DELAY_NODE-1:0] overfeds_n [NUM_NODES-1:0];
    genvar node_idx;
    for(node_idx = 0; node_idx < NUM_NODES; node_idx = node_idx + 1)
    begin
        assign valids_n[node_idx] =
            valids[DELAY_TOTAL-DELAY_BRAM-1-node_idx -: DELAY_NODE];
        assign ovs_n[node_idx] =
            ovs[DELAY_TOTAL-DELAY_BRAM-1-node_idx -: DELAY_NODE];
        assign overs_n[node_idx] =
            overs[DELAY_TOTAL-DELAY_BRAM-1-node_idx -: DELAY_NODE];
        assign overfeds_n[node_idx] =
            overfeds[DELAY_TOTAL-DELAY_BRAM-1-node_idx -: DELAY_NODE];
    end

    // FSM
    wire overfed_flush;
    assign valid = running & ~stopfeeding & ~overfed_flush;
    // Pipeline Delay Bars
    always @ (posedge clk)
    begin
        if(1'b0 == rstn)
        begin
            valids <= {DELAY_TOTAL{1'b0}};
            ovs <= {DELAY_TOTAL{1'b0}};
            overs <= {DELAY_TOTAL{1'b0}};
            overfeds <= {DELAY_TOTAL{1'b0}};
        end
        else
        begin
            valids <= {valid, valids[DELAY_TOTAL-1:1]};
            ovs <= {1'b0, ov&running, ovs[DELAY_TOTAL-2:1]};
            overs <= {1'b0, over&running, overs[DELAY_TOTAL-2:1]};
            overfeds <= {1'b0, overfed&running, overfeds[DELAY_TOTAL-2:1]};
        end
    end
    // Condition Signals from Comparers
    reg ov_flush_dly;  // one cycle later to reset itself
    reg over_flush_dly;  // one cycle later to reset itself
    reg overfed_flush_dly;  // one cycle later to reset itself
    wire over_long;  // longen over
    wire overfed_long;  // longen overfed
    step_counter # (
        .COUNTER_WIDTH(WIDTH_WIDTH),
        .STEP(1)
    ) valid_counter (
        .clk(clk),
        .rstn(rstn&~overfed_flush_dly),
        .cnt(valid),
        .max(width),
        .ov(ov)
    );
    always @ (posedge clk)
    begin
        ov_flush_dly <= ov;
    end
    step_counter # (
        .COUNTER_WIDTH(WIDTH_WIDTH),
        .STEP(NUM_NODES)
    ) ov_counter (
        .clk(ov),
        .rstn(rstn&~over_flush_dly),
        .cnt(running),
        .max(width),
        .ov(over_long)
    );
    assign over = ov & over_long;
    always @ (posedge clk)
    begin
        over_flush_dly <= over;
    end
    step_counter # (
        .COUNTER_WIDTH(ITERATION_WIDTH),
        .STEP(1)
    ) iter_counter (
        .clk(over),
        .rstn(rstn&~overfed_flush_dly),
        .cnt(running),
        .max(iteration),
        .ov(overfed_long)
    );
    assign overfed = ov & overfed_long;
    assign overfed_flush = overfed;
    always @ (posedge clk)
    begin
        overfed_flush_dly <= overfed & running;
    end
    // self-locked tofinish -- stop_feeding
    always @ (posedge clk)
    begin
        //if(1'b0 == rstn)
        //begin
        //    stopfeeding <= 1'b0;
        //end
        //else
        //begin
        //    if(~running)
        //    begin
        //        stopfeeding <= 1'b0;
        //    end
        //    else if(overfed)
        //    begin
        //        stopfeeding <= 1'b1;
        //    end
        //    else
        //        stopfeeding <= stopfeeding;
        //end
        casex({rstn&running, overfed})
            2'b0x  : stopfeeding <= 1'b0;  // not running equals to reset
            2'b11  : stopfeeding <= 1'b1;  // time to stop
            default: stopfeeding <= stopfeeding;
        endcase
    end

    //DELAY_TOTAL: 1+5+8-1  width: 17   iteration: 1 or 2
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //running:   | 1 ========================================================>
    //validcnt:  |  00 |  01 |  02 |  03 |  04 |  05 |  06 |  07 |  08 |  09 |
    //valids:    |0000 |1000 |1800 |1C00 |1E00 |1F00 |1F80 |1FC0 |1FE0 |1FF0 |
    //valids_n0: | 00  | 00  | 10  | 18  | 1C  | 1E  | 1F ===================>
    //maddr:     0  |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9
    //                rd0   rd1   rd2   rd3   rd4   rd5   rd6   rd7   rd8   rd9
    //mdout:      |     |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |
    //bufa/b_n0:  |     |     |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8
    //bufa/b_n7:                                                        |  0  |  1
    //valids_n7: |  00 ==============================================> |  10 |  18
    //sclrs:     |  FF |  FF |  FE |  FC |  F8 |  F0 |  E0 |  C0 |  80 |  00 ==>
    //csels:     |  00 |  00 |  00 |  00 |  00 |  01 |  03 |  07 |  0F |  1F |
    //
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //running:   > 1 ==========================================================>
    //validcnt:  |  0A |  0B |  0C |  0D |  0E |  0F |  10 |  11 |  01 |  02 |
    //ovcnt:       00 ===================================> |  08 ==============>
    //ovs:       |0000 |0000 |0000 |0000 |0000 |0000 |0000 |0000 |0800 |0400 |
    //ovs_n0:    | 00 =========================================> | 10  | 08  |
    //maddr:     9  |  A  |  B  |  C  |  D  |  E  |  F  | 10  |  11 |  12  | 13
    //          rd9   rdA   rdB   rdC   rdD   rdE   rdF  rd10   rd11  rd12  rd13
    //mdout:      |  9  |  A  |  B  |  C  |  D  |  E  |  F  | 10  | 11  |  12 | 13
    //bufa/b_n0: |  8  |  9  |  A  |  B  |  C  |  D  |  E  |  F  |  10 |0/11 |1/12
    //bufa/b_n7: |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |   9 |   A |  B
    //sclrs:    ==> 00 ========================================================>
    //csels:     |  3F |  7F |  FF ============================================>
    //
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //validcnt:  |  03 |  04 |  05 |  06 |  07 |  08 |  09 |  0A |  0B |  0C |
    //ovs:       |0200 |0100 |0080 |0040 |0020 |0010 |0008 |0004 |0002 |0001 |
    //ovs_n0:    | 04  | 02  | 01  | 00 ======================================>
    //ovs_n7:    | 00 =======================> |  10 |  08 |  04 |  02 |  01 |
    //maddr:     13 |  14 | 15  | 16  | 17  | 18  | 19  | 1A  | 1B  | 1C  | 1D
    //          rd13  rd14  rd15  rd16  rd17  rd18  rd19  rd1A  rd1B  rd1C  rd1D
    //bufa/b_n0:  1/12 |2/13 |3/14 |4/15 |5/16 |6/17 |7/18 |8/19 |9/1A |A/1B |B/1C
    //bufa/b_n7:    B  |  C  |  D  |  E  |  F  | 10  |0/11 |1/12 |2/13 |3/14 |4/15
    //csels:    ==> FF | FE  | FD  | FB  | F7  | EF  |  DF |  BF | 7F  | FF ===>
    //ressel:    |     |     |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
    //resbuf:    |     |     |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
    //resselect     |     |     |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
    //                            wr0   wr1   wr2   wr3   wr4   wr5   wr6   wr7
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //validcnt:  |  0D |  0E |  0F |  10 |  11 |  01 |  02 |  03 |  04 |  05 |
    //ovcnt:    ==>08 =================> |  10 ================================>
    //ovs:       |0000 |0000 |0000 |0000 |0000 |0800 |0400 |0200 |0100 |0080 |
    //ovs_n0:   ==>00 =======================> | 10  | 08  | 04  | 02  | 01  |
    //maddr:    1D  | 1E  | 1F  | 20  | 21  | 22  | 23  | 24  | 25  | 26  | 27
    //bufa/b_n0: |B/1C |C/1D |D/1E |E/1F |F/20 |10/21|0/22 |1/23 |2/24 |3/25 |
    //csels:     ======> FF ====================================>| FE  | FD  |
    //ressel:                                                          |  0  |
    //resselect: 7  |                                                     |  0
    //          wr7                                                         wr0
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //validcnt:  |  06 |  07 |  08 |  09 |  0A |  0B |  0C |  0D |  0E |  0F |
    //ovs:       |0040 |0020 |0010 |0008 |0004 |0002 |0001 |0000 |0000 |0000 |
    //ovs_n0:    | 00 =========================================================>
    //maddr:    27  | 28  | 29  | 2A  | 2B  | 2C  | 2D  | 2E  | 2F  | 30  | 31
    //bufa/b_n0: |4/26 |5/27 |6/28 |7/29 |8/2A |9/2B |A/2C |B/2D |C/2E |D/2F |E/30
    //csels:  FD | FB  | F7  | EF  | DF  | BF  |  7F |  FF ====================>
    //ressel:    |  1  |  2  |  3  |  4  |  5  |  6  |   7 |
    //resselect:    |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
    //
    //
    // DELAY_TOTAL: 1+5+8-1  width: 17   iteration: 1 
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //validcnt:  |  10 |  11 |  01 =============================================>
    //ovcnt:    ==>10=>|  18 ===================================================>
    //overcnt:  ==>0==>|  1  ===================================================>
    //ovs_n0:   ==>00 ======>| 10  | 08  | 04  | 02  | 01  | 00 ================>
    //overs_n0: ==>00 ======>| 10  | 08  | 04  | 02  | 01  | 00 ================>
    //overfeds_n0: ==>00 ===>| 10  | 08  | 04  | 02  | 01  | 00 ================>
    //overfeds:   0000 |0000 |0800 |0400 |0200 |0100 |0080 |0040 |0020 |0010 |
    //overfeds_n7: ==>00 =============================================>|  10 |
    //stopfeding:  0 =======>|  1 ========================================>
    //valids:   ==>1FFF ===> |0FFF |07FF |03FF |01FF |00FF |007F |003F |001F |
    //maddr:    31  | 32  =====================================================>
    //mdout:      | 31  | 32
    //bufa/b_n0: |E/30 |F/31 |10/32|
    //bufa/b_n7: |7/29 |8/2A |9/2B |A/2C |B/2D |C/2E |D/2F |E/30 |F/31 |10/32|
    //valids_n0: ==> 1F  =======>  | 0F  | 07  | 03  | 01  | 00 ===============>
    //sclrs:   ==> 00 ========================>| 01  | 03  |  07 | 0F  | 1F  |
    //csels:   ==> FF ========================>| FE  | FC  | F8  |  F0 | E0  |
    //ressel:                                        |  0  |  1  |  2  |  3  |
    //resselect                                         |  0  |  1  |  2  |  3
    //
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //running:  ==> 1 ==================>| 0 ===================================>
    //overfeds:  |0008 |0004 |0002 |0001 |0000 =================================>
    //overfeds_n7:  08 |  04 |  02 |  01 |  00 =================================>
    //finish:   ==> 0 ============>|   1 |   0 =================================>
    //valids_n7: |  0F |  07 |  03 |  01 |  00 =================================>
    //csels:     | C0  | 80  | 00
    //ressel:    |  4  |  5  |  6  |  7  |
    //resselect  3  |  4  |  5  |  6  |  7  |
    //          wr3   wr4   wr5   wr6   wr7
    //
    //
    //DELAY_TOTAL: 1+5+8-1  width: 17   iteration: 2 
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //validcnt:  |  10 |  11 |  01 |  02 |  03 |  04 |  05 |  06 |  07 |  08 |
    //ovcnt:    ==>10=>|  18 ===================================================>
    //overcnt:  ==>0============================================================>
    //ovs_n0:   ==>00 ======>| 10  | 08  | 04  | 02  | 01  | 00 ================>
    //overs_n0: ==>00 ======>| 10  | 08  | 04  | 02  | 01  | 00 ================>
    //overfeds_n0: ==>00 ==================================> 00 ================>
    //overfeds:   0000 |0000 |0000 |0000 |0000 |0000 |0000 |0000 |0000 |0000 |
    //overfeds_n7: ==>00 =======================================================>
    //stopfeding:  0 ===========================================================>
    //valids:   ==>1FFF ========================================================>
    //maddr:    31  | 32  |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8
    //mdout:      | 31  | 32  |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
    //bufa_n0:   |  E  |  F  |  10 |v0 0 |v0 1 |v0 2 |v0 3 |v0 4 |v0 5 |v0 6 |
    //bufb_n0:   |  30 |  31 |  32 |  0  |  1  |  2  |  3  |  4  |  5  |  6  |
    //bufa/b_n7: |7/29 |8/2A |9/2B |A/2C |B/2D |C/2E |D/2F |E/30 |F/31 |10/32|
    //valids_n0: ==> 1F  ======================================================>
    //sclrs:   ==> 00 =========================================================>
    //csels:   ==> FF ========================>| FE  | FD  | FB  |  F7 | EF  |
    //ressel:                                        |  0  |  1  |  2  |  3  |
    //resselect                                         |  0  |  1  |  2  |  3
    //asel:    ==> 1x =====> |  00 ============================================>
    //
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //running:  ==> 1 ==========================================================>
    //overfeds: ==> 0000 =======================================================>
    //overfeds_n7:  00 =========================================================>
    //finish:   ==> 0 ==========================================================>
    //valids_n7: |  1F =========================================================>
    //csels:     | DF  | BF  | 7F  |  FF =======================================>
    //ressel:    |  4  |  5  |  6  |  7  |
    //resselect  3  |  4  |  5  |  6  |  7  |
    //          wr3   wr4   wr5   wr6   wr7


    // finish
    assign finish = overfeds[0];


    //DELAY_TOTAL: 1+5+8-1  width: 17   iteration: 1 or 2
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //running:   | 1 ========================================================>
    //validcnt:  |  00 |  01 |  02 |  03 |  04 |  05 |  06 |  07 |  08 |  09 |
    //valids:    |0000 |1000 |1800 |1C00 |1E00 |1F00 |1F80 |1FC0 |1FE0 |1FF0 |
    //valids_n0: | 00  | 00  | 10  | 18  | 1C  | 1E  | 1F ===================>
    //                rd0   rd1   rd2   rd3   rd4   rd5   rd6   rd7   rd8   rd9
    //bufa/b_n0:  |     |     |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8
    //bufa/b_n7:                                                        |  0  |  1
    //valids_n7: |  00 ==============================================> |  10 |  18
    //sclrs:     |  FF |  FF |  FE |  FC |  F8 |  F0 |  E0 |  C0 |  80 |  00 ==>
    //csels:     |  00 |  00 |  00 |  00 |  00 |  01 |  03 |  07 |  0F |  1F |
    //
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //validcnt:  |  0A |  0B |  0C |  0D |  0E |  0F |  10 |  11 |  01 |  02 |
    //          rd9   rdA   rdB   rdC   rdD   rdE   rdF  rd10   rd11  rd12  rd13
    //bufa/b_n0: |  8  |  9  |  A  |  B  |  C  |  D  |  E  |  F  |  10 |0/11 |1/12
    //bufa/b_n7: |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |   9 |   A |  B
    //sclrs:    ==> 00 ========================================================>
    //csels:     |  3F |  7F |  FF ============================================>

    // sclrs
    for(node_idx = 0; node_idx < NUM_NODES; node_idx = node_idx + 1)
    begin
        assign sclrs[node_idx] =
            ~(|valids_n[node_idx][DELAY_NODE-DELAY_BUF -: DELAY_MAC]); // data TO pass mac
    end

    // csels
    for(node_idx = 0; node_idx < NUM_NODES; node_idx = node_idx + 1)
    begin
        assign csels[node_idx] =
            valids_n[node_idx][DELAY_SEL] & // valid is about to back to accumulator
            ~ovs_n[node_idx][DELAY_SEL];  // row passed node in stage 3 of mac
    end

    // ressel
    reg [IDX_WIDTH_FOR_NODES-1:0] ressel_reg;
    assign ressel = ressel_reg;
    for(node_idx = 0; node_idx < NUM_NODES; node_idx = node_idx + 1)
    begin
        always @ (posedge clk)
        begin
            if(ovs_n[node_idx][DELAY_SEL])  // next cycle would be in the buffer to select
            begin
                ressel_reg <= node_idx;
            end
        end
    end

    //DELAY_TOTAL: 1+5+8-1  width: 17   iteration: 2 
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //validcnt:  |  10 |  11 |  01 |  02 |  03 |  04 |  05 |  06 |  07 |  08 |
    //ovcnt:    ==>10=>|  18 ===================================================>
    //ovs_n0:   ==>00 ======>| 10  | 08  | 04  | 02  | 01  | 00 ================>
    //overs_n0: ==>00 ======>| 10  | 08  | 04  | 02  | 01  | 00 ================>
    //maddr:    31  | 32  |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8
    //mdout:      | 31  | 32  |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
    //bufa_n0:   |  E  |  F  |  10 |v0 0 |v0 1 |v0 2 |v0 3 |v0 4 |v0 5 |v0 6 |
    //bufb_n0:   |  30 |  31 |  32 |  0  |  1  |  2  |  3  |  4  |  5  |  6  |
    //bufa/b_n7: |7/29 |8/2A |9/2B |A/2C |B/2D |C/2E |D/2F |E/30 |F/31 |10/32|
    //sclrs:   ==> 00 =========================================================>
    //csels:   ==> FF ========================>| FE  | FD  | FB  |  F7 | EF  |
    //ressel:                                        |  0  |  1  |  2  |  3  |
    //resselect                                         |  0  |  1  |  2  |  3
    //asel:    ==> 1x =====> |  00 ============================================>

    // asel
    reg [1:0] asel_reg;
    reg [1:0] asel_dly;  // half cycle later
    assign asel = asel_dly;
    always @ (negedge clk)
    begin
        casex({rstn&running, over})
            2'b0x  : asel_reg <= 2'b11;  // not running equals to reset
            2'b11  : asel_reg <= {1'b0, ~asel_reg[0]};  // time to flip
            default: asel_reg <= asel_reg;
        endcase
    end
    always @ (posedge clk)
    begin
        asel_dly <= asel_reg;
    end

    // dinsel
    reg [1:0] dinsel_reg;
    assign dinsel = dinsel_reg;
    always @ (posedge clk)
    begin
        dinsel_reg <= {asel_reg[0], ~asel_reg[0]};
        // when a vbram is selected to output
        // if there is any din, it must come from another vbram
    end

    //DELAY_TOTAL: 1+5+8-1  width: 17   iteration: 1 or 2
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //running:   | 1 ========================================================>
    //validcnt:  |  00 |  01 |  02 |  03 |  04 |  05 |  06 |  07 |  08 |  09 |
    //valids:    |0000 |1000 |1800 |1C00 |1E00 |1F00 |1F80 |1FC0 |1FE0 |1FF0 |
    //valids_n0: | 00  | 00  | 10  | 18  | 1C  | 1E  | 1F ===================>
    //maddr:     0  |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9
    //                rd0   rd1   rd2   rd3   rd4   rd5   rd6   rd7   rd8   rd9
    //mdout:      |     |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |
    //bufa/b_n0:  |     |     |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8
    //bufa/b_n7:                                                        |  0  |  1
    //valids_n7: |  00 ==============================================> |  10 |  18
    //sclrs:     |  FF |  FF |  FE |  FC |  F8 |  F0 |  E0 |  C0 |  80 |  00 ==>
    //csels:     |  00 |  00 |  00 |  00 |  00 |  01 |  03 |  07 |  0F |  1F |
    //
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //running:   > 1 ==========================================================>
    //validcnt:  |  0A |  0B |  0C |  0D |  0E |  0F |  10 |  11 |  01 |  02 |
    //ovcnt:       00 ===================================> |  08 ==============>
    //ovs:       |0000 |0000 |0000 |0000 |0000 |0000 |0000 |0000 |0800 |0400 |
    //ovs_n0:    | 00 =========================================> | 10  | 08  |
    //maddr:     9  |  A  |  B  |  C  |  D  |  E  |  F  | 10  |  11 |  12  | 13
    //          rd9   rdA   rdB   rdC   rdD   rdE   rdF  rd10   rd11  rd12  rd13
    //mdout:      |  9  |  A  |  B  |  C  |  D  |  E  |  F  | 10  | 11  |  12 | 13
    //bufa/b_n0: |  8  |  9  |  A  |  B  |  C  |  D  |  E  |  F  |  10 |0/11 |1/12
    //bufa/b_n7: |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |   9 |   A |  B
    //sclrs:    ==> 00 ========================================================>
    //csels:     |  3F |  7F |  FF ============================================>
    //
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //validcnt:  |  03 |  04 |  05 |  06 |  07 |  08 |  09 |  0A |  0B |  0C |
    //ovs:       |0200 |0100 |0080 |0040 |0020 |0010 |0008 |0004 |0002 |0001 |
    //ovs_n0:    | 04  | 02  | 01  | 00 ======================================>
    //ovs_n7:    | 00 =======================> |  10 |  08 |  04 |  02 |  01 |
    //maddr:     13 |  14 | 15  | 16  | 17  | 18  | 19  | 1A  | 1B  | 1C  | 1D
    //          rd13  rd14  rd15  rd16  rd17  rd18  rd19  rd1A  rd1B  rd1C  rd1D
    //bufa/b_n0:  1/12 |2/13 |3/14 |4/15 |5/16 |6/17 |7/18 |8/19 |9/1A |A/1B |B/1C
    //bufa/b_n7:    B  |  C  |  D  |  E  |  F  | 10  |0/11 |1/12 |2/13 |3/14 |4/15
    //csels:    ==> FF | FE  | FD  | FB  | F7  | EF  |  DF |  BF | 7F  | FF ===>
    //ressel:    |     |     |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
    //resbuf:    |     |     |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
    //resselect     |     |     |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
    //                            wr0   wr1   wr2   wr3   wr4   wr5   wr6   wr7
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //validcnt:  |  0D |  0E |  0F |  10 |  11 |  01 |  02 |  03 |  04 |  05 |
    //ovcnt:    ==>08 =================> |  10 ================================>
    //ovs:       |0000 |0000 |0000 |0000 |0000 |0800 |0400 |0200 |0100 |0080 |
    //ovs_n0:   ==>00 =======================> | 10  | 08  | 04  | 02  | 01  |
    //maddr:    1D  | 1E  | 1F  | 20  | 21  | 22  | 23  | 24  | 25  | 26  | 27
    //bufa/b_n0: |B/1C |C/1D |D/1E |E/1F |F/20 |10/21|0/22 |1/23 |2/24 |3/25 |
    //csels:     ======> FF ====================================>| FE  | FD  |
    //ressel:                                                          |  0  |
    //resselect: 7  |                                                     |  0
    //          wr7                                                         wr0
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //validcnt:  |  06 |  07 |  08 |  09 |  0A |  0B |  0C |  0D |  0E |  0F |
    //ovs:       |0040 |0020 |0010 |0008 |0004 |0002 |0001 |0000 |0000 |0000 |
    //ovs_n0:    | 00 =========================================================>
    //maddr:    27  | 28  | 29  | 2A  | 2B  | 2C  | 2D  | 2E  | 2F  | 30  | 31
    //bufa/b_n0: |4/26 |5/27 |6/28 |7/29 |8/2A |9/2B |A/2C |B/2D |C/2E |D/2F |E/30
    //csels:  FD | FB  | F7  | EF  | DF  | BF  |  7F |  FF ====================>
    //ressel:    |  1  |  2  |  3  |  4  |  5  |  6  |   7 |
    //resselect:    |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
    //
    //
    // DELAY_TOTAL: 1+5+8-1  width: 17   iteration: 1 
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //validcnt:  |  10 |  11 |  01 =============================================>
    //ovcnt:    ==>10=>|  18 ===================================================>
    //overcnt:  ==>0==>|  1  ===================================================>
    //ovs_n0:   ==>00 ======>| 10  | 08  | 04  | 02  | 01  | 00 ================>
    //overs_n0: ==>00 ======>| 10  | 08  | 04  | 02  | 01  | 00 ================>
    //overfeds_n0: ==>00 ===>| 10  | 08  | 04  | 02  | 01  | 00 ================>
    //overfeds:   0000 |0000 |0800 |0400 |0200 |0100 |0080 |0040 |0020 |0010 |
    //overfeds_n7: ==>00 =============================================>|  10 |
    //stopfeding:  0 =======>|  1 ========================================>
    //valids:   ==>1FFF ===> |0FFF |07FF |03FF |01FF |00FF |007F |003F |001F |
    //maddr:    31  | 32  =====================================================>
    //mdout:      | 31  | 32
    //bufa/b_n0: |E/30 |F/31 |10/32|
    //bufa/b_n7: |7/29 |8/2A |9/2B |A/2C |B/2D |C/2E |D/2F |E/30 |F/31 |10/32|
    //valids_n0: ==> 1F  =======>  | 0F  | 07  | 03  | 01  | 00 ===============>
    //sclrs:   ==> 00 ========================>| 01  | 03  |  07 | 0F  | 1F  |
    //csels:   ==> FF ========================>| FE  | FC  | F8  |  F0 | E0  |
    //ressel:                                        |  0  |  1  |  2  |  3  |
    //resselect                                         |  0  |  1  |  2  |  3
    //
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //running:  ==> 1 ==================>| 0 ===================================>
    //overfeds:  |0008 |0004 |0002 |0001 |0000 =================================>
    //overfeds_n7:  08 |  04 |  02 |  01 |  00 =================================>
    //finish:   ==> 0 ============>|   1 |   0 =================================>
    //valids_n7: |  0F |  07 |  03 |  01 |  00 =================================>
    //csels:     | C0  | 80  | 00
    //ressel:    |  4  |  5  |  6  |  7  |
    //resselect  3  |  4  |  5  |  6  |  7  |
    //          wr3   wr4   wr5   wr6   wr7
    //
    //
    //DELAY_TOTAL: 1+5+8-1  width: 17   iteration: 2 
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //validcnt:  |  10 |  11 |  01 |  02 |  03 |  04 |  05 |  06 |  07 |  08 |
    //ovcnt:    ==>10=>|  18 ===================================================>
    //overcnt:  ==>0============================================================>
    //ovs_n0:   ==>00 ======>| 10  | 08  | 04  | 02  | 01  | 00 ================>
    //overs_n0: ==>00 ======>| 10  | 08  | 04  | 02  | 01  | 00 ================>
    //overfeds_n0: ==>00 ==================================> 00 ================>
    //overfeds:   0000 |0000 |0000 |0000 |0000 |0000 |0000 |0000 |0000 |0000 |
    //overfeds_n7: ==>00 =======================================================>
    //stopfeding:  0 ===========================================================>
    //valids:   ==>1FFF ========================================================>
    //maddr:    31  | 32  |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8
    //mdout:      | 31  | 32  |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
    //bufa_n0:   |  E  |  F  |  10 |v0 0 |v0 1 |v0 2 |v0 3 |v0 4 |v0 5 |v0 6 |
    //bufb_n0:   |  30 |  31 |  32 |  0  |  1  |  2  |  3  |  4  |  5  |  6  |
    //bufa/b_n7: |7/29 |8/2A |9/2B |A/2C |B/2D |C/2E |D/2F |E/30 |F/31 |10/32|
    //valids_n0: ==> 1F  ======================================================>
    //sclrs:   ==> 00 =========================================================>
    //csels:   ==> FF ========================>| FE  | FD  | FB  |  F7 | EF  |
    //ressel:                                        |  0  |  1  |  2  |  3  |
    //resselect                                         |  0  |  1  |  2  |  3
    //asel:    ==> 1x =====> |  00 ============================================>
    //
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //running:  ==> 1 ==========================================================>
    //overfeds: ==> 0000 =======================================================>
    //overfeds_n7:  00 =========================================================>
    //finish:   ==> 0 ==========================================================>
    //valids_n7: |  1F =========================================================>
    //csels:     | DF  | BF  | 7F  |  FF =======================================>
    //ressel:    |  4  |  5  |  6  |  7  |
    //resselect  3  |  4  |  5  |  6  |  7  |
    //          wr3   wr4   wr5   wr6   wr7

    // BRAM Interface
    assign mbram_clk = clk;
    assign vbram0_clk = clk;
    assign vbram1_clk = clk;
    assign mbram_en = running;
    assign vbram0_en = running;
    assign vbram1_en = running;
    // signals used to move cutoffed data from one vbram to another
    // declare those signals early so that we logic can use
    reg [VBRAM_ADDR_WIDTH-1:0] cutoff_addr;  // last address stored data before cut off
    wire cutoff_lck;  // in one run, lock cut off address once
    assign cutoff_lck = ~ asel_reg[1];
    wire readingcutoff;  // indication that is trying to read cutoffed data
    wire toreadcutoff;  // one cycle before readingcutoff so that vbram can prepare data
    reg iscomplete;  // indication that result in one vbram is complete
    //// Write Enable
    reg  wfromnodes;  // nodes want to write data to vbram
    wire wfromvbram;  // another vbram wants to write to vbram
    wire rwfromvbram;  // preprare for wfromvbram
    assign vbram0_we = asel_reg[0] ? wfromnodes : wfromvbram;
    assign vbram1_we = asel_reg[0] ? wfromvbram : wfromnodes;
    always @ (negedge clk)
    begin
        //for(node_idx = 0; node_idx < NUM_NODES; node_idx = node_idx + 1)
        //begin
        //    wen |= ovs_n[node_idx][0];
        //end
        wfromnodes <= |ovs[0 +: NUM_NODES];
    end
    //always @ (negedge clk)
    //begin
    //    wfromvbram <= 1'b0;//readingcutoff & ~iscomplete;
    //end
    assign wfromvbram = readingcutoff & ~iscomplete;
    assign rwfromvbram = toreadcutoff & ~iscomplete;
    //// Address
    reg [MBRAM_ADDR_WIDTH-1:0] mraddr;  // mbram read address only
    assign mbram_addr = mraddr;
    always @ (negedge clk)
    begin
        casex({rstn, running, over, valids[DELAY_TOTAL-1]})
            4'b0xxx : mraddr <= {MBRAM_ADDR_WIDTH{1'b0}};
            4'b10xx : mraddr <= {MBRAM_ADDR_WIDTH{1'b0}};
            4'b111x : mraddr <= {MBRAM_ADDR_WIDTH{1'b0}};
            4'b1100 : mraddr <= {MBRAM_ADDR_WIDTH{1'b0}};
            4'b1101 : mraddr <= mraddr + 1;
        endcase
    end
    reg [VBRAM_ADDR_WIDTH-1:0] vwaddr;  // vbram read address
    reg [VBRAM_ADDR_WIDTH-1:0] vraddr;  // vbram write address
    reg [VBRAM_ADDR_WIDTH-1:0] vrwaddr;  // vbram read address for write to another
    assign vbram0_addr = ~asel_reg[0] ? vraddr : (rwfromvbram ? vrwaddr : vwaddr);
    assign vbram1_addr =  asel_reg[0] ? vraddr : (rwfromvbram ? vrwaddr : vwaddr);
    reg overs0_dly;
    always @ (posedge clk)
    begin
        overs0_dly <= overs[0];  // indicate the actual writing cycle of the last
    end
    always @ (negedge clk)
    begin
        casex({rstn, running, overs0_dly, wfromnodes})
            4'b0xxx : vwaddr <= {VBRAM_ADDR_WIDTH{1'b0}};
            4'b10xx : vwaddr <= {VBRAM_ADDR_WIDTH{1'b0}};
            4'b111x : vwaddr <= {VBRAM_ADDR_WIDTH{1'b0}};
            4'b1101 : vwaddr <= vwaddr + 1;
            4'b1100 : vwaddr <= vwaddr;
        endcase
    end
    always @ (negedge clk)
    begin
        casex({rstn, running, ov, valids[DELAY_TOTAL-1]})
            4'b0xxx : vraddr <= {VBRAM_ADDR_WIDTH{1'b0}};
            4'b10xx : vraddr <= {VBRAM_ADDR_WIDTH{1'b0}};
            4'b111x : vraddr <= {VBRAM_ADDR_WIDTH{1'b0}};
            4'b1100 : vraddr <= {VBRAM_ADDR_WIDTH{1'b0}};
            4'b1101 : vraddr <= vraddr + 1;
        endcase
    end
    always @ (negedge clk)
    begin
        if(~toreadcutoff)
        begin
            vrwaddr <= cutoff_addr + 1;
        end
        else
        begin
            vrwaddr <= vrwaddr + 1;
        end
    end
    // cutoff_addr
    always @ (posedge clk)
    begin
        if(~cutoff_lck & wfromnodes)  // last write before lock
        begin
            cutoff_addr <= vwaddr;
        end
    end
    // iscomplete
    reg readingcutoff_dly;  // one cycle later
    wire movedone; // indication that cutoffed data is moved to correct vbram
    assign movedone = readingcutoff_dly & ~readingcutoff;
    always @ (posedge clk)
    begin
        readingcutoff_dly <= readingcutoff;
    end
    always @ (posedge clk)
    begin
        casex({rstn, running, over, movedone})
            4'b0xxx : iscomplete <= 1'b1;
            4'b10xx : iscomplete <= 1'b1;
            4'b111x : iscomplete <= 1'b0;  // every over switch vbram with result uncomplete
            4'b1101 : iscomplete <= 1'b1;
            4'b1100 : iscomplete <= iscomplete;
        endcase
    end
    assign readingcutoff = (vraddr > cutoff_addr) & cutoff_lck;
    assign toreadcutoff = (vraddr >= cutoff_addr) & cutoff_lck;

endmodule
