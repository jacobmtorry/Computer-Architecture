module cpu
import rv32i_types::*;
(
    input logic         clk,
    input logic         rst,

    output logic [31:0] imem_addr,    // Address of the instruction we are at 
    output logic [3:0]  imem_rmask,   // For reading a specific of a word
    input logic [31:0]  imem_rdata,   // The actuall 32 instruction
    input logic         imem_resp,    // Signals if we are done fetching the instrcution or not (handshake)

    output logic [31:0] dmem_addr,    // Address we want to read/write from
    output logic [3:0]  dmem_rmask,   // Bytes we want to read from word
    output logic [3:0]  dmem_wmask,   // Bytes we want to write to in a word
    input logic [31:0]  dmem_rdata,   // Data we read from memory
    output logic [31:0] dmem_wdata,   // Data we are writing to memory
    input logic         dmem_resp     // Handshake signal
);
  // ----
  // Signal Declarations & Logic
  // ----

  // Stall Signals
  logic           global_stall;
  logic           imem_stall;
  logic           dmem_stall; 

  assign global_stall = imem_stall || dmem_stall;

  // PC
  logic [31:0]    pc, pc_next;

  // Regfile Signals
  logic [4:0]     rs1_s, rs2_s, wb_rd_s;
  logic           wb_regf_we;
  logic [31:0]    rs1_v, rs2_v, wb_rd_v;

  // Stage registers
  if_id_t  if_id_reg,  if_id_reg_next;
  id_ex_t  id_ex_reg,  id_ex_reg_next;
  ex_mem_t ex_mem_reg, ex_mem_reg_next;
  mem_wb_t mem_wb_reg, mem_wb_reg_next;

  // Forwarding registers and logic (a module without creating a module)
  fwd_t    ex_mem_fwd_reg, mem_wb_fwd_reg;

  // EX/MEM -> EX stage; when EX needs something from the mem stage
  assign ex_mem_fwd_reg.valid = ex_mem_reg.valid;
  assign ex_mem_fwd_reg.we    = ex_mem_reg.valid && (ex_mem_reg.rd != 5'd0) && !ex_mem_reg.is_store && !ex_mem_reg.is_load;
  assign ex_mem_fwd_reg.rd    = ex_mem_reg.rd;
  assign ex_mem_fwd_reg.data  = ex_mem_reg.alu_out;

  // MEM/WB -> EX stage; when EX needs something from the wb stage
  assign mem_wb_fwd_reg.valid = mem_wb_reg.valid;
  assign mem_wb_fwd_reg.we    = mem_wb_reg.valid && (mem_wb_reg.rd != 5'd0) && !mem_wb_reg.is_store;
  assign mem_wb_fwd_reg.rd    = mem_wb_reg.rd;
  assign mem_wb_fwd_reg.data  = mem_wb_reg.is_load ? mem_wb_reg.rdata : mem_wb_reg.alu_data;

  // Memory signals
  logic [31:0]    dmem_addr_ex;
  logic [31:0]    dmem_wdata_ex;
  logic [3:0]     dmem_rmask_ex;
  logic [3:0]     dmem_wmask_ex;
  
  logic [31:0]    target_pc;
  logic           branch_taken;
  logic           load_hazard;
  logic [31:0]    pc_plus4;
  
  assign pc_plus4 = pc + 32'd4;

  always_comb begin
    load_hazard = 1'b0;
    if(id_ex_reg.is_load && id_ex_reg.valid) begin // (id_ex_reg.rd != 5'b0) && ((id_ex_reg.rd == rs1_s) || (id_ex_reg.rd == rs2_s))) begin
      load_hazard = 1'b1;
    end
  end

  always_comb begin
    if (branch_taken) begin
      pc_next = target_pc;
    end else if (global_stall) begin
      pc_next = pc;
    end else if(load_hazard) begin
      pc_next = pc;
    end else begin
      pc_next = pc_plus4; 
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      pc                <= 'haaaaa000;
      if_id_reg.valid   <= '0;
      id_ex_reg.valid   <= '0;
      ex_mem_reg.valid  <= '0;
      mem_wb_reg.valid  <= '0;
    end else if (!global_stall) begin
      if (branch_taken) begin
        pc            <= target_pc;
        if_id_reg     <= '0;
        id_ex_reg     <= '0;
      end else if (load_hazard) begin
        id_ex_reg              <= '0;     
        pc                     <= pc_next;  
        if_id_reg.latched_inst <= imem_rdata;
        if_id_reg.hazard_flag  <= load_hazard; 
      end else begin
        pc <= pc_next;
        if_id_reg <= if_id_reg_next;
        if_id_reg.latched_inst <= imem_rdata;
        if_id_reg.hazard_flag  <= load_hazard;
        id_ex_reg     <= id_ex_reg_next;
      end
      ex_mem_reg <= ex_mem_reg_next;
      mem_wb_reg <= mem_wb_reg_next;
    end
  end


  // ----
  // Module instantiations
  // ----

  regfile regfile_i (
    .clk     (clk),
    .rst     (rst),

    .regf_we (wb_regf_we),
    .rd_s    (wb_rd_s),
    .rd_v    (wb_rd_v),

    .rs1_s   (rs1_s),
    .rs2_s   (rs2_s),
    .rs1_v   (rs1_v),
    .rs2_v   (rs2_v)
  );

  if_stage if_stage_i (
    .imem_addr      (imem_addr),
    .imem_mask      (imem_rmask),
    .imem_stall     (imem_stall),
    .imem_resp      (imem_resp),
    .global_stall   (global_stall),
    .pc             (pc),
    .pc_next        (pc_next),
    .if_id_reg_next (if_id_reg_next)
  );


  id_stage id_stage_i (
    .if_id_reg      (if_id_reg),
    .id_ex_reg_next (id_ex_reg_next),
    .inst           (imem_rdata),
    .rs1_s          (rs1_s),
    .rs2_s          (rs2_s),
    .rs1_v          (rs1_v),
    .rs2_v          (rs2_v),
    .imem_resp      (imem_resp),
    .pc             (pc),
    .pc_plus4       (pc_plus4)
  );

  ex_stage ex_stage_i (
    .id_ex_reg       (id_ex_reg),
    .ex_mem_reg_next (ex_mem_reg_next),
    .dmem_addr       (dmem_addr_ex),
    .dmem_rmask      (dmem_rmask_ex),
    .dmem_wmask      (dmem_wmask_ex),
    .dmem_wdata      (dmem_wdata_ex),
    .branch_taken    (branch_taken),
    .target_pc       (target_pc),
    .ex_mem_fwd      (ex_mem_fwd_reg),
    .mem_wb_fwd      (mem_wb_fwd_reg),
    .global_stall     (global_stall)
  );

  mem_stage mem_stage_i (
    .ex_mem_reg      (ex_mem_reg),
    .mem_wb_reg_next (mem_wb_reg_next),
    .dmem_stall      (dmem_stall),
    .dmem_resp       (dmem_resp),
    .dmem_rdata      (dmem_rdata)
  );

  wb_stage wb_stage_i (
    .mem_wb_reg     (mem_wb_reg),
    .wb_rd_v        (wb_rd_v),
    .wb_rd_s        (wb_rd_s),
    .wb_regf_we     (wb_regf_we)
  );
  
  // IMPORTANT: Memeory Logic for load/stores
  always_comb begin
    if (ex_mem_reg.valid && (ex_mem_reg.is_load || ex_mem_reg.is_store) && !dmem_resp) begin // Checking if there is a memory operation and the mem hasnt responded yet
      // Use the signals stored in the MEM stage pipeline register
      dmem_addr = ex_mem_reg.dmem_addr;
      dmem_rmask = ex_mem_reg.dmem_rmask;
      dmem_wmask = ex_mem_reg.dmem_wmask;
      dmem_wdata = ex_mem_reg.dmem_wdata;
    end else begin
      // Use the signals from the execute stage
      dmem_addr = dmem_addr_ex;
      dmem_rmask = dmem_rmask_ex;
      dmem_wmask = dmem_wmask_ex;
      dmem_wdata = dmem_wdata_ex;
    end
  end
  

  // ----
  // RVFI Logic
  // ----

  logic [63:0] order;

  // Add more signals here for easy access in rvfi_reference.json!

  // Tip: For RVFI and HVL logic specifically, you can access signals
  // in submodules with [instance name].signal. You can even use the
  // dot operator to access a submodule inside of that instance!

  // Ex 1: assign test_signal = ex_stage_i.a;
  // Ex 2: assign another_test_signal = ex_stage_i.alu.as;
  
  logic commit;
  assign commit = mem_wb_reg.valid && !global_stall;

  always_ff @(posedge clk) begin
    if (rst) begin
      order <= 64'd0;
    end else if (mem_wb_reg.valid && !global_stall) begin
      order <= order + 1;
    end
  end
endmodule : cpu