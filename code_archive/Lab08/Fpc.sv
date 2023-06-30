module FP_ADD(
// input signals
a_sign,
b_sign,
a_exp,
b_exp,
a_frac,
b_frac,
// output signals
add_result
);

input a_sign, b_sign;
input [7:0] a_exp, b_exp, a_frac, b_frac;
output logic [15:0] add_result;
logic [7:0] max_exp, shifted_a_frac, shifted_b_frac, out_exp;
logic signed [8:0] signed_a_frac, signed_b_frac;
logic signed [9:0] frac_sum;
logic [8:0] frac_unnormalized;
logic [6:0] out_frac;
logic exp_comp;

always_comb begin : fp_add_comb
    exp_comp = a_exp > b_exp;
    max_exp = exp_comp ? a_exp : b_exp;

    shifted_a_frac = a_frac >> (max_exp - a_exp);
    shifted_b_frac = b_frac >> (max_exp - b_exp);

    signed_a_frac[7:0] = (a_sign) ? ~(shifted_a_frac) + 1 : shifted_a_frac;
    signed_a_frac[8] = a_sign;
    signed_b_frac[7:0] = (b_sign) ? ~(shifted_b_frac) + 1 : shifted_b_frac;
    signed_b_frac[8] = b_sign;

    frac_sum = signed_a_frac + signed_b_frac;
    frac_unnormalized = frac_sum[9] ? ~(frac_sum[8:0]) + 1 : frac_sum[8:0];

    casez(frac_unnormalized)
        9'b1????????: begin
            out_exp = max_exp +1;
            out_frac = frac_unnormalized[7:1];
        end
        9'b01???????: begin
            out_exp = max_exp;
            out_frac = frac_unnormalized[6:0];
        end
        9'b001??????: begin
            out_exp = max_exp - 1;
            out_frac = {frac_unnormalized[5:0], 1'b0};
        end
        9'b0001?????: begin
            out_exp = max_exp - 2;
            out_frac = {frac_unnormalized[4:0], 2'b0};
        end
        9'b00001????: begin
            out_exp = max_exp - 3;
            out_frac = {frac_unnormalized[3:0], 3'b0};
        end
        9'b000001???: begin
            out_exp = max_exp - 4;
            out_frac = {frac_unnormalized[2:0], 4'b0};
        end
        9'b0000001??: begin
            out_exp = max_exp - 5;
            out_frac = {frac_unnormalized[1:0], 5'b0};
        end
        9'b00000001?: begin
            out_exp = max_exp - 6;
            out_frac = {frac_unnormalized[0], 6'b0};
        end
        9'b000000001: begin
            out_exp = max_exp - 7;
            out_frac = 0;
        end
        9'b000000000: begin
            out_exp = max_exp;
            out_frac = 0;
        end
        default: begin
            out_exp = 8'bx;
            out_frac = 7'bx;
        end
    endcase

    add_result = {frac_sum[9], out_exp, out_frac};
end

endmodule

module  FP_MUL (
// input signals
a_sign,
b_sign,
a_exp,
b_exp,
a_frac,
b_frac,
// output signals
mul_result
);
    
input a_sign, b_sign;
input [7:0] a_exp, b_exp, a_frac, b_frac;
output logic [15:0] mul_result;

logic [7:0] out_exp;
logic [6:0] out_frac;
logic out_sign;
logic [15:0] frac_unnormalized;
logic [8:0] exp_sum;

always_comb begin : mul_comb
    out_sign = a_sign ^ b_sign;
    frac_unnormalized = a_frac * b_frac;
    exp_sum = a_exp + b_exp - 127;

    casez(frac_unnormalized)
        16'b1???????????????: begin
        out_exp = exp_sum+1;
        out_frac = frac_unnormalized[14:8];
        end

        16'b01??????????????: begin
        out_exp = exp_sum-0;
        out_frac = frac_unnormalized[13:7];
        end

        16'b001?????????????: begin
        out_exp = exp_sum-1;
        out_frac = frac_unnormalized[12:6];
        end

        16'b0001????????????: begin
        out_exp = exp_sum-2;
        out_frac = frac_unnormalized[11:5];
        end

        16'b00001???????????: begin
        out_exp = exp_sum-3;
        out_frac = frac_unnormalized[10:4];
        end

        16'b000001??????????: begin
        out_exp = exp_sum-4;
        out_frac = frac_unnormalized[9:3];
        end

        16'b0000001?????????: begin
        out_exp = exp_sum-5;
        out_frac = frac_unnormalized[8:2];
        end

        16'b00000001????????: begin
        out_exp = exp_sum-6;
        out_frac = frac_unnormalized[7:1];
        end

        16'b000000001???????: begin
        out_exp = exp_sum-7;
        out_frac = frac_unnormalized[6:0];
        end

        16'b0000000001??????: begin
        out_exp = exp_sum-8;
        out_frac = {frac_unnormalized[5:0], 1'b0};
        end

        16'b00000000001?????: begin
        out_exp = exp_sum-9;
        out_frac = {frac_unnormalized[4:0], 2'b0};
        end

        16'b000000000001????: begin
        out_exp = exp_sum-10;
        out_frac = {frac_unnormalized[3:0], 3'b0};
        end

        16'b0000000000001???: begin
        out_exp = exp_sum-11;
        out_frac = {frac_unnormalized[2:0], 4'b0};
        end

        16'b00000000000001??: begin
        out_exp = exp_sum-12;
        out_frac = {frac_unnormalized[1:0], 5'b0};
        end

        16'b000000000000001?: begin
        out_exp = exp_sum-13;
        out_frac = {frac_unnormalized[0], 6'b0};
        end

        16'b0000000000000001: begin
        out_exp = exp_sum - 14;
        out_frac = 0;
        end

        

        default:begin
            out_exp = 'bx;
            out_frac = 'bx;
        end
    endcase
    mul_result = {out_sign, out_exp, out_frac};
end

endmodule

module Fpc(
// input signals
clk,
rst_n,
in_valid,
in_a,
in_b,
mode,
// output signals
out_valid,
out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid, mode;
// sign 1 bit, exp 8 bit(-127), frac 7 bit
input [15:0] in_a, in_b;
output logic out_valid;
output logic [15:0] out;

// input processing
logic mode_buffer, mode_buffer_nxt;
logic a_sign, b_sign;
logic [7:0] a_exp, b_exp, a_frac, b_frac;
logic [6:0] a_frac_buffer, b_frac_bufer;
logic [15:0] a_buffer, b_buffer, a_buffer_nxt, b_buffer_nxt;
logic [15:0] out_nxt, out_temp;
logic sel;

// calculation
logic [15:0] mul_result, add_result, cal_result;

// control fsm
logic [1:0] next_state, curr_state, state;
parameter IDLE = 2'b00,
          CAL = 2'b01,
          OUTPUT = 2'b10;

//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------
FP_MUL mul(.a_sign(a_sign), .b_sign(b_sign), .a_exp(a_exp), .b_exp(b_exp), .a_frac(a_frac), .b_frac(b_frac), .mul_result(mul_result));
FP_ADD add(.a_sign(a_sign), .b_sign(b_sign), .a_exp(a_exp), .b_exp(b_exp), .a_frac(a_frac), .b_frac(b_frac), .add_result(add_result));

assign sel = state == CAL;

always_comb begin : out_comb
    /*if(sel)begin
        out_temp = mode_buffer ? mul_result : add_result;
    end
    else begin
        out_temp = 0;
    end*/
    casez(state)
        CAL: begin
            out_temp = mode_buffer ? mul_result : add_result;
        end
        default: begin
            out_temp = 0;
        end
    endcase
end

always_comb begin : out_nxt_comb
    /*if(state == CAL)begin
        out_nxt = out_temp;
    end
    else begin
        out_nxt = 0;
    end*/
    //out_nxt = (sel) ? out_temp : 0;

    casez(state)
        
        2'b10:begin
            out_nxt = 0;
        end
        2'b00:begin
            out_nxt = 0;
        end
        2'b01:begin
            out_nxt = out_temp;
        end
        default: out_nxt = 2'bx;
    endcase
end

always_ff @( posedge clk or negedge rst_n ) begin : out_seq
    if(!rst_n) begin
        out <= 0;
    end
    else begin
        out <= out_nxt;
    end
end

always_comb begin : input_parse_comb
    a_sign = a_buffer[15];
    b_sign = b_buffer[15];

    a_exp = a_buffer[14:7];
    b_exp = b_buffer[14:7];

    a_frac = {1'b1, a_buffer[6:0]};
    b_frac = {1'b1, b_buffer[6:0]};
end

always_ff @( posedge clk or negedge rst_n ) begin : input_seq
    if(!rst_n) begin
        mode_buffer <= 0;
        a_buffer <= 0;
        b_buffer <= 0;
    end
    else begin
        mode_buffer <= mode_buffer_nxt;
        a_buffer <= a_buffer_nxt;
        b_buffer <= b_buffer_nxt;
    end
end

always_comb begin : nxt_input_comb
    if(state == IDLE && in_valid) begin
        a_buffer_nxt = in_a;
        b_buffer_nxt = in_b;
        mode_buffer_nxt = mode;
    end
    else begin
        a_buffer_nxt = a_buffer;
        b_buffer_nxt = b_buffer;
        mode_buffer_nxt = mode_buffer;
    end
end

always_comb begin : next_state_comb
    state = curr_state;
    casez(curr_state)
        IDLE: next_state = (in_valid) ? CAL : IDLE;
        CAL: next_state = OUTPUT;
        OUTPUT: next_state = IDLE;
        default: next_state = 2'bx;
    endcase
end

always_ff @( posedge clk or negedge rst_n ) begin : state_seq
    if(!rst_n) begin
        curr_state <= IDLE;
    end
    else begin
        curr_state <= next_state;
    end
end

always_comb begin : out_valid_comb
    out_valid = state == OUTPUT;
end

endmodule

