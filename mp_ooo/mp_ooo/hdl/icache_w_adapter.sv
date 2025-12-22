module icache_w_adapter
import types::*;
(
    input  logic         clk,
    input  logic         rst,

    // CPU side
    input  logic  [31:0] ufp_addr,
    output logic [255:0] ufp_rdata,
    output logic         ufp_resp,
    input  logic         linebuf_en,
    output  logic [I_SET_BITS-1:0] cache_set,
    output  logic [I_TAG_BITS-1:0] cache_tag,

    // BRAM side
    input  logic         bmem_rvalid,
    input  logic  [63:0] bmem_rdata,
    input  logic         bmem_ready,
    output logic  [31:0] bmem_addr,
    output logic         bmem_read,
    output logic         dfp_resp
);

    // Bridge signals between cache and adapter
    logic [ 31:0] dfp_addr;
    logic         dfp_read;
    logic         dfp_write;            // unused here (tied off to 0)
    logic [255:0] dfp_rdata;
    logic [255:0] dfp_wdata;            // unused here (tied off to '0)

    logic         _unused1;
    logic [255:0] _unused2;

    assign dfp_write = _unused1;
    assign dfp_wdata = _unused2;

    // Adapter <-> BRAM
    icacheline_adapter cacheline_adapter_i (
        .clk (clk),
        .rst (rst),

        // cache <-> adapter
        .dfp_addr   (dfp_addr),         // [31:0]
        .dfp_read   (dfp_read),
        .dfp_resp   (dfp_resp),
        .dfp_rdata  (dfp_rdata),        // [255:0]

        // adapter <-> BRAM
        .bmem_rvalid (bmem_rvalid),
        .bmem_rdata  (bmem_rdata),       // [63:0]
        .bmem_ready  (bmem_ready),
        .bmem_addr   (bmem_addr),        // [31:0]
        .bmem_read   (bmem_read)
    );

    // iCache
    icache #(.I_WAYS(I_WAYS), .I_SETS(I_SETS)) icache_i (
        .clk (clk),
        .rst (rst),

        // CPU side
        .ufp_addr    (ufp_addr),         // [31:0]
        .ufp_rmask   ('1),               // [3:0] read all bytes
        .ufp_wmask   ('0),               // [3:0] no writes
        .ufp_rdata   (ufp_rdata),        // [255:0]
        .ufp_wdata   ('0),               // [31:0]
        .ufp_resp    (ufp_resp),
        .linebuf_en  (linebuf_en),
        .cache_set   (cache_set),
        .cache_tag   (cache_tag),

        // Downward-facing (to adapter)
        .dfp_addr   (dfp_addr),         // [31:0]
        .dfp_read   (dfp_read),
        .dfp_write  (_unused1),         // tie off
        .dfp_rdata  (dfp_rdata),        // [255:0]
        .dfp_wdata  (_unused2),         // [255:0]
        .dfp_resp   (dfp_resp)
    );

endmodule : icache_w_adapter
