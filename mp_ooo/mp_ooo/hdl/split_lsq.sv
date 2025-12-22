module split_lsq
import types::*;
(
    input  logic             clk,
    input  logic             rst,
    input  logic             flush,

    input  cdb_t             cdb,
    input  rob_cell_t        forward_from_commit,
    input  logic [$clog2(ROB_DEPTH)-1:0] rob_head_idx,

    // Dispatch -> Issue
    input  logic             inst_valid,
    output logic             mem_inst_ready,
    input  decode_to_issue_t inst_pkt,
    input  logic             backpressure,

    // Issue -> MEM FU
    output  fu_pkt_t         mem_pkt
);

    logic want_store;
    logic want_load;

    logic mem_pkt_ready;

    rs_t store_queue [MEM_RS_DEPTH];
    rs_t load_rs [MEM_RS_DEPTH];

    localparam MEM_RS_HEIGHT = $clog2(MEM_RS_DEPTH);

    // Global mask
    logic [MEM_RS_DEPTH-1:0] global_mask; // Needs as many biits as Stores we can have in queue
    logic [MEM_RS_DEPTH-1:0] next_global_mask;

    // store signals
    logic   store_q_empty;
    logic   store_q_full;
    logic   store_enqueue;
    logic   store_dequeue;
    logic   store_entry_ready;
    logic [MEM_RS_HEIGHT:0] store_head;
    logic [MEM_RS_HEIGHT:0] store_tail;
    logic [MEM_RS_HEIGHT-1:0] store_tail_idx;

    // load signals
    logic load_has_space;
    logic load_entry_ready;
    logic load_enqueue;
    logic load_dequeue;
    logic [$clog2(MEM_RS_DEPTH)-1:0] load_free_idx;
    logic [$clog2(MEM_RS_DEPTH)-1:0] load_ready_idx;

    assign mem_pkt_ready = !backpressure;
    assign store_tail_idx = store_tail[MEM_RS_HEIGHT-1:0];
    assign store_q_empty = (store_head == store_tail);
    assign store_q_full = (store_head[MEM_RS_HEIGHT] != store_tail[MEM_RS_HEIGHT]) && (store_head[MEM_RS_HEIGHT-1 : 0] == store_tail[MEM_RS_HEIGHT-1 : 0]);

    always_comb begin
        mem_pkt = '0;

        //////// LOADS //////// 
        want_load  = (inst_pkt.funct_unit == to_mem && inst_pkt.ls == IS_LOAD);

        load_has_space   = '0;
        load_entry_ready = '0;
        load_enqueue     = '0;
        load_dequeue     = '0;
        load_free_idx    = '0;
        load_ready_idx   = '0;

        for (integer i = 0; i < MEM_RS_DEPTH; i++) begin
            if (!load_rs[i].valid && !load_has_space) begin
                load_has_space = 1'b1;
                load_free_idx  = mem_sus'(i);
            end
        end

        for (integer i = 0; i < MEM_RS_DEPTH; i++) begin
            logic load_op_ready;

            if (load_rs[i].use_imm) begin
                load_op_ready      = load_rs[i].valid && load_rs[i].rs1.valid;
            end else load_op_ready = load_rs[i].valid && load_rs[i].rs1.valid && load_rs[i].rs2.valid;

            if (!load_entry_ready && load_op_ready && (load_rs[i].lsq_mask == '0)) begin
                load_entry_ready = 1'b1;
                load_ready_idx   = mem_sus'(i);
            end
        end

        load_enqueue = inst_valid && want_load && load_has_space;
        load_dequeue = mem_pkt_ready && !store_dequeue && load_entry_ready;


        //////// STORES //////// 
        want_store = (inst_pkt.funct_unit == to_mem && inst_pkt.ls == IS_STORE);

        // finding free mem_rs entry
        store_entry_ready = store_queue[store_head[MEM_RS_HEIGHT-1:0]].valid && store_queue[store_head[MEM_RS_HEIGHT-1:0]].rs1.valid && store_queue[store_head[MEM_RS_HEIGHT-1:0]].rs2.valid && (store_queue[store_head[MEM_RS_HEIGHT-1:0]].rob_tag == rob_head_idx);

        // build mem entry to FU
        if (mem_pkt_ready) begin
            if (store_entry_ready) begin
                mem_pkt.valid      = 1'b1;
                mem_pkt.muldiv_op  = mul_op;
                mem_pkt.alu_op     = none_op;
                mem_pkt.br_op      = no_op;
                mem_pkt.mem_op     = store_queue[store_head[MEM_RS_HEIGHT-1:0]].mem_op;
                mem_pkt.rs1_v      = store_queue[store_head[MEM_RS_HEIGHT-1:0]].rs1.data;
                mem_pkt.rob_tag    = store_queue[store_head[MEM_RS_HEIGHT-1:0]].rob_tag;
                mem_pkt.rvfi       = store_queue[store_head[MEM_RS_HEIGHT-1:0]].rvfi;
                mem_pkt.offset     = store_queue[store_head[MEM_RS_HEIGHT-1:0]].imm;
                mem_pkt.bj         = store_queue[store_head[MEM_RS_HEIGHT-1:0]].bj;
                mem_pkt.pc         = store_queue[store_head[MEM_RS_HEIGHT-1:0]].pc;
                mem_pkt.br_pred    = store_queue[store_head[MEM_RS_HEIGHT-1:0]].br_pred;
                mem_pkt.ls         = store_queue[store_head[MEM_RS_HEIGHT-1:0]].ls;
                if (store_queue[store_head[MEM_RS_HEIGHT-1:0]].ls == IS_STORE) begin
                    mem_pkt.rs2_v = store_queue[store_head[MEM_RS_HEIGHT-1:0]].rs2.data;
                end else mem_pkt.rs2_v = '0;
            end else if (load_entry_ready) begin
                mem_pkt.valid      = 1'b1;
                mem_pkt.muldiv_op  = mul_op;
                mem_pkt.alu_op     = none_op;
                mem_pkt.br_op      = no_op;
                mem_pkt.mem_op     = load_rs[load_ready_idx].mem_op;
                mem_pkt.rs1_v      = load_rs[load_ready_idx].rs1.data;
                mem_pkt.rob_tag    = load_rs[load_ready_idx].rob_tag;
                mem_pkt.rvfi       = load_rs[load_ready_idx].rvfi;
                mem_pkt.offset     = load_rs[load_ready_idx].imm;
                mem_pkt.bj         = load_rs[load_ready_idx].bj;
                mem_pkt.pc         = load_rs[load_ready_idx].pc;
                mem_pkt.br_pred    = load_rs[load_ready_idx].br_pred;
                mem_pkt.ls         = load_rs[load_ready_idx].ls;
            end
        end

        // backpressure to imem_q
        mem_inst_ready = (want_store && !store_q_full) || (want_load && load_has_space);

        // mem rs control
        store_enqueue  = inst_valid      && want_store && !store_q_full;
        store_dequeue  = mem_pkt_ready && store_entry_ready && !store_q_empty;

        // Global Mask updates
        next_global_mask = global_mask;
        if (store_dequeue) begin
            next_global_mask[store_queue[store_head[MEM_RS_HEIGHT-1:0]].lsq_one_hot_idx] = 1'b0;
        end

        if (store_enqueue) begin
            next_global_mask[store_tail_idx] = 1'b1;
        end

    end

    always_ff @(posedge clk) begin
        if (rst) begin
            store_head <= '0;
            store_tail <= '0;
            global_mask <= '0;
            for (integer i = 0; i < MEM_RS_DEPTH; i++) load_rs[i].valid <= '0;
            for (integer i = 0; i < MEM_RS_DEPTH; i++) store_queue[i].valid <= '0;
        end else if (flush) begin
            store_head <= '0;
            store_tail <= '0;
            global_mask <= '0;
            for (integer i = 0; i < MEM_RS_DEPTH; i++) load_rs[i].valid <= '0;
            for (integer i = 0; i < MEM_RS_DEPTH; i++) store_queue[i].valid <= '0;
        end else begin
            global_mask <= next_global_mask;

            store_head <= (store_dequeue) ? (store_head + 1'b1) : store_head;
            store_tail <= (store_enqueue) ? (store_tail + 1'b1) : store_tail;

            // forwarding commited values
            if (forward_from_commit.valid && !forward_from_commit.busy) begin
                // store forward
                for (integer i = 0; i < MEM_RS_DEPTH; i++) begin
                    if (store_queue[i].valid) begin
                        // rs1 wakeup
                        if (!store_queue[i].rs1.valid && store_queue[i].rs1.rob_tag == forward_from_commit.cdb_info.rob_tag) begin
                            store_queue[i].rs1.valid <= 1'b1;
                            store_queue[i].rs1.data  <= forward_from_commit.cdb_info.data;
                        end
                        // rs2 wakeup
                        if (!store_queue[i].rs2.valid && store_queue[i].rs2.rob_tag == forward_from_commit.cdb_info.rob_tag) begin
                            store_queue[i].rs2.valid <= 1'b1;
                            store_queue[i].rs2.data  <= forward_from_commit.cdb_info.data;
                        end
                    end
                end
                // load forward
                for (integer i = 0; i < MEM_RS_DEPTH; i++) begin
                    if (load_rs[i].valid) begin
                        // rs1 wakeup
                        if (!load_rs[i].rs1.valid && load_rs[i].rs1.rob_tag == forward_from_commit.cdb_info.rob_tag) begin
                            load_rs[i].rs1.valid <= 1'b1;
                            load_rs[i].rs1.data  <= forward_from_commit.cdb_info.data;
                        end
                        // rs2 wakeup
                        if (!load_rs[i].rs2.valid && load_rs[i].rs2.rob_tag == forward_from_commit.cdb_info.rob_tag) begin
                            load_rs[i].rs2.valid <= 1'b1;
                            load_rs[i].rs2.data  <= forward_from_commit.cdb_info.data;
                        end
                    end
                end
            end

            // cdb wakeup
            if (cdb.valid) begin
                // store wakeup
                for (integer i = 0; i < MEM_RS_DEPTH; i++) begin
                    if (store_queue[i].valid) begin
                        // rs1 wakeup
                        if (!store_queue[i].rs1.valid && store_queue[i].rs1.rob_tag == cdb.rob_tag) begin
                            store_queue[i].rs1.valid <= 1'b1;
                            store_queue[i].rs1.data  <= cdb.data;
                        end
                        // rs2 wakeup
                        if (!store_queue[i].rs2.valid && store_queue[i].rs2.rob_tag == cdb.rob_tag) begin
                            store_queue[i].rs2.valid <= 1'b1;
                            store_queue[i].rs2.data  <= cdb.data;
                        end
                    end
                end
                // load wakeup
                for (integer i = 0; i < MEM_RS_DEPTH; i++) begin
                    if (load_rs[i].valid) begin
                        // rs1 wakeup
                        if (!load_rs[i].rs1.valid && load_rs[i].rs1.rob_tag == cdb.rob_tag) begin
                            load_rs[i].rs1.valid <= 1'b1;
                            load_rs[i].rs1.data  <= cdb.data;
                        end
                        // rs2 wakeup
                        if (!load_rs[i].rs2.valid && load_rs[i].rs2.rob_tag == cdb.rob_tag) begin
                            load_rs[i].rs2.valid <= 1'b1;
                            load_rs[i].rs2.data  <= cdb.data;
                        end
                    end
                end
            end


            // RS dequeue logic
            if (store_dequeue) begin
                store_queue[store_head[MEM_RS_HEIGHT-1:0]].valid <= '0;
                // Update load masks
                for (integer i = 0; i < MEM_RS_DEPTH; i++) begin
                    if (load_rs[i].valid) begin
                        load_rs[i].lsq_mask[store_queue[store_head[MEM_RS_HEIGHT-1:0]].lsq_one_hot_idx] <= 1'b0;
                    end
                end
            end

            if (load_dequeue) begin
                load_rs[load_ready_idx].valid <= '0;
            end

            // RS enqueue logic
            if (store_enqueue) begin
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].valid      <= 1'b1;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].fu_sel     <= inst_pkt.funct_unit;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].muldiv_op  <= inst_pkt.multop;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].alu_op     <= inst_pkt.aluop;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].br_op      <= inst_pkt.brop;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].mem_op     <= inst_pkt.memop;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].rs1        <= inst_pkt.rs1;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].rs2        <= inst_pkt.rs2;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].rob_tag    <= inst_pkt.rob_tag;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].imm        <= inst_pkt.imm;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].use_imm    <= inst_pkt.use_imm;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].bj         <= inst_pkt.bj;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].br_pred    <= inst_pkt.br_pred;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].pc         <= inst_pkt.pc;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].ls         <= inst_pkt.ls;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].lsq_mask   <= 8'b1 << store_tail_idx;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].lsq_one_hot_idx <= store_tail_idx;
                store_queue[store_tail[MEM_RS_HEIGHT-1:0]].rvfi       <= inst_pkt.rvfi;
            end

            if (load_enqueue) begin
                load_rs[load_free_idx].valid      <= 1'b1;
                load_rs[load_free_idx].fu_sel     <= inst_pkt.funct_unit;
                load_rs[load_free_idx].muldiv_op  <= inst_pkt.multop;
                load_rs[load_free_idx].alu_op     <= inst_pkt.aluop;
                load_rs[load_free_idx].br_op      <= inst_pkt.brop;
                load_rs[load_free_idx].mem_op     <= inst_pkt.memop;
                load_rs[load_free_idx].rs1        <= inst_pkt.rs1;
                load_rs[load_free_idx].rs2        <= inst_pkt.rs2;
                load_rs[load_free_idx].rob_tag    <= inst_pkt.rob_tag;
                load_rs[load_free_idx].imm        <= inst_pkt.imm;
                load_rs[load_free_idx].use_imm    <= inst_pkt.use_imm;
                load_rs[load_free_idx].bj         <= inst_pkt.bj;
                load_rs[load_free_idx].br_pred    <= inst_pkt.br_pred;
                load_rs[load_free_idx].pc         <= inst_pkt.pc;
                load_rs[load_free_idx].ls         <= inst_pkt.ls;
                load_rs[load_free_idx].lsq_one_hot_idx <= '0;
                load_rs[load_free_idx].lsq_mask   <= next_global_mask;
                load_rs[load_free_idx].rvfi       <= inst_pkt.rvfi;
            end
        end
    end

endmodule