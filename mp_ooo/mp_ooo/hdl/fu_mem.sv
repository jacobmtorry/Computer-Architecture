module fu_mem
import types::*;
(
    input clk,
    input rst,
    input flush,

    //come from issue go to rob
    input  fu_pkt_t mem_pkt_in,
    output  cdb_t mem_out,

    //inputs come from cache
    input  logic [255:0] rdata,
    input  logic        d_cache_resp,

    //outputs go to cache
    output logic [31:0] mem_addr,
    output logic [ 3:0] mem_rmask,
    output logic [ 3:0] mem_wmask,  //only set when ROB[head] is store
    output logic [31:0] mem_wdata,
    output logic backpressure

);
logic signed   [31:0] as;
logic signed   [31:0] bs;
logic unsigned [31:0] au;
logic unsigned [31:0] bu;

logic [31:0] a, b, c;
logic [ 2:0] opcode;
logic        op_type;

logic inflight;
fu_pkt_t inflight_pkt;

logic [31:0] mem_addr_unaligned;
logic [31:0] mem_addr_unaligned_reg;
assign mem_addr_unaligned = mem_addr_unaligned_reg;
assign mem_addr = inflight_pkt.valid ? {mem_addr_unaligned[31:2], 2'b00} : 32'b0;

logic [31:0] daddy_rdata;

logic [31:0] load_result;
logic [31:0] store_data;

logic [31:0] store_data_reg;
logic [3:0]  store_mask_reg;


assign a = inflight_pkt.rs1_v;
assign b = inflight_pkt.rs2_v;
assign c = inflight_pkt.rs1_v + inflight_pkt.offset;

assign op_type            = inflight_pkt.ls;
assign opcode             = inflight_pkt.mem_op;
assign daddy_rdata = d_cache_resp       ? rdata[32*mem_addr_unaligned[4:2] +: 32] : '0;


always_comb begin
    mem_out = '0;
    mem_out.ls            = inflight_pkt.ls;
    mem_out.rs1_data      = a;
    mem_out.rs2_data      = b;
    mem_out.rob_tag       = inflight_pkt.rob_tag;
    mem_out.rvfi          = inflight_pkt.rvfi;
    mem_out.rvfi.mem_addr = mem_addr;

    mem_rmask   = '0;
    mem_wmask   = '0;
    mem_wdata   = '0;
    load_result = '0;
    store_data  = '0;

    if (inflight_pkt.valid) begin
        case (op_type)
            IS_LOAD: begin
                mem_wmask = '0;
                mem_out.rvfi.mem_wmask = '0;
                case(opcode)
                    mem_b_funct3 : mem_rmask = 4'b0001 << c[1:0];
                    mem_h_funct3 : mem_rmask = 4'b0011 << c[1:0];
                    mem_w_funct3 : mem_rmask = 4'b1111;
                    mem_bu_funct3: mem_rmask = 4'b0001 << c[1:0];
                    mem_hu_funct3: mem_rmask = 4'b0011 << c[1:0];
                    default: mem_rmask = 4'b0000;
                endcase

                if(d_cache_resp && inflight) begin
                    case(opcode)
                        mem_b_funct3 : load_result = {{24{daddy_rdata[7+8*mem_addr_unaligned[1:0]]}}, daddy_rdata[8*mem_addr_unaligned[1:0]+:8]};
                        mem_h_funct3 : load_result = {{16{daddy_rdata[15+16*mem_addr_unaligned[1]]}}, daddy_rdata[16*mem_addr_unaligned[1]+:16]};
                        mem_w_funct3 : load_result = daddy_rdata;
                        mem_bu_funct3: load_result = {24'b0, daddy_rdata[8*mem_addr_unaligned[1:0]+:8]};
                        mem_hu_funct3: load_result = {16'b0, daddy_rdata[16*mem_addr_unaligned[1]+:16]};
                        default: load_result = '0;
                    endcase

                    // put returned data on cdb
                    mem_out.valid          = inflight_pkt.valid;
                    mem_out.data           = load_result;
                    mem_out.rvfi.rd_wdata  = load_result;
                    mem_out.rvfi.mem_rdata = daddy_rdata;
                end

                // wdata
                mem_wdata              = '0;
                mem_out.rvfi.mem_wdata = '0;
                mem_out.rvfi.mem_rmask = mem_rmask;
            end

            IS_STORE: begin
                mem_wdata              = '0;
                mem_out.rvfi.mem_wdata = '0;

                mem_rmask              = '0;
                mem_out.rvfi.mem_rmask = '0;

                mem_wmask  = '0;
                store_data = '0;

                // switch for wmask
                // if(store_trigger) begin
                    case (opcode)
                        mem_b_funct3: mem_wmask = 4'b0001 << c[1:0];
                        mem_h_funct3: mem_wmask = 4'b0011 << c[1:0];
                        mem_w_funct3: mem_wmask = 4'b1111;
                        default:      mem_wmask = '0;
                    endcase

                    case (opcode)
                        mem_b_funct3: store_data[8 *mem_addr_unaligned[1:0] +: 8 ] = b[7:0];
                        mem_h_funct3: store_data[16*mem_addr_unaligned[1] +: 16] = b[15:0];
                        mem_w_funct3: store_data = b;
                        default:      store_data = '0;
                    endcase

                    mem_wdata = store_data;
                // end

                if(d_cache_resp && inflight) begin  // if dcache resp
                    // set the cdb to validate the rob entry so we can commit
                    mem_out.valid          = inflight_pkt.valid;
                    mem_out.rvfi.mem_wmask = mem_wmask;
                    mem_out.rvfi.mem_wdata = store_data;

                end
            end
            default: mem_out.valid = '0;
        endcase
    end
end

always_ff @(posedge clk) begin
        if (rst) begin
            inflight       <= 1'b0;
            inflight_pkt   <= '0;
            mem_addr_unaligned_reg <= '0;
        end else begin
            if (mem_pkt_in.valid && !inflight) begin
                inflight     <= 1'b1;
                inflight_pkt <= mem_pkt_in;
                mem_addr_unaligned_reg <= mem_pkt_in.rs1_v + mem_pkt_in.offset;
            end
            if (d_cache_resp || flush) begin
                inflight           <= 1'b0;
                inflight_pkt.valid <= 1'b0;
                mem_addr_unaligned_reg <= '0;
            end
        end
    end

assign backpressure = inflight;


endmodule : fu_mem
