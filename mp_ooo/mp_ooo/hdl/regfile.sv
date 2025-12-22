module regfile
import types::*;
(
    input   logic   clk,
    input   logic   rst,
    input   logic   flush,

    // Signals From Disptach
    input   logic   rename_en,
    input   logic   [4:0]   rd_to_rename,
    input   logic   [$clog2(ROB_DEPTH)-1:0] rename_rob_tag,

    // Singals From ROB (on commit)
    input   logic   commit_en,
    input   logic   [4:0]   commit_rd,
    input   logic   [31:0]  commit_val,
    input   logic   [$clog2(ROB_DEPTH)-1:0] commit_rob_tag,

    // Operand Ports - these are used by the RSs
    input   logic   [4:0]   rs1_s,
    input   logic   [4:0]   rs2_s,
    output  reg_t   rs1_out,
    output  reg_t   rs2_out
);

    reg_t   regs [32];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (integer i = 0; i < 32; i++) begin
                regs[i].valid   <= 1'b1;
                regs[i].data    <= '0;
                regs[i].rob_tag <= '0;
            end
        end else if(flush) begin
            for (integer i = 0; i < 32; i++) begin
                regs[i].valid   <= 1'b1;
                regs[i].rob_tag <= '0;
            end
            if (commit_rd != 5'd0) regs[commit_rd].data    <= commit_val;
        end else begin
            if (rename_en && (rd_to_rename != 5'b00000)) begin
                regs[rd_to_rename].valid    <= 1'b0;
                regs[rd_to_rename].rob_tag  <= rename_rob_tag;
            end 
            if ((rd_to_rename != commit_rd || !rename_en) && commit_en && (commit_rd != 5'b00000) && (commit_rob_tag == regs[commit_rd].rob_tag)) begin
                // regs[commit_rd].data    <= commit_val;
                regs[commit_rd].valid   <= 1'b1;
            end
            if (commit_en && (commit_rd != 5'b00000)) begin
                regs[commit_rd].data    <= commit_val;
                // regs[commit_rd].valid   <= 1'b1;
            end
        end
    end

    always_comb begin

        rs1_out.valid   = 1'b1;
        rs1_out.data    = 32'b0;
        rs1_out.rob_tag = '0;

        rs2_out.valid   = 1'b1;
        rs2_out.data    = 32'b0;
        rs2_out.rob_tag = '0;

        if (rst) begin
            rs1_out.data = '0;
        end else begin
            if (rs1_s != 5'b0) begin
                rs1_out.data = regs[rs1_s].data;
                if ((rs1_s == commit_rd) && commit_en && (commit_rd != 5'b00000) && (commit_rob_tag == regs[commit_rd].rob_tag)) begin
                    rs1_out.data    = commit_val;
                    rs1_out.valid   = 1'b1;
                end else if (regs[rs1_s].valid == 1'b0) begin
                    rs1_out.valid   = 1'b0;
                    rs1_out.rob_tag = regs[rs1_s].rob_tag;
                end else begin
                    rs1_out.valid   = 1'b1;
                    rs1_out.rob_tag = regs[rs1_s].rob_tag;
                end
            end else begin
                rs1_out.data = '0;
            end
        end

        if (rst) begin
            rs2_out.data = '0;
        end else begin
            if (rs2_s != 5'b0) begin
                rs2_out.data = regs[rs2_s].data;
                if ((rs2_s == commit_rd) && commit_en && (commit_rd != 5'b00000) && (commit_rob_tag == regs[commit_rd].rob_tag)) begin
                    rs2_out.data    = commit_val;
                    rs2_out.valid   = 1'b1;
                end else if (regs[rs2_s].valid == 1'b0) begin
                    rs2_out.valid   = 1'b0;
                    rs2_out.rob_tag = regs[rs2_s].rob_tag;
                end else begin
                    rs2_out.valid   = 1'b1;
                    rs2_out.rob_tag = regs[rs2_s].rob_tag;
                end
            end else begin
                rs2_out.data = '0;
            end
        end
    end
endmodule : regfile
