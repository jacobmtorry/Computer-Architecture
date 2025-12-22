module icacheline_adapter
import types::*;
(
    input   logic       clk,
    input   logic       rst,

    // cache <-> adapter signals
    input   logic   [31:0]  dfp_addr,       // address of data we want to get from BRAM
    input   logic           dfp_read,       // read request
    output  logic           dfp_resp,       // says line is ready
    output  logic   [255:0] dfp_rdata,      // full cache line to write

    // adapter <-> BRAM signals
    input   logic           bmem_rvalid,    // resp from BRAM burst
    input   logic   [63:0]  bmem_rdata,     // data from BRAM burst
    input   logic           bmem_ready,

    output  logic   [31:0]  bmem_addr,      // addr to read/write
    output  logic           bmem_read       // read request
);

typedef enum logic [1:0] {
    IDLE,
    ISSUE,
    WAIT,
    RESP
} state_e;
state_e state, next_state;

logic [255:0]  assembled_line;
logic [ 31:0]  base_addr;
logic [  1:0]  count;

logic _unused;
assign _unused = bmem_ready;

always_comb begin
    bmem_addr  = '0;
    bmem_read  = '0;
    dfp_resp   = '0;
    dfp_rdata  = '0;
    next_state = state;
    unique case (state)
        IDLE: begin
            if (dfp_read) begin
                next_state = ISSUE;
            end
        end
        ISSUE: begin
            bmem_addr = base_addr;
            bmem_read = 1'b1;
            if (bmem_ready) begin
                next_state = WAIT;
            end else begin
                next_state = ISSUE;
            end
        end
        WAIT: begin
            if (count == 2'd3 && bmem_rvalid) begin
                next_state = RESP;
            end
        end
        RESP: begin
            dfp_resp = 1'b1;
            dfp_rdata = assembled_line;
            next_state = IDLE;
        end
    endcase
end

always_ff @(posedge clk) begin
    if (rst) begin
        state          <= IDLE;
        base_addr      <= '0;
        assembled_line <= '0;
        count          <= '0;
    end else begin
        state <= next_state;
        if (state == IDLE && dfp_read) begin
            base_addr      <= {dfp_addr[31:5], 5'b0};
            assembled_line <= '0;
            count          <= 2'd0;
        end
        if (state == WAIT && bmem_rvalid) begin
            unique case (count)
                2'd0: assembled_line[ 63:  0] <= bmem_rdata;
                2'd1: assembled_line[127: 64] <= bmem_rdata;
                2'd2: assembled_line[191:128] <= bmem_rdata;
                2'd3: assembled_line[255:192] <= bmem_rdata;
            endcase
            count <= count + 2'd1;
        end
        if (!bmem_rvalid) begin
            count <= '0;
        end
    end
end

endmodule : icacheline_adapter;
