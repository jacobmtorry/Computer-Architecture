module fu_div
import types::*;
(
    input logic clk,
    input logic rst,
    input logic stall,
    input logic flush,

    input logic div_en,

    input fu_pkt_t div_pkt_in,
    output cdb_t div_out,

    output logic div_busy,
    output logic div_resp_pulse
);

  logic [2:0] divop;
  logic [31:0] a, b;
  logic [31:0] divout;

  logic [31:0] a_reg, b_reg;
  logic [2:0]  divop_reg;
  rvfi_t       rvfi_reg;
  logic [$clog2(ROB_DEPTH)-1:0] rob_tag_reg;

  logic [31:0] quotient, remainder;
  logic [31:0] quotient_u, remainder_u;
  logic complete_div, complete_divu;
  logic divide_by_0, divide_by_0_u;
  logic overflow;

  logic start_div, start_divu;
  logic div_resp;


  always_ff @(posedge clk) begin
  if (rst || flush) begin
    a_reg       <= 32'd0;
    b_reg       <= 32'd0;
    divop_reg   <= 3'd0;
    rvfi_reg    <= '0;
    rob_tag_reg <= '0;
    start_div   <= 1'b0;
    start_divu  <= 1'b0;
  end else if (div_en) begin
    a_reg       <= div_pkt_in.rs1_v;
    b_reg       <= div_pkt_in.rs2_v;
    divop_reg   <= div_pkt_in.muldiv_op;
    rvfi_reg    <= div_pkt_in.rvfi;
    rob_tag_reg <= div_pkt_in.rob_tag;
    start_div   <= 1'b1;
    start_divu  <= 1'b1;
  end else begin
    a_reg       <= a_reg;
    b_reg       <= b_reg;
    divop_reg   <= divop_reg;
    rvfi_reg    <= rvfi_reg;
    rob_tag_reg <= rob_tag_reg;
    start_div   <= 1'b0;
    start_divu  <= 1'b0;
  end
end


  assign a = a_reg;
  assign b = b_reg;
  assign divop = divop_reg;

  always_comb begin
    div_out               = '0;
    div_out.valid         = div_resp_pulse && div_busy && !flush;
    div_out.data          = divout;
    div_out.rs1_data      = a_reg;
    div_out.rs2_data      = b_reg;
    div_out.rob_tag       = rob_tag_reg;
    div_out.rvfi          = rvfi_reg;
    div_out.rvfi.rd_wdata = divout;

    // Assign rsp only when correct singal is complete
   div_resp = '0;
   div_resp =  (!start_div && !start_divu) && ((divop == div_op   && complete_div) ||
                     (divop == rem_op   && complete_div) ||
                     (divop == divu_op  && complete_divu) ||
                     (divop == remu_op  && complete_divu));

  end



  // covers the only overflow case
  // a = min and we divide by -1 and overflow
  assign overflow = (a == {{1'b1}, {31{1'b0}}} && b == {32{1'b1}});

  logic div_resp_d;
  always_ff @(posedge clk) begin
    if (rst || flush) begin
      div_resp_d <= 1'b0;
    end else if (div_resp_pulse) begin
      div_resp_d <= 1'b1;
    end else begin
      div_resp_d <= 1'b0;
    end
  end

  assign div_resp_pulse = div_resp && !div_resp_d;


always_ff @(posedge clk) begin
  if (rst || flush) begin
    div_busy <= 1'b0;
  end else if (div_en) begin
    div_busy <= 1'b1;
  end else if (div_resp_pulse) begin
    div_busy <= 1'b0;
  end
end


  // divide by 0 should return -1
  // overflow should output
  always_comb begin
    unique case (divop)
      div_op:   divout = overflow ? {{1'b1}, {31{1'b0}}} : (divide_by_0 ?  {32{1'b1}} : quotient);
      divu_op:  divout = divide_by_0_u ? {32{1'b1}} : quotient_u;
      rem_op:   divout = overflow      ? {32{1'b0}} : (divide_by_0 ? a : remainder);
      remu_op:  divout = divide_by_0_u ? a : remainder_u;
      default:  divout = 32'hx;
    endcase
  end


    DW_div_seq #(
        .a_width     (32),
        .b_width     (32),
        .tc_mode     (1),             //2's complement mode
        .num_cyc     (17),        // user defined number of cycles
        .early_start (0)          // Start on 1st cycle
    ) div_signed (
        .clk   (clk),
        .rst_n (~(rst || flush)),
        .hold  (stall),
        .start (start_div),
        .a(a),
        .b(b),
        .complete    (complete_div),
        .divide_by_0 (divide_by_0),
        .quotient    (quotient),
        .remainder   (remainder)
    );

    DW_div_seq #(
        .a_width     (32),
        .b_width     (32),
        .tc_mode     ( 0),         //2's complement mode
        .num_cyc     (17),         // user defined number of cycles
        .early_start ( 0)          // Start on 1st cycle
    ) div_unsigned (
        .clk   (clk),
        .rst_n (~(rst || flush)),
        .hold  (stall),
        .start (start_divu),
        .a(a),
        .b(b),
        .complete    (complete_divu),
        .divide_by_0 (divide_by_0_u),
        .quotient    (quotient_u),
        .remainder   (remainder_u)
    );



endmodule : fu_div
