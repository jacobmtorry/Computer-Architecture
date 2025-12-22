module ex_stage
import rv32i_types::*;
(
  input   id_ex_t         id_ex_reg,        // Data from ID stage
  input   fwd_t           ex_mem_fwd,       // Forwarding from mem stage
  input   fwd_t           mem_wb_fwd,       // Forwarding from wb stage
  output  ex_mem_t        ex_mem_reg_next,  

  output  logic   [31:0]  dmem_addr,    
  output  logic   [3:0]   dmem_rmask,
  output  logic   [3:0]   dmem_wmask,
  output  logic   [31:0]  dmem_wdata,
  output  logic   [31:0]  target_pc,
  output  logic           branch_taken,
  input   logic           global_stall     
);

  // ALU and comparator signals
  logic   [31:0]  a;
  logic   [31:0]  b;
  logic   [31:0]  cmp_a, cmp_b;
  logic   [2:0]   aluop;
  logic   [2:0]   cmpop;
  logic   [31:0]  aluout;
  logic           cmpout;

  // Comparator
  cmp cmp_i (
    .a      (cmp_a),
    .b      (cmp_b),
    .cmpop  (cmpop),
    .cmpout (cmpout)
  );

  // ALU
  alu alu(
    .a      (a),
    .b      (b),
    .aluop  (aluop),
    .aluout (aluout)
  );

  logic [1:0]   align_offset;
  logic [31:0]  eff_addr;
  logic [31:0]  rs1_fwd;
  logic [31:0]  rs2_fwd;

  logic branchy;
  logic jumpy;
  logic validy;

  always_comb begin
    // Initialize signals to alu, cmp, and ex_mem_reg_next

    //a = id_ex_reg.rs1_v; 
    if(ex_mem_fwd.we && (ex_mem_fwd.rd == id_ex_reg.rs1_s)) begin
      rs1_fwd = ex_mem_fwd.data;
    end else if (mem_wb_fwd.we && (mem_wb_fwd.rd == id_ex_reg.rs1_s)) begin
      rs1_fwd = mem_wb_fwd.data;
    end else begin
      rs1_fwd = id_ex_reg.rs1_v;
    end

    if(ex_mem_fwd.we && (ex_mem_fwd.rd == id_ex_reg.rs2_s)) begin
      rs2_fwd = ex_mem_fwd.data;
    end else if (mem_wb_fwd.we && (mem_wb_fwd.rd == id_ex_reg.rs2_s)) begin
      rs2_fwd = mem_wb_fwd.data;
    end else begin
      rs2_fwd = id_ex_reg.rs2_v;
    end

    cmp_a = rs1_fwd;
    if (id_ex_reg.is_branch) begin
      cmp_b =  rs2_fwd;
    end else if(id_ex_reg.ALU_rs2_mux_sel == 1'b1) begin
      cmp_b = id_ex_reg.imm;
    end else begin
      cmp_b = rs2_fwd;
    end

    if(id_ex_reg.pc_sel) begin
      a = id_ex_reg.pc;
    end else begin
      a = rs1_fwd;
    end

    if(id_ex_reg.ALU_rs2_mux_sel == 1'b1) begin
      b = id_ex_reg.imm;
    end else begin
      b = rs2_fwd;
    end

    // Passing operation codes to the ALU and Comparator
    aluop = id_ex_reg.alu_op;
    cmpop = id_ex_reg.cmp_op;

    // Decied if we need to use the ALU output or the Comparator output
    if (id_ex_reg.is_jump) begin
      ex_mem_reg_next.alu_out = id_ex_reg.pc_next;
    end else if(id_ex_reg.use_cmp) begin
      ex_mem_reg_next.alu_out = {31'b0, cmpout};  // CMP output is 1-biit so we need to extend to 32
    end else begin
      ex_mem_reg_next.alu_out = aluout;
    end

    // If we are a branch/jump operation and the branch/jump should be taken
    if(id_ex_reg.is_jalr) begin
      target_pc = {aluout[31:1], 1'b0};
    end else if (id_ex_reg.is_branch) begin
      target_pc = aluout;
    end else begin
      target_pc = id_ex_reg.target_pc;
    end

    branchy = id_ex_reg.is_branch && cmpout; 
    jumpy = id_ex_reg.is_jump;
    validy = id_ex_reg.valid;
    branch_taken = validy && (branchy || jumpy);

    ex_mem_reg_next.valid = id_ex_reg.valid;
    ex_mem_reg_next.rd = id_ex_reg.rd;

    // Propgate Signals through pipeline
    ex_mem_reg_next.pc = id_ex_reg.pc;
    
    if (branch_taken) begin
      ex_mem_reg_next.pc_next = target_pc;
    end else begin
      ex_mem_reg_next.pc_next = id_ex_reg.pc_next;
    end

    ex_mem_reg_next.instr = id_ex_reg.instr;
    ex_mem_reg_next.rs1_s = id_ex_reg.rs1_s;
    ex_mem_reg_next.rs2_s = id_ex_reg.rs2_s;
    ex_mem_reg_next.rs1_v = rs1_fwd;
    ex_mem_reg_next.rs2_v = rs2_fwd;
    ex_mem_reg_next.load_op = id_ex_reg.load_op;
    ex_mem_reg_next.store_op = id_ex_reg.store_op;

    // Default values
    dmem_addr = 32'b0; 
    dmem_rmask = 4'b0000;
    dmem_wmask = 4'b0000;      
    dmem_wdata = 32'b0; 
    ex_mem_reg_next.loadU = 1'b0;
    ex_mem_reg_next.is_load = 1'b0;
    ex_mem_reg_next.is_store = 1'b0;
    ex_mem_reg_next.offset = 2'b0;


    // If we want to use the aluout as an addr for load
    if(id_ex_reg.valid && id_ex_reg.is_load) begin

      ex_mem_reg_next.is_load = 1'b1;

      eff_addr = aluout;
      align_offset = eff_addr[1:0];
      ex_mem_reg_next.offset = align_offset;

      dmem_addr = {eff_addr[31:2], 2'b00};

      case (id_ex_reg.load_op)
        3'b001: dmem_rmask = 4'b0001 << eff_addr[1:0];  // LB
        3'b010: dmem_rmask = 4'b0011 << eff_addr[1:0];  // LH
        3'b011: dmem_rmask = 4'b1111; // LW
      
        // LBU
        3'b100: begin
          ex_mem_reg_next.loadU = 1'b1;
          dmem_rmask = 4'b0001 << eff_addr[1:0];
        end 

        // LHU
        3'b101: begin
          ex_mem_reg_next.loadU = 1'b1;
          dmem_rmask = 4'b0011 << eff_addr[1:0];
        end

        default: dmem_rmask = 4'b0000;
      endcase     
    end 

    // If we want to use the aluout as an addr for store
    if(id_ex_reg.valid && id_ex_reg.is_store) begin

      ex_mem_reg_next.is_store = 1'b1;

      eff_addr = aluout;
      align_offset = eff_addr[1:0];

      dmem_addr = {eff_addr[31:2], 2'b00};


      case (id_ex_reg.store_op)

        // SB
        2'b01: begin
          dmem_wmask = 4'b0001 << eff_addr[1:0];
          dmem_wdata[8 *eff_addr[1:0] +: 8 ] = rs2_fwd[7:0];
        end

        // SH
        2'b10: begin
          dmem_wmask = 4'b0011 << eff_addr[1:0];
          dmem_wdata[16*eff_addr[1]   +: 16] = rs2_fwd[15:0];
        end

        // SW
        2'b11: begin
          dmem_wmask = 4'b1111;
          dmem_wdata = rs2_fwd;
        end

        default: begin
          dmem_wmask = 4'b0000;
          dmem_wdata = 32'b0;
        end
      endcase      
    end
        
    if(id_ex_reg.valid && (id_ex_reg.is_load || id_ex_reg.is_store)) begin
      ex_mem_reg_next.dmem_addr = dmem_addr;
      ex_mem_reg_next.dmem_rmask = dmem_rmask;
      ex_mem_reg_next.dmem_wmask = dmem_wmask;
      ex_mem_reg_next.dmem_wdata = dmem_wdata;
    end else begin
      ex_mem_reg_next.dmem_addr = 32'b0;
      ex_mem_reg_next.dmem_rmask = 4'b0;
      ex_mem_reg_next.dmem_wmask = 4'b0;
      ex_mem_reg_next.dmem_wdata = 32'b0;
    end

    if(global_stall) begin
      dmem_rmask = 4'b0;
      dmem_wmask = 4'b0;
    end
    // CP3: Forwarding logic here too (remember to consider double data hazards)
  end
endmodule : ex_stage
