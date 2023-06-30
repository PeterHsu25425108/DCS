module Conv(
	// Input signals
	clk,
	rst_n,
	filter_valid,
	image_valid,
	filter_size,
	image_size,
	pad_mode,
	act_mode,
	in_data,
	// Output signals
	out_valid,
	out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------

parameter IDLE = 2'b00, FILTER = 2'b10, IMAGE = 2'b11;

input clk, rst_n, image_valid, filter_valid, filter_size, pad_mode, act_mode;
input [3:0] image_size;
input signed [7:0] in_data;
output logic out_valid;
output logic signed [15:0] out_data;

// input control
logic ftr_size_reg;
logic [3:0] ftr_size;
logic [/*4*/3:0] img_size_reg, nxt_img_size_reg;
logic pad_mode_reg, act_mode_reg, input_spec;
logic [1:0] state, curr_state, nxt_state;
logic signed [7:0] filter_reg [4:0][4:0];
logic signed [7:0] img_reg [7:0][7:0];

// output control
logic nxt_out_valid;
logic signed [15:0] nxt_out_data;
logic A, B, C;
logic [6:0] img_size_squared;

// master counter
logic [6:0] counter;

// multiplier array
logic signed [15:0] mult_outs [4:0][4:0];
logic signed [15:0] nxt_mult_outs [4:0][4:0];
logic signed [7:0] mult_ins [4:0][4:0];
logic signed [7:0] nxt_mult_ins [4:0][4:0];
logic [2:0] r;
logic [2:0] ro;
logic [2:0] c;
logic [2:0] co;
logic [4:0] min_out_cnt;
logic signed [7:0] mult_img [11:0][11:0];

// adder tree
logic signed [19:0] adder_tmps [2:0];
logic signed [15:0] adder_in1 [2:0][7:0];
logic signed [17:0] adder_in2 [2:0][3:0];
logic signed [17:0] adder_in3 [2:0][1:0];
logic signed [18:0] adder_outs [3:0];
logic signed [18:0] nxt_add_out3;

// padding
logic signed [7:0] UL_PAD, UR_PAD, DL_PAD, DR_PAD;
logic signed [7:0] U_PAD[5:0];
logic signed [7:0] D_PAD[5:0];
logic signed [7:0] L_PAD[5:0];
logic signed [7:0] R_PAD[5:0];

//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------
//assign r = counter/img_size_reg; // r: count until img_size_reg, ++ when c == img_size_reg-1
//assign c = counter%img_size_reg; // c: count until counter == img_size_reg-1, activated when image_valid, (filter_valid || image_valid) ? /*counter + */1: 0
//assign ro = (counter - min_out_cnt)/img_size_reg; // ro: count until img_size_reg, ++ when co == img_size_reg-1
//assign co = (counter - min_out_cnt)%img_size_reg; // co: count until img_size_reg-1, activated when counter >= min_out_cnt
assign min_out_cnt = ftr_size_reg ? (img_size_reg << 1) + /*3*/2 : img_size_reg + /*2*/1;

// ro counter
always_ff @(posedge clk or negedge rst_n) begin : ro_seq
	if(rst_n == 1'b0) begin
		ro <= 0;
	end
	else begin
		if(state == IMAGE)begin
			ro <= (co == img_size_reg-1) ? ro+1 : ro;
		end
		else begin
			ro <= 0;
		end
	end
end
// co counter
always_ff @(posedge clk or negedge rst_n) begin : co_seq
	if(rst_n == 1'b0) begin
		co <= 0;
	end
	else begin
		if(counter >= min_out_cnt)begin
			co <= (co<img_size_reg-1) ? co+1 : 0;
		end
		else begin
			co <= 0;
		end
	end
end

// r counter
always_ff @(posedge clk or negedge rst_n) begin : r_seq
	if(rst_n == 1'b0) begin
		r <= 0;
	end
	else begin
		if(state == IMAGE)begin
			r <= (c == img_size_reg-1) ? r+1 : r;
		end
		else begin
			r <= 0;
		end
	end
end

// c counter
always_ff @(posedge clk or negedge rst_n) begin : c_seq
	if(rst_n == 1'b0) begin
		c <= 0;
	end
	else begin
		if(image_valid)begin
			c <= (c<img_size_reg-1) ? c+1 : 0;
		end
		else begin
			c <= 0;
		end
	end
end

// padding
always_comb begin : padding_comb
	if(pad_mode_reg)begin
		UL_PAD = img_reg[0][0];
		UR_PAD = img_reg[0][img_size_reg-1];
		DL_PAD = img_reg[img_size_reg-1][0];
		DR_PAD = img_reg[img_size_reg-1][img_size_reg-1];

		U_PAD[0] = img_reg[0][1];
		U_PAD[1] = img_reg[0][2];
		U_PAD[2] = img_reg[0][3];
		U_PAD[3] = img_reg[0][4];
		U_PAD[4] = img_reg[0][5];
		U_PAD[5] = img_reg[0][6];

		D_PAD[0] = img_reg[img_size_reg-1][1];
		D_PAD[1] = img_reg[img_size_reg-1][2];
		D_PAD[2] = img_reg[img_size_reg-1][3];
		D_PAD[3] = img_reg[img_size_reg-1][4];
		D_PAD[4] = img_reg[img_size_reg-1][5];
		D_PAD[5] = img_reg[img_size_reg-1][6];

		L_PAD[0] = img_reg[1][0];
		L_PAD[1] = img_reg[2][0];
		L_PAD[2] = img_reg[3][0];
		L_PAD[3] = img_reg[4][0];
		L_PAD[4] = img_reg[5][0];
		L_PAD[5] = img_reg[6][0];

		R_PAD[0] = img_reg[1][img_size_reg-1];
		R_PAD[1] = img_reg[2][img_size_reg-1];
		R_PAD[2] = img_reg[3][img_size_reg-1];
		R_PAD[3] = img_reg[4][img_size_reg-1];
		R_PAD[4] = img_reg[5][img_size_reg-1];
		R_PAD[5] = img_reg[6][img_size_reg-1];

	end
	else begin
		UL_PAD = 0;
		UR_PAD = 0;
		DL_PAD = 0;
		DR_PAD = 0;
		for(integer i=0; i<6; i+=1) begin
			U_PAD[i] = 0;
			D_PAD[i] = 0;
			L_PAD[i] = 0;
			R_PAD[i] = 0;
		end
	end
end

// mult_img

always_comb begin : mult_img_comb
	// set all mult_img to 0
	for(int i=0;i<12;i=i+1)begin
		for(int j=0;j<12;j=j+1)begin
			mult_img[i][j]=0;
		end
	end

	/*mult_img[0][3] = U_PAD[0];
	mult_img[0][4] = U_PAD[1];
	mult_img[0][5] = U_PAD[2];
	mult_img[0][6] = U_PAD[3];
	mult_img[0][7] = U_PAD[4];
	mult_img[0][8] = U_PAD[5];
	mult_img[1][3] = U_PAD[0];
	mult_img[1][4] = U_PAD[1];
	mult_img[1][5] = U_PAD[2];
	mult_img[1][6] = U_PAD[3];
	mult_img[1][7] = U_PAD[4];
	mult_img[1][8] = U_PAD[5];*/
	for(integer i = 0;i<=1;i+=1)begin
		for(integer j = 3;j<=img_size_reg;j+=1)begin
			mult_img[i][j] = U_PAD[j-3];
		end
	end

	mult_img[0][0] = UL_PAD;
	mult_img[0][1] = UL_PAD;
	mult_img[0][2] = UL_PAD;
	mult_img[1][0] = UL_PAD;
	mult_img[1][1] = UL_PAD;
	mult_img[1][2] = UL_PAD;
	mult_img[2][0] = UL_PAD;
	mult_img[2][1] = UL_PAD;

	for(integer j = 2;j<=img_size_reg+1/*9*/;j+=1)begin
		mult_img[2][j] = img_reg[0][j-2];
	end

	for(integer i = 3;i<=img_size_reg;i+=1)begin
		mult_img[i][0] = L_PAD[i-3];
		mult_img[i][1] = L_PAD[i-3];
		for(integer j = 2;j<=img_size_reg+1/*9*/;j+=1)begin
			mult_img[i][j] = img_reg[i-2][j-2];
		end
		mult_img[i][/*10*/img_size_reg+2] = R_PAD[i-3];
		mult_img[i][/*11*/img_size_reg+3] = R_PAD[i-3];
	end


	for(integer j = 2;j<=img_size_reg+1/*9*/;j+=1)begin
		mult_img[img_size_reg+1][j] = img_reg[img_size_reg-1][j-2];
	end


	for(integer i =3;i<=8;i+=1)begin
		mult_img[img_size_reg+2][i] = D_PAD[i-3];
		mult_img[img_size_reg+3][i] = D_PAD[i-3];
	end
	/*for(integer i =3;i<=8;i+=1)begin
		mult_img[11][i] = D_PAD[i-3];
	end*/

	mult_img[0][/*9*/img_size_reg+1] = UR_PAD;
	mult_img[0][/*10*/img_size_reg+2] = UR_PAD;
	mult_img[0][/*11*/img_size_reg+3] = UR_PAD;
	mult_img[1][/*9*/img_size_reg+1] = UR_PAD;
	mult_img[1][/*10*/img_size_reg+2] = UR_PAD;
	mult_img[1][/*11*/img_size_reg+3] = UR_PAD;
	mult_img[2][/*10*/img_size_reg+2] = UR_PAD;
	mult_img[2][/*11*/img_size_reg+3] = UR_PAD;

	mult_img[/*9*/img_size_reg+1][0] = DL_PAD;
	mult_img[/*9*/img_size_reg+1][1] = DL_PAD;
	mult_img[/*10*/img_size_reg+2][0] = DL_PAD;
	mult_img[/*10*/img_size_reg+2][1] = DL_PAD;
	mult_img[/*10*/img_size_reg+2][2] = DL_PAD;
	mult_img[/*11*/img_size_reg+3][0] = DL_PAD;
	mult_img[/*11*/img_size_reg+3][1] = DL_PAD;
	mult_img[/*11*/img_size_reg+3][2] = DL_PAD;

	mult_img[img_size_reg+1/*9*/][img_size_reg+2/*10*/] = DR_PAD;
	mult_img[img_size_reg+1/*9*/][img_size_reg+3/*11*/] = DR_PAD;
	mult_img[img_size_reg+2/*10*/][img_size_reg+1/*9*/] = DR_PAD;
	mult_img[img_size_reg+2/*10*/][img_size_reg+2/*10*/] = DR_PAD;
	mult_img[img_size_reg+2/*10*/][img_size_reg+3/*11*/] = DR_PAD;
	mult_img[img_size_reg+3/*11*/][img_size_reg+1/*9*/] = DR_PAD;
	mult_img[img_size_reg+3/*11*/][img_size_reg+2/*10*/] = DR_PAD;
	mult_img[img_size_reg+3/*11*/][img_size_reg+3/*11*/] = DR_PAD;
end

// multiplier array(in)
// contain 1 ff
always_ff @(posedge clk or negedge rst_n) begin : mul_in_seq
	if(!rst_n)begin
		for(integer i=0; i<5; i+=1) begin
			for(integer j=0; j<5; j+=1) begin
				mult_ins[i][j] <= 0;
			end
		end
	end
	else begin
		for(integer i=0; i<5; i+=1) begin
			for(integer j=0; j<5; j+=1) begin
				mult_ins[i][j] <= nxt_mult_ins[i][j];
			end
		end
	end
end

always_comb begin : nxt_mult_ins_comb
	if(counter < min_out_cnt)begin
		// set nxt_mult_ins to 0
		for(integer i=0; i<5; i+=1) begin
			for(integer j=0; j<5; j+=1) begin
				nxt_mult_ins[i][j] = 0;
			end
		end
	end
	else begin
		// counter - min_out_cnt -> the index of output pixel
		if(co==0)begin
			for(integer i=0;i<5;i+=1)begin
				for(integer j=0;j<5;j+=1)begin
					if(ftr_size_reg)begin
						if(i==4 && j==4 && image_valid && c<img_size_reg+2) nxt_mult_ins[i][j] = in_data;
						else nxt_mult_ins[i][j] = mult_img[ro + i][co + j];
					end
					else begin
						if(i==3 && j==3 && image_valid && c<img_size_reg+3) nxt_mult_ins[i][j] = in_data;
						else nxt_mult_ins[i][j] = mult_img[ro + i][co + j];
					end
					
				end
			end
		end
		else begin
			if(ftr_size_reg)begin
				for(integer i=0;i<5;i+=1)begin
					for(integer j=0;j<4;j+=1)begin
						nxt_mult_ins[i][j] = mult_ins[i][j+1];
					end
				end

				for(integer i=0;i<5;i+=1)begin
					if(i==4) /*nxt_mult_ins[i][4] = in_data;*/begin
						if(ro+4<img_size_reg+1)begin
							nxt_mult_ins[i][4] = (co+4 >= img_size_reg+2) ? R_PAD[ro+1] : (image_valid) ? in_data : mult_img[ro+i][co+4];
						end
						else if(ro+4<img_size_reg+2)begin
							nxt_mult_ins[i][4] = (co+4 >= img_size_reg+2) ? DR_PAD : (image_valid) ? in_data : mult_img[ro+i][co+4];
						end
						else begin
							if(co+4>img_size_reg)begin
								nxt_mult_ins[i][4] = DR_PAD;
							end
							else begin
								nxt_mult_ins[i][4] = D_PAD[co+1];
							end
						end
					end
					else nxt_mult_ins[i][4] = mult_img[ro+i][co+4];
				end
			end
			else begin
				for(integer i=0;i<5;i+=1)begin
					for(integer j=0;j<3;j+=1)begin
						nxt_mult_ins[i][j] = mult_ins[i][j+1];
					end
				end

				for(integer i=0;i<5;i+=1)begin
					if(i==3) /*nxt_mult_ins[i][3] = in_data;*/begin
						if(ro+3<img_size_reg+1)begin
							nxt_mult_ins[i][3] = (co+3 >= img_size_reg+2) ? R_PAD[ro] : (image_valid) ? in_data : mult_img[ro+i][co+3];
						end
						else if(ro+3<img_size_reg+2)begin
							nxt_mult_ins[i][3] = (co+3 >= img_size_reg+2) ? DR_PAD : (image_valid) ? in_data : mult_img[ro+i][co+3];
						end
						else begin
							if(co+3>img_size_reg)begin
								nxt_mult_ins[i][3] = DR_PAD;
							end
							else begin
								nxt_mult_ins[i][3] = D_PAD[co];
							end
						end
					end
					else nxt_mult_ins[i][3] = mult_img[ro+i][co+3];
				end

				for(integer i=0;i<5;i+=1)begin
					nxt_mult_ins[i][4] = /*mult_img[ro+i][co+4]*/0;
				end
			end
		end
	end
end

// multiplier array(out)
// contain 1 ff

always_comb begin : blockName
	/*for(integer i=0; i<5; i+=1) begin
		for(integer j=0; j<5; j+=1) begin
			nxt_mult_outs[i][j] <= mult_ins[i][j] * filter_reg[i][j];
		end
	end*/
	// extend the above for loop:
	nxt_mult_outs[0][0] = mult_ins[0][0] * filter_reg[0][0];
	nxt_mult_outs[0][1] = mult_ins[0][1] * filter_reg[0][1];
	nxt_mult_outs[0][2] = mult_ins[0][2] * filter_reg[0][2];
	nxt_mult_outs[0][3] = mult_ins[0][3] * filter_reg[0][3];
	nxt_mult_outs[0][4] = mult_ins[0][4] * filter_reg[0][4];
	nxt_mult_outs[1][0] = mult_ins[1][0] * filter_reg[1][0];
	nxt_mult_outs[1][1] = mult_ins[1][1] * filter_reg[1][1];
	nxt_mult_outs[1][2] = mult_ins[1][2] * filter_reg[1][2];
	nxt_mult_outs[1][3] = mult_ins[1][3] * filter_reg[1][3];
	nxt_mult_outs[1][4] = mult_ins[1][4] * filter_reg[1][4];
	nxt_mult_outs[2][0] = mult_ins[2][0] * filter_reg[2][0];
	nxt_mult_outs[2][1] = mult_ins[2][1] * filter_reg[2][1];
	nxt_mult_outs[2][2] = mult_ins[2][2] * filter_reg[2][2];
	nxt_mult_outs[2][3] = mult_ins[2][3] * filter_reg[2][3];
	nxt_mult_outs[2][4] = mult_ins[2][4] * filter_reg[2][4];
	nxt_mult_outs[3][0] = mult_ins[3][0] * filter_reg[3][0];
	nxt_mult_outs[3][1] = mult_ins[3][1] * filter_reg[3][1];
	nxt_mult_outs[3][2] = mult_ins[3][2] * filter_reg[3][2];
	nxt_mult_outs[3][3] = mult_ins[3][3] * filter_reg[3][3];
	nxt_mult_outs[3][4] = mult_ins[3][4] * filter_reg[3][4];
	nxt_mult_outs[4][0] = mult_ins[4][0] * filter_reg[4][0];
	nxt_mult_outs[4][1] = mult_ins[4][1] * filter_reg[4][1];
	nxt_mult_outs[4][2] = mult_ins[4][2] * filter_reg[4][2];
	nxt_mult_outs[4][3] = mult_ins[4][3] * filter_reg[4][3];
	nxt_mult_outs[4][4] = mult_ins[4][4] * filter_reg[4][4];
end

always_ff @(posedge clk or negedge rst_n) begin : mul_out_seq
	if(!rst_n)begin
		for(integer i=0; i<5; i+=1) begin
			for(integer j=0; j<5; j+=1) begin
				mult_outs[i][j] <= 0;
			end
		end
	end
	else begin
		for(integer i=0; i<5; i+=1) begin
			for(integer j=0; j<5; j+=1) begin
				mult_outs[i][j] <= nxt_mult_outs[i][j];
			end
		end
	end
end


// adder tree
assign nxt_add_out3 = mult_outs[4][4];
always_ff @(posedge clk or negedge rst_n)begin : adder_outs_seq
	if(!rst_n)begin
		for(integer i=0;i<4;i+=1)begin
			//adder_outs[i] <= 0;
			adder_tmps[0] <= 0;
			adder_tmps[1] <= 0;
		end
	end
	else begin
		adder_tmps[0] <= adder_outs[0] + adder_outs[1];
		adder_tmps[1] <= adder_outs[2] + adder_outs[3];
	end
end

always_comb begin : adder_tree_comb
	// adder_in1
	for(integer i=0;i<3;i+=1)begin
		int j_i, j_f;
		j_i = i*8;
		j_f = j_i + 7;

		for(integer j=j_i;j<=j_f;j+=1)begin
			adder_in1[i][j-j_i] = mult_outs[j/5][j%5];
		end
	end

	//adder_in2
	/*for(integer i=0;i<3;i+=1)begin
		adder_in2[i][0] = adder_in1[i][0] + adder_in1[i][1];
		adder_in2[i][1] = adder_in1[i][2] + adder_in1[i][3];
		adder_in2[i][2] = adder_in1[i][4] + adder_in1[i][5];
		adder_in2[i][3] = adder_in1[i][6] + adder_in1[i][7];
	end*/

	// extend the above for loop:
	adder_in2[0][0] = adder_in1[0][0] + adder_in1[0][1];
	adder_in2[0][1] = adder_in1[0][2] + adder_in1[0][3];
	adder_in2[0][2] = adder_in1[0][4] + adder_in1[0][5];
	adder_in2[0][3] = adder_in1[0][6] + adder_in1[0][7];
	adder_in2[1][0] = adder_in1[1][0] + adder_in1[1][1];
	adder_in2[1][1] = adder_in1[1][2] + adder_in1[1][3];
	adder_in2[1][2] = adder_in1[1][4] + adder_in1[1][5];
	adder_in2[1][3] = adder_in1[1][6] + adder_in1[1][7];
	adder_in2[2][0] = adder_in1[2][0] + adder_in1[2][1];
	adder_in2[2][1] = adder_in1[2][2] + adder_in1[2][3];
	adder_in2[2][2] = adder_in1[2][4] + adder_in1[2][5];
	adder_in2[2][3] = adder_in1[2][6] + adder_in1[2][7];

	// extend the above for loop:
	/*adder_in1[0][0] = mult_outs[0][0];
	adder_in1[0][1] = mult_outs[0][1];
	adder_in1[0][2] = mult_outs[0][2];
	adder_in1[0][3] = mult_outs[0][3];
	adder_in1[0][4] = mult_outs[0][4];
	adder_in1[0][5] = mult_outs[1][0];
	adder_in1[0][6] = mult_outs[1][1];
	adder_in1[0][7] = mult_outs[1][2];
	adder_in1[1][0] = mult_outs[1][3];
	adder_in1[1][1] = mult_outs[1][4];
	adder_in1[1][2] = mult_outs[2][0];
	adder_in1[1][3] = mult_outs[2][1];
	adder_in1[1][4] = mult_outs[2][2];
	adder_in1[1][5] = mult_outs[2][3];
	adder_in1[1][6] = mult_outs[2][4];
	adder_in1[1][7] = mult_outs[3][0];
	adder_in1[2][0] = mult_outs[3][1];
	adder_in1[2][1] = mult_outs[3][2];
	adder_in1[2][2] = mult_outs[3][3];
	adder_in1[2][3] = mult_outs[3][4];
	adder_in1[2][4] = mult_outs[4][0];
	adder_in1[2][5] = mult_outs[4][1];
	adder_in1[2][6] = mult_outs[4][2];
	adder_in1[2][7] = mult_outs[4][3];*/

	// adder_in3
	for(integer i=0;i<3;i+=1)begin
		adder_in3[i][0] = adder_in2[i][0] + adder_in2[i][1];
		adder_in3[i][1] = adder_in2[i][2] + adder_in2[i][3];
	end

	for(integer i=0;i<3;i+=1)begin
		adder_outs[i] = adder_in3[i][0] + adder_in3[i][1];
	end
	adder_outs[3] = nxt_add_out3;

	// adder_tmps
	//adder_tmps[0] = adder_outs[0] + adder_outs[1];
	//adder_tmps[1] = adder_outs[2] + adder_outs[3];
	adder_tmps[2] = adder_tmps[0] + adder_tmps[1];

	// act mode = 0 -> 0 for x < 0
	casez({adder_tmps[2][19], act_mode_reg})
		2'b0?: nxt_out_data = (adder_tmps[2] >= 32767) ? 32767 : adder_tmps[2];
		2'b10: nxt_out_data = 0;
		2'b11: nxt_out_data = (adder_tmps[2]/10<= -32768) ? -32768 : adder_tmps[2]/10;
		default : nxt_out_data = 0;
	endcase
end

always_comb begin : img_size_squared_comb
	// 3~8
	casez(img_size_reg)
		4'd3: img_size_squared = 7'd9;
		4'd4: img_size_squared = 7'd16;
		4'd5: img_size_squared = 7'd25;
		4'd6: img_size_squared = 7'd36;
		4'd7: img_size_squared = 7'd49;
		4'd8: img_size_squared = 7'd64;
		default: img_size_squared = 'bx;
	endcase
end

// output control
assign /*A*/nxt_out_valid = (counter >= min_out_cnt+3) && (counter < min_out_cnt + /*img_size_reg * img_size_reg*/img_size_squared+3);

always_ff @(posedge clk or negedge rst_n) begin : out_seq
	if (rst_n == 1'b0) begin
		out_valid <= 0;
		out_data <= 0;
		//nxt_out_valid <= 0;
		//C <= 0;
		//B <= 0;
	end
	else begin
		if(state == IMAGE)begin
			out_valid <= nxt_out_valid;
			//nxt_out_valid <= A/*B*/;
			//B <= A;
			out_data <= (nxt_out_valid) ? nxt_out_data : 0;
		end
		else begin
			out_valid <= 0;
			out_data <= 0;
			//nxt_out_valid <= A;
			//B <= 0;
		end
	end
end

// master counter
always_ff @(posedge clk or negedge rst_n) begin : counter_seq
	if(rst_n == 1'b0) begin
		counter <= 0;
	end
	else begin
		casez(state)
			IDLE: begin
				counter <= (filter_valid || image_valid) ? /*counter + */1: 0;
			end
			FILTER: begin
				counter <= /*(!filter_valid) ? 0 :*/ counter + 1;
			end
			IMAGE: begin
				counter <= counter + 1;
			end
			default: counter <= counter;
		endcase
	end
end

// image input control
always_ff @(posedge clk or negedge rst_n) begin : img_input_seq
	if (rst_n == 1'b0) begin
		for(integer i=0; i<8; i+=1) begin
			for(integer j=0; j<8; j+=1) begin
				img_reg[i][j] <= 0;
			end
		end
	end
	else begin
		if(image_valid) begin
			for(integer i=0; i<8; i+=1) begin
				for(integer j=0; j<8; j+=1) begin
					if(image_valid)begin
                        // apply r, c
						img_reg[r][c] <= in_data;
					end
				end
			end
		end
		else if(state == IDLE)begin
			for(integer i=0; i<8; i+=1) begin
				for(integer j=0; j<8; j+=1) begin
					img_reg[i][j] <= 0;
				end
			end	
		end
	end
end

// filter input control
always_comb begin : input_spec_comb
	input_spec = (state == IDLE) && filter_valid;
	ftr_size = (ftr_size_reg) ? 5 : 3;
end

always_ff @(posedge clk or negedge rst_n) begin : filter_input_seq
	if (rst_n == 1'b0) begin
		ftr_size_reg <= 0;
		img_size_reg <= 0;
		pad_mode_reg <= 0;
		act_mode_reg <= 0;
		for(integer i=0; i<5; i+=1) begin
			for(integer j=0; j<5; j+=1) begin
				filter_reg[i][j] <= 0;
			end
		end
	end
	else begin
		ftr_size_reg <= input_spec ? filter_size : ftr_size_reg;
		img_size_reg <= input_spec ? image_size : img_size_reg;
		pad_mode_reg <= input_spec ? pad_mode : pad_mode_reg;
		act_mode_reg <= input_spec ? act_mode : act_mode_reg;

		if(input_spec)begin
			if(filter_size)begin // 5x5
				filter_reg[0][0] <= filter_reg[0][1];
				filter_reg[0][1] <= filter_reg[0][2];
				filter_reg[0][2] <= filter_reg[0][3];
				filter_reg[0][3] <= filter_reg[0][4];
				filter_reg[0][4] <= filter_reg[1][0];
				filter_reg[1][0] <= filter_reg[1][1];
				filter_reg[1][1] <= filter_reg[1][2];
				filter_reg[1][2] <= filter_reg[1][3];
				filter_reg[1][3] <= filter_reg[1][4];
				filter_reg[1][4] <= filter_reg[2][0];
				filter_reg[2][0] <= filter_reg[2][1];
				filter_reg[2][1] <= filter_reg[2][2];
				filter_reg[2][2] <= filter_reg[2][3];
				filter_reg[2][3] <= filter_reg[2][4];
				filter_reg[2][4] <= filter_reg[3][0];
				filter_reg[3][0] <= filter_reg[3][1];
				filter_reg[3][1] <= filter_reg[3][2];
				filter_reg[3][2] <= filter_reg[3][3];
				filter_reg[3][3] <= filter_reg[3][4];
				filter_reg[3][4] <= filter_reg[4][0];
				filter_reg[4][0] <= filter_reg[4][1];
				filter_reg[4][1] <= filter_reg[4][2];
				filter_reg[4][2] <= filter_reg[4][3];
				filter_reg[4][3] <= filter_reg[4][4];
				filter_reg[4][4] <= in_data;
			end
			else begin // 3x3
				for(integer i =0;i<5;i+=1)begin
					filter_reg[0][i] <= 0;
					filter_reg[4][i] <= 0;
				end

				for(integer j=1;j<=3;j+=1)begin
					filter_reg[j][0] <= 0;
					filter_reg[j][4] <= 0;
				end

				filter_reg[1][1] <= filter_reg[1][2];
				filter_reg[1][2] <= filter_reg[1][3];
				filter_reg[1][3] <= filter_reg[2][1];
				filter_reg[2][1] <= filter_reg[2][2];
				filter_reg[2][2] <= filter_reg[2][3];
				filter_reg[2][3] <= filter_reg[3][1];
				filter_reg[3][1] <= filter_reg[3][2];
				filter_reg[3][2] <= filter_reg[3][3];
				filter_reg[3][3] <= in_data;
			end
		end
		else if(state == FILTER && filter_valid)begin
			if(ftr_size_reg)begin // 5x5
				filter_reg[0][0] <= filter_reg[0][1];
				filter_reg[0][1] <= filter_reg[0][2];
				filter_reg[0][2] <= filter_reg[0][3];
				filter_reg[0][3] <= filter_reg[0][4];
				filter_reg[0][4] <= filter_reg[1][0];
				filter_reg[1][0] <= filter_reg[1][1];
				filter_reg[1][1] <= filter_reg[1][2];
				filter_reg[1][2] <= filter_reg[1][3];
				filter_reg[1][3] <= filter_reg[1][4];
				filter_reg[1][4] <= filter_reg[2][0];
				filter_reg[2][0] <= filter_reg[2][1];
				filter_reg[2][1] <= filter_reg[2][2];
				filter_reg[2][2] <= filter_reg[2][3];
				filter_reg[2][3] <= filter_reg[2][4];
				filter_reg[2][4] <= filter_reg[3][0];
				filter_reg[3][0] <= filter_reg[3][1];
				filter_reg[3][1] <= filter_reg[3][2];
				filter_reg[3][2] <= filter_reg[3][3];
				filter_reg[3][3] <= filter_reg[3][4];
				filter_reg[3][4] <= filter_reg[4][0];
				filter_reg[4][0] <= filter_reg[4][1];
				filter_reg[4][1] <= filter_reg[4][2];
				filter_reg[4][2] <= filter_reg[4][3];
				filter_reg[4][3] <= filter_reg[4][4];
				filter_reg[4][4] <= in_data;
			end
			else begin // 3x3
				for(integer i =0;i<5;i+=1)begin
					filter_reg[0][i] <= 0;
					filter_reg[4][i] <= 0;
				end

				for(integer j=1;j<=3;j+=1)begin
					filter_reg[j][0] <= 0;
					filter_reg[j][4] <= 0;
				end

				filter_reg[1][1] <= filter_reg[1][2];
				filter_reg[1][2] <= filter_reg[1][3];
				filter_reg[1][3] <= filter_reg[2][1];
				filter_reg[2][1] <= filter_reg[2][2];
				filter_reg[2][2] <= filter_reg[2][3];
				filter_reg[2][3] <= filter_reg[3][1];
				filter_reg[3][1] <= filter_reg[3][2];
				filter_reg[3][2] <= filter_reg[3][3];
				filter_reg[3][3] <= in_data;
			end
		end
	end
end


// FSM
always_ff @(posedge clk or negedge rst_n)begin
	if (!rst_n) begin
		curr_state <= IDLE;
	end
	else begin
		curr_state <= nxt_state;
	end
end

always_comb begin : nxt_state_comb
	state = curr_state;
	casez (curr_state)
		IDLE: begin
			if (filter_valid) begin
				nxt_state = FILTER;
			end
			else if (image_valid) begin
				nxt_state = IMAGE;
			end
			else begin
				nxt_state = IDLE;
			end
		end

		FILTER:begin
			nxt_state = (!filter_valid) ? IDLE : FILTER;
		end

		IMAGE:begin
			nxt_state = (out_valid && !nxt_out_valid) ? IDLE : IMAGE;
		end

		default: nxt_state = IDLE;
	endcase
end

endmodule
