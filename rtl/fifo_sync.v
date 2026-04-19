`timescale 1ns / 1ps

module fifo_sync #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8
)(
    input  wire clk,
    input  wire rst,        // synchronous reset
    input  wire wr_en,
    input  wire rd_en,
    input  wire [DATA_WIDTH-1:0] din,
    output reg  [DATA_WIDTH-1:0] dout,
    output wire full,
    output wire empty
);

    // -------------------------------
    // Internal memory
    // -------------------------------
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // -------------------------------
    // Pointer & counter
    // -------------------------------
    reg [$clog2(DEPTH)-1:0] wr_ptr;
    reg [$clog2(DEPTH)-1:0] rd_ptr;
    reg [$clog2(DEPTH+1)-1:0] count;

    // -------------------------------
    // Status flags
    // -------------------------------
    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    // -------------------------------
    // Main Sequential Logic
    // -------------------------------
    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            dout   <= 0;
        end else begin

            // -----------------------
            // WRITE Operation
            // -----------------------
            if (wr_en && (!full || (rd_en && !empty))) begin
                mem[wr_ptr] <= din;

                // pointer wrap-around
                if (wr_ptr == DEPTH-1)
                    wr_ptr <= 0;
                else
                    wr_ptr <= wr_ptr + 1;
            end

            // -----------------------
            // READ Operation
            // -----------------------
            if (rd_en && !empty) begin
                dout <= mem[rd_ptr];

                // pointer wrap-around
                if (rd_ptr == DEPTH-1)
                    rd_ptr <= 0;
                else
                    rd_ptr <= rd_ptr + 1;
            end

            // -----------------------
            // COUNT Update
            // -----------------------
            case ({wr_en && (!full || (rd_en && !empty)), rd_en && !empty})
                2'b10: count <= count + 1; // write only
                2'b01: count <= count - 1; // read only
                2'b11: count <= count;     // simultaneous
                default: count <= count;
            endcase

        end
    end

endmodule
