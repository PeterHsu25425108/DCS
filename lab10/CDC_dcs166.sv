`include "synchronizer.v"

module CDC(
    //input
    clk_1,
    clk_2,
    rst_n,
    in_valid,
    in_a,
    in_b,
    mode,
    //output
    out,
    out_valid
);
    
parameter IDLE = 2'b00,
          COMPUTE = 2'b01,
          OUT = 2'b10;

input clk_1, clk_2, rst_n, in_valid, mode;
input [3:0] in_a, in_b;
output logic [7:0] out;
output logic out_valid;
logic [3:0] a, b;
logic mode_buffer;
logic [1:0] curr_state, state, nxt_state;
logic clk, nxt_D, D, Q, Q_buffer, CDC_res;

// dataflow
always_ff @(posedge clk_1 or negedge rst_n) begin : input_seq
    if(!rst_n)begin
        a <= 0;
        b <= 0;
        mode_buffer <= 0;
    end
    else begin
        a <= in_valid ? in_a : a;
        b <= in_valid ? in_b : b;
        mode_buffer <= in_valid ? mode : mode_buffer;
    end 
end

always_comb begin : out_comb
    out_valid = state == OUT;

    if(state == IDLE)begin
        out = 0;
    end
    else begin
        out = mode_buffer ? a * b : a + b;
    end
end

// control fsm
always_ff @(posedge clk_1 or negedge rst_n) begin : D_seq
    if(!rst_n)begin
        D <= 0;
    end
    else begin
        D <= nxt_D;
    end
end

always_comb begin : nxt_D_comb
    nxt_D = in_valid ^ D;
end

synchronizer syn(.D(D), .clk(clk_2), .rst_n(rst_n), .Q(Q));

always_ff @(posedge clk_2 or negedge rst_n) begin : Q_buffer_seq
    if(!rst_n)begin
        Q_buffer <= 0;
    end
    else begin
        Q_buffer <= Q;
    end
end

always_comb begin : CDC_res_comb
    CDC_res = Q ^ Q_buffer;
end

always_ff @(posedge clk_2 or negedge rst_n) begin : state_seq
    if(!rst_n)begin
        curr_state <= IDLE;
    end
    else begin
        curr_state <= nxt_state;
    end
end

always_comb begin : state_comb
    state = curr_state;
    casez (curr_state)
        IDLE: nxt_state = CDC_res ? COMPUTE : IDLE;

        COMPUTE: nxt_state = OUT;

        OUT: nxt_state = IDLE;
        default: nxt_state = curr_state;
    endcase
end

endmodule