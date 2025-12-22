module top_tb;

    timeunit 1ps;
    timeprecision 1ps;

    int clock_half_period_ps;
    initial begin
        $value$plusargs("CLOCK_PERIOD_PS_ECE411=%d", clock_half_period_ps);
        clock_half_period_ps = clock_half_period_ps / 2;
    end

    bit clk;
    always #(clock_half_period_ps) clk = ~clk;
    bit rst;

    initial begin
        $fsdbDumpfile("dump.fsdb");
        if ($test$plusargs("NO_DUMP_ALL_ECE411")) begin
            $fsdbDumpvars(0, dut, "+all");

            // Added so I can acess in waveform
            // $fsdbDumpvars(1, top_tb.dut.id_ex_reg.instr);
            // $fsdbDumpvars(1, top_tb.dut.ex_mem_reg.instr);
            // $fsdbDumpvars(1, top_tb.dut.mem_wb_reg.instr);

            // $fsdbDumpvars(1, top_tb.dut.if_id_reg.valid);
            // $fsdbDumpvars(1, top_tb.dut.id_ex_reg.valid);
            // $fsdbDumpvars(1, top_tb.dut.ex_mem_reg.valid);
            // $fsdbDumpvars(1, top_tb.dut.mem_wb_reg.valid);

            // $fsdbDumpvars(1, top_tb.dut.global_stall);
            // $fsdbDumpvars(1, top_tb.dut.imem_stall);
            // $fsdbDumpvars(1, top_tb.dut.dmem_stall);
            
            // $fsdbDumpvars(1, top_tb.dut.mem_wb_reg.is_store);
            // $fsdbDumpvars(1, top_tb.dut.mem_wb_reg.is_load); 
            // $fsdbDumpvars(1, top_tb.dut.mem_wb_reg.is_store);
            // $fsdbDumpvars(1, top_tb.dut.mem_wb_reg.dmem_addr);
            // $fsdbDumpvars(1, top_tb.dut.mem_wb_reg.dmem_wdata);
            // $fsdbDumpvars(1, top_tb.dut.mem_wb_reg.dmem_wmask);
            // $fsdbDumpvars(1, top_tb.dut.mem_wb_reg.dmem_rmask);
            // $fsdbDumpvars(1, top_tb.dut.mem_wb_reg.rs2_v);
            // $fsdbDumpvars(1, top_tb.dut.mem_wb_reg.rs1_v);
            // $fsdbDumpvars(1, top_tb.dut.wb_rd_s);
            // $fsdbDumpvars(1, top_tb.dut.wb_rd_v);

            // $fsdbDumpvars(1, top_tb.dut.id_ex_reg.store_op);
            // $fsdbDumpvars(1, top_tb.dut.id_stage_i.instruction.s_type.funct3);

            // $fsdbDumpvars(1, top_tb.dut.commit);

            // $fsdbDumpvars(1, top_tb.dut.id_ex_reg.instr[7:0]);
            // $fsdbDumpvars(1, top_tb.dut.id_ex_reg.use_cmp);
            // $fsdbDumpvars(1, top_tb.dut.id_ex_reg.cmp_op);

            // $fsdbDumpvars(1, top_tb.dut.id_ex_reg.alu_op);

            // $fsdbDumpvars(1, top_tb.dut.ex_mem_reg.alu_out);

            // $fsdbDumpvars(1, top_tb.dut.imem_resp);

            // $fsdbDumpvars(1, top_tb.dut.mem_wb_reg.pc);
            // $fsdbDumpvars(1, top_tb.dut.mem_wb_reg.pc_next);
            

            $fsdbDumpoff();
        end else begin
            $fsdbDumpvars(0, "+all");
        end
        rst = 1'b1;
        repeat (2) @(posedge clk);
        rst <= 1'b0;
    end

    `include "top_tb.svh"

endmodule
