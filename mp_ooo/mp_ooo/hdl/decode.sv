module decode
import types::*;
(
    input logic [63:0] order,
    input logic flush,
    input   imem_pkt_t                     imem_q_data,
    input   logic                          rob_full,     //checks if the ROB is full
    input   logic [$clog2(ROB_DEPTH)-1:0]  rob_alloc,    //location of the newly allocated ROB index
    input reg_t                            rs1_regf,
    input reg_t                            rs2_regf,

    output  logic  [4:0]                    rs1_sel,
    output  logic  [4:0]                    rs2_sel,
    output  logic                           can_rename,
    output  logic  [4:0]                    rd_to_rename,
    output  logic  [$clog2(ROB_DEPTH)-1:0]  rob_tag,      // tag of the ROB index for reservation
    output  decode_to_issue_t               decode_out    // struct of information for issue
);

  logic [31:0] inst;
  assign inst = imem_q_data.instr;
  logic [6:0]  opcode;
  logic [2:0]  funct3;
  logic [6:0]  funct7;
  logic [31:0] i_imm, s_imm, b_imm, u_imm, j_imm;

  assign opcode       = inst[6:0];
  assign funct3       = inst[14:12];
  assign funct7       = inst[31:25];
  assign rs1_sel      = inst[19:15];
  assign rs2_sel      = inst[24:20];
  assign rd_to_rename = (opcode == br || opcode == store) ? '0 : inst[11:7];

  //Immediate values
  assign i_imm  = {{21{inst[31]}}, inst[30:20]};
  assign s_imm  = {{21{inst[31]}}, inst[30:25], inst[11:7]};
  assign b_imm  = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
  assign u_imm  = {inst[31:12], 12'h000};
  assign j_imm  = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};


  always_comb begin
    decode_out = '0;
    decode_out.inst        = inst;
    decode_out.opcode      = opcode;
    decode_out.funct3      = funct3;
    decode_out.funct7      = funct7;
    decode_out.rs1         = rs1_regf;
    decode_out.rs2         = rs2_regf;
    decode_out.rd          = rd_to_rename;
    decode_out.valid       = imem_q_data.valid;
    decode_out.order       = order;

    decode_out.bj      = NONE;
    decode_out.br_pred = imem_q_data.br_pred;
    decode_out.br_pred_info = imem_q_data.br_pred_info;
    decode_out.pc      = imem_q_data.pc;

    // RVFI assignments
    decode_out.rvfi           = imem_q_data.rvfi;
    decode_out.rvfi.order     = order;
    decode_out.rvfi.rs1_addr  = rs1_sel;
    decode_out.rvfi.rs1_rdata = rs1_regf.data;

    decode_out.rvfi.rd_addr = rd_to_rename;   //rob tag of inst is the return destination post


    // Rename logic
    can_rename         = !rob_full && !flush; // && !(opcode == br);
    rob_tag            = rob_alloc;
    decode_out.rob_tag = rob_tag;


    unique case (opcode)
      reg_alu : begin
        decode_out.rvfi.rs2_addr  = rs2_sel;
        decode_out.rvfi.rs2_rdata = rs2_regf.data;

        //if it is a multiply or divide
        if (funct7 == mul_div_funct7) begin
          unique case (funct3)
            mul_funct3   : decode_out.multop = mul_op;
            mulh_funct3  : decode_out.multop = mulh_op;
            mulsu_funct3 : decode_out.multop = mulsu_op;
            mulu_funct3  : decode_out.multop = mulu_op;
            div_funct3   : decode_out.multop = div_op;
            divu_funct3  : decode_out.multop = divu_op;
            rem_funct3   : decode_out.multop = rem_op;
            remu_funct3  : decode_out.multop = remu_op;
            default: decode_out.multop = mul_op;
          endcase
          if (funct3 inside {mul_funct3, mulh_funct3, mulsu_funct3, mulu_funct3}) begin
            decode_out.funct_unit = to_mul;
          end else begin
            decode_out.funct_unit = to_div;
          end

        end else begin
          //standard R-type instructions
          decode_out.funct_unit = to_alu;
          unique case (funct3)
            xor_funct3    : decode_out.aluop = xor_op;
            or_funct3     : decode_out.aluop = or_op;
            and_funct3    : decode_out.aluop = and_op;
            sll_funct3    : decode_out.aluop = sll_op;
            slt_funct3    : decode_out.aluop = slt_op;
            sltu_funct3   : decode_out.aluop = sltu_op;

            addsub_funct3 :
            begin
              unique case (funct7)
                add_logic_funct7 : decode_out.aluop = add_op;
                sub_arith_funct7 : decode_out.aluop = sub_op;
                default :          decode_out.aluop = none_op;
              endcase
            end
            sr_funct3     :
            begin
              unique case (funct7)
                add_logic_funct7 : decode_out.aluop = srl_op;
                sub_arith_funct7 : decode_out.aluop = sra_op;
                default :          decode_out.aluop = none_op;
              endcase
            end
            default : decode_out.aluop = add_op;
          endcase
        end
      end

      imm_alu : begin
        decode_out.imm            = i_imm;
        decode_out.funct_unit     = to_alu;
        decode_out.use_imm        = 1'b1;
        decode_out.rvfi.rs2_rdata = '0;
        decode_out.rvfi.rs2_addr  = '0;
        unique case (funct3)
          addsub_funct3 : decode_out.aluop = add_op;
          xor_funct3    : decode_out.aluop = xor_op;
          or_funct3     : decode_out.aluop = or_op;
          and_funct3    : decode_out.aluop = and_op;
          sll_funct3    : decode_out.aluop = sll_op;
          slt_funct3    : decode_out.aluop = slt_op;
          sltu_funct3   : decode_out.aluop = sltu_op;
          sr_funct3     :
          begin
            unique case (funct7)
              add_logic_funct7 : decode_out.aluop = srl_op;
              sub_arith_funct7 : decode_out.aluop = sra_op;
              default :          decode_out.aluop = none_op;
            endcase
          end
          default : decode_out.aluop = add_op;
        endcase
      end

      lui : begin
        decode_out.imm            = u_imm;
        decode_out.funct_unit     = to_alu;
        decode_out.aluop          = lui_op;
        decode_out.use_imm        = 1'b1;
        decode_out.rvfi.rs2_rdata = '0;
        decode_out.rvfi.rs2_addr  = '0;
        decode_out.rvfi.rs1_rdata = '0;
        decode_out.rvfi.rs1_addr  = '0;
      end

      auipc : begin
        decode_out.imm            = u_imm;
        decode_out.funct_unit     = to_alu;
        decode_out.aluop          = auipc_op;
        decode_out.use_imm        = 1'b1;
        decode_out.rvfi.rs1_addr  = '0;
        decode_out.rvfi.rs2_addr  = '0;
        decode_out.rvfi.rs2_rdata = '0;
        decode_out.rvfi.rs2_addr  = '0;
        decode_out.rvfi.rs1_rdata = '0;
        decode_out.rvfi.rs1_addr  = '0;
      end

      load : begin
        decode_out.imm            = i_imm;
        decode_out.funct_unit     = to_mem;
        decode_out.use_imm        = 1'b0;
        decode_out.rvfi.rs2_rdata = '0;
        decode_out.rvfi.rs2_addr  = '0;
        decode_out.ls             = IS_LOAD;
        decode_out.memop          = funct3;
      end

      store : begin
        //put book keeping here
        decode_out.imm            = s_imm;
        decode_out.funct_unit     = to_mem;
        decode_out.use_imm        = 1'b0;
        decode_out.rvfi.rs1_addr  = rs1_sel;
        decode_out.rvfi.rs1_rdata = rs1_regf.data;
        decode_out.rvfi.rs2_addr  = rs2_sel;
        decode_out.rvfi.rs2_rdata = rs2_regf.data;
        decode_out.ls             = IS_STORE;
        decode_out.memop          = funct3;
      end

      br : begin
        //put book keeping here
        decode_out.imm            = b_imm;
        decode_out.funct_unit     = to_br;
        decode_out.use_imm        = 1'b0;
        decode_out.rvfi.rs2_addr  = rs2_sel;
        decode_out.rvfi.rs2_rdata = rs2_regf.data;
        decode_out.rd             = '0;
        decode_out.rvfi.rd_addr   = '0;
        decode_out.bj = IS_BR;
        unique case (funct3)
          beq_funct3  : decode_out.brop = beq_op;
          bne_funct3  : decode_out.brop = bne_op;
          blt_funct3  : decode_out.brop = blt_op;
          bge_funct3  : decode_out.brop = bge_op;
          bltu_funct3 : decode_out.brop = bltu_op;
          bgeu_funct3 : decode_out.brop = bgeu_op;
          default     : decode_out.brop = no_op;
        endcase
      end


      jal : begin
         //put book keeping here
        decode_out.imm            = j_imm;
        decode_out.funct_unit     = to_br;
        decode_out.aluop          = add_op;
        decode_out.use_imm        = 1'b0;
        decode_out.rvfi.rs1_addr  = '0;
        decode_out.rvfi.rs1_rdata = '0;
        decode_out.rvfi.rs2_addr  = '0;
        decode_out.rvfi.rs2_rdata = '0;
        decode_out.bj = IS_JAL;
      end

      jalr : begin
        //put book keeping here
        decode_out.imm            = i_imm;
        decode_out.funct_unit     = to_br;
        decode_out.aluop          = add_op;
        decode_out.use_imm        = 1'b0;
        decode_out.rvfi.rs2_addr  = '0;
        decode_out.rvfi.rs2_rdata = '0;
        decode_out.bj = IS_JALR;
      end
    default : ;
    endcase
  end

endmodule : decode
