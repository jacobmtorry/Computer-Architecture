module dcache
import types::*;
#(parameter D_WAYS = 4, parameter D_SETS = 16) (
    input   logic           clk,
    input   logic           rst,

    // cpu side signals, ufp -> upward facing port
    input   logic   [31:0]  ufp_addr,
    input   logic   [3:0]   ufp_rmask,
    input   logic   [3:0]   ufp_wmask,
    output  logic   [255:0]  ufp_rdata,
    input   logic   [31:0]  ufp_wdata,
    output  logic           ufp_resp,

    // linebuf signals
    input   logic           linebuf_en,
    output  logic [D_SET_BITS-1:0]   cache_set,
    output  logic [D_TAG_BITS-1:0]   cache_tag,

    // memory side signals, dfp -> downward facing port
    output  logic   [31:0]  dfp_addr,
    output  logic           dfp_read,
    output  logic           dfp_write,
    input   logic   [255:0] dfp_rdata,
    output  logic   [255:0] dfp_wdata,
    input   logic           dfp_resp
);

    typedef enum logic [1:0] {IDLE, HIT, ALLOCATE, WRITEBACK} state_t;
    state_t current_state, next_state;

    typedef logic [D_WAY_BITS-1:0] sus;

    // PLRU Logic
    logic   [D_PLRU_BITS-1:0]   plru_out;
    logic   [D_PLRU_BITS-1:0]   plru_in;
    logic   [D_WAY_BITS-1:0]    victim;
    logic   dir;
    logic   dir_out;
    integer node;
    integer node_out;

    // Latched Inputs //
    logic   [31:0]  ufp_addr_latched;
    logic   [3:0]   ufp_rmask_latched;
    logic   [3:0]   ufp_wmask_latched;
    logic   [31:0]  ufp_wdata_latched;

    always_ff @(posedge clk) begin
        if (rst) begin
            ufp_addr_latched    <= '0;
            ufp_rmask_latched   <= '0;
            ufp_wdata_latched   <= '0;
            ufp_wmask_latched   <= '0;
        end else begin
            if (current_state == IDLE) begin
                ufp_addr_latched    <= ufp_addr;
                ufp_rmask_latched   <= ufp_rmask;
                ufp_wdata_latched   <= ufp_wdata;
                ufp_wmask_latched   <= ufp_wmask;
            end else begin
                ufp_addr_latched    <= ufp_addr_latched;
                ufp_rmask_latched   <= ufp_rmask_latched;
                ufp_wdata_latched   <= ufp_wdata_latched;
                ufp_wmask_latched   <= ufp_wmask_latched;
            end
        end
    end

    // Internal signals //
    logic   [D_WAYS-1:0]       hit;
    logic   [D_WAY_BITS-1:0]   hit_way;
    logic   [D_WAY_BITS-1:0]   evict_way;
    logic   [255:0] hit_line;
    logic   [2:0]   word_idx;

    // Way specific - allows us to distinguis between ways for reading and writing //
    logic   data_cs    [D_WAYS];
    logic   data_wb    [D_WAYS];
    logic   tag_cs     [D_WAYS];
    logic   tag_wb     [D_WAYS];
    logic   valid_cs   [D_WAYS];
    logic   valid_wb   [D_WAYS];
    logic   dirty_cs   [D_WAYS];
    logic   dirty_wb   [D_WAYS];
    logic   plru_cs;
    logic   plru_wb;

    // Address Decode //
    logic   [31:0]    eff_addr;
    logic   [D_TAG_BITS-1:0]     tag;
    logic   [4:0]     offset;
    logic   [D_SET_BITS-1:0]     set;

    assign eff_addr = (current_state == IDLE) ? ufp_addr : ufp_addr_latched;
    assign set    = eff_addr[5+D_SET_BITS-1:5];
    assign tag    = eff_addr[31:5+D_SET_BITS];
    assign offset = eff_addr[4:0];

    assign cache_set = set;
    assign cache_tag = tag;

    // Shared Inputs //
    logic   [255:0]   data_in;
    logic   [31:0]    data_wmask;
    logic             dirty_in;
    logic             valid_in;

    // Per Way Outputs //
    logic   [255:0]   data_out  [D_WAYS];
    logic   [D_TAG_BITS-1:0]    tag_out   [D_WAYS];
    logic             dirty_out [D_WAYS];
    logic             valid_out [D_WAYS];

    // Initialize all signals //
    always_comb begin
        // Chip Selects and Write enables
        data_wb  = '{default: 1'b1};
        tag_wb   = '{default: 1'b1};
        valid_wb = '{default: 1'b1};
        dirty_wb = '{default: 1'b1};
        plru_wb  = 1'b1;

        // Other
        dirty_in  = 1'b0;
        hit       = '0;
        hit_way   = '0;
        plru_in   = plru_out;
        evict_way = '0;
        valid_in  = 1'b0;

        // Other ports
        ufp_rdata = '0;
        ufp_resp  = '0;
        dfp_read  = '0;
        dfp_write = '0;
        dfp_wdata = '0;
        dfp_addr  = '0;

        // PLRU
        node = '0;
        victim   = '0;
        node_out = 0;

        // Determine if there is a hit
        for(integer i = 0; i < D_WAYS; i++) begin
            hit[i] = (tag_out[i] == tag) && valid_out[i];
        end

        // Find which way was hit
        for (integer i = 0; i < D_WAYS; i++) begin
          if (hit[i]) begin
            hit_way = sus'(i);
          end
        end

        hit_line = data_out[hit_way];

        word_idx = eff_addr[4:2];
        if (current_state == ALLOCATE && dfp_resp) begin
            data_wmask = '1;
            data_in    = dfp_rdata;
        end else begin
            unique case (word_idx)
                3'd0: begin
                    data_wmask = {28'b0, ufp_wmask_latched};
                    data_in    = {224'b0, ufp_wdata_latched};
                end
                3'd1: begin
                    data_wmask = {24'b0, ufp_wmask_latched, 4'b0};
                    data_in    = {192'b0, ufp_wdata_latched, 32'b0};
                end
                3'd2: begin
                    data_wmask = {20'b0, ufp_wmask_latched, 8'b0};
                    data_in    = {160'b0, ufp_wdata_latched, 64'b0};
                end
                3'd3: begin
                    data_wmask = {16'b0, ufp_wmask_latched, 12'b0};
                    data_in    = {128'b0, ufp_wdata_latched, 96'b0};
                end
                3'd4: begin
                    data_wmask = {12'b0, ufp_wmask_latched, 16'b0};
                    data_in    = {96'b0, ufp_wdata_latched, 128'b0};
                end
                3'd5: begin
                    data_wmask = {8'b0, ufp_wmask_latched, 20'b0};
                    data_in    = {64'b0, ufp_wdata_latched, 160'b0};
                end
                3'd6: begin
                    data_wmask = {4'b0, ufp_wmask_latched, 24'b0};
                    data_in    = {32'b0, ufp_wdata_latched, 192'b0};
                end
                3'd7: begin
                    data_wmask = {ufp_wmask_latched, 28'b0};
                    data_in    = {ufp_wdata_latched, 224'b0};
                end
                default: begin
                    data_wmask = '0;
                    data_in    = '0;
                end
            endcase
        end

        ////////////////// PLRU logic //////////////////

        // Decides input to plru

        // unique case (hit_way)
        //     2'd0: plru_in = {plru_out[2], 2'b00};
        //     2'd1: plru_in = {plru_out[2], 2'b10};
        //     2'd2: plru_in = {1'b0, plru_out[1], 1'b1};
        //     2'd3: plru_in = {1'b1, plru_out[1], 1'b1};
        //     default: plru_in = plru_out;
        // endcase

        for (integer i = 0; i < D_PLRU_LEVELS; i++) begin
            dir = hit_way[D_PLRU_LEVELS-1 - i];
            plru_in[node] = ~dir;
            if (dir == 1'b0) begin
                node = 2*node + 1;
            end else begin
                node = 2*node + 2;
            end
        end

        // Decides which way we are going to replace

        // unique casez (plru_out)
        //     3'b?11: evict_way = 2'b00;
        //     3'b?01: evict_way = 2'b01;
        //     3'b1?0: evict_way = 2'b10;
        //     3'b0?0: evict_way = 2'b11;
        //     default: evict_way = 2'b00;
        // endcase

        for (integer i = 0; i < D_PLRU_LEVELS; i++) begin
            dir_out = plru_out[node_out];
            victim[D_PLRU_LEVELS-1 - i] = dir_out;
            if (dir_out == 1'b0) begin
                node_out = 2*node_out + 1;
            end else begin
                node_out = 2*node_out + 2;
            end
        end
        evict_way = sus'(victim);

        // If we have a hit on read we immediatly return the word if its in the cache
        if (current_state == HIT && hit != '0) begin
            ufp_rdata = hit_line;
        end

        ////////////////// State Machine //////////////////
        data_cs  = '{default: 1'b0};
        tag_cs   = '{default: 1'b0};
        valid_cs = '{default: 1'b0};
        dirty_cs = '{default: 1'b0};
        plru_cs  = 1'b0;
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if((|ufp_rmask || |ufp_wmask) && ~linebuf_en) begin
                    next_state = HIT;
                end else begin
                    next_state = IDLE;
                end
            end
            HIT: begin
                plru_wb  = 1'b1;
                ufp_resp = '0;
                if (~|hit) begin
                    if (dirty_out[evict_way]) begin
                        next_state = WRITEBACK;
                    end else begin
                        next_state = ALLOCATE;
                    end
                end else if (|ufp_rmask_latched) begin
                    ufp_resp   = 1'b1;
                    plru_wb    = 1'b0;
                    dirty_in   = '0;
                    data_wb[hit_way]  = '1;
                    dirty_wb[hit_way] = '1;
                    next_state = IDLE;
                end else if (|ufp_wmask_latched) begin
                    ufp_resp   = 1'b1;
                    plru_wb    = '0;
                    dirty_in   = '1;
                    data_wb[hit_way]  = '0;
                    dirty_wb[hit_way] = '0;
                    next_state = IDLE;
                end else begin
                    next_state = IDLE;
                end
            end
            ALLOCATE: begin
                valid_in = 1'b1;
                dfp_read = 1'b1;
                dfp_addr = {ufp_addr_latched[31:5], 5'b00000};
                if (dfp_resp) begin
                    data_wb[evict_way]  = 1'b0;
                    tag_wb[evict_way]   = 1'b0;
                    valid_wb[evict_way] = 1'b0;
                    next_state = IDLE;
                end else begin
                    data_wb[evict_way]  = 1'b1;
                    tag_wb[evict_way]   = 1'b1;
                    valid_wb[evict_way] = 1'b1;
                    next_state = ALLOCATE;
                end
            end
            WRITEBACK: begin
                dfp_write = 1'b1;
                dfp_addr  = {tag_out[evict_way], set, 5'b00000};
                dfp_wdata = data_out[evict_way];
                data_wb[evict_way] = 1'b1;
                dirty_in = 1'b0;
                if (dfp_resp) begin
                    dirty_wb[evict_way] = 1'b0;
                    next_state = ALLOCATE;
                end else begin
                    dirty_wb[evict_way] = 1'b1;
                    next_state = WRITEBACK;
                end
            end
        endcase
    end

    // This is how the ways are created
    generate for (genvar i = 0; i < D_WAYS; i++) begin : arrays
        if (D_SETS == 32) begin
            cache_data_array_32_sets #( .ADDR_WIDTH(D_SET_BITS) ) data_array (
                .clk0       (clk && !data_cs[i]),
                .csb0       (data_cs[i]),
                .web0       (data_wb[i]),
                .wmask0     (data_wmask),
                .addr0      (set),
                .din0       (data_in),
                .dout0      (data_out[i])
            );
            cache_tag_array_32_sets #( .ADDR_WIDTH(D_SET_BITS), .DATA_WIDTH(D_TAG_BITS) ) tag_array (
                .clk0       (clk && !tag_cs[i]),
                .csb0       (tag_cs[i]),
                .web0       (tag_wb[i]),
                .addr0      (set),
                .din0       (tag),
                .dout0      (tag_out[i])
            );
        end else begin
            cache_data_array_16_sets #( .ADDR_WIDTH(D_SET_BITS) ) data_array (
                .clk0       (clk && !data_cs[i]),
                .csb0       (data_cs[i]),
                .web0       (data_wb[i]),
                .wmask0     (data_wmask),
                .addr0      (set),
                .din0       (data_in),
                .dout0      (data_out[i])
            );
            cache_tag_array_16_sets #( .ADDR_WIDTH(D_SET_BITS), .DATA_WIDTH(D_TAG_BITS) ) tag_array (
                .clk0       (clk && !tag_cs[i]),
                .csb0       (tag_cs[i]),
                .web0       (tag_wb[i]),
                .addr0      (set),
                .din0       (tag),
                .dout0      (tag_out[i])
            );
        end
        sp_ff_array #(.S_INDEX(D_SET_BITS)) valid_array (
            .clk0       (clk && !valid_cs[i]),
            .rst0       (rst),
            .csb0       (valid_cs[i]),
            .web0       (valid_wb[i]),
            .addr0      (set),
            .din0       (valid_in),
            .dout0      (valid_out[i])
        );
        sp_ff_array #(.S_INDEX(D_SET_BITS)) dirty_array (
            .clk0       (clk && !dirty_cs[i]),
            .rst0       (rst),
            .csb0       (dirty_cs[i]),
            .web0       (dirty_wb[i]),
            .addr0      (set),
            .din0       (dirty_in),
            .dout0      (dirty_out[i])
        );
    end endgenerate

    sp_ff_array #(
        .WIDTH      (D_PLRU_BITS),
        .S_INDEX    (D_SET_BITS)
    ) lru_array (
        .clk0       (clk && !plru_cs),
        .rst0       (rst),
        .csb0       (plru_cs),
        .web0       (plru_wb),
        .addr0      (set),
        .din0       (plru_in),
        .dout0      (plru_out)
    );

    // State Updating //
    always_ff @(posedge clk) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Performance measure //
    logic [63:0] cycle_count;
    logic [63:0] fetches;
    logic [63:0] stall_cycles;
    always_ff @(posedge clk) begin
        if (rst) begin
            cycle_count <= '0;
            fetches <= '0;
            stall_cycles <= '0;
        end else begin
            cycle_count <= cycle_count + 1'd1;
            if (ufp_resp) begin
                fetches <= fetches + 1'd1;
            end
            if ((|ufp_rmask_latched || |ufp_wmask_latched) && !ufp_resp) begin
                stall_cycles <= stall_cycles + 1'd1;
            end
        end
    end
endmodule
