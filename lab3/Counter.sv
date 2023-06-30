module Counter (
    input logic clk, rst_n,
    output logic clk2
);
  
logic next_clk2, A, next_A;

always @(posedge clk, negedge rst_n) begin : seq_block
    if(!rst_n) begin
        A <= 1;
        clk2 <= 0;
    end
    else begin
        clk2 <= next_clk2;
        A <= next_A;
    end
end

always_comb begin : comb_block
    next_A = !A;
    next_clk2 = clk2 ^ A;
end
  
endmodule