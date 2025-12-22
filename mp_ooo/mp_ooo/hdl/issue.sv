module issue
import types::*;
(
    input  logic             clk,
    input  logic             rst,
    input  logic             flush,

    input  cdb_t             cdb,
    input  rob_cell_t        forward_from_commit,

    // Dispatch -> Issue
    input  logic             inst_valid,
    output logic             inst_ready,
    input  decode_to_issue_t inst_pkt,

    // Issue -> ALU FU
    output  fu_pkt_t          alu_pkt,

    // Issue -> MUL FU
    output  fu_pkt_t         mul_pkt,

    // Issue -> DIV FU
    input   logic            div_busy,
    output  logic            div_start,
    output  fu_pkt_t         div_pkt,

    // Issue -> BR FU
    output  fu_pkt_t         br_pkt,

    // Issue -> MEM FU
    input  logic             mem_inst_ready
);

    logic want_alu;
    logic want_mul;
    logic want_div;
    logic want_br;

    rs_t alu_rs [ALU_RS_DEPTH];
    rs_t mul_rs [MUL_RS_DEPTH];
    rs_t div_rs [DIV_RS_DEPTH];
    rs_t br_rs  [ BR_RS_DEPTH];

    // free slot signals
    logic [$clog2(ALU_RS_DEPTH)-1:0] alu_free_idx;
    logic                            alu_has_space;

    logic [$clog2(MUL_RS_DEPTH)-1:0] mul_free_idx;
    logic                            mul_has_space;

    logic [$clog2(DIV_RS_DEPTH)-1:0] div_free_idx;
    logic                            div_has_space;

    logic [$clog2( BR_RS_DEPTH)-1:0] br_free_idx;
    logic                            br_has_space;

    // ready-to-issue signals
    logic [$clog2(ALU_RS_DEPTH)-1:0] alu_ready_idx;
    logic                            alu_entry_ready;

    logic [$clog2(MUL_RS_DEPTH)-1:0] mul_ready_idx;
    logic                            mul_entry_ready;

    logic [$clog2(DIV_RS_DEPTH)-1:0] div_ready_idx;
    logic                            div_entry_ready;

    logic [$clog2( BR_RS_DEPTH)-1:0] br_ready_idx;
    logic                            br_entry_ready;

    // control signals
    logic   alu_enqueue;
    logic   alu_dequeue;

    logic   mul_enqueue;
    logic   mul_dequeue;

    logic   div_enqueue;
    logic   div_dequeue;

    logic   br_enqueue;
    logic   br_dequeue;

    // registered outputs
    fu_pkt_t alu_pkt_next;
    fu_pkt_t mul_pkt_next;
    fu_pkt_t div_pkt_next;
    fu_pkt_t  br_pkt_next;

    always_comb begin

        want_alu = (inst_pkt.funct_unit == to_alu);
        want_mul = (inst_pkt.funct_unit == to_mul);
        want_div = (inst_pkt.funct_unit == to_div);
        want_br  = (inst_pkt.funct_unit ==  to_br);

        // ALU initialization
        alu_has_space   = '0;
        alu_free_idx    = '0;
        alu_entry_ready = '0;
        alu_ready_idx   = '0;
        alu_pkt_next = '0;
        // MUL initialization
        mul_has_space   = '0;
        mul_free_idx    = '0;
        mul_entry_ready = '0;
        mul_ready_idx   = '0;
        mul_pkt_next = '0;
        // DIV initialization
        div_has_space   = '0;
        div_free_idx    = '0;
        div_entry_ready = '0;
        div_ready_idx   = '0;
        div_pkt_next = '0;
        // BR initialization
        br_has_space    = '0;
        br_free_idx     = '0;
        br_entry_ready  = '0;
        br_ready_idx    = '0;
        br_pkt_next = '0;
        // finding free alu_rs entry
        for (integer i = 0; i < ALU_RS_DEPTH; i++) begin
            if (!alu_rs[i].valid && !alu_has_space) begin
                alu_has_space = 1'b1;
                alu_free_idx  = alu_sus'(i);
            end
        end

        // finding free mul_rs entry
        for (integer i = 0; i < MUL_RS_DEPTH; i++) begin
            if (!mul_rs[i].valid && !mul_has_space) begin
                mul_has_space = 1'b1;
                mul_free_idx  = mul_sus'(i);
            end
        end

        // finding free div_rs entry
        for (integer i = 0; i < DIV_RS_DEPTH; i++) begin
            if (!div_rs[i].valid && !div_has_space) begin
                div_has_space = 1'b1;
                div_free_idx  = div_sus'(i);
            end
        end


        // finding free br_rs entry
        for (integer i = 0; i < BR_RS_DEPTH; i++) begin
            if (!br_rs[i].valid && !br_has_space) begin
                br_has_space = 1'b1;
                br_free_idx  = br_sus'(i);
            end
        end

        // Finding alu_rs entry to issue
        for (integer i = 0; i < ALU_RS_DEPTH; i++) begin
            logic alu_op_ready;

            if (alu_rs[i].use_imm) begin
                alu_op_ready      = alu_rs[i].valid && alu_rs[i].rs1.valid;
            end else alu_op_ready = alu_rs[i].valid && alu_rs[i].rs1.valid && alu_rs[i].rs2.valid;

            if (!alu_entry_ready && alu_op_ready) begin
                alu_entry_ready = 1'b1;
                alu_ready_idx   = alu_sus'(i);
            end
        end

        // Finding mul_rs entry to issue
        for (integer i = 0; i < MUL_RS_DEPTH; i++) begin
            logic mul_op_ready;

            if (mul_rs[i].use_imm) begin
                mul_op_ready      = mul_rs[i].valid && mul_rs[i].rs1.valid;
            end else mul_op_ready = mul_rs[i].valid && mul_rs[i].rs1.valid && mul_rs[i].rs2.valid;

            if (!mul_entry_ready && mul_op_ready) begin
                mul_entry_ready = 1'b1;
                mul_ready_idx   = mul_sus'(i);
            end
        end

        // Finding div_rs entry to issue
        for (integer i = 0; i < DIV_RS_DEPTH; i++) begin
            logic div_op_ready;

            if (div_rs[i].use_imm) begin
                div_op_ready      = div_rs[i].valid && div_rs[i].rs1.valid;
            end else div_op_ready = div_rs[i].valid && div_rs[i].rs1.valid && div_rs[i].rs2.valid;

            if (!div_entry_ready && div_op_ready) begin
                div_entry_ready = 1'b1;
                div_ready_idx   = div_sus'(i);
            end
        end

        // Finding br_rs entry to issue
        for (integer i = 0; i < BR_RS_DEPTH; i++) begin
            logic br_op_ready;

            if (br_rs[i].use_imm) begin
                br_op_ready      = br_rs[i].valid && br_rs[i].rs1.valid;
            end else br_op_ready = br_rs[i].valid && br_rs[i].rs1.valid && br_rs[i].rs2.valid;

            if (!br_entry_ready && br_op_ready) begin
                br_entry_ready = 1'b1;
                br_ready_idx   = br_sus'(i);
            end
        end

        // build alu entry to FU
        if (alu_entry_ready) begin
            alu_pkt_next = '0;
            alu_pkt_next.valid      = 1'b1;
            alu_pkt_next.alu_op     = alu_rs[alu_ready_idx].alu_op;
            alu_pkt_next.pc     = alu_rs[alu_ready_idx].pc;
            alu_pkt_next.rs1_v      = alu_rs[alu_ready_idx].rs1.data;
            alu_pkt_next.rob_tag    = alu_rs[alu_ready_idx].rob_tag;
            alu_pkt_next.rvfi       = alu_rs[alu_ready_idx].rvfi;
            alu_pkt_next.offset     = alu_rs[alu_ready_idx].imm;

            if (alu_rs[alu_ready_idx].use_imm) begin
                alu_pkt_next.rs2_v = alu_rs[alu_ready_idx].imm;
            end else alu_pkt_next.rs2_v = alu_rs[alu_ready_idx].rs2.data;
        end

        // build mul entry to FU
        if (mul_entry_ready) begin
            mul_pkt_next = '0;
            mul_pkt_next.valid      = 1'b1;
            mul_pkt_next.muldiv_op  = mul_rs[mul_ready_idx].muldiv_op;
            mul_pkt_next.rs1_v      = mul_rs[mul_ready_idx].rs1.data;
            mul_pkt_next.rob_tag    = mul_rs[mul_ready_idx].rob_tag;
            mul_pkt_next.rvfi       = mul_rs[mul_ready_idx].rvfi;
            if (mul_rs[mul_ready_idx].use_imm) begin
                mul_pkt_next.rs2_v = mul_rs[mul_ready_idx].imm;
            end else mul_pkt_next.rs2_v = mul_rs[mul_ready_idx].rs2.data;
        end

        // build div entry to FU
        if (div_entry_ready) begin
            div_pkt_next = '0;
            div_pkt_next.valid      = 1'b1;
            div_pkt_next.muldiv_op  = div_rs[div_ready_idx].muldiv_op;
            div_pkt_next.rs1_v      = div_rs[div_ready_idx].rs1.data;
            div_pkt_next.rob_tag    = div_rs[div_ready_idx].rob_tag;
            div_pkt_next.rvfi       = div_rs[div_ready_idx].rvfi;

            if (div_rs[div_ready_idx].use_imm) begin
                div_pkt_next.rs2_v = div_rs[div_ready_idx].imm;
            end else div_pkt_next.rs2_v = div_rs[div_ready_idx].rs2.data;
        end

        // build br entry to FU
        if (br_entry_ready) begin
            br_pkt_next = '0;
            br_pkt_next.valid      = 1'b1;
            br_pkt_next.br_op      = br_rs[br_ready_idx].br_op;
            br_pkt_next.rs1_v      = br_rs[br_ready_idx].rs1.data;
            br_pkt_next.rs2_v      = br_rs[br_ready_idx].rs2.data;
            br_pkt_next.rob_tag    = br_rs[br_ready_idx].rob_tag;
            br_pkt_next.rvfi       = br_rs[br_ready_idx].rvfi;
            br_pkt_next.offset     = br_rs[br_ready_idx].imm;
            br_pkt_next.bj         = br_rs[br_ready_idx].bj;
            br_pkt_next.pc         = br_rs[br_ready_idx].pc;
            br_pkt_next.br_pred    = br_rs[br_ready_idx].br_pred;
        end

        // alu rs control
        alu_enqueue  = inst_valid && inst_ready && want_alu;
        alu_dequeue  = alu_entry_ready;


        // mul rs control
        mul_enqueue  = inst_valid && inst_ready && want_mul;
        mul_dequeue  = mul_entry_ready;


        // div rs control
        div_enqueue  = inst_valid && inst_ready && want_div;
        div_dequeue  = div_entry_ready && !div_busy;

        if (div_dequeue) begin
            div_start = 1'b1;
        end else begin
            div_start = 1'b0;
        end

        div_pkt = div_pkt_next;

        // br rs control
        br_enqueue  = inst_valid && inst_ready && want_br;
        br_dequeue  = br_entry_ready;

        // backpressure to imem_q
        inst_ready = (want_alu && alu_has_space) || (want_mul && mul_has_space)
         || (want_div && div_has_space) || (want_br && br_has_space) || (mem_inst_ready);
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            alu_pkt   <= '0;
            br_pkt    <= '0;
            mul_pkt   <= '0;
            for (integer i = 0; i < ALU_RS_DEPTH; i++) alu_rs[i].valid <= '0;
            for (integer i = 0; i < MUL_RS_DEPTH; i++) mul_rs[i].valid <= '0;
            for (integer i = 0; i < DIV_RS_DEPTH; i++) div_rs[i].valid <= '0;
            for (integer i = 0; i <  BR_RS_DEPTH; i++)  br_rs[i].valid <= '0;
        end else if(flush) begin
            alu_pkt.valid   <= '0;
            br_pkt.valid    <= '0;
            mul_pkt.valid   <= '0;
            for (integer i = 0; i < ALU_RS_DEPTH; i++) alu_rs[i].valid <= '0;
            for (integer i = 0; i < MUL_RS_DEPTH; i++) mul_rs[i].valid <= '0;
            for (integer i = 0; i < DIV_RS_DEPTH; i++) div_rs[i].valid <= '0;
            for (integer i = 0; i <  BR_RS_DEPTH; i++)  br_rs[i].valid <= '0;

        end else begin
            if (alu_entry_ready) begin
                alu_pkt <= alu_pkt_next;
            end else begin
                alu_pkt.valid <= 1'b0;
            end

            if (br_entry_ready) begin
                br_pkt <= br_pkt_next;
            end else begin
                br_pkt.valid <= 1'b0;
            end

            if(mul_entry_ready) begin
                mul_pkt   <= mul_pkt_next;
            end else begin
                mul_pkt.valid <= 1'b0;
            end

            // alu_pkt   <= alu_pkt_next;
            // mul_pkt   <= mul_pkt_next;
            // div_pkt   <= div_pkt_next;
            // br_pkt    <=  br_pkt_next;
            // && (forward_from_commit.cdb_info.bj != IS_BR)) begin
            // forwarding commited values
            if (forward_from_commit.valid && !forward_from_commit.busy && (forward_from_commit.cdb_info.bj != IS_BR)) begin
                // alu forward
                for (integer i = 0; i < ALU_RS_DEPTH; i++) begin
                    if (alu_rs[i].valid) begin
                        // rs1 wakeup
                        if (!alu_rs[i].rs1.valid && alu_rs[i].rs1.rob_tag == forward_from_commit.cdb_info.rob_tag) begin
                            alu_rs[i].rs1.valid <= 1'b1;
                            alu_rs[i].rs1.data  <= forward_from_commit.cdb_info.data;
                        end
                        // rs2 wakeup
                        if (!alu_rs[i].rs2.valid && alu_rs[i].rs2.rob_tag == forward_from_commit.cdb_info.rob_tag) begin
                            alu_rs[i].rs2.valid <= 1'b1;
                            alu_rs[i].rs2.data  <= forward_from_commit.cdb_info.data;
                        end
                    end
                end
                // mul forward
                for (integer i = 0; i < MUL_RS_DEPTH; i++) begin
                    if (mul_rs[i].valid) begin
                        // rs1 wakeup
                        if (!mul_rs[i].rs1.valid && mul_rs[i].rs1.rob_tag == forward_from_commit.cdb_info.rob_tag) begin
                            mul_rs[i].rs1.valid <= 1'b1;
                            mul_rs[i].rs1.data  <= forward_from_commit.cdb_info.data;
                        end
                        // rs2 wakeup
                        if (!mul_rs[i].rs2.valid && mul_rs[i].rs2.rob_tag == forward_from_commit.cdb_info.rob_tag) begin
                            mul_rs[i].rs2.valid <= 1'b1;
                            mul_rs[i].rs2.data  <= forward_from_commit.cdb_info.data;
                        end
                    end
                end
                // div forward
                for (integer i = 0; i < DIV_RS_DEPTH; i++) begin
                    if (div_rs[i].valid) begin
                        // rs1 wakeup
                        if (!div_rs[i].rs1.valid && div_rs[i].rs1.rob_tag == forward_from_commit.cdb_info.rob_tag) begin
                            div_rs[i].rs1.valid <= 1'b1;
                            div_rs[i].rs1.data  <= forward_from_commit.cdb_info.data;
                        end
                        // rs2 wakeup
                        if (!div_rs[i].rs2.valid && div_rs[i].rs2.rob_tag == forward_from_commit.cdb_info.rob_tag) begin
                            div_rs[i].rs2.valid <= 1'b1;
                            div_rs[i].rs2.data  <= forward_from_commit.cdb_info.data;
                        end
                    end
                end
                // br forward
                for (integer i = 0; i < BR_RS_DEPTH; i++) begin
                    if (br_rs[i].valid) begin
                        // rs1 wakeup
                        if (!br_rs[i].rs1.valid && br_rs[i].rs1.rob_tag == forward_from_commit.cdb_info.rob_tag) begin
                            br_rs[i].rs1.valid <= 1'b1;
                            br_rs[i].rs1.data  <= forward_from_commit.cdb_info.data;
                        end
                        // rs2 wakeup
                        if (!br_rs[i].rs2.valid && br_rs[i].rs2.rob_tag == forward_from_commit.cdb_info.rob_tag) begin
                            br_rs[i].rs2.valid <= 1'b1;
                            br_rs[i].rs2.data  <= forward_from_commit.cdb_info.data;
                        end
                    end
                end
            end


            // cdb wakeup
            if (cdb.valid) begin
                // alu wakeup
                for (integer i = 0; i < ALU_RS_DEPTH; i++) begin
                    if (alu_rs[i].valid) begin
                        // rs1 wakeup
                        if (!alu_rs[i].rs1.valid && alu_rs[i].rs1.rob_tag == cdb.rob_tag) begin
                            alu_rs[i].rs1.valid <= 1'b1;
                            alu_rs[i].rs1.data  <= cdb.data;
                        end
                        // rs2 wakeup
                        if (!alu_rs[i].rs2.valid && alu_rs[i].rs2.rob_tag == cdb.rob_tag) begin
                            alu_rs[i].rs2.valid <= 1'b1;
                            alu_rs[i].rs2.data  <= cdb.data;
                        end
                    end
                end
                // mul wakeup
                for (integer i = 0; i < MUL_RS_DEPTH; i++) begin
                    if (mul_rs[i].valid) begin
                        // rs1 wakeup
                        if (!mul_rs[i].rs1.valid && mul_rs[i].rs1.rob_tag == cdb.rob_tag) begin
                            mul_rs[i].rs1.valid <= 1'b1;
                            mul_rs[i].rs1.data  <= cdb.data;
                        end
                        // rs2 wakeup
                        if (!mul_rs[i].rs2.valid && mul_rs[i].rs2.rob_tag == cdb.rob_tag) begin
                            mul_rs[i].rs2.valid <= 1'b1;
                            mul_rs[i].rs2.data  <= cdb.data;
                        end
                    end
                end
                // div wakeup
                for (integer i = 0; i < DIV_RS_DEPTH; i++) begin
                    if (div_rs[i].valid) begin
                        // rs1 wakeup
                        if (!div_rs[i].rs1.valid && div_rs[i].rs1.rob_tag == cdb.rob_tag) begin
                            div_rs[i].rs1.valid <= 1'b1;
                            div_rs[i].rs1.data  <= cdb.data;
                        end
                        // rs2 wakeup
                        if (!div_rs[i].rs2.valid && div_rs[i].rs2.rob_tag == cdb.rob_tag) begin
                            div_rs[i].rs2.valid <= 1'b1;
                            div_rs[i].rs2.data  <= cdb.data;
                        end
                    end
                end
                // br wakeup
                for (integer i = 0; i < BR_RS_DEPTH; i++) begin
                    if (br_rs[i].valid) begin
                        // rs1 wakeup
                        if (!br_rs[i].rs1.valid && br_rs[i].rs1.rob_tag == cdb.rob_tag) begin
                            br_rs[i].rs1.valid <= 1'b1;
                            br_rs[i].rs1.data  <= cdb.data;
                        end
                        // rs2 wakeup
                        if (!br_rs[i].rs2.valid && br_rs[i].rs2.rob_tag == cdb.rob_tag) begin
                            br_rs[i].rs2.valid <= 1'b1;
                            br_rs[i].rs2.data  <= cdb.data;
                        end
                    end
                end
            end



            // RS dequeue logic
            if (alu_dequeue) alu_rs[alu_ready_idx].valid <= '0;
            if (mul_dequeue) mul_rs[mul_ready_idx].valid <= '0;
            if (div_dequeue) div_rs[div_ready_idx].valid <= '0;
            if (br_dequeue)   br_rs[ br_ready_idx].valid <= '0;

            // RS enqueue logic
            if (alu_enqueue) begin
                alu_rs[alu_free_idx]      <= '0;
                alu_rs[alu_free_idx].valid      <= 1'b1;
                alu_rs[alu_free_idx].fu_sel     <= inst_pkt.funct_unit;
                alu_rs[alu_free_idx].muldiv_op  <= inst_pkt.multop;
                alu_rs[alu_free_idx].alu_op     <= inst_pkt.aluop;
                alu_rs[alu_free_idx].br_op      <= inst_pkt.brop;
                alu_rs[alu_free_idx].mem_op     <= inst_pkt.memop;
                alu_rs[alu_free_idx].rs1        <= inst_pkt.rs1;
                alu_rs[alu_free_idx].rs2        <= inst_pkt.rs2;
                alu_rs[alu_free_idx].rob_tag    <= inst_pkt.rob_tag;
                alu_rs[alu_free_idx].imm        <= inst_pkt.imm;
                alu_rs[alu_free_idx].use_imm    <= inst_pkt.use_imm;
                alu_rs[alu_free_idx].bj         <= inst_pkt.bj;
                alu_rs[alu_free_idx].br_pred    <= inst_pkt.br_pred;
                alu_rs[alu_free_idx].pc         <= inst_pkt.pc;
                alu_rs[alu_free_idx].rvfi       <= inst_pkt.rvfi;
            end
            if (mul_enqueue) begin
                mul_rs[mul_free_idx]      <= '0;
                mul_rs[mul_free_idx].valid      <= 1'b1;
                mul_rs[mul_free_idx].fu_sel     <= inst_pkt.funct_unit;
                mul_rs[mul_free_idx].muldiv_op  <= inst_pkt.multop;
                mul_rs[mul_free_idx].alu_op     <= inst_pkt.aluop;
                mul_rs[mul_free_idx].br_op      <= inst_pkt.brop;
                mul_rs[mul_free_idx].mem_op     <= inst_pkt.memop;
                mul_rs[mul_free_idx].rs1        <= inst_pkt.rs1;
                mul_rs[mul_free_idx].rs2        <= inst_pkt.rs2;
                mul_rs[mul_free_idx].rob_tag    <= inst_pkt.rob_tag;
                mul_rs[mul_free_idx].imm        <= inst_pkt.imm;
                mul_rs[mul_free_idx].use_imm    <= inst_pkt.use_imm;
                mul_rs[mul_free_idx].bj         <= inst_pkt.bj;
                mul_rs[mul_free_idx].br_pred    <= inst_pkt.br_pred;
                mul_rs[mul_free_idx].pc         <= inst_pkt.pc;
                mul_rs[mul_free_idx].rvfi       <= inst_pkt.rvfi;
            end
            if (div_enqueue) begin
                div_rs[div_free_idx]      <= '0;
                div_rs[div_free_idx].valid      <= 1'b1;
                div_rs[div_free_idx].fu_sel     <= inst_pkt.funct_unit;
                div_rs[div_free_idx].muldiv_op  <= inst_pkt.multop;
                div_rs[div_free_idx].alu_op     <= inst_pkt.aluop;
                div_rs[div_free_idx].br_op      <= inst_pkt.brop;
                div_rs[div_free_idx].mem_op     <= inst_pkt.memop;
                div_rs[div_free_idx].rs1        <= inst_pkt.rs1;
                div_rs[div_free_idx].rs2        <= inst_pkt.rs2;
                div_rs[div_free_idx].rob_tag    <= inst_pkt.rob_tag;
                div_rs[div_free_idx].imm        <= inst_pkt.imm;
                div_rs[div_free_idx].use_imm    <= inst_pkt.use_imm;
                div_rs[div_free_idx].bj         <= inst_pkt.bj;
                div_rs[div_free_idx].br_pred    <= inst_pkt.br_pred;
                div_rs[div_free_idx].pc         <= inst_pkt.pc;
                div_rs[div_free_idx].rvfi       <= inst_pkt.rvfi;
            end
            if (br_enqueue) begin
                br_rs[br_free_idx]      <= '0;
                br_rs[br_free_idx].valid      <= 1'b1;
                br_rs[br_free_idx].fu_sel     <= inst_pkt.funct_unit;
                br_rs[br_free_idx].muldiv_op  <= inst_pkt.multop;
                br_rs[br_free_idx].alu_op     <= inst_pkt.aluop;
                br_rs[br_free_idx].br_op      <= inst_pkt.brop;
                br_rs[br_free_idx].rs1        <= inst_pkt.rs1;
                br_rs[br_free_idx].rs2        <= inst_pkt.rs2;
                br_rs[br_free_idx].rob_tag    <= inst_pkt.rob_tag;
                br_rs[br_free_idx].imm        <= inst_pkt.imm;
                br_rs[br_free_idx].use_imm    <= inst_pkt.use_imm;
                br_rs[br_free_idx].bj         <= inst_pkt.bj;
                br_rs[br_free_idx].br_pred    <= inst_pkt.br_pred;
                br_rs[br_free_idx].pc         <= inst_pkt.pc;
                br_rs[br_free_idx].rvfi       <= inst_pkt.rvfi;
            end
        end
    end

endmodule : issue
