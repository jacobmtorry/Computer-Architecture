module if_stage
import rv32i_types::*;
(
  input   logic   [31:0]  pc,               // Current program counter
  input   logic   [31:0]  pc_next,          // Next program counter
  input   logic           imem_resp,        // Instruction Memory response valid
  input   logic           global_stall,

  output  logic   [31:0]  imem_addr,        // Address to get instruction from in memory
  output  logic   [3:0]   imem_mask,        // How many bytes to read (want all 4)
  output  logic           imem_stall,       // Stall signal while we wait for memory response
  output  if_id_t         if_id_reg_next    // Data to pass to the next if_id_reg pipline stage
);

  always_comb begin
    // Add logic to update the IF/ID register, read from imem
    
    // Sending the current PC to instruction memory to get the instruction
    imem_addr = global_stall ? pc : pc_next;

    // Reading all 4 bytes of the instruction  
    imem_mask = 4'b1111;

    // Stall the pipleine until memory responds with valid data
    imem_stall = ~imem_resp;  


    // Preapre data for updating the IF/ID register
    if_id_reg_next.valid = imem_resp;
    if_id_reg_next.pc_next = pc_next;
    if_id_reg_next.pc = pc;    
    if_id_reg_next.latched_inst = 32'b0;
    if_id_reg_next.hazard_flag = 1'b0;         
  end
endmodule : if_stage
