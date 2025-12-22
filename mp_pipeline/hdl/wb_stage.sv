module wb_stage
import rv32i_types::*;
(
  input mem_wb_t      mem_wb_reg,
  output logic [31:0] wb_rd_v,
  output logic [4:0]  wb_rd_s,
  output logic        wb_regf_we
);
  always_comb begin
    // Add Regfile write logic here!

    // Writing the data to destination register rd
    if(mem_wb_reg.is_load) begin
      wb_rd_v = mem_wb_reg.rdata;
    end else begin
      wb_rd_v = mem_wb_reg.alu_data;   
    end

    wb_rd_s = mem_wb_reg.rd;

    // We should only write if the instruction is VALID and we arent trying to write to register x0
    wb_regf_we = mem_wb_reg.valid && (mem_wb_reg.rd != 5'd0) && !mem_wb_reg.is_store;          
  end
endmodule : wb_stage
