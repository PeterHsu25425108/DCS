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
input [15:0] in_a, in_b;
output logic out_valid;
output logic [15:0] out;

logic [1:0] state, next_state;
logic [15:0] store_a, next_a;
logic [15:0] store_b, next_b;

logic [7:0] fraction_a, fraction_b;
logic signed [8:0] sign_a, sign_b;
logic signed[9:0] sum;
logic [15:0] mul;

logic [7:0] max_exp;

parameter IDLE = 0,
          ADD  = 1,
          MUL  = 2;
//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------
always_ff@(posedge clk, negedge rst_n)begin
    if (!rst_n)begin
        state<=IDLE;
        store_a<=0;
        store_b<=0;
    end 
    else begin
        state<=next_state;
        store_a<=next_a;
        store_b<=next_b;
    end
end

always_comb begin : combination_part

    case (state)
        IDLE:begin
            out_valid=0;
            out=0;
            casez ({in_valid,mode})
                2'b0?:begin
                    next_state=IDLE;
                    next_a=0;
                    next_b=0;
                end 
                2'b10:begin
                    next_state=ADD;
                    next_a=in_a;
                    next_b=in_b;
                end 
                2'b11:begin
                    next_state=MUL;
                    next_a=in_a;
                    next_b=in_b;
                end 
                
                default:begin
                    next_state=IDLE;
                    next_a=0;
                    next_b=0;
                end 
            endcase
        end 
        ADD:begin
            next_a=store_a;
            next_b=store_b;
            next_state=IDLE;
            fraction_a={1'b1,store_a[6:0]};
            fraction_b={1'b1,store_b[6:0]};

            if(store_a[14:7]<store_b[14:7])begin
                sign_a=fraction_a>>(store_b[14:7]-store_a[14:7]);
                sign_b=fraction_b;
                max_exp = store_b[14:7];
            end else begin
                sign_a=fraction_a;
                sign_b=fraction_b>>(store_a[14:7]-store_b[14:7]);
                max_exp = store_a[14:7];
            end

            if(store_a[15]==1)begin
                sign_a=~sign_a+1;
            end
            if(store_b[15]==1)begin
                sign_b=~sign_b+1;
            end
            sum = sign_a+sign_b;

            out_valid=1;
            out[15] = sum[9];
            casez (sum)
                
                10'b?1????????:begin
                    out[6:0]=sum[7:1];
                    out[14:7]=max_exp+1;
                end 
                10'b?01???????:begin
                    out[6:0]=sum[6:0];
                    out[14:7]=max_exp;
                end 
                10'b?001??????:begin
                    out[6:0]={sum[5:0],1'b0};
                    out[14:7]=max_exp-1;
                end 
                10'b?0001?????:begin
                    out[6:0]={sum[4:0],2'b0};
                    out[14:7]=max_exp-2;
                end 
                10'b?00001????:begin
                    out[6:0]={sum[3:0],3'b0};
                    out[14:7]=max_exp-3;
                end 
                10'b?000001???:begin
                    out[6:0]={sum[2:0],4'b0};
                    out[14:7]=max_exp-4;
                end 
                10'b?0000001??:begin
                    out[6:0]={sum[1:0],5'b0};
                    out[14:7]=max_exp-5;
                end 
                10'b?00000001?:begin
                    out[6:0]={sum[0],6'b0};
                    out[14:7]=max_exp-6;
                end 
                10'b?000000001:begin
                    out[6:0]={7'b0};
                    out[14:7]=max_exp-7;
                end 
                default: begin
                    out[6:0]={7'b0};
                end
            endcase

        end 
        MUL:begin
            next_a=store_a;
            next_b=store_b;
            next_state=IDLE;
            fraction_a={1'b1,store_a[6:0]};
            fraction_b={1'b1,store_b[6:0]};

            
            mul = fraction_a*fraction_b;
            max_exp=store_a[14:7]+store_b[14:7]-127;
            out_valid=1;
            out[15] = store_a[15]^store_b[15];
            // case ({store_a[15],store_b[15]})
            //     2'b00: out[15]=0;
            //     2'b10: out[15]=1;
            //     2'b01: out[15]=1;
            //     2'b11: out[15]=0;
                 
            //     default: out[15]=0;
            // endcase
            casez (mul)
                
                16'b1?:begin
                    out[6:0]=mul[14:8];
             
                    out[14:7]=max_exp+1;
                end 
                16'b01?:begin
                    out[6:0]=mul[13:7];
     
                    out[14:7]=max_exp;
                end 
                16'b001?:begin
                    out[6:0]=mul[12:6];
   
                    out[14:7]=max_exp-1;
                end 
                16'b0001?:begin
                    out[6:0]=mul[11:5];

                    out[14:7]=max_exp-2;
                end 
                16'b00001?:begin
                    out[6:0]=mul[10:4];

                    out[14:7]=max_exp-3;
                end 
                16'b000001?:begin
                    out[6:0]=mul[9:3];

                    out[14:7]=max_exp-4;
                end 
                16'b0000001?:begin
                    out[6:0]=mul[8:2];

                    out[14:7]=max_exp-5;
                end 
                16'b00000001?:begin
                    out[6:0]=mul[7:1];

                    out[14:7]=max_exp-6;
                end 
                16'b000000001?:begin
                    out[6:0]=mul[6:0];
                    out[14:7]=max_exp-7;
                end 
                16'b0000000001?:begin
                    out[6:0]={mul[5:0],1'b0};
                    out[14:7]=max_exp-8;
                end 
                16'b00000000001?:begin
                    out[6:0]={mul[4:0],2'b0};
                    out[14:7]=max_exp-9;
                end 
                16'b000000000001?:begin
                    out[6:0]={mul[3:0],3'b0};
                    out[14:7]=max_exp-10;
                end 
                16'b0000000000001?:begin
                    out[6:0]={mul[2:0],4'b0};
                    out[14:7]=max_exp-11;
                end 
                16'b00000000000001?:begin
                    out[6:0]={mul[1:0],5'b0};
                    out[14:7]=max_exp-12;
                end 
                16'b000000000000001?:begin
                    out[6:0]={mul[0],6'b0};
                    out[14:7]=max_exp-13;
                end 
                
                default: begin
                    out[6:0]=mul[14:8];
                    out[14:7]=max_exp+1;
                end
            endcase
        end 
        
        default: begin
            out_valid=0;
            out=0;
            next_state=IDLE;
            next_a=0;
            next_b=0;
        end
    endcase

end


endmodule