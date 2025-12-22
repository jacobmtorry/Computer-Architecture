module dcache_w_adapter
import types::*;
(
    input  logic clk,
    input  logic rst,

    // CPU side (data cache interface)
    input  logic  [31:0] ufp_addr,
    input  logic  [3:0]  ufp_rmask,
    input  logic  [3:0]  ufp_wmask,
    input  logic  [31:0] ufp_wdata,

    output logic [255:0] ufp_rdata,
    output logic         ufp_resp,

    // BRAM side (shared with rest of system)
    input  logic         bmem_rvalid,
    input  logic  [63:0] bmem_rdata,
    input  logic         bmem_ready,
    output logic         dfp_resp,

    output logic [31:0]  bmem_addr,
    output logic         bmem_read,
    output logic         bmem_write,
    output logic [63:0]  bmem_wdata
);

    // Bridge signals between cache and adapter
    logic  [31:0] dfp_addr;
    logic         dfp_read;
    logic         dfp_write;
    logic [255:0] dfp_rdata;
    logic [255:0] dfp_wdata;
    //logic         dfp_resp;

    // Adapter (handles splitting/assembling 256b <-> 4x64b)
    dcacheline_adapter dcacheline_adapter_i (
        .clk        (clk),
        .rst        (rst),

        // cache <-> adapter
        .dfp_addr   (dfp_addr),
        .dfp_read   (dfp_read),
        .dfp_write  (dfp_write),
        .dfp_resp   (dfp_resp),
        .dfp_rdata  (dfp_rdata),
        .dfp_wdata  (dfp_wdata),

        // adapter <-> BRAM
        .bmem_rvalid(bmem_rvalid),
        .bmem_rdata (bmem_rdata),
        .bmem_ready (bmem_ready),
        .bmem_addr  (bmem_addr),
        .bmem_read  (bmem_read),
        .bmem_write (bmem_write),
        .bmem_wdata (bmem_wdata)
    );

    // Data cache instance
    dcache dcache_i (
        .clk (clk),
        .rst (rst),

        // CPU side
        .ufp_addr   (ufp_addr),
        .ufp_rmask  (ufp_rmask),
        .ufp_wmask  (ufp_wmask),
        .ufp_rdata  (ufp_rdata),
        .ufp_wdata  (ufp_wdata),
        .ufp_resp   (ufp_resp),

        // Downward-facing (to adapter)
        .dfp_addr   (dfp_addr),
        .dfp_read   (dfp_read),
        .dfp_write  (dfp_write),
        .dfp_rdata  (dfp_rdata),
        .dfp_wdata  (dfp_wdata),
        .dfp_resp   (dfp_resp),

        .linebuf_en ('0) // not used for DCache
    );

endmodule : dcache_w_adapter
