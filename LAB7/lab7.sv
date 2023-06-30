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
parameter OUTPUT = 4;
parameter FIRST_MULT = 2;
parameter SECOND_MULT = 3;

logic signed [7:0]dctmtx[0:3][0:3];

logic [2:0]STATE,NS;
logic [3:0]input_cnt;
logic signed [7:0]inbuffer[0:3][0:3];

logic signed [32:0]inter_mult_result[0:3];
logic signed [32:0]inter_add_result;
logic signed [9:0] inter_shift_result;
logic [3:0]mul_cnt;
logic signed [9:0]interbuffer[0:3][0:3];
logic signed [9:0]next_interbuffer;

logic signed [32:0]out_mult_result[0:3];
logic signed [32:0]out_add_result;
logic signed [9:0]out_shift_result;
logic signed [9:0]next_outbuffer;

logic [3:0]output_cnt;
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

// MULT CNT
always_ff@(posedge clk or negedge rst_n)begin : mul_cnt_seq
	if(~rst_n)begin
		mul_cnt<=0;
	end
	else begin

		if((STATE==FIRST_MULT || STATE == SECOND_MULT) && mul_cnt < 15)begin
			mul_cnt<=mul_cnt+1;
		end
		else begin
			mul_cnt<=0;
		end
	end
end

// FIRST MULT STAGE

always_ff@(posedge clk or negedge rst_n)begin : inter_buffer_seq
	if(~rst_n)begin
		for(integer i=0;i<4;i=i+1)begin
			for(integer j=0;j<4;j=j+1)begin
				interbuffer[i][j] <= 0;
			end
		end
	end
	else begin
		if(STATE == FIRST_MULT) begin
			interbuffer[mul_cnt[3:2]][mul_cnt[1:0]] <=  next_interbuffer;
		end
	end
end

always_comb begin : inter_buffer_comb
	inter_mult_result[0] = dctmtx[mul_cnt[3:2]][0] * inbuffer[0][mul_cnt[1:0]];
	inter_mult_result[1] = dctmtx[mul_cnt[3:2]][1] * inbuffer[1][mul_cnt[1:0]];
	inter_mult_result[2] = dctmtx[mul_cnt[3:2]][2] * inbuffer[2][mul_cnt[1:0]];
	inter_mult_result[3] = dctmtx[mul_cnt[3:2]][3] * inbuffer[3][mul_cnt[1:0]];

	inter_add_result = (inter_mult_result[0] + inter_mult_result[1] + inter_mult_result[2] + inter_mult_result[3]);
	inter_shift_result = (inter_add_result/128/*>>> 7*/);
	next_interbuffer = inter_shift_result;
end

// --------------------------

// FSECOND MULT STAGE

always_ff@(posedge clk or negedge rst_n)begin : outbuffer_seq
	if(~rst_n)begin
		for(integer i=0;i<4;i=i+1)begin
			for(integer j=0;j<4;j=j+1)begin
				outbuffer[i][j] <= 0;
			end
		end
	end
	else begin
		if(STATE == SECOND_MULT) begin
			outbuffer[mul_cnt[3:2]][mul_cnt[1:0]] <=  next_outbuffer;
		end
	end
end

always_comb begin : outbuffer_comb
	out_mult_result[0] = interbuffer[mul_cnt[3:2]][0] * dctmtx[mul_cnt[1:0]][0];
	out_mult_result[1] = interbuffer[mul_cnt[3:2]][1] * dctmtx[mul_cnt[1:0]][1];
	out_mult_result[2] = interbuffer[mul_cnt[3:2]][2] * dctmtx[mul_cnt[1:0]][2];
	out_mult_result[3] = interbuffer[mul_cnt[3:2]][3] * dctmtx[mul_cnt[1:0]][3];

	out_add_result = (out_mult_result[0] + out_mult_result[1] + out_mult_result[2] + out_mult_result[3]);
	out_shift_result = (out_add_result/128 /*>>> 7*/);
	next_outbuffer = out_shift_result;
end

// --------------------------

always_ff@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		STATE<=0;
		out_valid<=0;
		out_data<=0;
	end
	else begin
		STATE<=NS;
		out_valid<= (STATE==OUTPUT);
		out_data<= (STATE==OUTPUT ? outbuffer[output_cnt[3:2]][output_cnt[1:0]] : 0);
	end
end

always_comb begin
	case(STATE)
		IDLE:begin
			if(in_valid)	NS = INPUT;
			else 			NS = STATE;
		end
		INPUT:begin
			if(~in_valid)	NS = FIRST_MULT;
			else 			NS = STATE;
		end
		//next state start matrix multiplication
		//finish your FSM

		FIRST_MULT:begin
			if(mul_cnt == 15) NS = SECOND_MULT;
			else NS = FIRST_MULT;
		end
		
		SECOND_MULT:begin
			if(mul_cnt == 15) NS = OUTPUT;
			else NS = SECOND_MULT;
		end
		
		OUTPUT:begin
			if(output_cnt==15)NS = IDLE;
			else 			NS = STATE;
		end
		default:begin
			NS = 3'bx;
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
//input matrix stored in inbuffer
//output matrix should store in outbuffer
//finish your matrix multiplier











endmodule