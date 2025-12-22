module issue_mem
import types::*;
(
    input  logic             clk,
    input  logic             rst,
    input  logic             flush,

    input  cdb_t             cdb,
    input  rob_cell_t        forward_from_commit,

    // Dispatch -> Issue
    input  logic             inst_valid,
    output logic             mem_inst_ready,
    input  decode_to_issue_t inst_pkt,
    input  logic             backpressure,

    // Issue -> MEM FU
    output  fu_pkt_t         mem_pkt
);

    logic want_mem;
    rs_t mem_rs [MEM_RS_DEPTH];
    localparam MEM_RS_HEIGHT = $clog2(MEM_RS_DEPTH);

    // free slot signals
    logic [MEM_RS_HEIGHT:0] head, tail;

    // control signals
    logic   empty;
    logic   full;
    logic   mem_enqueue;
    logic   mem_dequeue;
    logic   mem_entry_ready;
    assign empty = (head == tail);
    assign full = (head[MEM_RS_HEIGHT] != tail[MEM_RS_HEIGHT]) && (head[MEM_RS_HEIGHT-1 : 0] == tail[MEM_RS_HEIGHT-1 : 0]);

    // fu_pkt_t mem_pkt;


    always_comb begin
        mem_pkt = '0;
        want_mem = (inst_pkt.funct_unit ==  to_mem);

        // MEM initialization
        mem_entry_ready = mem_rs[head[MEM_RS_HEIGHT-1:0]].valid &&
                          mem_rs[head[MEM_RS_HEIGHT-1:0]].rs1.valid &&
                          (mem_rs[head[MEM_RS_HEIGHT-1:0]].ls == IS_STORE ? mem_rs[head[MEM_RS_HEIGHT-1:0]].rs2.valid : 1'b1);

        // finding free mem_rs entry

        // only the head of the FIFO (LSQ) may issue
        // default: not ready

        // build mem entry to FU
        if (mem_entry_ready && !backpressure) begin
            mem_pkt = '0;
            mem_pkt.valid      = 1'b1;
            mem_pkt.mem_op     = mem_rs[head[MEM_RS_HEIGHT-1:0]].mem_op;
            mem_pkt.rs1_v      = mem_rs[head[MEM_RS_HEIGHT-1:0]].rs1.data;
            mem_pkt.rob_tag    = mem_rs[head[MEM_RS_HEIGHT-1:0]].rob_tag;
            mem_pkt.rvfi       = mem_rs[head[MEM_RS_HEIGHT-1:0]].rvfi;
            mem_pkt.offset     = mem_rs[head[MEM_RS_HEIGHT-1:0]].imm;
            mem_pkt.pc         = mem_rs[head[MEM_RS_HEIGHT-1:0]].pc;
            mem_pkt.ls         = mem_rs[head[MEM_RS_HEIGHT-1:0]].ls;
            if (mem_rs[head[MEM_RS_HEIGHT-1:0]].ls == IS_STORE) begin
                mem_pkt.rs2_v = mem_rs[head[MEM_RS_HEIGHT-1:0]].rs2.data;
            end else mem_pkt.rs2_v = '0;
        end

        // backpressure to imem_q
        mem_inst_ready = (want_mem && !full);

        // mem rs control
        mem_enqueue  = inst_valid      && want_mem && !full;
        mem_dequeue  = mem_entry_ready && !empty   && !backpressure;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            for (integer i = 0; i < MEM_RS_DEPTH; i++) begin
                mem_rs[i] <= '0;
            end
            head <= '0;
            tail <= '0;
        end else if (flush) begin
            head <= '0;
            tail <= '0;
            for (integer i = 0; i < MEM_RS_DEPTH; i++) begin
                mem_rs[i].valid <= '0;
            end
        end else begin
            head <= (mem_dequeue) ? (head + 1'b1) : head;
            tail <= (mem_enqueue) ? (tail + 1'b1) : tail;
            // && (forward_from_commit.cdb_info.bj != IS_BR)) begin
            // forwarding commited values
            if (forward_from_commit.valid && !forward_from_commit.busy && (forward_from_commit.cdb_info.bj != IS_BR)) begin
                // mem forward
                for (integer i = 0; i < MEM_RS_DEPTH; i++) begin
                    if (mem_rs[i].valid) begin
                        // rs1 wakeup
                        if (!mem_rs[i].rs1.valid && mem_rs[i].rs1.rob_tag == forward_from_commit.cdb_info.rob_tag) begin
                            mem_rs[i].rs1.valid <= 1'b1;
                            mem_rs[i].rs1.data  <= forward_from_commit.cdb_info.data;
                        end
                        // rs2 wakeup
                        if (!mem_rs[i].rs2.valid && mem_rs[i].rs2.rob_tag == forward_from_commit.cdb_info.rob_tag) begin
                            mem_rs[i].rs2.valid <= 1'b1;
                            mem_rs[i].rs2.data  <= forward_from_commit.cdb_info.data;
                        end
                    end
                end
            end

            // cdb wakeup
            if (cdb.valid) begin
                // mem wakeup
                for (integer i = 0; i < MEM_RS_DEPTH; i++) begin
                    if (mem_rs[i].valid) begin
                        // rs1 wakeup
                        if (!mem_rs[i].rs1.valid && mem_rs[i].rs1.rob_tag == cdb.rob_tag) begin
                            mem_rs[i].rs1.valid <= 1'b1;
                            mem_rs[i].rs1.data  <= cdb.data;
                        end
                        // rs2 wakeup
                        if (!mem_rs[i].rs2.valid && mem_rs[i].rs2.rob_tag == cdb.rob_tag) begin
                            mem_rs[i].rs2.valid <= 1'b1;
                            mem_rs[i].rs2.data  <= cdb.data;
                        end
                    end
                end
            end


            // RS dequeue logic
            if (mem_dequeue) begin
                mem_rs[head[MEM_RS_HEIGHT-1:0]].valid <= '0;
            end

            // RS enqueue logic
            if (mem_enqueue) begin
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].valid      <= 1'b1;
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].fu_sel     <= inst_pkt.funct_unit;
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].muldiv_op  <= inst_pkt.multop;
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].alu_op     <= inst_pkt.aluop;
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].br_op      <= inst_pkt.brop;
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].mem_op     <= inst_pkt.memop;
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].rs1        <= inst_pkt.rs1;
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].rs2        <= inst_pkt.rs2;
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].rob_tag    <= inst_pkt.rob_tag;
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].imm        <= inst_pkt.imm;
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].use_imm    <= inst_pkt.use_imm;
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].bj         <= inst_pkt.bj;
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].br_pred    <= inst_pkt.br_pred;
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].pc         <= inst_pkt.pc;
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].ls         <= inst_pkt.ls;
                mem_rs[tail[MEM_RS_HEIGHT-1:0]].rvfi       <= inst_pkt.rvfi;
            end
        end
    end

endmodule
