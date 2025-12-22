package rv32i_types;
  typedef enum logic [6:0] {
    op_lui       = 7'b0110111, // load upper imemediate (U type)
    op_auipc     = 7'b0010111, // add upper imemediate PC (U type)
    op_jal       = 7'b1101111, // jump and link (J type)
    op_jalr      = 7'b1100111, // jump and link register (I type)
    op_br        = 7'b1100011, // branch (B type)
    op_load      = 7'b0000011, // load (I type)
    op_store     = 7'b0100011, // store (S type)
    op_imm       = 7'b0010011, // arith ops with register/imemediate operands (I type)
    op_reg       = 7'b0110011  // arith ops with register operands (R type)
  } rv32i_opcode;

  typedef enum logic [2:0] {
    beq  = 3'b000,
    bne  = 3'b001,
    blt  = 3'b100,
    bge  = 3'b101,
    bltu = 3'b110,
    bgeu = 3'b111
  } branch_funct3_t;

  typedef enum logic [2:0] {
    lb  = 3'b000,
    lh  = 3'b001,
    lw  = 3'b010,
    lbu = 3'b100,
    lhu = 3'b101
  } load_funct3_t;

  typedef enum logic [2:0] {
    sb = 3'b000,
    sh = 3'b001,
    sw = 3'b010
  } store_funct3_t;

  typedef enum logic [2:0] {
    add  = 3'b000, //check logic 30 for sub if op_reg opcode
    sll  = 3'b001,
    slt  = 3'b010,
    sltu = 3'b011,
    axor = 3'b100,
    sr  = 3'b101, //check logic 30 for logical/arithmetic
    aor  = 3'b110,
    aand = 3'b111
  } arith_funct3_t;

  typedef enum logic [2:0] {
    alu_add = 3'b000,
    alu_sll = 3'b001,
    alu_sra = 3'b010,
    alu_sub = 3'b011,
    alu_xor = 3'b100,
    alu_srl = 3'b101,
    alu_or  = 3'b110,
    alu_and = 3'b111
  } alu_ops;

  typedef enum logic {
    rs1_out = 1'b0,
    pc_out  = 1'b1
  } alu_m1_sel_t;

  // IF -> ID
  typedef struct packed {
    logic valid;
    logic   [31:0]      pc;
    logic   [31:0]      pc_next; 
    logic   [31:0]      latched_inst;
    logic               hazard_flag;
  } if_id_t;

  // ID -> EX
  typedef struct packed {
    logic [31:0]    pc;
    logic [31:0]    pc_next;
    logic [31:0]    instr;

    logic valid; 

    alu_ops alu_op;

    logic [2:0]     cmp_op;
    logic use_cmp;

    logic ALU_rs2_mux_sel;
    logic pc_sel;

    logic is_load;    
    logic [2:0]     load_op;  

    logic is_store;
    logic [1:0]     store_op;

    logic [31:0]    target_pc;
    logic           is_branch;

    logic           is_jump;
    logic           is_jalr;

    logic [4:0]     rd; 
    logic [4:0]     rs1_s;
    logic [4:0]     rs2_s; 
    logic [31:0]    rs1_v;
    logic [31:0]    rs2_v;
    logic [31:0]    imm;
  } id_ex_t;

  // EX -> M
  typedef struct packed {
    logic [31:0]    pc;
    logic [31:0]    pc_next;
    logic [31:0]    instr;

    logic valid;
    logic [4:0]     rd;
    logic [31:0]    alu_out;

    logic loadU;
    logic is_load;    
    logic [2:0]     load_op;
    logic [1:0]     offset;  

    logic is_store;
    logic [1:0]     store_op;

    logic [31:0]    dmem_addr;
    logic [3:0]     dmem_rmask;
    logic [3:0]     dmem_wmask;
    logic [31:0]    dmem_wdata;

    logic [4:0]     rs1_s;
    logic [4:0]     rs2_s;
    logic [31:0]    rs1_v;
    logic [31:0]    rs2_v;
  } ex_mem_t;

  // M -> WB
  typedef struct packed {
    logic [31:0]    pc;
    logic [31:0]    pc_next;
    logic [31:0]    instr;

    logic valid;
    logic [4:0]     rd;
    logic [31:0]    alu_data;
    logic [31:0]    rdata;
    logic [31:0]    mem_rdata;

    logic is_load;
    logic is_store;

    logic [31:0]    dmem_addr;
    logic [3:0]     dmem_rmask;
    logic [3:0]     dmem_wmask;
    logic [31:0]    dmem_wdata;

    logic [4:0]     rs1_s;
    logic [4:0]     rs2_s;
    logic [31:0]    rs1_v;
    logic [31:0]    rs2_v;
  } mem_wb_t;

  typedef struct packed {
    logic valid;
    logic we;
    logic [4:0]   rd;
    logic [31:0]  data;
  } fwd_t;

  typedef union packed {
    logic [31:0] word;

    struct packed {
      logic [11:0] i_imm;
      logic [4:0]  rs1;
      logic [2:0]  funct3;
      logic [4:0]  rd;
      rv32i_opcode opcode;
    } i_type;

    struct packed {
      logic [6:0]  funct7;
      logic [4:0]  rs2;
      logic [4:0]  rs1;
      logic [2:0]  funct3;
      logic [4:0]  rd;
      rv32i_opcode opcode;
    } r_type;

    struct packed {
      logic [11:5] imm_s_top;
      logic [4:0]  rs2;
      logic [4:0]  rs1;
      logic [2:0]  funct3;
      logic [4:0]  imm_s_bot;
      rv32i_opcode opcode;
    } s_type;

    struct packed {
      logic [31:12] imm;
      logic [4:0]   rd;
      rv32i_opcode  opcode;
    } j_type;

    struct packed {
      logic [19:0] imm_u;
      logic [4:0] rd;
      rv32i_opcode  opcode;
    } u_type;
  } instr_t;
endpackage
