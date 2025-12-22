module mem_stage
import rv32i_types::*;
(
  input ex_mem_t      ex_mem_reg,
  output mem_wb_t     mem_wb_reg_next,
  output logic        dmem_stall,
  input logic         dmem_resp,
  input logic [31:0]  dmem_rdata
);

  always_comb begin
    
    dmem_stall = (ex_mem_reg.is_load || ex_mem_reg.is_store) && ex_mem_reg.valid && !dmem_resp;
    
    mem_wb_reg_next.rd = ex_mem_reg.rd;

    mem_wb_reg_next.pc_next = ex_mem_reg.pc_next;
    mem_wb_reg_next.pc = ex_mem_reg.pc;

    mem_wb_reg_next.instr = ex_mem_reg.instr;
    mem_wb_reg_next.rs1_s = ex_mem_reg.rs1_s;
    mem_wb_reg_next.rs2_s = ex_mem_reg.rs2_s;
    mem_wb_reg_next.rs1_v = ex_mem_reg.rs1_v;
    mem_wb_reg_next.rs2_v = ex_mem_reg.rs2_v;
    mem_wb_reg_next.dmem_addr = ex_mem_reg.dmem_addr;
    mem_wb_reg_next.dmem_rmask = ex_mem_reg.dmem_rmask;
    mem_wb_reg_next.dmem_wmask = ex_mem_reg.dmem_wmask;
    mem_wb_reg_next.dmem_wdata = ex_mem_reg.dmem_wdata;

    mem_wb_reg_next.valid = 1'b0; 
    mem_wb_reg_next.rdata = 32'b0;
    mem_wb_reg_next.mem_rdata = 32'b0;

    mem_wb_reg_next.is_load = ex_mem_reg.is_load;
    mem_wb_reg_next.is_store = ex_mem_reg.is_store;
    mem_wb_reg_next.alu_data = ex_mem_reg.alu_out;

    // need to add checks to to see if we are valid, is_load, and dmem_resp then nest he case in that with a defualt to valid = 1 if not load
    if (ex_mem_reg.valid) begin
      if (ex_mem_reg.is_load || ex_mem_reg.is_store) begin
        if (dmem_resp) begin
          mem_wb_reg_next.valid = 1'b1;
          mem_wb_reg_next.mem_rdata = dmem_rdata;
          // Tells us which part of dmem_rdata to put into rd
          case (ex_mem_reg.load_op)
            // LB
            3'b001: begin
              case (ex_mem_reg.offset)
                2'b00:  mem_wb_reg_next.rdata = {{24{dmem_rdata[7]}}, dmem_rdata[7:0]}; 
                2'b01:  mem_wb_reg_next.rdata = {{24{dmem_rdata[15]}}, dmem_rdata[15:8]}; 
                2'b10:  mem_wb_reg_next.rdata = {{24{dmem_rdata[23]}}, dmem_rdata[23:16]}; 
                2'b11:  mem_wb_reg_next.rdata = {{24{dmem_rdata[31]}}, dmem_rdata[31:24]}; 
                default: mem_wb_reg_next.rdata = 32'b0; 
              endcase
            end
            // LH
            3'b010: begin
              if (ex_mem_reg.offset == 2'b00) begin
                mem_wb_reg_next.rdata = {{16{dmem_rdata[15]}}, dmem_rdata[15:0]};
              end else if (ex_mem_reg.offset == 2'b10) begin
                mem_wb_reg_next.rdata = {{16{dmem_rdata[31]}}, dmem_rdata[31:16]};
              end else begin
                mem_wb_reg_next.rdata = 32'b0;
              end
            end
            // LW
            3'b011: begin
              mem_wb_reg_next.rdata = dmem_rdata;
            end
            // LBU
            3'b100: begin
              case (ex_mem_reg.offset)
                2'b00:  mem_wb_reg_next.rdata = {24'b0, dmem_rdata[7:0]}; 
                2'b01:  mem_wb_reg_next.rdata = {24'b0, dmem_rdata[15:8]}; 
                2'b10:  mem_wb_reg_next.rdata = {24'b0, dmem_rdata[23:16]}; 
                2'b11:  mem_wb_reg_next.rdata = {24'b0, dmem_rdata[31:24]}; 
                default: mem_wb_reg_next.rdata = 32'b0; 
              endcase
            end 
            // LHU
            3'b101: begin
               if (ex_mem_reg.offset == 2'b00) begin
                mem_wb_reg_next.rdata = {16'b0, dmem_rdata[15:0]};
              end else if (ex_mem_reg.offset == 2'b10) begin
                mem_wb_reg_next.rdata = {16'b0, dmem_rdata[31:16]};
              end else begin
                mem_wb_reg_next.rdata = 32'b0;
              end
            end
            default: begin
              mem_wb_reg_next.rdata = 32'b0;
            end
          endcase 
        end
      end else begin
        mem_wb_reg_next.valid = 1'b1;
      end
    end
  end
endmodule : mem_stage
