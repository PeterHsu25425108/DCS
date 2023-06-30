module MUL_16(
    //input
    clk,
    rst_n,
    in_1,
    in_2,
    //output
    out_mul
);

input clk, rst_n;
input [15:0] in_1, in_2;
output logic [95:0] out_mul;
logic [95:0] nxt_out;

always_comb begin : mul16_comb
    nxt_out = in_1 * in_2;
end

always_ff @(posedge clk or negedge rst_n) begin : mul16_seq
    if(!rst_n)begin
        out_mul <= 0;
    end
    else begin
        out_mul <= nxt_out;
    end
end

endmodule

module P_MUL (
    //input
    clk,
    rst_n,
    in_1,
    in_2,
    in_3,
    in_4,
    in_valid,
    //output
    out_valid,
    out
);

input clk, rst_n, in_valid;
input [46:0] in_1;
input [46:0] in_2;
input [46:0] in_3;
input [46:0] in_4;
output logic  out_valid;
output logic [95:0] out;

logic out_valid_1, out_valid_2;
logic [95:0] nxt_out;
logic [95:0] z1;
logic [95:0] z2;
logic [95:0] z3;
logic [95:0] z4;
logic [95:0] z5;
logic [95:0] z6;
logic [95:0] z7;
logic [95:0] z8;
logic [95:0] z9;

logic [15:0] x1;
logic [15:0] x2;
logic [15:0] x3;
logic [15:0] y1;
logic [15:0] y2;
logic [15:0] y3;

logic [47:0] A, nxt_A;
logic [47:0] B, nxt_B;

    MUL_16 mul_1(.clk(clk), .rst_n(rst_n), .in_1(x1), .in_2(y1), .out_mul(z1));
    MUL_16 mul_2(.clk(clk), .rst_n(rst_n), .in_1(x1), .in_2(y2), .out_mul(z2));
    MUL_16 mul_3(.clk(clk), .rst_n(rst_n), .in_1(x2), .in_2(y1), .out_mul(z3));
    MUL_16 mul_4(.clk(clk), .rst_n(rst_n), .in_1(x2), .in_2(y2), .out_mul(z4));
    MUL_16 mul_5(.clk(clk), .rst_n(rst_n), .in_1(x1), .in_2(y3), .out_mul(z5));
    MUL_16 mul_6(.clk(clk), .rst_n(rst_n), .in_1(x3), .in_2(y1), .out_mul(z6));
    MUL_16 mul_7(.clk(clk), .rst_n(rst_n), .in_1(x2), .in_2(y3), .out_mul(z7));
    MUL_16 mul_8(.clk(clk), .rst_n(rst_n), .in_1(x3), .in_2(y2), .out_mul(z8));
    MUL_16 mul_9(.clk(clk), .rst_n(rst_n), .in_1(x3), .in_2(y3), .out_mul(z9));

always_comb begin : partition_comb
    x1 = A[47:32];
    x2 = A[31:16];
    x3 = A[15:0];
    
    y1 = B[47:32];
    y2 = B[31:16];
    y3 = B[15:0];

    //nxt_out = z1<<64 + z2<<48 + z3<<48 + z4<<32 + z5<<32 + z6<<32 + z7<<16 + z8<<16 + z9;
  nxt_out = z9;
  nxt_out += z1<<64;
  nxt_out += z2<<48;
  nxt_out += z3<<48;
  nxt_out += z4<<32;
  nxt_out += z5<<32;
  nxt_out += z6<<32;
  nxt_out += z7<<16;
  nxt_out += z8<<16;
  
  //$dispaly("z9 = %h", z9);
end

always_ff  @(posedge clk or negedge rst_n)  begin : out_seq
    if(!rst_n)begin
        out <= 0;
    end
    else begin
        out <= nxt_out;
    end
end

always_comb begin : nxt_AB_comb
    nxt_A = in_valid ? in_1 + in_2 : 0;
    nxt_B = in_valid ? in_3 + in_4 : 0;
end

always_ff @(posedge clk or negedge rst_n) begin : AB_seq
    if(!rst_n)begin
        A <= 0;
        B <= 0;
    end
    else begin
        A <= nxt_A;
        B <= nxt_B;
    end
end

always_ff @(posedge clk or negedge rst_n) begin : out_valid_seq
    if(!rst_n)begin
        out_valid <= 0;
        out_valid_1 <=0;
        out_valid_2<=0;
    end
    else begin
        out_valid_1 <= in_valid;
        out_valid_2 <= out_valid_1;
        out_valid <= out_valid_2;
    end
end

endmodule