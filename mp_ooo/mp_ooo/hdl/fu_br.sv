module fu_br
  import types::*;
(
    input  fu_pkt_t br_pkt_in,
    output  cdb_t br_out
);
  logic signed   [31:0] as;
  logic signed   [31:0] bs;
  logic unsigned [31:0] au;
  logic unsigned [31:0] bu;

  logic [31:0] a;
  logic [31:0] b;
  logic [ 2:0] opcode;
  logic        br_taken;
  logic [1:0]  op_type;

  assign op_type = br_pkt_in.bj;

  assign a = br_pkt_in.rs1_v;
  assign b = br_pkt_in.rs2_v;

  assign as = signed'(a);
  assign bs = signed'(b);
  assign au = unsigned'(a);
  assign bu = unsigned'(b);

  assign opcode = br_pkt_in.br_op;

  always_comb begin
    br_out    = '0;
    br_taken  = '0;
    br_out.bj = br_pkt_in.bj;

    br_out.rs1_data = a;
    br_out.rs2_data = b;

    br_out.rob_tag  = br_pkt_in.rob_tag;
    br_out.rvfi     = br_pkt_in.rvfi;


  unique case (op_type)
    NONE: begin
      br_out.valid = '0;
    end

    IS_BR: begin
        unique case (opcode)
          beq_op: br_taken  = (au == bu);
          bne_op: br_taken  = (au != bu);
          blt_op: br_taken  = (as < bs);
          bge_op: br_taken  = (as >= bs);
          bltu_op: br_taken = (au < bu);
          bgeu_op: br_taken = (au >= bu);
          default: br_taken = 1'b0;
      endcase
      br_out.valid         = br_pkt_in.valid;
      br_out.take_target   = br_pkt_in.br_pred != br_taken;
      br_out.data          = {31'd0, br_taken};
      br_out.rvfi.rd_wdata = {31'd0, br_taken};
        //  4 cases
      if(br_taken) begin
        br_out.rvfi.pc_wdata = br_pkt_in.pc + br_pkt_in.offset;
        br_out.target_pc     = br_pkt_in.pc + br_pkt_in.offset;
      end else if (!br_taken) begin
        br_out.rvfi.pc_wdata = br_pkt_in.rvfi.pc_wdata;
        br_out.target_pc     =  br_pkt_in.pc + 3'd4;
      end
    end

    IS_JAL: begin
      br_out.valid         = br_pkt_in.valid;
      br_out.take_target   = 1'b0;
      br_out.target_pc     = br_pkt_in.pc + br_pkt_in.offset;
      br_out.data          = br_pkt_in.pc + 3'd4;
      br_out.rvfi.rd_wdata = br_pkt_in.pc + 3'd4;
      br_out.rvfi.pc_wdata = br_out.target_pc;
    end

    IS_JALR: begin
      br_out.valid         = br_pkt_in.valid;
      br_out.take_target   = 1'b1;
      br_out.target_pc     = br_pkt_in.rs1_v + br_pkt_in.offset; // RS1 + imm
      br_out.data          = br_pkt_in.pc + 3'd4;
      br_out.rvfi.rd_wdata = br_pkt_in.pc + 3'd4;
      br_out.rvfi.pc_wdata = br_out.target_pc;
    end
    default: ;
  endcase
  end

endmodule
