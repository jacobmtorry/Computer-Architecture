package types;

// LOCAL PARAMETERS

// I CACHE
localparam I_WAYS = 4;
localparam I_SETS = 32;
localparam I_WAY_BITS    = (I_WAYS > 1) ? $clog2(I_WAYS) : 1;
localparam I_SET_BITS    = $clog2(I_SETS);
localparam I_PLRU_LEVELS = $clog2(I_WAYS);
localparam I_PLRU_BITS   = I_WAYS - 1;
localparam I_TAG_BITS    = 32 - I_SET_BITS - 5;

// D CACHE
localparam D_WAYS = 4;
localparam D_SETS = 16;
localparam D_WAY_BITS    = $clog2(D_WAYS);
localparam D_SET_BITS    = $clog2(D_SETS);
localparam D_PLRU_LEVELS = $clog2(D_WAYS);
localparam D_PLRU_BITS   = D_WAYS - 1;
localparam D_TAG_BITS    = 32 - D_SET_BITS - 5;


// QUEUE / RS
localparam IMEM_Q_DEPTH = 4;

localparam     ROB_DEPTH = 16;
localparam  ALU_RS_DEPTH = 8;
localparam  MUL_RS_DEPTH = 8;
localparam  DIV_RS_DEPTH = 2;
localparam   BR_RS_DEPTH = 8;
localparam  MEM_RS_DEPTH = 8;


// MEM Arbiter
localparam MEM_ARB_DEPTH = 4;

// CDB Arbiter Queue Depths
localparam  BR_BUF_Q_DEPTH = 2;
localparam MEM_BUF_Q_DEPTH = 2;
localparam MUL_BUF_Q_DEPTH = 3;
localparam DIV_BUF_Q_DEPTH = 3;
localparam ALU_BUF_Q_DEPTH = 3;

// Typecast integer to logic
typedef logic [$clog2(ALU_RS_DEPTH)-1:0] alu_sus;
typedef logic [$clog2(MUL_RS_DEPTH)-1:0] mul_sus;
typedef logic [$clog2(DIV_RS_DEPTH)-1:0] div_sus;
typedef logic [$clog2( BR_RS_DEPTH)-1:0]  br_sus;
typedef logic [$clog2(MEM_RS_DEPTH)-1:0] mem_sus;


// br predictors
typedef enum logic [1:0] {
    STRONGLY_TAKEN      = 2'b11,
    WEAKLY_TAKEN        = 2'b10,
    WEAKLY_NOT_TAKEN    = 2'b01,
    STRONGLY_NOT_TAKEN  = 2'b00
} br_pred_e;

typedef enum logic [1:0] {
    STRONGLY_GSHARE      = 2'b11,
    WEAKLY_GSHARE        = 2'b10,
    WEAKLY_2LEVEL    = 2'b01,
    STRONGLY_2LEVEL  = 2'b00
} tournament_e;


localparam GHT_SIZE = 8;
localparam GHR_INIT = 8'b11111111;
localparam TOURN_IDX_BITS = 8;
localparam GSHARE_IDX_BITS = 8;
localparam LHT_IDX_BITS    = 8;
localparam PHT_IDX_BITS    = 8;

localparam tournament_e TOURN_INIT  = WEAKLY_GSHARE;  // if tournament not valid
localparam br_pred_e    GSHARE_INIT = WEAKLY_NOT_TAKEN;   // if gshare not valid
localparam logic [LHT_IDX_BITS-1:0] LHT_INIT = '0;    // if LHT not valid
localparam br_pred_e    PHT_INIT    = WEAKLY_NOT_TAKEN;

// Branch Prediction Writeback
typedef struct packed {
    logic valid;
    logic [31:0] pc;
    logic [31:0] inst;
    logic [31:0] target_pc;
    logic [63:0] order;

    logic                       gshare_valid;
    br_pred_e                   gshare_state;  // enum for this
    logic                       gshare_pred;   // for wb
    logic [GSHARE_IDX_BITS-1:0] gshare_index;  // GHT ^ pc[N+1:2]

    logic                      tournament_valid;
    tournament_e               tournament_state; // enum for this
    logic                      tournament_pred;  // actual prediction
    logic [TOURN_IDX_BITS-1:0] tournament_index; // pc[N+1:2]

    logic                    LHT_valid;
    logic [LHT_IDX_BITS-1:0] LHT_index;     // PC[N+1:2] for wb
    logic [LHT_IDX_BITS-1:0] LHT_value;
    logic                    PHT_valid;
    logic [PHT_IDX_BITS-1:0] PHT_index;     // LHT[PC[N+1:2]] for wb
    br_pred_e                two_lvl_state; // enum for this
    logic                    two_lvl_pred;  // for wb
} br_pred_t;

// In cache.sv
typedef enum logic [1:0] {
    IDLE       = 2'b00,
    CHECK_FOR_HIT        = 2'b01,
    WRITEBACK  = 2'b10,
    ALLOCATE   = 2'b11
} cache_state_e;

// BJs
typedef enum logic [1:0] {
    NONE    = 2'b00,
    IS_BR   = 2'b01,
    IS_JAL  = 2'b10,
    IS_JALR = 2'b11
} bj_t;

// LSs
typedef enum logic {
    IS_LOAD    = 1'b0,
    IS_STORE   = 1'b1
} ls_t;

// In cacheline_adapter.sv
typedef struct packed {
    logic           valid;          // keeps tracks if request is active
    logic           req_issued;     // indicates that the BRAM request has alredy been issued
    logic           is_write;       // 1 = write, 0 = read
    logic   [3:0]   burst;          // what bursts have responded for a specifc line
    logic   [31:0]  base_addr;      // need to be an aligned base address
    logic   [255:0] rdata;          // assembled 256-biit line to send to cache
    logic   [255:0] wdata;
} bmem_request_t;

// RVFI Signals
  typedef struct packed {
    logic         valid;
    logic [63:0]  order;
    logic [31:0]  inst;            // instruction word
    logic [4:0]   rs1_addr;        // rs1 index
    logic [4:0]   rs2_addr;        // rs2 index
    logic [31:0]  rs1_rdata;       // value read from register file (rs1)
    logic [31:0]  rs2_rdata;       // value read from register file (rs2)
    logic [4:0]   rd_addr;         // destination register
    logic [31:0]  rd_wdata;        // value to write to destination register
    logic [31:0]  pc_rdata;        // current PC when fetched
    logic [31:0]  pc_wdata;        // next pc (duh)

    logic [31:0]  mem_addr;        // address (if memory operation)
    logic [3:0]   mem_rmask;       //read mask
    logic [3:0]   mem_wmask;       //write mask
    logic [31:0]  mem_rdata;       //read data
    logic [31:0]  mem_wdata;       //write data

  } rvfi_t;


typedef struct packed {
    logic valid;
    logic br_pred;
    logic [31:0] pc;
    logic [31:0] pc_next;
    logic [31:0] instr;
    logic [63:0] order;

    br_pred_t br_pred_info;

    rvfi_t rvfi;
} imem_pkt_t;


typedef enum logic [6:0] {
    reg_alu   = 7'b0110011, // (R type)
    imm_alu   = 7'b0010011, // (I type)
    load      = 7'b0000011, // (I type)
    store     = 7'b0100011, // (S type)
    br        = 7'b1100011, // (B type)
    jal       = 7'b1101111, // (J type)
    jalr      = 7'b1100111, // (I type)
    lui       = 7'b0110111, // (U type)
    auipc     = 7'b0010111  // (U type)
} rv32i_opcode_t;

typedef enum logic [2:0] {
    addsub_funct3   = 3'b000,
    xor_funct3      = 3'b100,
    or_funct3       = 3'b110,
    and_funct3      = 3'b111,
    sll_funct3      = 3'b001,
    sr_funct3       = 3'b101,
    slt_funct3      = 3'b010,  //check if its logical or arithmetic
    sltu_funct3     = 3'b011
} alu_funct3_t;

typedef enum logic [6:0] {
    add_logic_funct7       = 7'b0000000,
    sub_arith_funct7       = 7'b0100000,
    mul_div_funct7         = 7'b0000001
} alu_funct7_t;


typedef enum logic [3:0] {
    add_op   = 4'b0000,
    xor_op   = 4'b0100,
    or_op    = 4'b0110,
    and_op   = 4'b0111,
    sll_op   = 4'b0001,
    srl_op   = 4'b0101,
    slt_op   = 4'b0010,
    sltu_op  = 4'b0011,
    lui_op   = 4'b1011,
    sub_op   = 4'b1000,
    sra_op   = 4'b1101,
    auipc_op = 4'b1110,
    none_op  = 4'b1111    //just here to ensure alu op is exactly what is said
} aluops_t;


typedef enum logic [2:0] {      //the existance of this struct will be redundant but for clarity
    mem_b_funct3     = 3'b000,
    mem_h_funct3     = 3'b001,
    mem_w_funct3     = 3'b010,
    mem_bu_funct3    = 3'b100,
    mem_hu_funct3    = 3'b101
} mem_funct3_t;

// mem ops: loads and stores; widen to 4 bits so we can include all encodings
typedef enum logic [3:0] {
    mem_b_op     = 4'b0000,
    mem_h_op     = 4'b0001,
    mem_w_op     = 4'b0010,
    mem_bu_op    = 4'b0100,
    mem_hu_op    = 4'b0101,
    // store ops
    mem_sb_op    = 4'b0110,
    mem_sh_op    = 4'b0111,
    mem_sw_op    = 4'b1000,
    mem_no_op    = 4'b1111
} memops_t;

typedef enum logic [2:0] {
    beq_funct3  = 3'b000,
    bne_funct3  = 3'b001,
    blt_funct3  = 3'b100,
    bge_funct3  = 3'b101,
    bltu_funct3 = 3'b110,
    bgeu_funct3 = 3'b111
} brops_funct3_t;

typedef enum logic [2:0] {
    beq_op  = 3'b000,
    bne_op  = 3'b001,
    blt_op  = 3'b100,
    bge_op  = 3'b101,
    bltu_op = 3'b110,
    bgeu_op = 3'b111,
    no_op   = 3'b010     //just here to ensure branch is exactly taken when said
} brops_t;


typedef enum logic [2:0] {
    mul_funct3    = 3'b000,
    mulh_funct3   = 3'b001,
    mulsu_funct3  = 3'b010,
    mulu_funct3   = 3'b011,
    div_funct3    = 3'b100,
    divu_funct3   = 3'b101,
    rem_funct3    = 3'b110,
    remu_funct3   = 3'b111
} multops_funct3_t;


typedef enum logic [2:0] {
    mul_op    = 3'b000,
    mulh_op   = 3'b001,
    mulsu_op  = 3'b010,
    mulu_op   = 3'b011,
    div_op    = 3'b100,
    divu_op   = 3'b101,
    rem_op    = 3'b110,
    remu_op   = 3'b111
} multops_t;

typedef enum logic [2:0] {
    to_alu   = 3'b000,
    to_mul   = 3'b001,
    to_div   = 3'b010,
    to_br    = 3'b011,
    to_mem   = 3'b100
} functu_t;

// Regfile entry
typedef struct packed {
    logic           valid;
    logic   [31:0]   data;
    logic   [$clog2(ROB_DEPTH)-1:0] rob_tag;
} reg_t;

typedef struct packed {
    //taken care of indicriminately
    logic   [31:0]                  inst;
    logic   [6:0]                   opcode;
    logic   [4:0]                   rd;
    logic   [2:0]                   funct3;
    logic   [6:0]                   funct7;
    logic   [31:0]                  imm;
    logic                           use_imm;
    logic  [$clog2(ROB_DEPTH)-1:0]  rob_tag;
    reg_t                           rs1;
    reg_t                           rs2;
    logic                           valid;

    //taken care of based on what kind of instruction it is.
    aluops_t                        aluop;
    multops_t                       multop;
    brops_t                         brop;
    logic [2:0]                        memop;
    functu_t                        funct_unit;

    //bj shit for issue input
    bj_t bj;
    logic br_pred;
    br_pred_t br_pred_info;
    logic [31:0] pc;

    //ls shit for issue input
    ls_t ls;

    logic [63:0] order;
    rvfi_t rvfi;
} decode_to_issue_t;

// CDB Struct
typedef struct packed {
    logic           valid;
    logic   [31:0]  data;
    logic   [$clog2(ROB_DEPTH)-1:0] rob_tag;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    // cdb shit for bjs
    bj_t bj;
    logic take_target;
    logic [31:0] target_pc;

    // cdb shit for ls
    ls_t ls;

    rvfi_t rvfi;
} cdb_t;

// Reservation station
typedef struct packed {
    logic       valid;
    functu_t    fu_sel;
    multops_t   muldiv_op;
    aluops_t    alu_op;
    brops_t     br_op;
    logic [2:0]    mem_op;
    reg_t       rs1;
    reg_t       rs2;
    logic       [31:0]  imm;
    logic       use_imm;
    logic       [$clog2(ROB_DEPTH)-1:0] rob_tag;

    // rs shit for bjs
    bj_t bj;
    logic br_pred;
    logic [31:0] pc;

    // rs shit for ls
    ls_t ls;
    logic [MEM_RS_DEPTH-1:0] lsq_mask;
    logic [2:0] lsq_one_hot_idx;

    rvfi_t      rvfi;
} rs_t;

// Struct sent fron Issue to FU
typedef struct packed {
    multops_t                         muldiv_op;
    aluops_t                          alu_op;
    brops_t                           br_op;
    logic[2:0]                      mem_op;
    logic                             valid;
    logic     [31:0]                  rs1_v;
    logic     [31:0]                  rs2_v;
    logic     [31:0]                  offset;
    logic     [$clog2(ROB_DEPTH)-1:0] rob_tag;

    // rs shit for bjs
    bj_t bj;
    logic br_pred;
    logic [31:0] pc;

    // rs shit for ls
    ls_t ls;

    rvfi_t rvfi;
} fu_pkt_t;

typedef struct packed {
    logic valid;
    logic busy;
    logic [63:0]  order;

    decode_to_issue_t dispatch_info;
    cdb_t cdb_info;

    rvfi_t rvfi;
} rob_cell_t;

typedef struct packed {
    logic        valid;
    logic        is_dcache;
    logic [31:0] addr_tag;
} mem_reqs_t;

endpackage
