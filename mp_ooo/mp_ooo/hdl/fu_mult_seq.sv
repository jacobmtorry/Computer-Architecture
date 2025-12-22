module fu_mult_seq
import types::*;
(
    input logic clk,
    input logic rst,
    input logic stall,
    input logic flush,

    input logic mult_en,

    input fu_pkt_t mult_pkt_in,
    output cdb_t   mult_out,

    output logic mult_busy,
    output logic mult_resp_pulse
);

  logic [ 2:0] multop;
  logic [31:0] a, b;
  logic [31:0] multout;

  logic [ 2:0]  multop_reg;
  logic [31:0] a_reg, b_reg;
  rvfi_t       rvfi_reg;
  logic [$clog2(ROB_DEPTH)-1:0] rob_tag_reg;

  logic [63:0] product_mulu, product_mul;
  logic [65:0] product_mulsu;
  logic complete_mul, complete_mulsu, complete_mulu;

  logic start_mul, start_mulu, start_mulsu;
  logic mult_resp;
  logic mult_resp_d;

  // Latch inputs on mult_en
  always_ff @(posedge clk) begin
    if (rst || flush) begin
      a_reg        <= 32'd0;
      b_reg        <= 32'd0;
      multop_reg   <= 3'd0;
      rvfi_reg     <= '0;
      rob_tag_reg  <= '0;
      start_mul    <= 1'b0;
      start_mulsu  <= 1'b0;
      start_mulu   <= 1'b0;
    end else begin
      if (mult_en) begin
        a_reg        <= mult_pkt_in.rs1_v;
        b_reg        <= mult_pkt_in.rs2_v;
        multop_reg   <= mult_pkt_in.muldiv_op;
        rvfi_reg     <= mult_pkt_in.rvfi;
        rob_tag_reg  <= mult_pkt_in.rob_tag;
        start_mul    <= 1'b1;
        start_mulsu  <= 1'b1;
        start_mulu   <= 1'b1;
      end else begin
        start_mul    <= 1'b0;
        start_mulsu  <= 1'b0;
        start_mulu   <= 1'b0;
      end
    end
  end

  assign a = a_reg;
  assign b = b_reg;
  assign multop = multop_reg;

  always_comb begin
    mult_out          = '0;
    mult_out.valid    = mult_resp && !flush;
    mult_out.data     = multout;
    mult_out.rs1_data = a_reg;
    mult_out.rs2_data = b_reg;
    mult_out.rob_tag  = rob_tag_reg;
    mult_out.rvfi     = rvfi_reg;

    mult_out.rvfi.rd_wdata = multout;

    mult_resp = '0;
    mult_resp = (multop == mul_op   && complete_mul)  ||
                (multop == mulh_op  && complete_mul)  ||
                (multop == mulsu_op && complete_mulsu)||
                (multop == mulu_op  && complete_mulu);
  end

always_ff @(posedge clk) begin
  if (rst || flush) begin
    mult_busy <= 1'b0;
  end else if (mult_en) begin
    mult_busy <= 1'b1;
  end else if (mult_resp_pulse) begin
    mult_busy <= 1'b0;
  end else if (stall) begin
    mult_busy <= mult_busy;
  end
end

always_ff @(posedge clk) begin
  if (rst || flush) begin
    mult_resp_d <= 1'b0;
  end else if (mult_resp_pulse) begin
    mult_resp_d <= 1'b1;
  end else begin
    mult_resp_d <= 1'b0;
  end
end

assign mult_resp_pulse = mult_resp && !mult_resp_d;

always_comb begin
  case (multop)
    mul_op:   multout = product_mul   [31:0];
    mulh_op:  multout = product_mul   [63:32];
    mulsu_op: multout = product_mulsu [63:32];
    mulu_op:  multout = product_mulu  [63:32];
    default:  multout = 32'hx;
  endcase
end


DW_mult_seq #(
    .a_width     (32),
    .b_width     (32),
    .tc_mode     (1),
    .num_cyc     (5),
    .input_mode  (1),
    .output_mode (1),
    .early_start (0)
) mult_mul (
    .clk   (clk),
    .rst_n (~(rst || flush)),
    .hold  (stall),
    .start (start_mul),
    .a(a),
    .b(b),
    .complete (complete_mul),
    .product  (product_mul)
);

DW_mult_seq #(
    .a_width     (33),
    .b_width     (33),
    .tc_mode     (1),
    .num_cyc     (5),
    .input_mode  (1),
    .output_mode (1),
    .early_start (0)
) mult_mulsu (
    .clk   (clk),
    .rst_n (~(rst || flush)),
    .hold  (stall),
    .start (start_mulsu),
    .a({a[31], a}),
    .b({1'b0, b}),
    .complete (complete_mulsu),
    .product  (product_mulsu)
);

DW_mult_seq #(
    .a_width     (32),
    .b_width     (32),
    .tc_mode     (0),
    .num_cyc     (5),
    .input_mode  (1),
    .output_mode (1),
    .early_start (0)
) mult_mulu (
    .clk   (clk),
    .rst_n (~(rst || flush)),
    .hold  (stall),
    .start (start_mulu),
    .a(a),
    .b(b),
    .complete (complete_mulu),
    .product  (product_mulu)
);

endmodule : fu_mult_seq
