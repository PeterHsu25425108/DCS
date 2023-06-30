//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------

//COUNTER #(.COUNTERSIZE(COUNTERSIZE)) master_counter(.flush(master_flush), .count(master_count), .counter_out(master_count_val), .clk(clk), .rst_n(rst_n));
module COUNTER(
  // Input signals
  clk, 
  rst_n, 
  count, 
  flush,
  // Output signals
  counter_out
);

//parameter COUNTERSIZE = 8;

input logic clk, rst_n, count, flush;
output logic [/*COUNTERSIZE-1*/9 : 0] counter_out;
logic [/*COUNTERSIZE-1*/9 : 0] next_counter_out;

always @(posedge clk or negedge rst_n) begin : counter_seq
  if(!rst_n) begin
    counter_out <= 0;
  end
  else begin
    counter_out <= next_counter_out;
  end
end

always_comb begin : counter_comb
	case({count, flush})
		2'b00: next_counter_out = counter_out;
		2'b01: next_counter_out = 0;
		2'b10: next_counter_out = counter_out + 1;
		default: next_counter_out = 1;
	endcase
end

endmodule

module CUMU_COUNTER(
  // Input signals
  clk, 
  rst_n, 
  count, 
  flush,
  // Output signals
  counter_out
);

//parameter COUNTERSIZE = 8;

input logic clk, rst_n, count, flush;
output logic [/*COUNTERSIZE-1*/2 : 0] counter_out;
logic [/*COUNTERSIZE-1*/2 : 0] next_counter_out;

always @(posedge clk or negedge rst_n) begin : counter_seq
  if(!rst_n) begin
    counter_out <= 0;
  end
  else begin
    counter_out <= next_counter_out;
  end
end

always_comb begin : counter_comb
	case({count, flush})
		2'b00: next_counter_out = counter_out;
		2'b01: next_counter_out = 0;
		2'b10: next_counter_out = counter_out + 1;
		default: next_counter_out = 1;
	endcase
end

endmodule

module THRES_COUNTER(
  // Input signals
  clk, 
  rst_n, 
  count, 
  flush,
  // Output signals
  counter_out
);

//parameter COUNTERSIZE = 8;

input logic clk, rst_n, count, flush;
output logic [/*COUNTERSIZE-1*/4 : 0] counter_out;
logic [/*COUNTERSIZE-1*/4 : 0] next_counter_out;

always @(posedge clk or negedge rst_n) begin : counter_seq
  if(!rst_n) begin
    counter_out <= 0;
  end
  else begin
    counter_out <= next_counter_out;
  end
end

always_comb begin : counter_comb
	case({count, flush})
		2'b00: next_counter_out = counter_out;
		2'b01: next_counter_out = 0;
		2'b10: next_counter_out = counter_out + 1;
		default: next_counter_out = 1;
	endcase
end

endmodule

module TF_COUNTER(
  // Input signals
  clk, 
  rst_n, 
  count, 
  flush,
  // Output signals
  counter_out
);

//parameter COUNTERSIZE = 8;

input logic clk, rst_n, count, flush;
output logic [/*COUNTERSIZE-1*/8 : 0] counter_out;
logic [/*COUNTERSIZE-1*/8 : 0] next_counter_out;

always @(posedge clk or negedge rst_n) begin : counter_seq
  if(!rst_n) begin
    counter_out <= 0;
  end
  else begin
    counter_out <= next_counter_out;
  end
end

always_comb begin : counter_comb
	case({count, flush})
		2'b00: next_counter_out = counter_out;
		2'b01: next_counter_out = 0;
		2'b10: next_counter_out = counter_out + 1;
		default: next_counter_out = 1;
	endcase
end

endmodule

module TF_UNIT(
	// Input signals
	tf_uint_in,
	tf_flush_ext,
	tf_count_ext,
	clk,
	rst_n,
	// Output signals
	tf_unit_out,
	exception
);
parameter TFSIZE = 8;

input tf_uint_in, tf_flush_ext, tf_count_ext, clk, rst_n;
output logic [/*TFSIZE-1*/8:0] tf_unit_out;
output logic [1:0] exception;
logic count, flush;
logic [/*TFSIZE-1*/7:0] tf_counter_val;

TF_COUNTER tf_count(.flush(flush), .count(count), .counter_out(tf_counter_val), .clk(clk), .rst_n(rst_n));
assign count = ((tf_counter_val <= 256) && tf_count_ext) && tf_uint_in;
assign flush = tf_flush_ext;
assign tf_unit_out = tf_counter_val;
assign exception = {(tf_counter_val == 238), (tf_counter_val == 239)};

endmodule

//CUMU_UNIT cumu_unit0 (.in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_reg[0]), .cumu_uint_in(in_image_reg[0]), .clk(clk), .rst_n(rst_n));

module CUMU_UNIT(
	// Input signals
	cumu_count_ext,
	cumu_flush_ext,
	clk,
	rst_n,
	in_image,
	cumu_uint_in,
	thres,
	// Output signals
	cumu_unit_out
);
//parameter CUMUSIZE = 3;

input [7:0] cumu_uint_in;
input [7:0] in_image;
input [2:0] thres;
input 	cumu_count_ext, cumu_flush_ext, clk, rst_n;
output logic cumu_unit_out;

logic count, flush;
logic [/*CUMUSIZE-1*/2:0] cumu_counter_val;
logic comp;

CUMU_COUNTER cumu_count(.flush(flush), .count(count), .counter_out(cumu_counter_val), .clk(clk), .rst_n(rst_n));
assign comp = (cumu_counter_val >= thres);
assign count = (/*!comp && */cumu_count_ext) && (cumu_uint_in >= in_image);
assign flush = comp || cumu_flush_ext;
assign cumu_unit_out = comp;

endmodule

//THRES_UNIT thres_unit0(.thres_flush_ext(thres_flush_ext), .thres_count_ext(thres_count_ext), .meet_thres(cumu_reg[0]), .exception(exception_arr[0]), .thres_out(thres_arr[0]), .clk(clk), .rst_n(rst_n));

module THRES_UNIT(
	// Input
	thres_flush_ext, 
	thres_count_ext, 
	meet_thres, 
	exception, 
	clk, 
	rst_n,
	// Output
	thres_out
);

input thres_flush_ext, thres_count_ext, meet_thres, clk, rst_n;
input [1:0] exception;
output logic [2:0] thres_out;

logic [4:0] thres_counter_val;
logic count, flush, comp;
logic [2:0] periodic_thres;

THRES_COUNTER thres_count(.flush(flush), .count(count), .counter_out(thres_counter_val), .clk(clk), .rst_n(rst_n));
assign comp = thres_counter_val >= 18;
assign count = meet_thres && thres_count_ext && !comp;
assign flush = thres_flush_ext || (comp && meet_thres);

always_comb begin : thres_func

	casez(thres_counter_val)
		5'd0, 5'd2, 5'd5, 5'd8, 5'd10, 5'd13, 5'd16: periodic_thres = 5;
		default: periodic_thres = 4;
	endcase
end

always_comb begin : exception_handling

	casez(exception)
		2'b00: thres_out = periodic_thres;
		2'b01: thres_out = 4;
		2'b10: thres_out = 5;
		default: thres_out = 3'bx;
	endcase
end

endmodule

module THRESHOLD(
	// Input signals
	thres_count_ext,
	thres_flush_ext,
	exception_arr,
	cumu_reg,
	clk,
	rst_n,
	// Output signals
	thres_arr
);

input thres_count_ext, thres_flush_ext, clk, rst_n;
input cumu_reg [7:0];
input [1:0] exception_arr [7:0];
output logic [2:0] thres_arr [7:0];

THRES_UNIT thres_unit0(.thres_flush_ext(thres_flush_ext), .thres_count_ext(thres_count_ext), .meet_thres(cumu_reg[0]), .exception(exception_arr[0]), .thres_out(thres_arr[0]), .clk(clk), .rst_n(rst_n));
THRES_UNIT thres_unit1(.thres_flush_ext(thres_flush_ext), .thres_count_ext(thres_count_ext), .meet_thres(cumu_reg[1]), .exception(exception_arr[1]), .thres_out(thres_arr[1]), .clk(clk), .rst_n(rst_n));
THRES_UNIT thres_unit2(.thres_flush_ext(thres_flush_ext), .thres_count_ext(thres_count_ext), .meet_thres(cumu_reg[2]), .exception(exception_arr[2]), .thres_out(thres_arr[2]), .clk(clk), .rst_n(rst_n));
THRES_UNIT thres_unit3(.thres_flush_ext(thres_flush_ext), .thres_count_ext(thres_count_ext), .meet_thres(cumu_reg[3]), .exception(exception_arr[3]), .thres_out(thres_arr[3]), .clk(clk), .rst_n(rst_n));
THRES_UNIT thres_unit4(.thres_flush_ext(thres_flush_ext), .thres_count_ext(thres_count_ext), .meet_thres(cumu_reg[4]), .exception(exception_arr[4]), .thres_out(thres_arr[4]), .clk(clk), .rst_n(rst_n));
THRES_UNIT thres_unit5(.thres_flush_ext(thres_flush_ext), .thres_count_ext(thres_count_ext), .meet_thres(cumu_reg[5]), .exception(exception_arr[5]), .thres_out(thres_arr[5]), .clk(clk), .rst_n(rst_n));
THRES_UNIT thres_unit6(.thres_flush_ext(thres_flush_ext), .thres_count_ext(thres_count_ext), .meet_thres(cumu_reg[6]), .exception(exception_arr[6]), .thres_out(thres_arr[6]), .clk(clk), .rst_n(rst_n));
THRES_UNIT thres_unit7(.thres_flush_ext(thres_flush_ext), .thres_count_ext(thres_count_ext), .meet_thres(cumu_reg[7]), .exception(exception_arr[7]), .thres_out(thres_arr[7]), .clk(clk), .rst_n(rst_n));
endmodule

module CUMU_STAGE(
	// Input signals
	in_image_reg,
	cumu_count_ext,
	cumu_flush_ext,
	clk,
	rst_n,
	in_image,
	thres_arr,
	// Output signals
	cumu_reg,
);
input [7:0] in_image_reg [7:0];
input 	cumu_count_ext, cumu_flush_ext, clk, rst_n;
input logic [7:0] in_image;
input [2:0] thres_arr [7:0];
output logic cumu_reg[7:0];

CUMU_UNIT cumu_unit0 (.thres(thres_arr[0]), .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_reg[0]), .cumu_uint_in(in_image_reg[0]), .clk(clk), .rst_n(rst_n));
CUMU_UNIT cumu_unit1 (.thres(thres_arr[1]), .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_reg[1]), .cumu_uint_in(in_image_reg[1]), .clk(clk), .rst_n(rst_n));
CUMU_UNIT cumu_unit2 (.thres(thres_arr[2]), .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_reg[2]), .cumu_uint_in(in_image_reg[2]), .clk(clk), .rst_n(rst_n));
CUMU_UNIT cumu_unit3 (.thres(thres_arr[3]), .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_reg[3]), .cumu_uint_in(in_image_reg[3]), .clk(clk), .rst_n(rst_n));
CUMU_UNIT cumu_unit4 (.thres(thres_arr[4]), .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_reg[4]), .cumu_uint_in(in_image_reg[4]), .clk(clk), .rst_n(rst_n));
CUMU_UNIT cumu_unit5 (.thres(thres_arr[5]), .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_reg[5]), .cumu_uint_in(in_image_reg[5]), .clk(clk), .rst_n(rst_n));
CUMU_UNIT cumu_unit6 (.thres(thres_arr[6]), .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_reg[6]), .cumu_uint_in(in_image_reg[6]), .clk(clk), .rst_n(rst_n));
CUMU_UNIT cumu_unit7 (.thres(thres_arr[7]), .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_reg[7]), .cumu_uint_in(in_image_reg[7]), .clk(clk), .rst_n(rst_n));

endmodule

module TF_STAGE(
	// Input signals
	cumu_reg, 
	master_count_val,
	clk,
	rst_n,
	tf_count_ext,
	tf_flush_ext,
	CUMU_stop,
	cumu_unit0_out,
	// Output signals
	tf_reg,
	exception_arr
);
input clk, rst_n, tf_count_ext, tf_flush_ext,CUMU_stop, cumu_unit0_out;
input [2:0] master_count_val;
input cumu_reg [7:0];
output logic [8:0] tf_reg;
output logic [1:0] exception_arr [7:0];
logic [8:0] tf_unit_out_arr[7:0];
logic [3:0] crit;

logic [8:0] tf_unit0_preout;

TF_UNIT tf_unit0 (.exception(exception_arr[0]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit0_preout), .tf_uint_in(cumu_reg[0]), .clk(clk), .rst_n(rst_n));
TF_UNIT tf_unit1 (.exception(exception_arr[1]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit_out_arr[1]), .tf_uint_in(cumu_reg[1]), .clk(clk), .rst_n(rst_n));
TF_UNIT tf_unit2 (.exception(exception_arr[2]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit_out_arr[2]), .tf_uint_in(cumu_reg[2]), .clk(clk), .rst_n(rst_n));
TF_UNIT tf_unit3 (.exception(exception_arr[3]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit_out_arr[3]), .tf_uint_in(cumu_reg[3]), .clk(clk), .rst_n(rst_n));
TF_UNIT tf_unit4 (.exception(exception_arr[4]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit_out_arr[4]), .tf_uint_in(cumu_reg[4]), .clk(clk), .rst_n(rst_n));
TF_UNIT tf_unit5 (.exception(exception_arr[5]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit_out_arr[5]), .tf_uint_in(cumu_reg[5]), .clk(clk), .rst_n(rst_n));
TF_UNIT tf_unit6 (.exception(exception_arr[6]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit_out_arr[6]), .tf_uint_in(cumu_reg[6]), .clk(clk), .rst_n(rst_n));
TF_UNIT tf_unit7 (.exception(exception_arr[7]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit_out_arr[7]), .tf_uint_in(cumu_reg[7]), .clk(clk), .rst_n(rst_n));

assign tf_unit_out_arr[0] = (CUMU_stop && cumu_unit0_out && !(&tf_unit0_preout)) ? tf_unit0_preout + 1: tf_unit0_preout;

always_comb begin : tf_stage_output_selection
	crit = {master_count_val, CUMU_stop};
	casez({master_count_val, CUMU_stop})
		4'b???1: tf_reg = tf_unit_out_arr[0];
		4'b0010: tf_reg = tf_unit_out_arr[1];
		4'b0100: tf_reg = tf_unit_out_arr[2];
		4'b0110: tf_reg = tf_unit_out_arr[3];
		4'b1000: tf_reg = tf_unit_out_arr[4];
		4'b1010: tf_reg = tf_unit_out_arr[5];
		4'b1100: tf_reg = tf_unit_out_arr[6];
		4'b1110: tf_reg = tf_unit_out_arr[7];
		default:
		tf_reg = 9'bx;
	endcase
end

endmodule

//INPUT_STAGE input_stage(.in_image(in_image), .input_ctrl_sig(input_ctrl_sig), .in_image_reg(in_image_reg), .clk(clk), .rst_n(rst_n));

module INPUT_STAGE(
	// Input signals
	in_image, 
	input_ctrl_sig,
	clk,
	rst_n,
	// Output signals
	in_image_reg
);

input input_ctrl_sig, clk, rst_n;
input [7:0] in_image;
output logic [7:0] in_image_reg [7:0];

logic [7:0] next_in_image_reg [7:0];

always_ff @(posedge clk or negedge rst_n) begin : out_stage_seq
	if(!rst_n) begin
		in_image_reg[0] <= 0;
		in_image_reg[1] <= 0;
		in_image_reg[2] <= 0;
		in_image_reg[3] <= 0;
		in_image_reg[4] <= 0;
		in_image_reg[5] <= 0;
		in_image_reg[6] <= 0;
		in_image_reg[7] <= 0;
	end 

	else begin
		in_image_reg[0] <= next_in_image_reg[0];
		in_image_reg[1] <= next_in_image_reg[1];
		in_image_reg[2] <= next_in_image_reg[2];
		in_image_reg[3] <= next_in_image_reg[3];
		in_image_reg[4] <= next_in_image_reg[4];
		in_image_reg[5] <= next_in_image_reg[5];
		in_image_reg[6] <= next_in_image_reg[6];
		in_image_reg[7] <= next_in_image_reg[7];
	end
end

always_comb begin : next_in_image_reg_comb
	if(input_ctrl_sig) begin
		next_in_image_reg = {in_image, in_image_reg[7], in_image_reg[6], in_image_reg[5], in_image_reg[4], in_image_reg[3], in_image_reg[2], in_image_reg[1]};
	end
	else begin
		next_in_image_reg[0] = in_image_reg[0];
		next_in_image_reg[1] = in_image_reg[1];
		next_in_image_reg[2] = in_image_reg[2];
		next_in_image_reg[3] = in_image_reg[3];
		next_in_image_reg[4] = in_image_reg[4];
		next_in_image_reg[5] = in_image_reg[5];
		next_in_image_reg[6] = in_image_reg[6];
		next_in_image_reg[7] = in_image_reg[7];
	end
end

endmodule

module  OUT_STAGE(
	// Input signals
	tf_reg, 
	output_ctrl_sig,
	clk,
	rst_n,
	// Output signals
	out_image
);

input 	clk, rst_n;
input [8:0] tf_reg;
input output_ctrl_sig;
output logic [7:0] out_image;

//logic [7:0] selected, next_selected;

/*always_ff @(posedge clk or negedge rst_n) begin : out_stage_seq
	if(!rst_n) begin
		selected <= 0;
	end 

	else begin
		selected <= next_selected;
	end
end*/

/*always_comb begin : next_selected_comb
	if(output_ctrl_sig) next_selected = (tf_reg > 0) ? tf_reg - 1: tf_reg;
	else next_selected = 0;
end*/

always_comb begin : out_image_comb
	casez({tf_reg, output_ctrl_sig})
		10'b?0: out_image = 0;
		10'b000000001: out_image = 0;
		10'b000000011: out_image = 0;
		10'b000000101: out_image = 1;
		10'b000000111: out_image = 2;
		10'b000001001: out_image = 3;
		10'b000001011: out_image = 4;
		10'b000001101: out_image = 5;
		10'b000001111: out_image = 6;
		10'b000010001: out_image = 7;
		10'b000010011: out_image = 8;
		10'b000010101: out_image = 9;
		10'b000010111: out_image = 10;
		10'b000011001: out_image = 11;
		10'b000011011: out_image = 12;
		10'b000011101: out_image = 13;
		10'b000011111: out_image = 14;
		10'b000100001: out_image = 15;
		10'b000100011: out_image = 16;
		10'b000100101: out_image = 17;
		10'b000100111: out_image = 18;
		10'b000101001: out_image = 19;
		10'b000101011: out_image = 20;
		10'b000101101: out_image = 21;
		10'b000101111: out_image = 22;
		10'b000110001: out_image = 23;
		10'b000110011: out_image = 24;
		10'b000110101: out_image = 25;
		10'b000110111: out_image = 26;
		10'b000111001: out_image = 27;
		10'b000111011: out_image = 28;
		10'b000111101: out_image = 29;
		10'b000111111: out_image = 30;
		10'b001000001: out_image = 31;
		10'b001000011: out_image = 32;
		10'b001000101: out_image = 33;
		10'b001000111: out_image = 34;
		10'b001001001: out_image = 35;
		10'b001001011: out_image = 36;
		10'b001001101: out_image = 37;
		10'b001001111: out_image = 38;
		10'b001010001: out_image = 39;
		10'b001010011: out_image = 40;
		10'b001010101: out_image = 41;
		10'b001010111: out_image = 42;
		10'b001011001: out_image = 43;
		10'b001011011: out_image = 44;
		10'b001011101: out_image = 45;
		10'b001011111: out_image = 46;
		10'b001100001: out_image = 47;
		10'b001100011: out_image = 48;
		10'b001100101: out_image = 49;
		10'b001100111: out_image = 50;
		10'b001101001: out_image = 51;
		10'b001101011: out_image = 52;
		10'b001101101: out_image = 53;
		10'b001101111: out_image = 54;
		10'b001110001: out_image = 55;
		10'b001110011: out_image = 56;
		10'b001110101: out_image = 57;
		10'b001110111: out_image = 58;
		10'b001111001: out_image = 59;
		10'b001111011: out_image = 60;
		10'b001111101: out_image = 61;
		10'b001111111: out_image = 62;
		10'b010000001: out_image = 63;
		10'b010000011: out_image = 64;
		10'b010000101: out_image = 65;
		10'b010000111: out_image = 66;
		10'b010001001: out_image = 67;
		10'b010001011: out_image = 68;
		10'b010001101: out_image = 69;
		10'b010001111: out_image = 70;
		10'b010010001: out_image = 71;
		10'b010010011: out_image = 72;
		10'b010010101: out_image = 73;
		10'b010010111: out_image = 74;
		10'b010011001: out_image = 75;
		10'b010011011: out_image = 76;
		10'b010011101: out_image = 77;
		10'b010011111: out_image = 78;
		10'b010100001: out_image = 79;
		10'b010100011: out_image = 80;
		10'b010100101: out_image = 81;
		10'b010100111: out_image = 82;
		10'b010101001: out_image = 83;
		10'b010101011: out_image = 84;
		10'b010101101: out_image = 85;
		10'b010101111: out_image = 86;
		10'b010110001: out_image = 87;
		10'b010110011: out_image = 88;
		10'b010110101: out_image = 89;
		10'b010110111: out_image = 90;
		10'b010111001: out_image = 91;
		10'b010111011: out_image = 92;
		10'b010111101: out_image = 93;
		10'b010111111: out_image = 94;
		10'b011000001: out_image = 95;
		10'b011000011: out_image = 96;
		10'b011000101: out_image = 97;
		10'b011000111: out_image = 98;
		10'b011001001: out_image = 99;
		10'b011001011: out_image = 100;
		10'b011001101: out_image = 101;
		10'b011001111: out_image = 102;
		10'b011010001: out_image = 103;
		10'b011010011: out_image = 104;
		10'b011010101: out_image = 105;
		10'b011010111: out_image = 106;
		10'b011011001: out_image = 107;
		10'b011011011: out_image = 108;
		10'b011011101: out_image = 109;
		10'b011011111: out_image = 110;
		10'b011100001: out_image = 111;
		10'b011100011: out_image = 112;
		10'b011100101: out_image = 113;
		10'b011100111: out_image = 114;
		10'b011101001: out_image = 115;
		10'b011101011: out_image = 116;
		10'b011101101: out_image = 117;
		10'b011101111: out_image = 118;
		10'b011110001: out_image = 119;
		10'b011110011: out_image = 120;
		10'b011110101: out_image = 121;
		10'b011110111: out_image = 122;
		10'b011111001: out_image = 123;
		10'b011111011: out_image = 124;
		10'b011111101: out_image = 125;
		10'b011111111: out_image = 126;
		10'b100000001: out_image = 127;
		10'b100000011: out_image = 128;
		10'b100000101: out_image = 129;
		10'b100000111: out_image = 130;
		10'b100001001: out_image = 131;
		10'b100001011: out_image = 132;
		10'b100001101: out_image = 133;
		10'b100001111: out_image = 134;
		10'b100010001: out_image = 135;
		10'b100010011: out_image = 136;
		10'b100010101: out_image = 137;
		10'b100010111: out_image = 138;
		10'b100011001: out_image = 139;
		10'b100011011: out_image = 140;
		10'b100011101: out_image = 141;
		10'b100011111: out_image = 142;
		10'b100100001: out_image = 143;
		10'b100100011: out_image = 144;
		10'b100100101: out_image = 145;
		10'b100100111: out_image = 146;
		10'b100101001: out_image = 147;
		10'b100101011: out_image = 148;
		10'b100101101: out_image = 149;
		10'b100101111: out_image = 150;
		10'b100110001: out_image = 151;
		10'b100110011: out_image = 152;
		10'b100110101: out_image = 153;
		10'b100110111: out_image = 154;
		10'b100111001: out_image = 155;
		10'b100111011: out_image = 156;
		10'b100111101: out_image = 157;
		10'b100111111: out_image = 158;
		10'b101000001: out_image = 159;
		10'b101000011: out_image = 160;
		10'b101000101: out_image = 161;
		10'b101000111: out_image = 162;
		10'b101001001: out_image = 163;
		10'b101001011: out_image = 164;
		10'b101001101: out_image = 165;
		10'b101001111: out_image = 166;
		10'b101010001: out_image = 167;
		10'b101010011: out_image = 168;
		10'b101010101: out_image = 169;
		10'b101010111: out_image = 170;
		10'b101011001: out_image = 171;
		10'b101011011: out_image = 172;
		10'b101011101: out_image = 173;
		10'b101011111: out_image = 174;
		10'b101100001: out_image = 175;
		10'b101100011: out_image = 176;
		10'b101100101: out_image = 177;
		10'b101100111: out_image = 178;
		10'b101101001: out_image = 179;
		10'b101101011: out_image = 180;
		10'b101101101: out_image = 181;
		10'b101101111: out_image = 182;
		10'b101110001: out_image = 183;
		10'b101110011: out_image = 184;
		10'b101110101: out_image = 185;
		10'b101110111: out_image = 186;
		10'b101111001: out_image = 187;
		10'b101111011: out_image = 188;
		10'b101111101: out_image = 189;
		10'b101111111: out_image = 190;
		10'b110000001: out_image = 191;
		10'b110000011: out_image = 192;
		10'b110000101: out_image = 193;
		10'b110000111: out_image = 194;
		10'b110001001: out_image = 195;
		10'b110001011: out_image = 196;
		10'b110001101: out_image = 197;
		10'b110001111: out_image = 198;
		10'b110010001: out_image = 199;
		10'b110010011: out_image = 200;
		10'b110010101: out_image = 201;
		10'b110010111: out_image = 202;
		10'b110011001: out_image = 203;
		10'b110011011: out_image = 204;
		10'b110011101: out_image = 205;
		10'b110011111: out_image = 206;
		10'b110100001: out_image = 207;
		10'b110100011: out_image = 208;
		10'b110100101: out_image = 209;
		10'b110100111: out_image = 210;
		10'b110101001: out_image = 211;
		10'b110101011: out_image = 212;
		10'b110101101: out_image = 213;
		10'b110101111: out_image = 214;
		10'b110110001: out_image = 215;
		10'b110110011: out_image = 216;
		10'b110110101: out_image = 217;
		10'b110110111: out_image = 218;
		10'b110111001: out_image = 219;
		10'b110111011: out_image = 220;
		10'b110111101: out_image = 221;
		10'b110111111: out_image = 222;
		10'b111000001: out_image = 223;
		10'b111000011: out_image = 224;
		10'b111000101: out_image = 225;
		10'b111000111: out_image = 226;
		10'b111001001: out_image = 227;
		10'b111001011: out_image = 228;
		10'b111001101: out_image = 229;
		10'b111001111: out_image = 230;
		10'b111010001: out_image = 231;
		10'b111010011: out_image = 232;
		10'b111010101: out_image = 233;
		10'b111010111: out_image = 234;
		10'b111011001: out_image = 235;
		10'b111011011: out_image = 236;
		10'b111011101: out_image = 237;
		10'b111011111: out_image = 238;
		10'b111100001: out_image = 239;
		10'b111100011: out_image = 240;
		10'b111100101: out_image = 241;
		10'b111100111: out_image = 242;
		10'b111101001: out_image = 243;
		10'b111101011: out_image = 244;
		10'b111101101: out_image = 245;
		10'b111101111: out_image = 246;
		10'b111110001: out_image = 247;
		10'b111110011: out_image = 248;
		10'b111110101: out_image = 249;
		10'b111110111: out_image = 250;
		10'b111111001: out_image = 251;
		10'b111111011: out_image = 252;
		10'b111111101: out_image = 253;
		10'b111111111: out_image = 254;
		10'b000000001: out_image = 255;
		default: out_image = 10b'x;
	endcase
	//out_image = next_selected;
end

endmodule

module HE(
	// Input signals
	clk,
	rst_n,
	in_valid,
	in_image,
  // Output signals
	out_valid,
	out_image
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input				clk,rst_n,in_valid;
input [7:0]			in_image;
output logic 		out_valid;
output logic [7:0]	out_image;

//---------------------------------------------------------------------
//   LOGIC DECLARATION                             
//---------------------------------------------------------------------
// fsm
logic [1:0] next_state, state, current_state;

// ctrl sig
logic IO_stop, CUMU_stop; // on when master counter val == 8
logic master_flush, master_count; // count/flush for master counter
logic cumu_flush_ext, cumu_count_ext; // count/flush for cumu counter
logic tf_flush_ext, tf_count_ext; // count/flush for tf counter
logic output_ctrl_sig, input_ctrl_sig; // decide whether i/o stage will be active
logic cumu_unit0_out;
//---------------------------------------------------------------------
//   parameter                                         
//---------------------------------------------------------------------
/*parameter MASTERSIZE = 2;*/
parameter 
	IDLE = 2'b00,
	INPUT = 2'b01,
	CUMU = 2'b11,
	OUTPUT = 2'b10;

// wires
logic [7:0] in_image_reg [7:0];
logic cumu_reg [7:0];
logic [8:0] tf_reg;
logic [7:0] next_out_image;
logic [1:0] exception_arr [7:0];
logic [2:0] thres_arr [7:0];
logic thres_count_ext, thres_flush_ext;

// master counter
logic [/*MASTERSIZE-1*/9:0] master_count_val;

//---------------------------------------------------------------------
//   Ctrl sig logic                                         
//---------------------------------------------------------------------

always_comb begin : cumu_flush_ext_comb
	casez (state)
		IDLE: begin
			cumu_flush_ext = 1;
		end 

		default: begin
			cumu_flush_ext = 0;
		end
	endcase
end

always_comb begin : cumu_count_ext_comb
	casez (state)
		INPUT: begin
			cumu_count_ext = IO_stop;
		end

		CUMU: begin
			cumu_count_ext = in_valid;
		end

		default: begin
			cumu_count_ext = 0;
		end
	endcase
end

always_comb begin : tf_flush_ext_comb
	casez (state)

		CUMU, OUTPUT: begin
			tf_flush_ext = 0;
		end
		default: begin
			tf_flush_ext = 1;
		end
	endcase
end

always_comb begin : tf_count_ext_comb
	tf_count_ext = (state == CUMU);
end

always_comb begin : input_ctrl_comb
	casez(state)
		IDLE: begin
			input_ctrl_sig = in_valid;
		end

		INPUT: begin
			input_ctrl_sig = !IO_stop;
		end

		OUTPUT,CUMU: begin
			input_ctrl_sig = 0;
		end

		default: begin
			input_ctrl_sig = 1'bx;
		end
	endcase
end

always_comb begin : output_ctrl_comb
	casez(state)
		CUMU:begin
			output_ctrl_sig = CUMU_stop;
		end

		OUTPUT:begin
			output_ctrl_sig = !IO_stop;
		end

		INPUT, IDLE:begin
			output_ctrl_sig = 0;
		end

		default:begin
			output_ctrl_sig = 1'bx;
		end
	endcase
end

// IO_stop logic
assign IO_stop = (master_count_val>=8);
assign CUMU_stop = (master_count_val==1023);

// master_flush
always_comb begin : master_flush_comb
	casez (state)
		IDLE: begin
			master_flush = !in_valid;
		end

		INPUT: begin
			master_flush = IO_stop;
		end

		CUMU:begin
			// wait until TF is completed, and then flush master_counter to raise IO_stop
			master_flush = (!in_valid) && IO_stop;
		end

		OUTPUT: begin
			master_flush = 0;
		end

		default: begin
			master_flush = 1'bx;
		end
	endcase	
end

// master_count
always_comb begin : master_count_comb
	casez (state)
		IDLE: begin
			master_count = in_valid;
		end

		INPUT: begin
			master_count = !IO_stop;
		end

		CUMU/*, OUTPUT*/:begin
			master_count = 1/*!IO_stop*//*in_valid*/;
		end

		OUTPUT: begin
			master_count = !IO_stop;
		end

		default: begin
			master_count = 1'bx;
		end
	endcase	
end

//---------------------------------------------------------------------
//   Threshould logic                                          
//---------------------------------------------------------------------
always_comb begin : thres_count_ext_comb
	thres_count_ext = (in_valid) && (state == CUMU);
end

always_comb begin : thres_flush_ext_comb
	thres_flush_ext = (state == IDLE);
end

//---------------------------------------------------------------------
//   Pipeline structure implementation                                          
//---------------------------------------------------------------------
COUNTER master_counter(.flush(master_flush), .count(master_count), .counter_out(master_count_val), .clk(clk), .rst_n(rst_n));
INPUT_STAGE input_stage(.in_image(in_image), .input_ctrl_sig(input_ctrl_sig), .in_image_reg(in_image_reg), .clk(clk), .rst_n(rst_n));
CUMU_STAGE cumu_stage(.thres_arr(thres_arr), .in_image, .in_image_reg(in_image_reg), .cumu_reg(cumu_reg), .cumu_count_ext(cumu_count_ext), .cumu_flush_ext(cumu_flush_ext), .clk(clk), .rst_n(rst_n));
TF_STAGE tf_stage(.CUMU_stop(CUMU_stop), .cumu_unit0_out(cumu_reg[0]), .exception_arr(exception_arr), .cumu_reg(cumu_reg), .tf_reg(tf_reg), .master_count_val(master_count_val[2:0]), .tf_count_ext(tf_count_ext), .tf_flush_ext(tf_flush_ext), .clk(clk), .rst_n(rst_n));
OUT_STAGE out_stage(.tf_reg(tf_reg), .out_image(out_image), .output_ctrl_sig(output_ctrl_sig), .clk(clk), .rst_n(rst_n));
THRESHOLD threshold(.thres_count_ext(thres_count_ext), .thres_flush_ext(thres_flush_ext), .exception_arr(exception_arr), .cumu_reg(cumu_reg), .thres_arr(thres_arr), .clk(clk), .rst_n(rst_n));
//---------------------------------------------------------------------
//   out_valid logic                                         
//---------------------------------------------------------------------

always_comb begin : out_valid_comb
	/*if(state == OUTPUT || state == CUMU) out_valid = !IO_stop;
	else out_valid = 0;*/
	casez(state)
		OUTPUT: out_valid = !IO_stop;
		CUMU: out_valid = CUMU_stop;
		default: out_valid = 0;
	endcase
end

//---------------------------------------------------------------------
//   Finite-State Mechine                                          
//---------------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin : state_seq
	if(!rst_n) begin
		current_state <= IDLE;
	end
	else begin
		current_state <= next_state;
	end
end

always_comb begin : next_state_comb
	state = current_state;

	casez (current_state)
		IDLE:begin
			if(in_valid) next_state = INPUT;
			else next_state = IDLE;

		end

		INPUT:begin
			if(IO_stop) next_state = CUMU;
			else next_state = INPUT;
		end

		CUMU:begin
			/*if(master_count_val == 0) next_state = CUMU;
			else next_state = OUTPUT;*/
			casez({in_valid, CUMU_stop})
				2'b01: next_state = OUTPUT;
				/*2'b00: next_state = CUMU;*/
				/*2'b11: next_state = CUMU;*/
				default: next_state = /*2'bx*/CUMU;
			endcase
		end

		OUTPUT:begin
			if(IO_stop) next_state = IDLE;
			else next_state = OUTPUT;
		end
		default: next_state = 2'bx;
	endcase
end

endmodule