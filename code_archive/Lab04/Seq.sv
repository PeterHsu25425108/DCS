module Seq(
    input logic clk, rst_n,in_valid, [3:0] in_data,
    output logic out_data, out_valid
);
  
logic [11:0] temp;

always @(posedge clk, negedge rst_n) begin : seq_block

    if(!rst_n)begin
      	temp <= 0;
    end

    else begin
        if(in_valid)begin
  	        temp <= {temp[7:4], temp[3:0], in_data[3:0]};
        end
        else begin
            temp <= 0;
        end
    end
end

always_comb begin : comb_block
    // out_data
    if(temp[11:8]!=0)begin
        if((temp[7:4] > temp[3:0] && temp[11:8] > temp[7:4]) || (temp[7:4] < temp[3:0] && temp[11:8] < temp[7:4]))begin // condition met
            out_data = 1;
        end
        else begin // input and output are both valid but doesn't meet the condition
            out_data = 0;
        end
    end
    else begin
        out_data = 0;
    end

    // out_valid
  	out_valid = (temp[11:8]!=0);
end
  
endmodule