module DCT(
	// Input signals
	clk,
	rst_n,
	in_valid,
	in_data,
	// Output signals
	out_valid,
	out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input        clk, rst_n, in_valid;
input signed [7:0]in_data;
output logic out_valid;
output logic signed[9:0]out_data;

//---------------------------------------------------------------------
//   REG AND WIRE DECLARATION
//---------------------------------------------------------------------
integer i,j;
parameter IDLE = 0;
parameter INPUT = 1;
parameter CAL = 2;
parameter CAL2 = 3;
parameter OUTPUT = 4;
logic signed [7:0]dctmtx[0:3][0:3];
logic signed [7:0]dctmtxt[0:3][0:3];
logic signed [9:0]buffer[0:3][0:3];

logic [2:0]STATE,NS;
logic [3:0]input_cnt, input_cnt_nxt;
logic signed [7:0]inbuffer[0:3][0:3];
logic signed [7:0]inbuffer_nxt[0:3][0:3];
logic signed [32:0]mul[0:3];
logic signed [32:0]result;
logic [3:0]output_cnt, output_cnt_nxt, counter, counter_nxt;
logic signed [9:0]outbuffer[0:3][0:3];
//finish your declaration

//---------------------------------------------------------------------
//   YOUR DESIGN
//---------------------------------------------------------------------
assign dctmtx[0][0] = 8'b01000000;
assign dctmtx[0][1] = 8'b01000000;
assign dctmtx[0][2] = 8'b01000000;
assign dctmtx[0][3] = 8'b01000000;
assign dctmtx[1][0] = 8'b01010011;
assign dctmtx[1][1] = 8'b00100010;
assign dctmtx[1][2] = 8'b11011110;
assign dctmtx[1][3] = 8'b10101101;
assign dctmtx[2][0] = 8'b01000000;
assign dctmtx[2][1] = 8'b11000000;
assign dctmtx[2][2] = 8'b11000000;
assign dctmtx[2][3] = 8'b01000000;
assign dctmtx[3][0] = 8'b00100010;
assign dctmtx[3][1] = 8'b10101101;
assign dctmtx[3][2] = 8'b01010011;
assign dctmtx[3][3] = 8'b11011110;

assign dctmtxt[0][0] = 8'b01000000;
assign dctmtxt[1][0] = 8'b01000000;
assign dctmtxt[2][0] = 8'b01000000;
assign dctmtxt[3][0] = 8'b01000000;
assign dctmtxt[0][1] = 8'b01010011;
assign dctmtxt[1][1] = 8'b00100010;
assign dctmtxt[2][1] = 8'b11011110;
assign dctmtxt[3][1] = 8'b10101101;
assign dctmtxt[0][2] = 8'b01000000;
assign dctmtxt[1][2] = 8'b11000000;
assign dctmtxt[2][2] = 8'b11000000;
assign dctmtxt[3][2] = 8'b01000000;
assign dctmtxt[0][3] = 8'b00100010;
assign dctmtxt[1][3] = 8'b10101101;
assign dctmtxt[2][3] = 8'b01010011;
assign dctmtxt[3][3] = 8'b11011110;


always_ff@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		STATE<=0;
		out_valid<=0;
		out_data<=0;
        counter <= 0;
	end
	else begin
		STATE<=NS;
		out_valid<= (STATE==OUTPUT);
		out_data<= (STATE==OUTPUT ? outbuffer[output_cnt[3:2]][output_cnt[1:0]] : 0);
        counter <= counter_nxt;
	end
end

always_comb begin
    counter_nxt = counter;
	result = 0;
	case(STATE)
		IDLE:begin
			if(in_valid)	NS = INPUT;
			else 			NS = STATE;
		end
		INPUT:begin
			if(~in_valid)	begin
                NS = CAL;
                counter_nxt = 0;
            end
			else 			NS = STATE;
		end
		//next state start matrix multiplication
		//finish your FSM
        CAL: begin
            if (counter == 15) begin
                NS = CAL2;
                counter_nxt = 0;
            end
            else NS = STATE;
            counter_nxt = counter+1;
			mul[0] = dctmtx[counter[3:2]][0] * inbuffer[0][counter[1:0]];
            mul[1] = dctmtx[counter[3:2]][1] * inbuffer[1][counter[1:0]];
            mul[2] = dctmtx[counter[3:2]][2] * inbuffer[2][counter[1:0]];
            mul[3] = dctmtx[counter[3:2]][3] * inbuffer[3][counter[1:0]];
            result = (mul[0]+mul[1]+mul[2]+mul[3])/128;
        end
        CAL2: begin
            if (counter == 15) begin
                NS = OUTPUT;
                counter_nxt = 0;
            end
            else NS = STATE;
            counter_nxt = counter+1;

            mul[0] = buffer[counter[3:2]][0] * dctmtxt[0][counter[1:0]];
            mul[1] = buffer[counter[3:2]][1] * dctmtxt[1][counter[1:0]];
            mul[2] = buffer[counter[3:2]][2] * dctmtxt[2][counter[1:0]];
            mul[3] = buffer[counter[3:2]][3] * dctmtxt[3][counter[1:0]];
            result = (mul[0]+mul[1]+mul[2]+mul[3])/128;
        end

		OUTPUT:begin
			if(output_cnt==15)NS = IDLE;
			else 			NS = STATE;
		end
		default:begin
			NS = STATE;
        end
	endcase
end

always_ff@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		input_cnt<=0;
	end
	else begin
		if(in_valid)begin
			input_cnt<=input_cnt+1;
		end
		else begin
			input_cnt<=0;
		end
	end
end

always_ff@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		for(integer i=0;i<4;i=i+1)begin
			for(integer j=0;j<4;j=j+1)begin
				inbuffer[i][j]<=0;
			end
		end
	end
	else begin
		if(in_valid)begin
			inbuffer[input_cnt[3:2]][input_cnt[1:0]]<=in_data;
		end
	end
end

always_ff@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		output_cnt<=0;
	end
	else begin
		if(STATE==OUTPUT)begin
			output_cnt<=output_cnt+1;
		end
		else begin
			output_cnt<=0;
		end
	end
end

always_ff@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		for(integer i=0;i<4;i=i+1)begin
			for(integer j=0;j<4;j=j+1)begin
				outbuffer[i][j]<=0;
				buffer[i][j]<=0;
			end
		end
	end
	else begin
		if(STATE==CAL)begin
			buffer[counter[3:2]][counter[1:0]]<=result;
		end
		else if (STATE==CAL2) begin
			outbuffer[counter[3:2]][counter[1:0]]<=result;
		end
	end
end


//input matrix stored in inbuffer
//output matrix should store in outbuffer
//finish your matrix multiplier


endmodule