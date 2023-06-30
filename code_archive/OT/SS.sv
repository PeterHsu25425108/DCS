module MAC(
    input clk, rst_n,
    input [15:0] ina,
    input [37:0] inb,
    output logic [37:0] outc,
    output logic [15:0] outd,
    input [15:0] W
);

always_ff @(posedge clk or negedge rst_n) begin : MAC_seq
    if(!rst_n)begin
        outc <= 0;
        outd <= 0;
    end
    else begin
        outc <= ina * W + inb;
        outd <= ina;
    end
end

endmodule

module SS(
// input signals
    clk,
    rst_n,
    in_valid,
    matrix,
    matrix_size,
// output signals
    out_valid,
    out_value
);
//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input               clk, rst_n, in_valid;
input        [15:0] matrix;
input               matrix_size;

output logic        out_valid;
output logic [39:0] out_value;

logic [39:0] add_result;
logic size;
logic [15:0] W[15:0];
logic [15:0] K[15:0];
logic [15:0] Y[15:0];
logic [15:0] X[15:0];
logic [37:0] outc[3:0][3:0];
logic [37:0] inb[3:0][3:0];
logic [15:0] outd[3:0][3:0];
logic [15:0] ina[3:0][3:0];

logic [4:0] counter;
logic [1:0] state, nxt_state, curr_state;
logic [3:0] m_time, w_time;// size=0 -> 3, size=1 -> 15
logic [4:0] o_time;// size=0 -> 3, size=1 -> 6

parameter IDLE = 2'b00, WEIGHT = 2'b01, MATRIX = 2'b10, OUTPUT = 2'b11;
integer i,j;

always_comb begin : Y_comb
    for(integer i=0;i<16;i+=1)begin
        Y[i]<= X[i];
    end 
end

always_ff @(posedge clk or negedge rst_n) begin : blockName
    if(!rst_n)begin
        for(integer i=0;i<16;i+=1)begin
            X[i]<= 0;
        end
    end
    else begin
        if(in_valid && ((state == WEIGHT && counter == w_time) || (state == MATRIX && counter < w_time)))begin
            if(state == IDLE ? matrix_size : size) begin
                X[15] <= matrix;
                /*for(j=1;j<16;j+=1)begin
                    X[j-1] <= X[j];
                end*/
                X[14] <= Y[15];
                X[13] <= Y[14];
                X[12] <= Y[13];
                X[11] <= Y[12];
                X[10] <= Y[11];
                X[9] <= Y[10];
                X[8] <= Y[9];
                X[7] <= Y[8];
                X[6] <= Y[7];
                X[5] <= Y[6];
                X[4] <= Y[5];
                X[3] <= Y[4];
                X[2] <= Y[3];
                X[1] <= Y[2];
                X[0] <= Y[1];
            end
            else begin
                X[13] <= matrix;
                X[12] <= Y[13];
                X[9] <= Y[12];
                X[8] <= Y[9];

                X[0] <= Y[0];
                X[1] <= Y[1];
                X[2] <= Y[2];
                X[3] <= Y[3];
                X[4] <= Y[4];
                X[5] <= Y[5];
                X[6] <= Y[6];
                X[7] <= Y[7];
                X[10] <= Y[10];
                X[11] <= Y[11];
                X[14] <= Y[14];
                X[15] <= Y[15];
            end
        end

        else begin
            for(integer j=0;j<16;j+=1)begin
                X[j] <= Y[j];
            end
        end
    end
end

always_comb begin : K_comb
    if(in_valid && (state == WEIGHT || state == IDLE) && counter < w_time)begin
        if(state == IDLE ? matrix_size : size) begin
            K[15] = matrix;
            /*for(j=1;j<16;j+=1)begin
                W[j-1] <= W[j];
            end*/
            K[14] = W[15];
            K[13] = W[14];
            K[12] = W[13];
            K[11] = W[12];
            K[10] = W[11];
            K[9] = W[10];
            K[8] = W[9];
            K[7] = W[8];
            K[6] = W[7];
            K[5] = W[6];
            K[4] = W[5];
            K[3] = W[4];
            K[2] = W[3];
            K[1] = W[2];
            K[0] = W[1];
        end
        else begin
            K[13] = matrix;
            K[12] = W[13];
            K[9] = W[12];
            K[8] = W[9];

            K[0] = 0;
            K[1] = 0;
            K[2] = 0;
            K[3] = 0;
            K[4] = 0;
            K[5] = 0;
            K[6] = 0;
            K[7] = 0;
            K[10] = 0;
            K[11] = 0;
            K[14] = 0;
            K[15] = 0;
        end
    end

    else begin
        K[0] = W[0];
        K[1] = W[1];
        K[2] = W[2];
        K[3] = W[3];
        K[4] = W[4];
        K[5] = W[5];
        K[6] = W[6];
        K[7] = W[7];
        K[8] = W[8];
        K[9] = W[9];
        K[10] = W[10];
        K[11] = W[11];
        K[12] = W[12];
        K[13] = W[13];
        K[14] = W[14];
        K[15] = W[15];
    end
end

always_ff @(posedge clk or negedge rst_n)begin : weight_input_seq
    if(!rst_n)begin
        for(integer i=0;i<16;i+=1)begin
            W[i]<= 0;
        end
    end
    else begin
        for(integer i=0;i<16;i+=1)begin
            W[i] <= K[i];
        end
    end
end

always_comb begin : in_comb
    /*ina[0][0] = in_valid && (state==MATRIX) && (counter % w_time == 0) ? matrix : outd[0][0];
    ina[0][1] = in_valid && (state==MATRIX) && (counter % w_time == 1) ? matrix : outd[0][1];
    ina[0][2] = in_valid && (state==MATRIX) && (counter % w_time == 2) ? matrix : outd[0][2];
    ina[0][3] = in_valid && (state==MATRIX) && (counter % w_time == 3) ? matrix : outd[0][3];*/
    if(size) begin
        /*ina[0][0] = in_valid && (state==MATRIX) && (counter % 3 == 0) ? matrix : outd[0][0];
        ina[1][0] = in_valid && (state==MATRIX) && (counter % 3 == 1) ? matrix : outd[0][1];
        ina[2][0] = in_valid && (state==MATRIX) && (counter % 3 == 2) ? matrix : outd[0][2];
        ina[3][0] = in_valid && (state==MATRIX) && (counter % 3 == 3) ? matrix : outd[0][3];*/
        if(state == OUTPUT) begin
            case(counter)
                5'd0: begin
                    ina[0][0] = X[0]; 
                    ina[1][0] = 0;
                    ina[2][0] = 0;
                    ina[3][0] = 0;
                end
                5'd1: begin
                    ina[0][0] = X[4]; 
                    ina[1][0] = X[1];
                    ina[2][0] = 0;
                    ina[3][0] = 0;
                end
                5'd2: begin
                    ina[0][0] = X[8]; 
                    ina[1][0] = X[5];
                    ina[2][0] = X[2];
                    ina[3][0] = 0;
                end
                5'd3: begin
                    ina[0][0] = X[12]; 
                    ina[1][0] = X[9];
                    ina[2][0] = X[6];
                    ina[3][0] = X[3];
                end
                5'd4: begin
                    ina[0][0] = 0; 
                    ina[1][0] = X[13];
                    ina[2][0] = X[10];
                    ina[3][0] = X[7];
                end
                5'd5: begin
                    ina[0][0] = 0; 
                    ina[1][0] = 0;
                    ina[2][0] = X[14];
                    ina[3][0] = X[11];
                end
                5'd6: begin
                    ina[0][0] = 0; 
                    ina[1][0] = 0;
                    ina[2][0] = 0;
                    ina[3][0] = X[15];
                end
                default: begin
                    ina[0][0] = 0; 
                    ina[1][0] = 0;
                    ina[2][0] = 0;
                    ina[3][0] = 0;
                end
            endcase
        end

        else begin
            ina[0][0] = 0; 
            ina[1][0] = 0;
            ina[2][0] = 0;
            ina[3][0] = 0;
        end
    end
    else begin
        ina[0][0] = 0;
        ina[1][0] = 0;
        /*ina[2][0] = in_valid && (state==MATRIX) && (counter % 1 == 0) ? matrix : outd[0][2];
        ina[3][0] = in_valid && (state==MATRIX) && (counter % 1 == 1) ? matrix : outd[0][3];*/
        if(state == OUTPUT) begin
            case(counter)
                5'd0: begin
                    ina[2][0] = X[8];
                    ina[3][0] = 0;
                end
                5'd1: begin
                    ina[2][0] = X[12];
                    ina[3][0] = X[9];
                end
                5'd2: begin
                    ina[2][0] = 0;
                    ina[3][0] = X[13];
                end
                default: begin
                    ina[2][0] = 0;
                    ina[3][0] = 0;
                end
            endcase
        end

        else begin
            ina[2][0] = 0;
            ina[3][0] = 0;
        end
        
    end

    inb[0][0] = 0;
    inb[0][1] = 0;
    inb[0][2] = 0;
    inb[0][3] = 0;

    /*for(integer i=0;i<4;i+=1)begin
        for(integer j=1;j<4;j+=1)begin
            ina[i][j] = outd[i][j-1];
            
        end
    end*/
    ina[0][1] = outd[0][0];
    ina[0][2] = outd[0][1];
    ina[0][3] = outd[0][2];
    ina[1][1] = outd[1][0];
    ina[1][2] = outd[1][1];
    ina[1][3] = outd[1][2];
    ina[2][1] = outd[2][0];
    ina[2][2] = outd[2][1];
    ina[2][3] = outd[2][2];
    ina[3][1] = outd[3][0];
    ina[3][2] = outd[3][1];
    ina[3][3] = outd[3][2];


    for(integer i=1;i<4;i+=1)begin
        for(integer j=0;j<4;j+=1)begin
            inb[i][j] = outc[i-1][j];
        end
    end
end

MAC mac11(.clk(clk), .rst_n(rst_n), .ina(ina[0][0]), .inb(inb[0][0]), .outc(outc[0][0]), .outd(outd[0][0]), .W(W[0]));
MAC mac12(.clk(clk), .rst_n(rst_n), .ina(ina[0][1]), .inb(inb[0][1]), .outc(outc[0][1]), .outd(outd[0][1]), .W(W[1]));
MAC mac13(.clk(clk), .rst_n(rst_n), .ina(ina[0][2]), .inb(inb[0][2]), .outc(outc[0][2]), .outd(outd[0][2]), .W(W[2]));
MAC mac14(.clk(clk), .rst_n(rst_n), .ina(ina[0][3]), .inb(inb[0][3]), .outc(outc[0][3]), .outd(outd[0][3]), .W(W[3]));
MAC mac21(.clk(clk), .rst_n(rst_n), .ina(ina[1][0]), .inb(inb[1][0]), .outc(outc[1][0]), .outd(outd[1][0]), .W(W[4]));
MAC mac22(.clk(clk), .rst_n(rst_n), .ina(ina[1][1]), .inb(inb[1][1]), .outc(outc[1][1]), .outd(outd[1][1]), .W(W[5]));
MAC mac23(.clk(clk), .rst_n(rst_n), .ina(ina[1][2]), .inb(inb[1][2]), .outc(outc[1][2]), .outd(outd[1][2]), .W(W[6]));
MAC mac24(.clk(clk), .rst_n(rst_n), .ina(ina[1][3]), .inb(inb[1][3]), .outc(outc[1][3]), .outd(outd[1][3]), .W(W[7]));
MAC mac31(.clk(clk), .rst_n(rst_n), .ina(ina[2][0]), .inb(inb[2][0]), .outc(outc[2][0]), .outd(outd[2][0]), .W(W[8]));
MAC mac32(.clk(clk), .rst_n(rst_n), .ina(ina[2][1]), .inb(inb[2][1]), .outc(outc[2][1]), .outd(outd[2][1]), .W(W[9]));
MAC mac33(.clk(clk), .rst_n(rst_n), .ina(ina[2][2]), .inb(inb[2][2]), .outc(outc[2][2]), .outd(outd[2][2]), .W(W[10]));
MAC mac34(.clk(clk), .rst_n(rst_n), .ina(ina[2][3]), .inb(inb[2][3]), .outc(outc[2][3]), .outd(outd[2][3]), .W(W[11]));
MAC mac41(.clk(clk), .rst_n(rst_n), .ina(ina[3][0]), .inb(inb[3][0]), .outc(outc[3][0]), .outd(outd[3][0]), .W(W[12]));
MAC mac42(.clk(clk), .rst_n(rst_n), .ina(ina[3][1]), .inb(inb[3][1]), .outc(outc[3][1]), .outd(outd[3][1]), .W(W[13]));
MAC mac43(.clk(clk), .rst_n(rst_n), .ina(ina[3][2]), .inb(inb[3][2]), .outc(outc[3][2]), .outd(outd[3][2]), .W(W[14]));
MAC mac44(.clk(clk), .rst_n(rst_n), .ina(ina[3][3]), .inb(inb[3][3]), .outc(outc[3][3]), .outd(outd[3][3]), .W(W[15]));

always_comb begin : time_comb
        w_time = size ? 15 : 3;
        m_time = w_time - 1;
        o_time = size ? /*10*/11 : /*4*/5;
end

always_ff @(posedge clk or negedge rst_n) begin : size_seq
    if(!rst_n)begin
        size <= 0;
    end
    else begin
        size <= (in_valid && state == IDLE) ? matrix_size : size;
    end
end

always_ff @(posedge clk or negedge rst_n) begin : counter_seq
    if(!rst_n)begin
        counter <= 0;
    end
    else begin
        casez(state)
            IDLE: begin
                counter <= 0;
            end
            WEIGHT: begin
                counter <= (counter == w_time) ? 0 : counter + 1;
            end
            MATRIX: begin
                counter <= (counter == m_time) ? 0 : counter + 1;
            end
            OUTPUT: begin
                counter <= (counter == o_time) ? 0 : counter + 1;
            end
        endcase
    end
end

always_ff @(posedge clk or negedge rst_n)begin : state_seq
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
        IDLE: begin
            nxt_state = in_valid ? WEIGHT : IDLE;
        end

        WEIGHT:begin
            nxt_state = counter == w_time ? MATRIX : WEIGHT;
        end

        MATRIX:begin
            //nxt_state = counter == m_time ? IDLE : MATRIX;
            if(size) begin
                nxt_state = counter == m_time ? OUTPUT : MATRIX;
            end
            else begin
                nxt_state = counter == m_time ? OUTPUT : MATRIX;
            end
        end

        OUTPUT: begin
            nxt_state = counter == o_time ? IDLE : OUTPUT;
        end
        default: nxt_state = 'bx;
    endcase
end

always_comb begin : out_comb
    add_result = /*(out_valid) ? */outc[3][0] + outc[3][1] + outc[3][2] + outc[3][3]/* : 0*/;
    out_valid = (state == OUTPUT) && (size ? counter >= 5/*4*/ : counter >= 3/*2*/);
end

always_ff @(posedge clk or negedge rst_n) begin : out_seq
    if(!rst_n)begin
        out_value <= 0;
    end
    else begin
        out_value <= add_result;
    end
end

endmodule