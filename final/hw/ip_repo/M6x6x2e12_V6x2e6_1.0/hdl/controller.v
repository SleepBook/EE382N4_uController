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
    parameter integer DELAY_BUF = 1,  // actually decided by three internal step counters
    parameter integer DELAY_MUL	= 7,
    parameter integer DELAY_ADD = 12,
    parameter integer DELAY_ACC = 38
)
(
    input  wire clk,
    input  wire rstn,
    input  wire running,
    input  wire [8:0] width,  // 6~180h
    input  wire [15:0] iteration,  // 1~65535
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
    output wire rows_over,  // rows accumulation done, to latch result to write back
    output wire finish  // finish MV
);
	localparam integer DELAY_TOTAL = DELAY_BUF + DELAY_MUL + DELAY_ADD*3 + DELAY_ACC;

    wire valid;  // signal for whether this cycle should feed in data or not
    wire ov;  // pulses every time 6 rows reach the end
    wire over;  // pulses every iteration ends
    wire overfed;  // pulses upon data needed in all iterations are fed in
    reg [DELAY_TOTAL-1:0] valids;  // mark the validness of data in each stage
    reg [DELAY_TOTAL-1:0] ovs;  // mark the last data of rows in each stage
    reg [DELAY_TOTAL-1:0] overs;  // mark the last submatrix of an iteration in each stage
    reg [DELAY_TOTAL-1:0] overfeds;  // delay to output the finish signal
    reg stopfeeding;  // self-locked overfed, indicating having fed in enough data
    wire over_invalid;  // alias of over, used to invalid a wrong data in buf
    wire overfed_flush;  // alias of overfed, used to remove dummy 1s in valids after finish
    wire [1:0] state;  // alias of {zero_in, rows_over} 00:moveon, 01:rowover, 10:zeroin, 11:zeroin&rowover

    // FSM
    assign rows_over = ovs[0];
    assign valid = running & ~rows_over & ~over_invalid & ~stopfeeding;
    assign zero_in = ~valids[DELAY_TOTAL-1];
    assign state = {zero_in, rows_over};
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
            valids <= {
                valid&~overfed_flush,  // flush pre-fed data
                valids[DELAY_TOTAL-1]&~overfed_flush,  // flush pre-fed data
                valids[DELAY_TOTAL-2:1]};
            ovs <= {1'b0, ov&running, ovs[DELAY_TOTAL-2:1]};
            overs <= {1'b0, over&running, overs[DELAY_TOTAL-2:1]};
            overfeds <= {2'b00, overfed&running, overfeds[DELAY_TOTAL-3:1]};
        end
    end
    // Condition Signals from Comparers
    step_counter # (
        .COUNTER_WIDTH(9),
        .STEP(6)
    ) valid_counter (
        .clk(clk),
        .rstn(rstn&~overfed_flush),
        .cnt(valid),
        .max(width),
        .ov(ov)
    );
    step_counter # (
        .COUNTER_WIDTH(9),
        .STEP(6)
    ) ov_counter (
        .clk(~clk),
        .rstn(rstn&~overfed_flush),
        .cnt(ov&running),
        .max(width),
        .ov(over)
    );
    assign over_invalid = over;
    step_counter # (
        .COUNTER_WIDTH(16),
        .STEP(1)
    ) iter_counter (
        .clk(clk),
        .rstn(rstn&~overfed_flush),
        .cnt(over&running),
        .max(iteration),
        .ov(overfed)
    );
    assign overfed_flush = overfed;
    // self-locked tofinish -- stop_feeding
    always @ (posedge clk)
    begin
        if(1'b0 == rstn)
        begin
            stopfeeding <= 1'b0;
        end
        else
        begin
            if(~running)
            begin
                stopfeeding <= 1'b0;
            end
            else if(overfed)
            begin
                stopfeeding <= 1'b1;
            end
            else
                stopfeeding <= stopfeeding;
        end
    end

    //DELAY_TOTAL: 9   DELAY_ACC:3   width: 13   iteration: 1
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //running:   | 1 ========================================================>
    //state: 10  | 10  | 00  | 00  | 00  | 00  | 00  | 00  | 00  | 00  | 00  |
    //valid:     |  1  |  1  |  1  |  1  |  1  |  1  |  1  |  1  |  1  |  1  |
    //valids:    | 000 | 100 | 180 | 1c0 | 1e0 | 1f0 | 1f8 | 1fc | 1fe | 1ff |
    //ovs:       | 000 | 000 | 000 | 000 | 080 | 040 | 020 | 090 | 048 | 024 |
    //overs:     | 000 | 000 | 000 | 000 | 000 | 000 | 000 | 000 | 000 | 000 |
    //overfeds:  | 000 | 000 | 000 | 000 | 000 | 000 | 000 | 000 | 000 | 000 |
    //addr:      0  |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9
    //                rd0   rd1   rd2   rd3   rd4   rd5   rd6   rd7   rd8   rd9
    //dout:       |     |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |
    //buf:       |     |     |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8
    //send_last: 1 ======================================> |  0  |  0  |  1  |
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //running:   > 1 ==========================================> | 0 ======>
    //state: 00  | 00  | 01  | 10  | 10  | 11  | 10  | 10  | 11  | 10  | 100 |
    //valids:    | 1ff | 1ff | 03f | 01f | 00f | 007 | 003 | 001 | 000 | 000 |
    //ovs:       | 092 | 049 | 024 | 012 | 009 | 004 | 002 | 001 | 000 | 000 |
    //overs:     | 080 | 040 | 020 | 010 | 008 | 004 | 002 | 001 | 000 | 000 |
    //overfeds:  | 000 | 000 | 020 | 010 | 008 | 004 | 002 | 001 | 000 | 000 |
    //     |  ov |
    //        | over|
    //           |ovfed|stopfeeding ===========================> |
    //           |flush|                                   |finish
    //buf:       |  8  |  9  | 10  | 11  | 12  | 13  | 14  | 15  | 16  | 17  |
    //          rd9   rd0  // rd9 is the inevitable dummy read to invalid
    //addr:      9  |  0  |  0  |     |     |  1  |     |     |  2  |
    //din(we):      |     |  0  |     |     |  1  |     |     |  2  |
    //                      wr0               wr1               wr2
    //send_last: |  0  |  0  |  1  |  0  |  0  |  1 ========================>


    // last
    reg send_last;
    assign last = send_last;
    always @ (posedge clk)
    begin
        if(1'b0 == rstn)
        begin
            send_last <= 1'b1;
        end
        else
        begin
            if(ovs[DELAY_ACC+1])
            begin
                send_last <= 1'b1;
            end
            else if(valids[DELAY_ACC+1])
            begin
                send_last <= 1'b0;
            end
            else
                send_last <= send_last;
        end
    end
    // finish
    assign finish = overfeds[0];

    //DELAY_TOTAL: 9   DELAY_ACC:3   width: 13   iteration: 1
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //running:   | 1 ========================================================>
    //state: 10  | 10  | 00  | 00  | 00  | 00  | 00  | 00  | 00  | 00  | 00  |
    //valid:     |  1  |  1  |  1  |  1  |  1  |  1  |  1  |  1  |  1  |  1  |
    //valids:    | 000 | 100 | 180 | 1c0 | 1e0 | 1f0 | 1f8 | 1fc | 1fe | 1ff |
    //ovs:       | 000 | 000 | 000 | 000 | 080 | 040 | 020 | 090 | 048 | 024 |
    //overs:     | 000 | 000 | 000 | 000 | 000 | 000 | 000 | 000 | 000 | 000 |
    //maddr:     0  |  0  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9
    //vaddr:     0  |  0  |  1  |  2  |  0  |  1  |  2  |  0  |  1  |  2  |  0
    //                rd0   rd1   rd2   rd3   rd4   rd5   rd6   rd7   rd8   rd9
    //
    //clk:    n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p  n  p
    //running:   > 1 ==========================================> | 0 ======>
    //state: 00  | 00  | 01  | 10  | 10  | 11  | 10  | 10  | 11  | 10  | 100 |
    //valids:    | 1ff | 1ff | 03f | 01f | 00f | 007 | 003 | 001 | 000 | 000 |
    //ovs:       | 092 | 049 | 024 | 012 | 009 | 004 | 002 | 001 | 000 | 000 |
    //overs:     | 080 | 040 | 020 | 010 | 008 | 004 | 002 | 001 | 000 | 000 |
    //overfeds:  | 000 | 000 | 020 | 010 | 008 | 004 | 002 | 001 | 000 | 000 |
    //          rd9   rd0  // rd9 is the inevitable dummy read to invalid
    //maddr:     9  |  0  |     |     |     |     |     |     |     |
    //vaddr:     0  |  0  |  0  |  0  |  0  |  1  |  0  |  0  |  2  |
    //din(we):      |     |  0  |     |     |  1  |     |     |  2  |
    //                      wr0               wr1               wr2
    //send_last: |  0  |  0  |  1  |  0  |  0  |  1 ========================>

    // BRAM Interface
    assign mbram_clk = clk;
    assign vbram_clk = clk;
    assign mbram_en = running;
    assign vbram_en = running;
    // Write Enable
    reg we;
    assign vbram_we = we;
    always @ (negedge clk)
    begin
        we <= state[0];
    end
    // Address
    reg [11:0] mraddr;  // matrix bram read only
    reg [9:0] vraddr, vwaddr;
    reg [9:0] vraddr_base, vwaddr_base;  // bases exchange per iteration
    wire [9:0] vraddr_base_next, vwaddr_base_next;
    assign mbram_addr = mraddr[11:0];
    assign vbram_addr = ({10{we}} & vwaddr[9:0]) | ({10{~we}} & vraddr[9:0]);
    always @ (negedge clk)
    begin
        if(1'b0 == (rstn & running))
        begin
            mraddr <= 12'h000;
        end
        else
        begin
            casex({over, state[1]})
                2'b1x: mraddr <= 12'h000;
                2'b00: mraddr <= mraddr + 1;
                2'b01: mraddr <= mraddr;
                default: mraddr <= mraddr;
            endcase
        end
    end
    always @ (negedge clk)
    begin
        if(1'b0 == (rstn & running))
        begin
            vraddr <= vraddr_base_next;
        end
        else
        begin
            casex({ov|over, state[1]})
                2'b1x: vraddr <= vraddr_base_next;
                2'b00: vraddr <= vraddr + 1;
                2'b01: vraddr <= vraddr;
                default: vraddr <= vraddr;
            endcase
        end
    end
    reg overs0_dly;
    always @ (posedge clk)
    begin
        overs0_dly <= overs[0];
    end
    always @ (negedge clk)
    begin
        if(1'b0 == (rstn & running))
        begin
            vwaddr <= vwaddr_base_next;
        end
        else
        begin
            casex({overs0_dly, we})
                2'b1x: vwaddr <= vwaddr_base_next;
                2'b01: vwaddr <= vwaddr + 1;
                2'b00: vwaddr <= vwaddr;
                default: vwaddr <= vwaddr;
            endcase
        end
    end
    assign vraddr_base_next = {(over&running), 9'd0} ^ vraddr_base;
    assign vwaddr_base_next = {(overs0_dly&running), 9'd0} ^ vwaddr_base;
    always @ (negedge clk)
    begin
        if(1'b0 == (rstn & running))
        begin
            vraddr_base <= 10'd0;
            vwaddr_base <= 10'h200;
        end
        else
        begin
            vraddr_base <= vraddr_base_next;
            vwaddr_base <= vwaddr_base_next;
        end
    end

endmodule
