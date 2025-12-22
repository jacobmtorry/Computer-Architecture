    longint timeout;
    initial begin
        $value$plusargs("TIMEOUT_ECE411=%d", timeout);
        
    end

    mem_itf_banked mem_itf(.*);
    dram_w_burst_frfcfs_controller mem(.itf(mem_itf));

    mon_itf #(.CHANNELS(8)) mon_itf(.*);
    monitor #(.CHANNELS(8)) monitor(.itf(mon_itf));

    cpu dut(
        .clk            (clk),
        .rst            (rst),

        .bmem_addr  (mem_itf.addr  ),
        .bmem_read  (mem_itf.read  ),
        .bmem_write (mem_itf.write ),
        .bmem_wdata (mem_itf.wdata ),
        .bmem_ready (mem_itf.ready ),
        .bmem_raddr (mem_itf.raddr ),
        .bmem_rdata (mem_itf.rdata ),
        .bmem_rvalid(mem_itf.rvalid)
    );

    `include "rvfi_reference.svh"

    always @(posedge clk) begin
        if (mon_itf.halt) begin
            $display("###############################################");
            $display("#");
            $display("Total Flushes = %0d", dut.flush_count);
            $display("BR: Flushes/Count = %0d/%0d = %0f", dut.br_flush_count, dut.br_count, 1 - (real'(dut.br_flush_count)/real'(dut.br_count)));
            $display("JAL: Flushes/Count = %0d/%0d = %0f", dut.jal_flush_count, dut.jal_count, 1 - (real'(dut.jal_flush_count)/real'(dut.jal_count)));
            $display("JALR: Flushes/Count = %0d/%0d = %0f", dut.jalr_flush_count, dut.jalr_count, 1 - (real'(dut.jalr_flush_count)/real'(dut.jalr_count)));
            $display("MULT/DIV: %0d", dut.multdiv_count);
            $display("#");
            $display("###############################################");
            $finish;
        end
        if (timeout == 0) begin
            $error("TB Error: Timed out");
            $fatal;
        end
        if (mem_itf.error != 0 || mon_itf.error != 0) begin
            $fatal;
        end
        timeout <= timeout - 1;
    end
