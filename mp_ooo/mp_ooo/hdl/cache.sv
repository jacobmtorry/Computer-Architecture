module cache
import types::*;
(
    input   logic           clk,
    input   logic           rst,

    // cpu side signals, ufp -> upward facing port
    input   logic   [31:0]  ufp_addr,
    input   logic   [3:0]   ufp_rmask,
    input   logic   [3:0]   ufp_wmask,
    output  logic   [255:0]  ufp_rdata,
    input   logic   [31:0]  ufp_wdata,
    output  logic           ufp_resp,
    input   logic           linebuf_en,
    output  logic [3:0]     cache_set,
    output  logic [22:0]    cache_tag,
    output  logic [2:0]     cache_index,

    // memory side signals, dfp -> downward facing port
    output  logic   [31:0]  dfp_addr,
    output  logic           dfp_read,
    output  logic           dfp_write,
    input   logic   [255:0] dfp_rdata,
    output  logic   [255:0] dfp_wdata,
    input   logic           dfp_resp
);

    cache_state_e state, next_state;
    logic [31:0] ufp_addr_next;
    logic [3:0] ufp_rmask_next;
    logic [3:0] ufp_wmask_next;
    logic [31:0] ufp_wdata_next;


    // Latch inputs
    always_ff @(posedge clk) begin
        if (rst) begin
            ufp_addr_next   <= '0;
            ufp_rmask_next  <= '0;
            ufp_wmask_next  <= '0;
            ufp_wdata_next  <= '0;
        end else begin
            ufp_addr_next  <= (state == IDLE) ? ufp_addr : ufp_addr_next;
            ufp_rmask_next <= (state == IDLE) ? ufp_rmask : ufp_rmask_next;
            ufp_wmask_next <= (state == IDLE) ? ufp_wmask : ufp_wmask_next;
            ufp_wdata_next <= (state == IDLE) ? ufp_wdata : ufp_wdata_next;
        end
    end

    // Tag, Set Index, and Line Offset
    logic [22:0] addr_tag;
    logic [3:0] addr_index;
    logic [4:0] addr_offset;
    logic [2:0] addr_offset_U3;

    // Chip Select and Write Enable for each way
    logic [3:0] csb_data_way, csb_tag_way, csb_valid_way, csb_dirty_way;
    logic [3:0] web_data_way, web_tag_way, web_valid_way, web_dirty_way;

    // Outputs Data, Tag, Valid and Dirty for each way
    logic [255:0] data_out_way[4];
    logic [22:0] tag_out_way[4];
    logic valid_out_way[4], dirty_out_way[4];

    // LRU input, output, chip select, writeback and decode (replacement decision)
    logic [2:0] lru_in, lru_out;
    logic lru_csb, lru_wbe;
    logic [1:0] lru_decode;

    // Logic to decide which way has been hit
    logic [3:0] way_hit;
    logic [1:0] way_hit_decimal;

    logic is_cpu_command, is_read, is_write, is_new_data;
    logic valid_in, dirty_in;
    logic [255:0] data_in, build_cache_line;
    logic [31:0] wmask_line;

    logic [31:0] wmask_next32;
    logic [31:0] eff_addr;


    always_comb begin
        // Initialize module outputs
        ufp_rdata = '0;
        ufp_resp = '0;
        dfp_read = '0;
        dfp_write = '0;
        dfp_wdata = '0;
        dfp_addr = '0;

        // Get Tag, Set Index, Offset and Offsets Upper 3
        eff_addr = (state == IDLE) ? ufp_addr : ufp_addr_next;
        addr_tag       = eff_addr[31:9];
        addr_index     = eff_addr[8:5];     // set
        addr_offset    = eff_addr[4:0];
        addr_offset_U3 = eff_addr[4:2];

        cache_set = eff_addr[8:5];
        cache_tag = eff_addr[31:9];
        cache_index = eff_addr[4:2];

        // Initialize chip select and write enable for each way (Active low)
        csb_data_way = 4'b1111;
        csb_tag_way = 4'b1111;
        csb_valid_way = 4'b1111;
        csb_dirty_way = 4'b1111;
        lru_csb = 1'b1;

        web_data_way = 4'b1111;
        web_tag_way = 4'b1111;
        web_valid_way = 4'b1111;
        web_dirty_way = 4'b1111;
        lru_wbe = 1'b1;

        // Control
        is_cpu_command = ufp_rmask != 4'h0 || ufp_wmask != 4'h0;
        is_read  = ufp_rmask_next != 4'h0;
        is_write = ufp_wmask_next != 4'h0;
        is_new_data = (state==ALLOCATE && dfp_resp);

        // Initialize other values
        lru_in = 3'b000;
        lru_decode = 2'd0;
        way_hit_decimal = 2'b00;
        dirty_in = 1'b0;
        valid_in = 1'b0;

        // Build the WMask. Converts 4b mask into 32b mask for data array. addr_offset_U3 is used to position the mask
        wmask_line = '0;
        wmask_line = (is_new_data) ? '1 : {28'd0, ufp_wmask_next} << {addr_offset_U3, 2'b00};

        // Builds cache lint. Converts 32b data from CPU builds 256b data that will be input to cache line
        data_in = '0;
        data_in = (is_new_data) ? dfp_rdata : {224'd0, ufp_wdata_next} << {addr_offset_U3, 5'd0000};

        // Find which way was hit
        for (integer i = 0; i < 4; i++) begin
            way_hit[i] = (tag_out_way[i] == addr_tag) && valid_out_way[i];
            // if(way_hit[i])break;
        end


        // Tree from L9 Slide 32
        priority case(way_hit)
            4'b0000: lru_in = lru_out;
            4'b0001: lru_in = {lru_out[2], 2'b00};      // Way 0 hit
            4'b0010: lru_in = {lru_out[2], 2'b10};      // Way 1 hit
            4'b0100: lru_in = {1'b0, lru_out[1], 1'b1}; // Way 2 hit
            4'b1000: lru_in = {1'b1, lru_out[1], 1'b1}; // Way 3 hit
            default: lru_in = lru_out;
        endcase


        // Decides which way we are going to replace (L9 Slide 32)
        unique casez (lru_out)
            3'b?11: lru_decode = 2'd0; // Replace way 0
            3'b?01: lru_decode = 2'd1; // Replace way 1
            3'b1?0: lru_decode = 2'd2; // Replace way 2
            3'b0?0: lru_decode = 2'd3; // Replace way 3
            default: lru_decode = 2'd0;
        endcase


        // Convert way_hit to decimal for offset calculations
        // !! 0 could mean wither way0 hit or miss
        priority case(way_hit)
            4'b0000: way_hit_decimal = 2'd0;
            4'b0001: way_hit_decimal = 2'd0;
            4'b0010: way_hit_decimal = 2'd1;
            4'b0100: way_hit_decimal = 2'd2;
            4'b1000: way_hit_decimal = 2'd3;
            default: way_hit_decimal = 2'd0;
        endcase


        // State Machine
        case(state)
        IDLE: begin
            csb_data_way = 4'b0000;
            csb_tag_way = 4'b0000;
            csb_valid_way = 4'b0000;
            csb_dirty_way = 4'b0000;
            lru_csb = 1'b0;

            next_state = (is_cpu_command && ~linebuf_en) ? CHECK_FOR_HIT : IDLE;
        end

        CHECK_FOR_HIT: begin // Check to see if we find a hit
            csb_data_way = 4'b0000;
            csb_tag_way = 4'b0000;
            csb_valid_way = 4'b0000;
            csb_dirty_way = 4'b0000;
            lru_csb = 1'b0;
            lru_wbe = 1'b1;
            ufp_resp = '0;

            if(way_hit == 4'b0000) begin
                // No way has been hit (miss)
                next_state = (dirty_out_way[lru_decode]) ? WRITEBACK : ALLOCATE;

            end else if(is_read && way_hit != 4'b0000) begin // Else if theres a read
                next_state = IDLE;
                ufp_resp = '1;
                lru_wbe = '0;
                // Says take the way indicated by "way_hit_decimal" and addr_offset << 3 down 32
                ufp_rdata = data_out_way[way_hit_decimal];
                web_data_way[way_hit_decimal] = '1;
                web_dirty_way[way_hit_decimal] = '1;
                dirty_in = '0;

            end else if(is_write && way_hit != 4'b0000)begin // Writing to cache
                next_state = IDLE;
                ufp_resp = '1;
                lru_wbe = '0;
                // Says take the way indicated by "way_hit_decimal" and addr_offset << 3 down 32
                ufp_rdata = 'x;
                web_data_way[way_hit_decimal] = '0;
                web_dirty_way[way_hit_decimal] = '0;
                dirty_in = '1;

            end else begin
                next_state = IDLE;
            end
        end

        WRITEBACK: begin // Evict dirty line to memory
            csb_data_way = 4'b0000;
            csb_tag_way = 4'b0000;
            csb_valid_way = 4'b0000;
            csb_dirty_way = 4'b0000;
            lru_csb = 1'b0;


            dfp_write = 1'b1;
            dfp_addr = {tag_out_way[lru_decode], addr_index, 5'b00000};
            dfp_wdata = data_out_way[lru_decode];

            // Never write data array during writeback
            web_data_way[lru_decode]  = 1'b1;

            // Clear dirty only when memory acks
            dirty_in = 1'b0;
            web_dirty_way[lru_decode] = dfp_resp ? 1'b0 : 1'b1;

            next_state = (dfp_resp) ? ALLOCATE : WRITEBACK;
        end
        ALLOCATE: begin // Bring data from memory
            csb_data_way = 4'b0000;
            csb_tag_way = 4'b0000;
            csb_valid_way = 4'b0000;
            csb_dirty_way = 4'b0000;
            lru_csb = 1'b0;


            web_data_way[lru_decode]  = dfp_resp ? 1'b0 : 1'b1;
            web_tag_way[lru_decode]   = dfp_resp ? 1'b0 : 1'b1;
            web_valid_way[lru_decode] = dfp_resp ? 1'b0 : 1'b1;
            valid_in = 1'b1;

            dfp_read = 1'b1;
            dfp_addr = {ufp_addr_next[31:5], 5'b00000};

            next_state = (dfp_resp) ? IDLE : ALLOCATE;
        end
        default: next_state = state;
        endcase
    end


    // Essentially assigns our 4 ways
    generate for (genvar i = 0; i < 4; i++) begin : g_arrays
        mp_cache_data_array data_array (    // Data storeage for cache lines
            .clk0       (clk && ~csb_data_way[i]),
            .csb0       (csb_data_way[i]),  // Chip select for way
            .web0       (web_data_way[i]),  // Write Enable for way
            .wmask0     (wmask_line),       // Write Mask
            .addr0      (addr_index),       // Address input
            .din0       (data_in),          // Data input
            .dout0      (data_out_way[i])   // Data output
        );
        mp_cache_tag_array tag_array (      // Tag storage array
            .clk0       (clk && ~csb_tag_way[i]),
            .csb0       (csb_tag_way[i]),   // Chip select for way
            .web0       (web_tag_way[i]),   // Write Enable for way
            .addr0      (addr_index),       // Address inout
            .din0       (addr_tag),         // Data input
            .dout0      (tag_out_way[i])    // Data output
        );
        sp_ff_array valid_array (           // stores the valid
            .clk0       (clk && ~csb_valid_way[i]),
            .rst0       (rst),
            .csb0       (csb_valid_way[i]), // Chip select for way
            .web0       (web_valid_way[i]), // Write Enable for way
            .addr0      (addr_index),       // Address input
            .din0       (valid_in),         // Data input
            .dout0      (valid_out_way[i])  // Data output
        );

        sp_ff_array dirty_array (           // stores the ditry
            .clk0       (clk && ~csb_dirty_way[i]),
            .rst0       (rst),
            .csb0       (csb_dirty_way[i]), // Chip select for way
            .web0       (web_dirty_way[i]), // Write Enable for way
            .addr0      (addr_index),       // Address input
            .din0       (dirty_in),         // Data input
            .dout0      (dirty_out_way[i])  // Data output
        );
    end endgenerate


    sp_ff_array #(
        .WIDTH      (3)
    ) lru_array (
        .clk0       (clk && ~lru_csb),
        .rst0       (rst),
        .csb0       (lru_csb),
        .web0       (lru_wbe),
        .addr0      (addr_index),
        .din0       (lru_in),
        .dout0      (lru_out)
    );


    always_ff @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
endmodule
