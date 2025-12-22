module queue_cdb
import types::*;
#(
    parameter HEIGHT = 2
)(
    input   logic  clk,
    input   logic  rst,
    input   logic  flush,
    input   logic  enq_en,
    input   logic  deq_en,
    input   cdb_t  din,
    output  cdb_t  dout,
    output  logic  q_space_avail,
    output  logic  q_empty
);
    localparam      BUF_SIZE    = 2**HEIGHT;

    logic [HEIGHT:0] head;
    logic [HEIGHT:0] tail;
    cdb_t queue [BUF_SIZE];
    logic empty, full;
    logic valid_read, valid_write;

    // Calculate Empty/Full flags
    assign empty = (head == tail);
    assign full  = (head[HEIGHT] != tail[HEIGHT]) && (head[HEIGHT-1 : 0] == tail[HEIGHT-1 : 0]);

    // Export Empty/Full flags
    assign q_empty       = empty;
    assign q_space_avail = ~full;

    // Assign valid flags if enabled and space is avail
    assign valid_write = enq_en & !full;
    assign valid_read = deq_en  & !empty;

    assign dout = queue[head[HEIGHT-1 : 0]];

    always_ff @(posedge clk) begin
        if(rst) begin
            head <= '0;
            tail <= '0;
            for(integer i=0; i<BUF_SIZE; i++) begin
                queue[i] <= '0;
            end
        end else if (flush) begin 
            head <= tail;
            // for(integer i=0; i<BUF_SIZE; i++) begin
            //     queue[i].valid <= '0;
            // end
        end else begin
            head <= valid_read  ? (head + 1'b1) : head;
            tail <= valid_write ? (tail + 1'b1) : tail;
            // queue[tail[HEIGHT-1 :0]] means index the queue at the cell given by the tail (without the MSB)
            queue[tail[HEIGHT-1 : 0]] <= valid_write ? din : queue[tail[HEIGHT-1 : 0]];
        end
    end

endmodule : queue_cdb
