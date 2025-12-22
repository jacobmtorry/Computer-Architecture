module dcacheline_adapter
import types::*;
(
    input  logic        clk,
    input  logic        rst,

    // cache <-> adapter signals
    input  logic [31:0] dfp_addr,     // address of data we want to get from BRAM
    input  logic        dfp_read,     // read request (full line)
    input  logic        dfp_write,    // NEW: writeback request (full line)
    output logic        dfp_resp,     // says line is ready
    output logic [255:0] dfp_rdata,   // full cache line to read
    input  logic [255:0] dfp_wdata,   // NEW: full cache line to writeback

    // adapter <-> BRAM signals (existing project conventions)
    input  logic        bmem_rvalid,  // resp from BRAM burst
    input  logic [63:0] bmem_rdata,   // data from BRAM burst
    input  logic        bmem_ready,

    output logic [31:0] bmem_addr,    // addr to read/write
    output logic        bmem_read,    // read request
    output logic        bmem_write,   // NEW: write request (single-beat write)
    output logic [63:0] bmem_wdata    // NEW: data beat for write
);

typedef enum logic [1:0] {
    IDLE,
    ISSUE,
    WAIT,
    RESP
} state_e;

state_e state, next_state;

logic [255:0] assembled_line;
logic [31:0]  base_addr;
logic [1:0]   count;
logic [1:0]   next_count;
logic [255:0] write_buffer;

logic _unused;
assign _unused = bmem_ready;

// Calculate next count value
always_comb begin
    next_count = count;

    // For writes: increment when beat is accepted
    if ((state == ISSUE || state == WAIT) && dfp_write && bmem_ready) begin
        next_count = count + 2'd1;
    end
    // For reads: increment when beat is received
    else if (state == WAIT && dfp_read && bmem_rvalid) begin
        next_count = count + 2'd1;
    end
end

always_comb begin
    // Default outputs
    bmem_addr  = base_addr;
    bmem_read  = '0;
    bmem_write = '0;
    bmem_wdata = '0;
    dfp_resp   = '0;
    dfp_rdata  = '0;
    next_state = state;

    unique case (state)

        IDLE: begin
            if (dfp_read || dfp_write) begin
                next_state = ISSUE;
            end
        end

        ISSUE: begin
            bmem_addr = base_addr;

            if (dfp_read) begin
                bmem_read = 1'b1;
                if (bmem_ready) begin
                    next_state = WAIT;
                end else begin
                    next_state = ISSUE;
                end

            end else if (dfp_write) begin
                // Start writing beats - use current count (starts at 0)
                bmem_write = 1'b1;
                bmem_wdata = write_buffer[64*next_count +: 64];

                if (bmem_ready) begin
                    // If this was the last beat (count will become 3 after increment)
                    if (next_count == 2'd3) begin
                        next_state = RESP;
                    end else begin
                        next_state = WAIT;
                    end
                end else begin
                    next_state = ISSUE;
                end
            end
        end

        WAIT: begin
            if (dfp_read) begin
                // Read path: wait for all 4 beats
                if (count == 2'd3 && bmem_rvalid) begin
                    next_state = RESP;
                end

            end else if (dfp_write) begin
                // Write path: continue writing beats
                if (count < 2'd3) begin
                    bmem_write = 1'b1;
                    bmem_wdata = write_buffer[64*next_count +: 64];
                    // Check if this is the last beat
                    if (bmem_ready && next_count == 2'd3) begin
                        next_state = RESP;
                    end
                end
            end
        end

        RESP: begin
            dfp_resp = 1'b1;
            if (dfp_read) dfp_rdata = assembled_line;
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
        write_buffer   <= '0;

    end else begin
        state <= next_state;

        // Capture request on IDLE
        if (state == IDLE && (dfp_read || dfp_write)) begin
            base_addr <= {dfp_addr[31:5], 5'b0};
            count     <= 2'd0;

            if (dfp_read) begin
                assembled_line <= '0;
            end else if (dfp_write) begin
                write_buffer <= dfp_wdata;
            end
        end

        // Read path: collect beats
        if (state == WAIT && dfp_read && bmem_rvalid) begin
            assembled_line[64*count +: 64] <= bmem_rdata;
            count <= next_count;
        end

        // Write path: increment counter after each beat accepted
        if ((state == ISSUE || state == WAIT) && dfp_write && bmem_ready) begin
            count <= next_count;
        end

        if (!bmem_rvalid && !bmem_write) begin
            count <= '0;
        end
    end
end

endmodule : dcacheline_adapter
