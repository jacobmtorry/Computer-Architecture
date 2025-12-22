module fu_mult_pipelined
import types::*;
(
    input logic clk,
    input logic rst,
    input logic flush,

    input fu_pkt_t mult_pkt_in,
    output cdb_t   mult_out
);
  logic [ 2:0] multop;
  logic [31:0] a, b;
  logic [31:0] multout;
  logic [65:0] a_ext, b_ext;
  logic [65:0] product;
  logic [31:0] data;
  assign a = mult_pkt_in.rs1_v;
  assign b = mult_pkt_in.rs2_v;

  localparam MULT_STAGES = 3;
  cdb_t regs [MULT_STAGES];
  cdb_t regs_next[MULT_STAGES];


  always_comb begin
    if(mult_pkt_in.valid) begin
        case (mult_pkt_in.muldiv_op)
            mul_op  : a_ext = {{33'd0}, a[31] , a};
            mulh_op : a_ext = {{33'd0}, a[31] , a};
            mulsu_op: a_ext = {{33'd0}, a[31] , a};
            mulu_op : a_ext = {{33'd0}, 1'b0 , a};
            default: a_ext = '0;
        endcase

        case (mult_pkt_in.muldiv_op)
            mul_op  : b_ext = {{33'd0}, b[31] , b};
            mulh_op : b_ext = {{33'd0}, b[31] , b};
            mulsu_op: b_ext = {{33'd0}, 1'b0 , b};
            mulu_op : b_ext = {{33'd0}, 1'b0 , b};
        default: b_ext = '0;
        endcase

        product = (a_ext * b_ext);

        case (mult_pkt_in.muldiv_op)
            mul_op  : data = product[31:0 ];
            mulh_op : data = product[63:32];
            mulsu_op: data = product[63:32];
            mulu_op : data = product[63:32];
        default: data = '0;
        endcase

            regs_next[0] = '0;
            regs_next[0].valid = mult_pkt_in.valid;
            regs_next[0].data = data;
            regs_next[0].rob_tag = mult_pkt_in.rob_tag;
            regs_next[0].rs1_data = a;
            regs_next[0].rs2_data = b;
            regs_next[0].rvfi = mult_pkt_in.rvfi;
            regs_next[0].rvfi.rd_wdata = data;

    end else begin
        regs_next[0] = '0;
        a_ext = '0;
        b_ext = '0;
        data = '0;
        product = '0;
    end
    for(integer i=1; i<MULT_STAGES; i++) regs_next[i] = regs_next[i-1];

  end


always_ff @(posedge clk) begin
    if(rst) begin
        for(integer i=0; i<MULT_STAGES; i++) regs[i]<= '0;

    end else if(flush) begin
        for(integer i=0; i<MULT_STAGES; i++) regs[i].valid <= '0;

    end else begin
        for(integer i=0; i<MULT_STAGES; i++) regs[i] <= regs_next[i];

    end
end

assign mult_out = regs[MULT_STAGES-1];

endmodule : fu_mult_pipelined
