module id_stage
import rv32i_types::*;
(
  input   logic   [31:0]  inst,
  output  logic   [4:0]   rs1_s,     
  output  logic   [4:0]   rs2_s,     
  input   logic   [31:0]  rs1_v,   
  input   logic   [31:0]  rs2_v,
  input   logic           imem_resp,   
  input   if_id_t         if_id_reg,
  input           [31:0]  pc,
  input           [31:0]  pc_plus4,
  output  id_ex_t         id_ex_reg_next
);

  instr_t instruction; 
  logic [31:0] i_imm, s_imm, b_imm, u_imm, j_imm;
  logic [6:0] opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;

  always_comb begin

    if (if_id_reg.hazard_flag && if_id_reg.valid) begin
      instruction.word = if_id_reg.latched_inst;
    end else begin
      instruction.word = inst;
    end

    // Get all the possible immediate values (easier this way)
    i_imm  = {{21{instruction.word[31]}}, instruction.word[30:20]};
    s_imm  = {{21{instruction.word[31]}}, instruction.word[30:25], instruction.word[11:7]};
    b_imm  = {{20{instruction.word[31]}}, instruction.word[7], instruction.word[30:25], instruction.word[11:8], 1'b0};
    u_imm  = {instruction.word[31:12], 12'h000};
    j_imm  = {{12{instruction.word[31]}}, instruction.word[19:12], instruction.word[20], instruction.word[30:21], 1'b0};

    rs1_s = instruction.word[19:15];
    rs2_s = instruction.word[24:20];
    opcode = instruction.word[6:0]; 
    funct3 = instruction.word[14:12];
    funct7 = instruction.word[31:25]; 

    // Initialize ALL id_ex_reg_next signals
    id_ex_reg_next.valid = 1'b0;
    id_ex_reg_next.pc = 32'b0;
    id_ex_reg_next.pc_next = 32'b0;
    id_ex_reg_next.instr = 32'b0;

    // Determines in casees based of what instruction we are doing
    id_ex_reg_next = '0;      

    id_ex_reg_next.valid = imem_resp;
    id_ex_reg_next.pc = pc;
    id_ex_reg_next.pc_next = pc_plus4;
    id_ex_reg_next.instr = instruction.word;

    case (opcode)    // Gets the opcode for any type of instruction because opcaode is always first 8-biit

      op_jal: begin

        // set up rd = pc + 4
        id_ex_reg_next.rd = instruction.j_type.rd;
        id_ex_reg_next.rs1_v = pc;
        id_ex_reg_next.imm = 'd4;
        id_ex_reg_next.alu_op = alu_add;
        id_ex_reg_next.ALU_rs2_mux_sel = 1'b1;

        // Set target pc: pc += imm
        id_ex_reg_next.target_pc = pc + j_imm;

        // Set that it is a jump
        id_ex_reg_next.is_jump = 1'b1;
      end

      op_jalr: begin

        // Calculate target
        id_ex_reg_next.rd = instruction.i_type.rd;
        id_ex_reg_next.rs1_s = instruction.i_type.rs1;
        id_ex_reg_next.rs1_v = rs1_v;

        id_ex_reg_next.imm = i_imm;
        id_ex_reg_next.alu_op = alu_add;
        id_ex_reg_next.ALU_rs2_mux_sel = 1'b1;

        // set that it is a jump
        id_ex_reg_next.is_jump = 1'b1;
        id_ex_reg_next.is_jalr = 1'b1;
      end

      // Branch operations
      op_br: begin

        // s_type have the same format for rs1 and rs2
        id_ex_reg_next.rs1_s = instruction.s_type.rs1;
        id_ex_reg_next.rs2_s = instruction.s_type.rs2;
        id_ex_reg_next.rs1_v = rs1_v;
        id_ex_reg_next.rs2_v = rs2_v;

        id_ex_reg_next.is_branch = 1'b1;

        // Precalculate target
        //id_ex_reg_next.target_pc = pc + b_imm;

        id_ex_reg_next.imm = b_imm;
        id_ex_reg_next.ALU_rs2_mux_sel = 1'b1;
        id_ex_reg_next.pc_sel = 1'b1;
        id_ex_reg_next.alu_op = alu_add;

        // Indicate we want to use the comparator
        id_ex_reg_next.use_cmp = 1'b1;

        // Determine which branch condition to use
        case (funct3)
          beq:  id_ex_reg_next.cmp_op = beq;
          bne:  id_ex_reg_next.cmp_op = bne;
          blt:  id_ex_reg_next.cmp_op = blt;
          bge:  id_ex_reg_next.cmp_op = bge;
          bltu: id_ex_reg_next.cmp_op = bltu;
          bgeu: id_ex_reg_next.cmp_op = bgeu;
          default: id_ex_reg_next.cmp_op = beq;
        endcase
      end
      
      // Load operations
      op_load: begin

        // All Loads load into some desitnation register
        id_ex_reg_next.rd = instruction.i_type.rd; 

        // Get rs1 
        id_ex_reg_next.rs1_s = instruction.i_type.rs1;
        id_ex_reg_next.rs1_v = rs1_v;

        // Get the imm value we are adding to rs1
        id_ex_reg_next.imm = i_imm;

        // We are always adding some rs1 to an immediate 
        id_ex_reg_next.ALU_rs2_mux_sel = 1'b1;
        id_ex_reg_next.alu_op = alu_add;

        // Indication to ALU that the output is an address
        id_ex_reg_next.is_load = 1'b1;

        // This will determin how we calculate the biit masks in execute
        case (funct3)
          lb:  id_ex_reg_next.load_op = 3'b001;
          lh:  id_ex_reg_next.load_op = 3'b010;
          lw:  id_ex_reg_next.load_op = 3'b011;
          lbu: id_ex_reg_next.load_op = 3'b100;
          lhu: id_ex_reg_next.load_op = 3'b101;
          default: id_ex_reg_next.load_op = 3'b000;
        endcase
      end

      // Store operations
      op_store: begin

        // Get rs1 
        id_ex_reg_next.rs1_s = instruction.s_type.rs1;
        id_ex_reg_next.rs1_v = rs1_v;

        // Get Data from rs2
        id_ex_reg_next.rs2_s = instruction.s_type.rs2;
        id_ex_reg_next.rs2_v = rs2_v;

        // Get the imm value we are adding to rs1
        id_ex_reg_next.imm = s_imm;

        // We are always adding some rs1 to an immediate 
        id_ex_reg_next.ALU_rs2_mux_sel = 1'b1;
        id_ex_reg_next.alu_op = alu_add;

        // Indication to ALU that the output is an address
        id_ex_reg_next.is_store = 1'b1;

        case (funct3)
          sb: id_ex_reg_next.store_op = 2'b01;
          sh: id_ex_reg_next.store_op = 2'b10;
          sw: id_ex_reg_next.store_op = 2'b11;
          default:  id_ex_reg_next.store_op = 2'b00;
        endcase
      end  
      
      // Arith operations reg-reg
      op_reg: begin   
        case (funct3)
          add: begin
            if (funct7 == 7'b0) begin
              id_ex_reg_next.alu_op = alu_add;
            end else begin
              id_ex_reg_next.alu_op = alu_sub;
            end
          end
          sll: id_ex_reg_next.alu_op = alu_sll;
          slt: begin
            id_ex_reg_next.cmp_op = blt;
            id_ex_reg_next.use_cmp = 1'b1;
          end
          sltu: begin
            id_ex_reg_next.cmp_op = bltu;
            id_ex_reg_next.use_cmp = 1'b1;
          end
          axor: id_ex_reg_next.alu_op = alu_xor;
          sr: begin
            if (funct7 == 7'b0) begin
              id_ex_reg_next.alu_op = alu_srl;
            end else begin
              id_ex_reg_next.alu_op = alu_sra;
            end
          end
          aor: id_ex_reg_next.alu_op = alu_or;
          aand: id_ex_reg_next.alu_op = alu_and;
          default: begin
            id_ex_reg_next.alu_op = alu_add;
          end
        endcase

        id_ex_reg_next.rd = instruction.r_type.rd;
        id_ex_reg_next.ALU_rs2_mux_sel = 1'b0;
        id_ex_reg_next.imm = 32'b0;

        id_ex_reg_next.rs1_s = instruction.r_type.rs1;
        id_ex_reg_next.rs2_s = instruction.r_type.rs2;
        id_ex_reg_next.rs1_v = rs1_v;
        id_ex_reg_next.rs2_v = rs2_v;
      end

      // Load Upper Immediate: rd = imm << 12
      op_lui: begin
        id_ex_reg_next.rd = instruction.u_type.rd;
        id_ex_reg_next.ALU_rs2_mux_sel = 1'b1; 
        id_ex_reg_next.imm = u_imm;
        id_ex_reg_next.alu_op = alu_add;
        id_ex_reg_next.rs1_s = 5'b0;  
        id_ex_reg_next.rs2_s = 5'b0;
        id_ex_reg_next.rs1_v = 32'b0; 
        id_ex_reg_next.rs2_v = 32'b0;
      end

      // Add Upper Immedite to PC: rd = PC + (imm << 12)
      op_auipc: begin
        id_ex_reg_next.rd = instruction.u_type.rd;
        id_ex_reg_next.ALU_rs2_mux_sel = 1'b1;  
        id_ex_reg_next.imm = u_imm;
        id_ex_reg_next.alu_op = alu_add;
        id_ex_reg_next.rs1_s = 5'b0;
        id_ex_reg_next.rs2_s = 5'b0;
        id_ex_reg_next.rs1_v = pc;  
        id_ex_reg_next.rs2_v = 32'b0;
      end

      // Arith operations reg-immediate
      op_imm: begin
        case (funct3)
          add: id_ex_reg_next.alu_op = alu_add;
          sll: id_ex_reg_next.alu_op = alu_sll;
          slt: begin
            id_ex_reg_next.cmp_op = blt;
            id_ex_reg_next.use_cmp = 1'b1;
          end
          sltu: begin
            id_ex_reg_next.cmp_op = bltu;
            id_ex_reg_next.use_cmp = 1'b1;
          end
          axor: id_ex_reg_next.alu_op = alu_xor;
          sr: begin
            if (instruction.i_type.i_imm[11:5] == 7'b0000000 ) begin
              id_ex_reg_next.alu_op = alu_srl;
            end else begin
              id_ex_reg_next.alu_op = alu_sra;
            end
          end
          aor: id_ex_reg_next.alu_op = alu_or;
          aand: id_ex_reg_next.alu_op = alu_and;
          default: begin
            id_ex_reg_next.alu_op = alu_add;
          end
        endcase

        id_ex_reg_next.rd = instruction.i_type.rd;
        id_ex_reg_next.ALU_rs2_mux_sel = 1'b1;
        id_ex_reg_next.imm = i_imm;
        id_ex_reg_next.rs1_s = instruction.i_type.rs1;
        id_ex_reg_next.rs2_s = rs2_s;
        id_ex_reg_next.rs1_v = rs1_v;
        id_ex_reg_next.rs2_v = rs2_v;
      end 

      default: begin
        // All fields are initialized at the beginning of the always_comb
      end
    endcase    
  end
endmodule : id_stage
