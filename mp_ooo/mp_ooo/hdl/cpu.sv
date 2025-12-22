module cpu
import types::*;
(
    input   logic               clk,
    input   logic               rst,

    output  logic   [31:0]      bmem_addr,
    output  logic               bmem_read,
    output  logic               bmem_write,
    output  logic   [63:0]      bmem_wdata,
    input   logic               bmem_ready,

    input   logic   [31:0]      bmem_raddr,
    input   logic   [63:0]      bmem_rdata,
    input   logic               bmem_rvalid
);

    /////////////// Logic Declarations /////////////

    // imem_q
    logic           imem_q_ren;
    logic           imem_q_space;
    logic           imem_q_empty;
    imem_pkt_t      imem_q_in;
    imem_pkt_t      imem_q_out;

    // i_cache
    logic           i_cache_resp;
    logic           i_burst_done;
    logic           bmem_i_read;
    logic           bmem_i_ready;
    logic           bmem_i_rvalid;
    logic [31:0]    bmem_i_addr;
    logic [63:0]    bmem_i_rdata;
    logic [255:0]   i_cache_rdata;

    // d_cache
    logic           d_cache_resp;
    logic           d_burst_done;
    logic           bmem_d_read;
    logic           bmem_d_ready;
    logic           bmem_d_rvalid;
    logic           bmem_d_write;
    logic [3:0]     d_cache_rmask;
    logic [3:0]     d_cache_wmask;
    logic [31:0]    d_cache_addr;
    logic [31:0]    bmem_d_addr;
    logic [31:0]    d_cache_wdata;
    logic [63:0]    bmem_d_rdata;
    logic [63:0]    bmem_d_wdata;
    logic [255:0]   d_cache_rdata;

    // linebuffer
    logic           linebuf_hit;
    logic           linebuf_en;
    logic [2:0]     linebuf_index;
    logic [I_SET_BITS-1:0]   linebuf_set;
    logic [I_SET_BITS-1:0]   cache_set;
    logic [I_TAG_BITS-1:0]   linebuf_tag;
    logic [I_TAG_BITS-1:0]   cache_tag;
    logic [31:0]    pc_aligned;
    logic [31:0]    linebuf_address;
    logic [255:0]   linebuf;

    // PC control
    logic           flush;
    logic           br_pred;
    logic           take_target;
    logic [31:0]    pc;
    logic [31:0]    pc_next;
    logic [63:0]    order;
    logic [63:0]    order_next;
    logic [31:0]    pc_out;
    logic [31:0]    instr;
    logic [31:0]    target_pc;

    // origin: decode.sv
    logic                          can_rename;         // -> rename_en (regfile)
    logic [4:0]                    rs1_sel;            // -> rs1_s (regfile)
    logic [4:0]                    rs2_sel;            // -> rs2_s (regfile)
    logic [4:0]                    rd_to_rename;       // -> rd_to_rename (regfile)
    decode_to_issue_t              decode_out;         // -> inst_pkt (issue.sv) ,  -> din (rob.sv)
    logic [$clog2(ROB_DEPTH)-1:0]  rob_tag;            // -> (regfile)

    // origin: rob.sv
    rob_cell_t                      rob_out;
    logic                           rob_space_avail;   // -> rob_full (decode)
    logic                           rob_empty;         // UNUSED CURRENTLY (updated: 11/20)
    logic                           commit_en;
    logic                           store_trigger;
    logic [$clog2(ROB_DEPTH)-1:0]   rob_index;         // -> rob_alloc (decode)
    logic [$clog2(ROB_DEPTH)-1:0]   rob_head_idx;

    // origin: regfile.sv
    reg_t rs1_out; // -> rs1_regf (decode)
    reg_t rs2_out; // -> rs2_regf (decode)

    // origin: issue.sv
    logic       inst_ready;  // -> cpu
    logic       mem_inst_ready;
    fu_pkt_t    alu_pkt;     // -> alu_pkt_in (alu_cmp_combo)
    fu_pkt_t    mul_pkt;
    fu_pkt_t    div_pkt;
    fu_pkt_t    mem_pkt;
    fu_pkt_t    br_pkt;

    // origin: fu_[OPERATION].sv (FUs)
    cdb_t alu_out;
    cdb_t mul_out;
    cdb_t div_out;
    cdb_t mem_out;
    cdb_t br_out;
    logic div_resp;
    logic alu_start;
    logic div_start;
    logic div_busy;
    logic backpressure;

    // cdb
    cdb_t common_cdb;       //it is super common for added commonality

    // br pred
    br_pred_t br_pred_out;
    logic take_pred;


    // update pc and order
    always_ff @(posedge clk) begin
        pc    <= pc_next;
        order <= order_next;
    end


    // pc_next, order_next assignmenets
    always_comb begin
        priority case(1'b1)
            rst:                          pc_next  = 32'hAAAAA000;
            flush:                        pc_next  = target_pc;
            take_pred:                    pc_next  = br_pred_out.target_pc;
            (linebuf_hit && imem_q_space): pc_next = pc + 3'd4;
            default:                      pc_next  = pc;
        endcase

        priority case(1'b1)
            rst:            order_next = 64'd0;
            flush:          order_next = rob_out.order + 1'd1;
            take_pred:      order_next = br_pred_out.order + 1'd1;
            (linebuf_hit && imem_q_space):   order_next = order + 1'd1;
            default:        order_next = order;
        endcase
    end

    assign pc_aligned      = {pc[31:5], 5'd0};
    assign linebuf_address = {linebuf_tag, linebuf_set, 5'd0};
    assign linebuf_hit     = linebuf_en && (linebuf_tag == cache_tag && linebuf_set == cache_set);
    // Serial linebuffer extraction logic
    always_ff @(posedge clk) begin
        if(rst) begin
            linebuf       <= '0;
            linebuf_tag   <= '0;
            linebuf_set   <= '0;
            linebuf_index <= '0;
            linebuf_en    <= '0;
        end else if (flush || take_pred) begin
            linebuf_en     <= 1'b0;
            linebuf_index  <= pc[4:2];
        end else if (i_cache_resp) begin // on response
            linebuf       <= i_cache_rdata; // Assign the cache line
            linebuf_tag   <= cache_tag;
            linebuf_set   <= cache_set;
            linebuf_index <= pc[4:2];
            linebuf_en    <= 1'b1;
        end else if(linebuf_hit && imem_q_space) begin
            linebuf_index <= linebuf_index + 1'b1;
            if (linebuf_index == 3'd7) begin
                linebuf_en <= '0;
            end else begin
                linebuf_en <= '1;
            end
        end
    end


    br_pred br_pred_i (
        .clk(clk),
        .rst(rst),
        .flush(flush || take_pred),
        .imem_q_space(imem_q_space),
        .pc(pc),
        .inst(linebuf[32*linebuf_index +: 32]),
        .order(order),
        .linebuf_hit(linebuf_hit),

        .out(br_pred_out),
        .take_pred(take_pred),

        .write_back(rob_out.dispatch_info.br_pred_info),
        .actual(rob_out.cdb_info.data[0]),
        .wb_en(commit_en && rob_out.dispatch_info.bj == IS_BR) // if commit_en && IS_BR
    );


    always_comb begin
        imem_q_in.valid   = br_pred_out.valid;
        imem_q_in.br_pred = take_pred;
        imem_q_in.pc      = br_pred_out.pc;
        imem_q_in.pc_next = br_pred_out.pc + 3'd4;
        imem_q_in.instr   = br_pred_out.inst;
        imem_q_in.order   = br_pred_out.order;
        imem_q_in.br_pred_info = br_pred_out;

        //RVFI initialization
        imem_q_in.rvfi.valid = br_pred_out.valid;
        imem_q_in.rvfi.order = br_pred_out.order;
        imem_q_in.rvfi.inst = br_pred_out.inst;
        imem_q_in.rvfi.rs1_addr  = '0;
        imem_q_in.rvfi.rs2_addr  = '0;
        imem_q_in.rvfi.rs1_rdata = '0;
        imem_q_in.rvfi.rs2_rdata = '0;
        imem_q_in.rvfi.rd_addr   = '0;
        imem_q_in.rvfi.rd_wdata  = '0;
        imem_q_in.rvfi.pc_rdata  = br_pred_out.pc;
        imem_q_in.rvfi.pc_wdata  = br_pred_out.pc + 3'd4;

        imem_q_in.rvfi.mem_addr  = '0;
        imem_q_in.rvfi.mem_rmask = '0;
        imem_q_in.rvfi.mem_wmask = '0;
        imem_q_in.rvfi.mem_rdata = '0;
        imem_q_in.rvfi.mem_wdata = '0;
    end


    icache_w_adapter icache_w_adapter_i(
        .clk (clk),
        .rst (rst),

        // CPU side
        .ufp_addr    (pc_aligned),
        .ufp_rdata   (i_cache_rdata),
        .ufp_resp    (i_cache_resp),
        .linebuf_en  (linebuf_hit),
        .cache_set   (cache_set),
        .cache_tag   (cache_tag),

        // BRAM side (from BRAM)
        .bmem_rvalid (bmem_i_rvalid),
        .bmem_rdata  (bmem_i_rdata),
        .bmem_ready  (bmem_i_ready),

        // BRAM side (to mem_arbiter)
        .bmem_addr (bmem_i_addr),
        .bmem_read (bmem_i_read),
        .dfp_resp  (i_burst_done)
    );


    dcache_w_adapter dcache_w_adapter_i (
        .clk (clk),
        .rst (rst),

        // CPU side (to dcache)
        .ufp_addr  (d_cache_addr),  // from fu_mem
        .ufp_rmask (d_cache_rmask),
        .ufp_wmask (d_cache_wmask),
        .ufp_wdata (d_cache_wdata),

        // CPU side (from dcahce)
        .ufp_rdata (d_cache_rdata), // data read from cache, needs to be forwarded
        .ufp_resp  (d_cache_resp),  // dcache resp -> stall commit until this

        // BRAM side (to mem_arbiter)
        .bmem_addr  (bmem_d_addr),
        .bmem_read  (bmem_d_read),
        .bmem_write (bmem_d_write),
        .bmem_wdata (bmem_d_wdata),
        .dfp_resp   (d_burst_done),

        // BRAM side (to dcache)
        .bmem_rvalid (bmem_d_rvalid),
        .bmem_rdata  (bmem_d_rdata),
        .bmem_ready  (bmem_d_ready)
    );


    mem_arbiter mem_arbiter_i (
        .clk (clk),
        .rst (rst),

        // from icache
        .bmem_i_read (bmem_i_read),
        .bmem_i_addr (bmem_i_addr),

        // from icache_adapter
        .i_burst_done (i_burst_done),

        // to icache
        .bmem_i_ready  (bmem_i_ready),
        .bmem_i_rvalid (bmem_i_rvalid),
        .bmem_i_rdata  (bmem_i_rdata),

        // from dcache
        .bmem_d_read  (bmem_d_read),
        .bmem_d_write (bmem_d_write),
        .bmem_d_addr  (bmem_d_addr),
        .bmem_d_wdata (bmem_d_wdata),

        // from dcache adapter
        .d_burst_done (d_burst_done),

        // to dcache
        .bmem_d_ready  (bmem_d_ready),
        .bmem_d_rvalid (bmem_d_rvalid),
        .bmem_d_rdata  (bmem_d_rdata),

        // to memory
        .bmem_read  (bmem_read),
        .bmem_write (bmem_write),
        .bmem_addr  (bmem_addr),
        .bmem_wdata (bmem_wdata),

        // from memory
        .bmem_ready  (bmem_ready),
        .bmem_rvalid (bmem_rvalid),
        .bmem_raddr  (bmem_raddr),
        .bmem_rdata  (bmem_rdata)
    );


    queue_imem #(.HEIGHT(IMEM_Q_DEPTH)) imem_q (
        .clk(clk),
        .rst(rst),
        .flush(flush),
        .enq_en         (br_pred_out.valid && imem_q_space),
        .deq_en         (imem_q_ren),
        .din            (imem_q_in),
        .dout           (imem_q_out),
        .q_space_avail  (imem_q_space),
        .q_empty        (imem_q_empty)
    );


    decode decode_i (
        .order (imem_q_out.br_pred_info.order),
        .flush(flush),
        .imem_q_data  (imem_q_out),
        .rob_full     (~rob_space_avail),
        .rob_alloc    (rob_index),
        .rs1_regf     (rs1_out),
        .rs2_regf     (rs2_out),

        .rs1_sel      (rs1_sel),
        .rs2_sel      (rs2_sel),
        .can_rename   (can_rename),
        .rd_to_rename (rd_to_rename),
        .rob_tag      (rob_tag),
        .decode_out   (decode_out)
    );


    rob #(.DEPTH(ROB_DEPTH)) rob_i (
        .clk                (clk),
        .rst                (rst),
        .flush              (flush),
        .stall              (1'b0),                 //<- intentional hardcode
        .din                (decode_out),
        .enq_en             (imem_q_ren),
        .dout               (rob_out),
        // .inflight_rob_idx   (inflight_rob_idx),
        .rob_index          (rob_index),
        .rob_head_idx       (rob_head_idx),

        .cdb                (common_cdb),

        .q_space_avail      (rob_space_avail),
        .q_empty            (rob_empty)
    );


    regfile regfile_i (
        .clk(clk),
        .rst(rst),
        .flush(flush),

        // Signals From Disptach
        .rename_en      (imem_q_ren),
        .rd_to_rename   (rd_to_rename),
        .rename_rob_tag (rob_tag),

        // Singals From ROB (on commit)
        .commit_en      (rob_out.valid && ~rob_out.busy),
        .commit_rd      (rob_out.dispatch_info.rd),
        .commit_val     (rob_out.cdb_info.data),
        .commit_rob_tag (rob_out.cdb_info.rob_tag),

        // Operand Ports - these are used by the RSs
        .rs1_s          (rs1_sel),
        .rs2_s          (rs2_sel),
        .rs1_out        (rs1_out),
        .rs2_out        (rs2_out)
    );


    issue issue_i (
        .clk        (clk),
        .rst        (rst),
        .flush      (flush),

        .cdb                 (common_cdb),
        .forward_from_commit (rob_out),
        .inst_valid          (imem_q_ren),
        .inst_ready          (inst_ready),
        .inst_pkt            (decode_out),

        .alu_pkt    (alu_pkt),

        .mul_pkt    (mul_pkt),

        .div_busy   (div_busy),
        .div_start  (div_start),
        .div_pkt    (div_pkt),

        .br_pkt     (br_pkt),

        .mem_inst_ready    (mem_inst_ready)
    );


    split_lsq issue_mem_i (
        .clk   (clk),
        .rst   (rst),
        .flush (flush),

        .cdb                 (common_cdb),
        .rob_head_idx        (rob_head_idx),
        .forward_from_commit (rob_out),
        .inst_valid          (imem_q_ren),
        .mem_inst_ready      (mem_inst_ready),
        .inst_pkt            (decode_out),
        .backpressure        (backpressure),
        .mem_pkt             (mem_pkt)
    );


    priority_arbiter_cdb priority_arbiter_cdb_i (
        .clk   (clk),
        .rst   (rst),
        .flush (flush),

        .alu_fu_output (alu_out),
        .mul_fu_output (mul_out),
        .div_fu_output (div_out),
        .mem_fu_output (mem_out),
        .br_fu_output  (br_out),

        .alu_enq_en (alu_out.valid),
        .mul_enq_en (mul_out.valid),
        .div_enq_en (div_resp && div_busy),
        .mem_enq_en (mem_out.valid),
        .br_enq_en  (br_out.valid),

        .cdb_out (common_cdb)
    );


    fu_alu fu_alu_i (
        .alu_pkt_in (alu_pkt),
        .alu_out    (alu_out)
    );

    fu_mult_pipelined fu_mult_i (
        .clk             (clk),
        .rst             (rst),
        .flush           (flush),

        .mult_pkt_in     (mul_pkt),
        .mult_out        (mul_out)
    );


    fu_div fu_div_i (
        .clk            (clk),
        .rst            (rst),
        .stall          (1'b0),         //<- intentional hardcode cause we dont have a stall signal
        .flush          (flush),
        .div_en         (div_start),
        .div_pkt_in     (div_pkt),
        .div_out        (div_out),
        .div_busy       (div_busy),
        .div_resp_pulse (div_resp)
    );


    fu_br fu_br_i (
        .br_pkt_in (br_pkt),
        .br_out    (br_out)
    );


    fu_mem fu_mem_i (
        .clk   (clk),
        .rst   (rst),
        .flush (flush),

        .mem_pkt_in       (mem_pkt),
        .mem_out          (mem_out),
        .rdata            (d_cache_rdata),     // data read from cache
        .d_cache_resp     (d_cache_resp),

        // outputs to dcache
        .mem_addr    (d_cache_addr),
        .mem_rmask   (d_cache_rmask),
        .mem_wmask   (d_cache_wmask),
        .mem_wdata   (d_cache_wdata),
        .backpressure(backpressure)
    );


    // Stuff for proving cp1 works
    always_comb begin
        // Read if not empty
        if (flush) begin
            imem_q_ren = '0;
        end else begin
            imem_q_ren = !imem_q_empty && inst_ready && can_rename;
        end

        // Decouple pc_out and instruction
        pc_out = imem_q_out.pc;
        instr = imem_q_out.instr;
    end


    rvfi_t rvfi_out;
    always_comb begin
        commit_en = rob_out.valid && !rob_out.busy;
        take_target = rob_out.cdb_info.take_target;
        target_pc = rob_out.cdb_info.target_pc;
        flush = (rob_out.valid && !rob_out.busy) && take_target;
        rvfi_out = rob_out.rvfi;
        rvfi_out.order = rob_out.order;
        rvfi_out.valid = rob_out.valid && !rob_out.busy ;
    end


// Performance Counters
logic [63:0] flush_count;
logic [63:0] br_count;
logic [63:0] br_flush_count;
logic [63:0] jal_count;
logic [63:0] jal_flush_count;
logic [63:0] jalr_count;
logic [63:0] jalr_flush_count;
logic [63:0] multdiv_count;
always_ff @(posedge clk) begin
    if (rst) begin
        flush_count      <= '0;
        multdiv_count    <= '0;
        br_count         <= '0;
        br_flush_count   <= '0;
        jal_count        <= '0;
        jal_flush_count  <= '0;
        jalr_count       <= '0;
        jalr_flush_count <= '0;
    end else begin
        flush_count      <=  flush ? flush_count + 1'b1 : flush_count;
        br_count         <= (commit_en && rob_out.cdb_info.bj == IS_BR)   ? br_count         + 1'b1 : br_count;
        jal_count        <= (commit_en && rob_out.cdb_info.bj == IS_JAL)  ? jal_count        + 1'b1 : jal_count;
        jalr_count       <= (commit_en && rob_out.cdb_info.bj == IS_JALR) ? jalr_count       + 1'b1 : jalr_count;
        br_flush_count   <= (flush && rob_out.cdb_info.bj == IS_BR)       ? br_flush_count   + 1'b1 : br_flush_count;
        jal_flush_count  <= (flush && rob_out.cdb_info.bj == IS_JAL)      ? jal_flush_count  + 1'b1 : jal_flush_count;
        jalr_flush_count <= (flush && rob_out.cdb_info.bj == IS_JALR)     ? jalr_flush_count + 1'b1 : jalr_flush_count;
        multdiv_count    <= (commit_en && rob_out.dispatch_info.opcode == 7'b0110011) ? multdiv_count + 1'b1 : multdiv_count;
    end
  end

endmodule : cpu
