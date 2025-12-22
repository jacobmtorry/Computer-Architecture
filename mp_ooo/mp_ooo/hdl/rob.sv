module rob
import types::*;
#(
            parameter               WIDTH       = 32,
            parameter               DEPTH       = 32
)

(
    input   logic             clk,
    input   logic             rst,
    input   logic             flush,
    input   logic             stall,
    input   decode_to_issue_t din,
    input   logic             enq_en,
    output  rob_cell_t        dout,

    output  logic [$clog2(ROB_DEPTH)-1:0] rob_index,
    output  logic [$clog2(ROB_DEPTH)-1:0] rob_head_idx,

    input   cdb_t cdb,
    output  logic q_space_avail,
    output  logic q_empty
);
    localparam HEIGHT   = $clog2(ROB_DEPTH);
    localparam BUF_SIZE = 2**HEIGHT;

    // LOGAN NOTES:
    // Need a struct for what is being inputted from the dispatch stage

    logic [HEIGHT:0] head;
    logic [HEIGHT:0] tail;

    rob_cell_t rob [BUF_SIZE];
    logic empty, full;
    logic valid_read, valid_write;

    rob_cell_t rob_to_be_written, rob_to_be_written_random_idx;

    always_comb begin
    full = '0;
    // Calculate Empty/Full flags
    empty = (head == tail);
    full  = (head[HEIGHT] != tail[HEIGHT]) && (head[HEIGHT-1:0] == tail[HEIGHT-1:0]);

    // Export Empty/Full flags
    q_empty       = empty;
    q_space_avail = ~full;

    // Assign valid flags if enabled and space is avail
    valid_write = enq_en && !full;
    valid_read  = !empty && (!rob[head[HEIGHT-1:0]].busy) && !stall;

    // prev
    // valid_read = !empty && (rob[head[HEIGHT-1:0]].valid && !rob[head[HEIGHT-1:0]].busy);

    dout          = rob[head[HEIGHT-1 : 0]];
    rob_index     = tail    [HEIGHT-1 : 0];
    rob_head_idx  = head[HEIGHT-1:0];

    // TODO:
    // !! NEED TO MAKE SURE ALL OF THESE GETS FILLED OUT
    rob_to_be_written               = '0;
    rob_to_be_written.valid         = din.valid;
    rob_to_be_written.busy          = 1'b1;
    rob_to_be_written.dispatch_info = din;
    rob_to_be_written.order         = din.order;
    rob_to_be_written.rvfi          = din.rvfi;

    rob_to_be_written_random_idx                = '0;
    rob_to_be_written_random_idx                = rob[cdb.rob_tag];
    rob_to_be_written_random_idx.cdb_info       = cdb;
    rob_to_be_written_random_idx.rvfi.rd_wdata  = cdb.rvfi.rd_wdata;
    rob_to_be_written_random_idx.rvfi.rs1_rdata = cdb.rs1_data;
    rob_to_be_written_random_idx.rvfi.rs2_rdata = cdb.rs2_data;
    rob_to_be_written_random_idx.rvfi.pc_wdata  = cdb.rvfi.pc_wdata;
    rob_to_be_written_random_idx.rvfi.mem_addr  = cdb.rvfi.mem_addr;
    rob_to_be_written_random_idx.rvfi.mem_rmask = cdb.rvfi.mem_rmask;
    rob_to_be_written_random_idx.rvfi.mem_wmask = cdb.rvfi.mem_wmask;
    rob_to_be_written_random_idx.rvfi.mem_rdata = cdb.rvfi.mem_rdata;
    rob_to_be_written_random_idx.rvfi.mem_wdata = cdb.rvfi.mem_wdata;
    // rob_to_be_written_random_idx.rvfi = cdb.rvfi;
    rob_to_be_written_random_idx.busy = 1'b0;
    end


    always_ff @(posedge clk) begin
        if(rst) begin
            head <= '0;
            tail <= '0;

            for(integer i=0; i<BUF_SIZE; i++) begin
                rob[i].valid      <= 1'b0;
                rob[i].busy       <= 1'b0;
                rob[i].rvfi.valid <= 1'b0;
                rob[i]            <= '0;
            end
        end else if(flush) begin
            head <= '0;
            tail <= '0;
            
            for(integer i=0; i<BUF_SIZE; i++) begin
                rob[i].valid      <= 1'b0;
                rob[i].busy       <= 1'b0;
                rob[i].rvfi.valid <= 1'b0;
            end
        end else begin
            head <= valid_read  ? (head + 1'b1) : head;
            tail <= valid_write ? (tail + 1'b1) : tail;
            // otherwise do this combinationally
            // rob[tail[HEIGHT-1 :0]] means index the rob at the cell given by the tail (without the MSB)
            if (valid_write) rob[tail[HEIGHT-1 : 0]] <= rob_to_be_written;

            if (cdb.valid) rob[cdb.rob_tag] <= rob_to_be_written_random_idx;

            if(valid_read) begin
                rob[head[HEIGHT-1:0]].busy <= '0;
                rob[head[HEIGHT-1:0]].valid <='0;
            end
        end
    end


endmodule : rob