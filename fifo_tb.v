`timescale 1ns / 1ps

module tb;
parameter DEPTH=16;
parameter WIDTH=8;
parameter PTR_WIDTH=4;

reg wr_en_i, rd_en_i;
reg [WIDTH-1:0] wdata_i;
wire full_o;
wire [WIDTH-1:0] rdata_o;
wire empty_o;
reg clk_i, rst_i;
wire error_o;
integer i;

fifo dut(
    .clk_i(clk_i), .rst_i(rst_i), 
    .wr_en_i(wr_en_i), .rd_en_i(rd_en_i), 
    .wdata_i(wdata_i), .full_o(full_o), 
    .rdata_o(rdata_o), .empty_o(empty_o), 
    .error_o(error_o)
);

//////////////////// CLOCK ////////////////////
initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i;  // 10ns period
end

//////////////////// TEST SEQUENCE ////////////////////
initial begin
    // Initial values
    wr_en_i = 0;
    rd_en_i = 0;
    wdata_i = 0;

    // Apply reset
    rst_i = 1;
    repeat(2) @(posedge clk_i);
    rst_i = 0;

    // ========== 1) NORMAL FIFO FILL ==========
    $display("\n---- Filling FIFO ----");
    for (i = 0; i < DEPTH; i=i+1) begin
        @(posedge clk_i);
        wdata_i = $random;
        wr_en_i = 1;
    end
    @(posedge clk_i);
    wr_en_i = 0;

    // ========== 2) WRITE WHEN FULL (Error Expected) ==========
    $display("\n---- Write when FULL (Expect error) ----");
    @(posedge clk_i);
    wdata_i = 8'hAA;
    wr_en_i = 1;
    @(posedge clk_i);
    wr_en_i = 0;

    // ========== 3) NORMAL FIFO DRAIN ==========
    $display("\n---- Reading FIFO ----");
    for (i = 0; i < DEPTH; i=i+1) begin
        @(posedge clk_i);
        rd_en_i = 1;
    end
    @(posedge clk_i);
    rd_en_i = 0;

    // ========== 4) READ WHEN EMPTY (Error Expected) ==========
    $display("\n---- Read when EMPTY (Expect error) ----");
    @(posedge clk_i);
    rd_en_i = 1;
    @(posedge clk_i);
    rd_en_i = 0;

    #50;
    $finish;
end

endmodule
