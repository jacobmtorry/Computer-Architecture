module priority_arbiter_cdb
import types::*;
(
    input logic clk,
    input logic rst,
    input logic flush,

    input cdb_t alu_fu_output,
    input cdb_t mul_fu_output,
    input cdb_t div_fu_output,
    input cdb_t mem_fu_output,
    input cdb_t br_fu_output,

    input logic alu_enq_en,
    input logic mul_enq_en,
    input logic div_enq_en,
    input logic mem_enq_en,
    input logic br_enq_en,


    output cdb_t cdb_out
);

logic alu_dq_en,   mul_dq_en,   div_dq_en,   mem_dq_en,   br_dq_en;
logic alu_q_empty, mul_q_empty, div_q_empty, mem_q_empty, br_q_empty;
logic alu_q_space, mul_q_space, div_q_space, mem_q_space, br_q_space;
cdb_t alu_dout, mul_dout, div_dout, mem_dout, br_dout;

logic  _unused3, _unused4, _unused5, _unused6, _unused7;

assign _unused3 = alu_q_space;
assign _unused4 = mul_q_space;
assign _unused5 = div_q_space;
assign _unused6 = mem_q_space;
assign _unused7 = br_q_space;


assign  br_dq_en = !br_q_empty;
assign mem_dq_en = !br_dq_en && !mem_q_empty;
assign div_dq_en = !br_dq_en && !mem_dq_en && !div_q_empty;
assign mul_dq_en = !br_dq_en && !mem_dq_en && !div_dq_en && !mul_q_empty;
assign alu_dq_en = !br_dq_en && !mem_dq_en && !div_dq_en && !mul_dq_en && !alu_q_empty;

always_comb begin
    priority case (1'b1)
    br_dq_en : cdb_out = br_dout;
    mem_dq_en: cdb_out = mem_dout;
    div_dq_en: cdb_out = div_dout;
    mul_dq_en: cdb_out = mul_dout;
    alu_dq_en: cdb_out = alu_dout;
    default cdb_out = '0;
    endcase
end


queue_cdb #(.HEIGHT(ALU_BUF_Q_DEPTH)) alu_buf_queue (
    .clk           (clk),
    .rst           (rst),
    .flush         (flush),
    .enq_en        (alu_enq_en),
    .deq_en        (alu_dq_en),
    .din           (alu_fu_output),
    .dout          (alu_dout),
    .q_space_avail (alu_q_space),
    .q_empty       (alu_q_empty)
);

queue_cdb #(.HEIGHT(MUL_BUF_Q_DEPTH)) mul_buf_queue (
    .clk           (clk),
    .rst           (rst),
    .flush         (flush),
    .enq_en        (mul_enq_en),
    .deq_en        (mul_dq_en),
    .din           (mul_fu_output),
    .dout          (mul_dout),
    .q_space_avail (mul_q_space),
    .q_empty       (mul_q_empty)
);

queue_cdb #(.HEIGHT(DIV_BUF_Q_DEPTH)) div_buf_queue (
    .clk           (clk),
    .rst           (rst),
    .flush         (flush),
    .enq_en        (div_enq_en),
    .deq_en        (div_dq_en),
    .din           (div_fu_output),
    .dout          (div_dout),
    .q_space_avail (div_q_space),
    .q_empty       (div_q_empty)
);

queue_cdb #(.HEIGHT(MEM_BUF_Q_DEPTH)) mem_buf_queue (
    .clk           (clk),
    .rst           (rst),
    .flush         (flush),
    .enq_en        (mem_enq_en),
    .deq_en        (mem_dq_en),
    .din           (mem_fu_output),
    .dout          (mem_dout),
    .q_space_avail (mem_q_space),
    .q_empty       (mem_q_empty)
);

queue_cdb #(.HEIGHT(BR_BUF_Q_DEPTH)) br_buf_queue (
    .clk           (clk),
    .rst           (rst),
    .flush         (flush),
    .enq_en        (br_enq_en),
    .deq_en        (br_dq_en),
    .din           (br_fu_output),
    .dout          (br_dout),
    .q_space_avail (br_q_space),
    .q_empty       (br_q_empty)
);

endmodule : priority_arbiter_cdb
