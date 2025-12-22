module fu_alu
  import types::*;
(
    input  fu_pkt_t alu_pkt_in,
    output cdb_t alu_out
);
  logic [31:0] a;
  logic [31:0] b;
  logic [ 3:0] opcode;
  logic [31:0] aluout;

  assign a = alu_pkt_in.rs1_v;
  assign b = alu_pkt_in.rs2_v;
  assign opcode = alu_pkt_in.alu_op;

  always_comb begin
    alu_out       = '0;
    alu_out.valid = alu_pkt_in.valid;

    alu_out.data     = aluout;
    alu_out.rs1_data = a;
    alu_out.rs2_data = b;

    alu_out.rob_tag       = alu_pkt_in.rob_tag;
    alu_out.rvfi          = alu_pkt_in.rvfi;
    alu_out.rvfi.rd_wdata = aluout;
  end


  logic signed   [31:0] as;
  logic signed   [31:0] bs;
  logic unsigned [31:0] au;
  logic unsigned [31:0] bu;

  assign as = signed'(a);
  assign bs = signed'(b);
  assign au = unsigned'(a);
  assign bu = unsigned'(b);

  always_comb begin
    unique case (opcode)
      add_op:   aluout = au + bu;
      sub_op:   aluout = au - bu;
      xor_op:   aluout = au ^ bu;
      or_op:    aluout = au | bu;
      and_op:   aluout = au & bu;
      lui_op:   aluout = {b[31:12], 12'h000};
      sll_op:   aluout = au << bu[4:0];
      srl_op:   aluout = au >> bu[4:0];
      sra_op:   aluout = unsigned'(as >>> bu[4:0]);
      slt_op:   aluout = (as < bs) ? {31'd0, 1'b1} : {32'd0};
      sltu_op:  aluout = (au < bu)? {31'd0, 1'b1} : {32'd0};
      auipc_op: aluout =  alu_pkt_in.pc + {b[31:12], 12'h000};
      default:  aluout = 32'hx;
    endcase
  end

endmodule : fu_alu
