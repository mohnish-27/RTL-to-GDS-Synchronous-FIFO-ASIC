`timescale 1ns / 1ps

module tb_fifo_sync;

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 8;

    reg clk, rst;
    reg wr_en, rd_en;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire full, empty;

    // DUT
    fifo_sync #(DATA_WIDTH, DEPTH) dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // Clock
    always #5 clk = ~clk;

    // -------------------------------
    // Golden Model (Queue)
    // -------------------------------
    reg [DATA_WIDTH-1:0] queue [0:DEPTH-1];
    integer head = 0, tail = 0, q_count = 0;

    // -------------------------------
    // TASK: WRITE
    // -------------------------------
    task write(input [7:0] data);
    begin
        @(posedge clk);
        wr_en = 1; rd_en = 0;
        din = data;

        if (!full) begin
            queue[tail] = data;
            tail = (tail + 1) % DEPTH;
            q_count = q_count + 1;
        end
    end
    endtask

    // -------------------------------
    // TASK: READ
    // -------------------------------
    task read;
    reg [7:0] expected;
    begin
        @(posedge clk);
        wr_en = 0; rd_en = 1;

        if (!empty) begin
            expected = queue[head];
            head = (head + 1) % DEPTH;
            q_count = q_count - 1;

            #1;
            if (dout !== expected)
                $display("❌ ERROR: Expected=%0d Got=%0d", expected, dout);
            else
                $display("✅ READ OK: %0d", dout);
        end
    end
    endtask

    // -------------------------------
    // TEST SEQUENCE
    // -------------------------------
    initial begin
        clk = 0; rst = 1;
        wr_en = 0; rd_en = 0;

        #10 rst = 0;

        $display("\n--- TEST START ---\n");

        // Fill FIFO
        $display("FILL FIFO");
        repeat (DEPTH) write($random);

        // Try overflow
        $display("TRY OVERFLOW");
        write(99);

        // Empty FIFO
        $display("EMPTY FIFO");
        repeat (DEPTH) read;

        // Try underflow
        $display("TRY UNDERFLOW");
        read;

        // Simultaneous R/W
        $display("SIMULTANEOUS READ/WRITE");
        repeat (5) begin
            @(posedge clk);
            wr_en = 1;
            rd_en = 1;
            din = $random;
        end

        wr_en = 0; rd_en = 0;

        #20;
        $display("\n--- TEST COMPLETE ---\n");
        $finish;
    end

endmodule
