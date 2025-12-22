module mem_arbiter
import types::*;
(
    input  logic         clk,
    input  logic         rst,

    // from icache
    input  logic         bmem_i_read,
    input  logic [31:0]  bmem_i_addr,

    // from icache_adapter
    input  logic         i_burst_done,

    // to icache
    output logic         bmem_i_ready,
    output logic         bmem_i_rvalid,
    output logic [63:0]  bmem_i_rdata,

    // from dcache
    input  logic         bmem_d_read,
    input  logic         bmem_d_write,
    input  logic [31:0]  bmem_d_addr,
    input  logic [63:0]  bmem_d_wdata,

    // from dcache adapter
    input  logic         d_burst_done,

    // to dcache
    output logic         bmem_d_ready,
    output logic         bmem_d_rvalid,
    output logic [63:0]  bmem_d_rdata,

    // to memory
    output logic         bmem_read,
    output logic         bmem_write,
    output logic [31:0]  bmem_addr,
    output logic [63:0]  bmem_wdata,

    // from memory
    input  logic         bmem_ready,
    input  logic         bmem_rvalid,
    input  logic [31:0]  bmem_raddr,
    input  logic [63:0]  bmem_rdata
);

  typedef enum logic [1:0] {ARB_IDLE, SERVE_I, SERVE_D} arb_state_e;
  arb_state_e state, state_n;

  // Next-grant priority: 1 = D first, 0 = I first
  logic pri_d, pri_d_n;

  // registerd outputs
  logic         next_bmem_read;
  logic         next_bmem_write;
  logic [31:0]  next_bmem_addr;
  logic [63:0]  next_bmem_wdata;
  logic         next_bmem_d_ready;
  logic         next_bmem_d_rvalid;
  logic [63:0]  next_bmem_d_rdata;
  logic         next_bmem_i_ready;
  logic         next_bmem_i_rvalid;
  logic [63:0]  next_bmem_i_rdata;

  logic i_req, d_req;
  assign i_req = bmem_i_read;
  assign d_req = bmem_d_read | bmem_d_write;

  logic i_inflight, d_inflight;
  logic [31:0] i_tag, d_tag;


  always_comb begin
    next_bmem_read      = '0;
    next_bmem_write     = '0;
    next_bmem_addr      = '0;
    next_bmem_wdata     = '0;

    next_bmem_i_ready   = '0;
    next_bmem_i_rvalid  = '0;
    next_bmem_i_rdata   = '0;

    next_bmem_d_ready   = '0;
    next_bmem_d_rvalid  = '0;
    next_bmem_d_rdata   = '0;

    state_n        = state;
    pri_d_n        = pri_d;

    unique case (state)
      ARB_IDLE: begin
        // Decide winner
        if (d_req && i_req ? pri_d : d_req) begin
            // D wins
            next_bmem_read     = bmem_d_read;
            next_bmem_write    = bmem_d_write;
            next_bmem_addr     = bmem_d_addr;
            next_bmem_wdata    = bmem_d_wdata;
            next_bmem_d_ready  = bmem_ready;

            state_n = SERVE_D;
        end else if (i_req) begin
            // I wins
            next_bmem_read     = bmem_i_read;
            next_bmem_write    = 1'b0;
            next_bmem_addr     = bmem_i_addr;
            next_bmem_i_ready  = bmem_ready;


            state_n = SERVE_I;
        end
        end

      SERVE_D: begin

        next_bmem_read     = bmem_d_read;
        next_bmem_write    = bmem_d_write;
        next_bmem_addr     = bmem_d_addr;
        next_bmem_wdata    = bmem_d_wdata;
        next_bmem_d_ready  = bmem_ready;


        if (d_burst_done) begin
          state_n = (bmem_i_read) ? SERVE_I : ARB_IDLE;
          pri_d_n = 1'b0;
        end
      end

      SERVE_I: begin

        next_bmem_read     = bmem_i_read;
        next_bmem_write    = 1'b0;
        next_bmem_addr     = bmem_i_addr;
        next_bmem_i_ready  = bmem_ready;


        if (i_burst_done) begin
          state_n = (bmem_d_read | bmem_d_write) ? SERVE_D : ARB_IDLE;
          pri_d_n = 1'b1;
        end
      end

      default: begin
        state_n = ARB_IDLE;
      end
    endcase

    if (bmem_rvalid && ({bmem_raddr[31:5], 5'b0} == i_tag)) begin
      next_bmem_i_rvalid = 1'b1;
      next_bmem_i_rdata  = bmem_rdata;
    end

    if (bmem_rvalid && ({bmem_raddr[31:5], 5'b0} == d_tag)) begin
      next_bmem_d_rvalid = 1'b1;
      next_bmem_d_rdata  = bmem_rdata;
    end

  end


  always_ff @(posedge clk) begin
    if (rst) begin
      bmem_read     <= '0;
      bmem_d_rvalid <= '0;
      bmem_write    <= '0;
      bmem_addr     <= '0;
      bmem_wdata    <= '0;
      bmem_d_ready  <= '0;
      bmem_d_rdata  <= '0;
      bmem_i_ready  <= '0;
      bmem_i_rvalid <= '0;
      bmem_i_rdata  <= '0;
    end else begin
      bmem_read     <= next_bmem_read;
      bmem_write    <= next_bmem_write;
      bmem_addr     <= next_bmem_addr;
      bmem_wdata    <= next_bmem_wdata;
      bmem_d_ready  <= next_bmem_d_ready;
      bmem_d_rvalid <= next_bmem_d_rvalid;
      bmem_d_rdata  <= next_bmem_d_rdata;
      bmem_i_ready  <= next_bmem_i_ready;
      bmem_i_rvalid <= next_bmem_i_rvalid;
      bmem_i_rdata  <= next_bmem_i_rdata;
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      state <= ARB_IDLE;
      pri_d <= 1'b0;
    end else begin
      state <= state_n;
      pri_d <= pri_d_n;
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      i_inflight <= '0;
      d_inflight <= '0;
      i_tag      <= '0;
      d_tag      <= '0;
    end else begin
      if (state == SERVE_I && bmem_i_read) begin
        i_inflight <= 1'b1;
        i_tag <= {bmem_i_addr[31:5], 5'b0};
      end
      if (state == SERVE_D && bmem_d_read) begin
        d_inflight <= 1'b1;
        d_tag <= {bmem_d_addr[31:5], 5'b0};
      end
      if (i_burst_done && i_inflight) begin
        i_inflight <= 1'b0;
      end
      if (d_burst_done && d_inflight) begin
        d_inflight <= 1'b0;
      end
    end
  end

endmodule
