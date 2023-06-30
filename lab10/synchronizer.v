module synchronizer (
    // input
    clk,
    rst_n,
    D,
    // output
    Q
);
input clk, rst_n, D;
output Q;

reg A1, A2;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        A1 <= 0;
        A2 <= 0;
    end
    else begin
        A1 <= D;
        A2 <= A1;
    end
end

assign Q = A2;
    
endmodule