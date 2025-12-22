module br_pred
import types::*;
(
    input logic clk,
    input logic rst,
    input logic flush,
    input logic [31:0] pc,
    input logic [31:0] inst,
    input logic [63:0] order,
    input logic linebuf_hit,
    input logic imem_q_space,

    output br_pred_t out,
    output logic take_pred,

    input br_pred_t write_back,
    input logic actual,
    input logic wb_en // if commit_en && IS_BR
);
    logic [GHT_SIZE-1:0] ghr;
    br_pred_t cycle1, cycle1_next;
    br_pred_t cycle2, cycle2_next;

    // GSHARE
    logic [GSHARE_IDX_BITS-1 :0] gshare_raddr;
    logic [1:0]                  gshare_rdata;
    logic                        gshare_valid_rdata;


    assign gshare_raddr = pc[GSHARE_IDX_BITS+1:2] ^ ghr;

    // wb
    logic [GSHARE_IDX_BITS-1 :0] gshare_waddr;
    logic [1:0]                 gshare_wdata;

    assign gshare_waddr = write_back.gshare_index;


    // Other stuff
    logic [31:0] b_imm, j_imm;
    logic final_pred;
    logic _unused0;

// 2 x 512
gshare_sram gshare (
    // write port
    .clk0(clk), // clock
    .csb0(~wb_en), // active low chip select
    .addr0(gshare_waddr), // [8:0]
    .din0(gshare_wdata), // [1:0]
    // read port
    .clk1(clk), // clock
    .csb1(1'b0), // active low chip select
    .addr1(gshare_raddr), // [8:0]
    .dout1(gshare_rdata) // [1:0]
);
// 1 x 512
dp_ff_array #(
    .S_INDEX(GSHARE_IDX_BITS),
    .WIDTH(1)
) gshare_valid (
    .clk0(clk), //
    .rst0(rst), //
        // read port
    .csb0(1'b0), // active low
    .web0(1'b1), // not used
    .addr0(gshare_raddr), //
    .din0('0), // not used
    .dout0(gshare_valid_rdata), //
        // writeback port
    .csb1(1'b0), //
    .web1(~wb_en), //
    .addr1(gshare_waddr), //
    .din1(1'b1), // always write 1
    .dout1(_unused0) // not used
);


// Cycle 1
always_comb begin
    cycle1_next = '0;
    cycle1_next.valid      = linebuf_hit;
    cycle1_next.pc         = pc;
    cycle1_next.inst       = inst;
    cycle1_next.target_pc  = 32'b0;
    cycle1_next.order = order;
    cycle1_next.gshare_index     = gshare_raddr;

    j_imm  = {{12{cycle1.inst[31]}}, cycle1.inst[19:12], cycle1.inst[20], cycle1.inst[30:21], 1'b0};
    b_imm = {{20{cycle1.inst[31]}}, cycle1.inst[7], cycle1.inst[30:25], cycle1.inst[11:8], 1'b0};
end

// Cycle 2
always_comb begin
    cycle2_next = cycle1;
    cycle2_next.valid      = cycle1.valid;
    cycle2_next.gshare_state = gshare_valid_rdata ? br_pred_e'(gshare_rdata) : GSHARE_INIT;
    cycle2_next.gshare_pred = cycle2_next.gshare_state[1];
    final_pred = cycle2_next.gshare_pred;
    cycle2_next.tournament_pred = final_pred; // from cycle4
    if(cycle1.inst[6:0] == 7'b1101111) begin
        cycle2_next.target_pc = cycle1.pc + j_imm;
    end else begin
        cycle2_next.target_pc = cycle1.pc + b_imm;
    end
end


// update logic
always_comb begin
    // update gshare
    case(write_back.gshare_state)
    STRONGLY_TAKEN:     gshare_wdata = actual ? STRONGLY_TAKEN : WEAKLY_TAKEN;
    WEAKLY_TAKEN:       gshare_wdata = actual ? STRONGLY_TAKEN : WEAKLY_NOT_TAKEN;
    WEAKLY_NOT_TAKEN:   gshare_wdata = actual ? WEAKLY_TAKEN : STRONGLY_NOT_TAKEN;
    STRONGLY_NOT_TAKEN: gshare_wdata = actual ? WEAKLY_NOT_TAKEN : STRONGLY_NOT_TAKEN;
    default: ;
    endcase
end

always_ff @(posedge clk) begin
    if(rst) begin
        cycle1 <= '0;
        cycle2 <= '0;
        ghr <= GHR_INIT;

    end else begin
        if(flush) begin
            cycle1.valid <= '0;
            cycle2.valid <= '0;
        end else if (imem_q_space) begin // stall
            cycle1 <= cycle1_next;
            cycle2 <= cycle2_next;
        end else begin
            cycle1 <= cycle1;
            cycle2 <= cycle2;
        end

        if(wb_en) begin
            ghr <= {ghr[GHT_SIZE-2:0], actual};
        end else begin
            ghr <= ghr;
        end
    end
end


assign out = cycle2;
assign take_pred = imem_q_space && cycle2.valid && ((cycle2.tournament_pred &&
                    (cycle2.inst[6:0] == 7'b1100011)) || cycle2.inst[6:0] == 7'b1101111);

endmodule : br_pred
