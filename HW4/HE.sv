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
output logic [/*COUNTERSIZE-1*/7 : 0] counter_out;
logic [/*COUNTERSIZE-1*/7 : 0] next_counter_out;

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
output logic [/*TFSIZE-1*/7:0] tf_unit_out;
output logic exception;
logic count, flush;
logic [/*TFSIZE-1*/7:0] tf_counter_val;

TF_COUNTER tf_count(.flush(flush), .count(count), .counter_out(tf_counter_val), .clk(clk), .rst_n(rst_n));
assign count = ((tf_counter_val < 255) && tf_count_ext) && tf_uint_in;
assign flush = tf_flush_ext;
assign tf_unit_out = tf_counter_val;
assign exception = {(tf_counter_val == 238) || (tf_counter_val == 239)};
/*always_comb begin : exception_comb
	casez(tf_counter_val)
		8'b00000000: exception = 2'b00;
		8'b00000001: exception = 2'b00;
		8'b00000010: exception = 2'b00;
		8'b00000011: exception = 2'b00;
		8'b00000100: exception = 2'b00;
		8'b00000101: exception = 2'b00;
		8'b00000110: exception = 2'b00;
		8'b00000111: exception = 2'b00;
		8'b00001000: exception = 2'b00;
		8'b00001001: exception = 2'b00;
		8'b00001010: exception = 2'b00;
		8'b00001011: exception = 2'b00;
		8'b00001100: exception = 2'b00;
		8'b00001101: exception = 2'b00;
		8'b00001110: exception = 2'b00;
		8'b00001111: exception = 2'b00;
		8'b00010000: exception = 2'b00;
		8'b00010001: exception = 2'b00;
		8'b00010010: exception = 2'b00;
		8'b00010011: exception = 2'b00;
		8'b00010100: exception = 2'b00;
		8'b00010101: exception = 2'b00;
		8'b00010110: exception = 2'b00;
		8'b00010111: exception = 2'b00;
		8'b00011000: exception = 2'b00;
		8'b00011001: exception = 2'b00;
		8'b00011010: exception = 2'b00;
		8'b00011011: exception = 2'b00;
		8'b00011100: exception = 2'b00;
		8'b00011101: exception = 2'b00;
		8'b00011110: exception = 2'b00;
		8'b00011111: exception = 2'b00;
		8'b00100000: exception = 2'b00;
		8'b00100001: exception = 2'b00;
		8'b00100010: exception = 2'b00;
		8'b00100011: exception = 2'b00;
		8'b00100100: exception = 2'b00;
		8'b00100101: exception = 2'b00;
		8'b00100110: exception = 2'b00;
		8'b00100111: exception = 2'b00;
		8'b00101000: exception = 2'b00;
		8'b00101001: exception = 2'b00;
		8'b00101010: exception = 2'b00;
		8'b00101011: exception = 2'b00;
		8'b00101100: exception = 2'b00;
		8'b00101101: exception = 2'b00;
		8'b00101110: exception = 2'b00;
		8'b00101111: exception = 2'b00;
		8'b00110000: exception = 2'b00;
		8'b00110001: exception = 2'b00;
		8'b00110010: exception = 2'b00;
		8'b00110011: exception = 2'b00;
		8'b00110100: exception = 2'b00;
		8'b00110101: exception = 2'b00;
		8'b00110110: exception = 2'b00;
		8'b00110111: exception = 2'b00;
		8'b00111000: exception = 2'b00;
		8'b00111001: exception = 2'b00;
		8'b00111010: exception = 2'b00;
		8'b00111011: exception = 2'b00;
		8'b00111100: exception = 2'b00;
		8'b00111101: exception = 2'b00;
		8'b00111110: exception = 2'b00;
		8'b00111111: exception = 2'b00;
		8'b01000000: exception = 2'b00;
		8'b01000001: exception = 2'b00;
		8'b01000010: exception = 2'b00;
		8'b01000011: exception = 2'b00;
		8'b01000100: exception = 2'b00;
		8'b01000101: exception = 2'b00;
		8'b01000110: exception = 2'b00;
		8'b01000111: exception = 2'b00;
		8'b01001000: exception = 2'b00;
		8'b01001001: exception = 2'b00;
		8'b01001010: exception = 2'b00;
		8'b01001011: exception = 2'b00;
		8'b01001100: exception = 2'b00;
		8'b01001101: exception = 2'b00;
		8'b01001110: exception = 2'b00;
		8'b01001111: exception = 2'b00;
		8'b01010000: exception = 2'b00;
		8'b01010001: exception = 2'b00;
		8'b01010010: exception = 2'b00;
		8'b01010011: exception = 2'b00;
		8'b01010100: exception = 2'b00;
		8'b01010101: exception = 2'b00;
		8'b01010110: exception = 2'b00;
		8'b01010111: exception = 2'b00;
		8'b01011000: exception = 2'b00;
		8'b01011001: exception = 2'b00;
		8'b01011010: exception = 2'b00;
		8'b01011011: exception = 2'b00;
		8'b01011100: exception = 2'b00;
		8'b01011101: exception = 2'b00;
		8'b01011110: exception = 2'b00;
		8'b01011111: exception = 2'b00;
		8'b01100000: exception = 2'b00;
		8'b01100001: exception = 2'b00;
		8'b01100010: exception = 2'b00;
		8'b01100011: exception = 2'b00;
		8'b01100100: exception = 2'b00;
		8'b01100101: exception = 2'b00;
		8'b01100110: exception = 2'b00;
		8'b01100111: exception = 2'b00;
		8'b01101000: exception = 2'b00;
		8'b01101001: exception = 2'b00;
		8'b01101010: exception = 2'b00;
		8'b01101011: exception = 2'b00;
		8'b01101100: exception = 2'b00;
		8'b01101101: exception = 2'b00;
		8'b01101110: exception = 2'b00;
		8'b01101111: exception = 2'b00;
		8'b01110000: exception = 2'b00;
		8'b01110001: exception = 2'b00;
		8'b01110010: exception = 2'b00;
		8'b01110011: exception = 2'b00;
		8'b01110100: exception = 2'b00;
		8'b01110101: exception = 2'b00;
		8'b01110110: exception = 2'b00;
		8'b01110111: exception = 2'b00;
		8'b01111000: exception = 2'b00;
		8'b01111001: exception = 2'b00;
		8'b01111010: exception = 2'b00;
		8'b01111011: exception = 2'b00;
		8'b01111100: exception = 2'b00;
		8'b01111101: exception = 2'b00;
		8'b01111110: exception = 2'b00;
		8'b01111111: exception = 2'b00;
		8'b10000000: exception = 2'b00;
		8'b10000001: exception = 2'b00;
		8'b10000010: exception = 2'b00;
		8'b10000011: exception = 2'b00;
		8'b10000100: exception = 2'b00;
		8'b10000101: exception = 2'b00;
		8'b10000110: exception = 2'b00;
		8'b10000111: exception = 2'b00;
		8'b10001000: exception = 2'b00;
		8'b10001001: exception = 2'b00;
		8'b10001010: exception = 2'b00;
		8'b10001011: exception = 2'b00;
		8'b10001100: exception = 2'b00;
		8'b10001101: exception = 2'b00;
		8'b10001110: exception = 2'b00;
		8'b10001111: exception = 2'b00;
		8'b10010000: exception = 2'b00;
		8'b10010001: exception = 2'b00;
		8'b10010010: exception = 2'b00;
		8'b10010011: exception = 2'b00;
		8'b10010100: exception = 2'b00;
		8'b10010101: exception = 2'b00;
		8'b10010110: exception = 2'b00;
		8'b10010111: exception = 2'b00;
		8'b10011000: exception = 2'b00;
		8'b10011001: exception = 2'b00;
		8'b10011010: exception = 2'b00;
		8'b10011011: exception = 2'b00;
		8'b10011100: exception = 2'b00;
		8'b10011101: exception = 2'b00;
		8'b10011110: exception = 2'b00;
		8'b10011111: exception = 2'b00;
		8'b10100000: exception = 2'b00;
		8'b10100001: exception = 2'b00;
		8'b10100010: exception = 2'b00;
		8'b10100011: exception = 2'b00;
		8'b10100100: exception = 2'b00;
		8'b10100101: exception = 2'b00;
		8'b10100110: exception = 2'b00;
		8'b10100111: exception = 2'b00;
		8'b10101000: exception = 2'b00;
		8'b10101001: exception = 2'b00;
		8'b10101010: exception = 2'b00;
		8'b10101011: exception = 2'b00;
		8'b10101100: exception = 2'b00;
		8'b10101101: exception = 2'b00;
		8'b10101110: exception = 2'b00;
		8'b10101111: exception = 2'b00;
		8'b10110000: exception = 2'b00;
		8'b10110001: exception = 2'b00;
		8'b10110010: exception = 2'b00;
		8'b10110011: exception = 2'b00;
		8'b10110100: exception = 2'b00;
		8'b10110101: exception = 2'b00;
		8'b10110110: exception = 2'b00;
		8'b10110111: exception = 2'b00;
		8'b10111000: exception = 2'b00;
		8'b10111001: exception = 2'b00;
		8'b10111010: exception = 2'b00;
		8'b10111011: exception = 2'b00;
		8'b10111100: exception = 2'b00;
		8'b10111101: exception = 2'b00;
		8'b10111110: exception = 2'b00;
		8'b10111111: exception = 2'b00;
		8'b11000000: exception = 2'b00;
		8'b11000001: exception = 2'b00;
		8'b11000010: exception = 2'b00;
		8'b11000011: exception = 2'b00;
		8'b11000100: exception = 2'b00;
		8'b11000101: exception = 2'b00;
		8'b11000110: exception = 2'b00;
		8'b11000111: exception = 2'b00;
		8'b11001000: exception = 2'b00;
		8'b11001001: exception = 2'b00;
		8'b11001010: exception = 2'b00;
		8'b11001011: exception = 2'b00;
		8'b11001100: exception = 2'b00;
		8'b11001101: exception = 2'b00;
		8'b11001110: exception = 2'b00;
		8'b11001111: exception = 2'b00;
		8'b11010000: exception = 2'b00;
		8'b11010001: exception = 2'b00;
		8'b11010010: exception = 2'b00;
		8'b11010011: exception = 2'b00;
		8'b11010100: exception = 2'b00;
		8'b11010101: exception = 2'b00;
		8'b11010110: exception = 2'b00;
		8'b11010111: exception = 2'b00;
		8'b11011000: exception = 2'b00;
		8'b11011001: exception = 2'b00;
		8'b11011010: exception = 2'b00;
		8'b11011011: exception = 2'b00;
		8'b11011100: exception = 2'b00;
		8'b11011101: exception = 2'b00;
		8'b11011110: exception = 2'b00;
		8'b11011111: exception = 2'b00;
		8'b11100000: exception = 2'b00;
		8'b11100001: exception = 2'b00;
		8'b11100010: exception = 2'b00;
		8'b11100011: exception = 2'b00;
		8'b11100100: exception = 2'b00;
		8'b11100101: exception = 2'b00;
		8'b11100110: exception = 2'b00;
		8'b11100111: exception = 2'b00;
		8'b11101000: exception = 2'b00;
		8'b11101001: exception = 2'b00;
		8'b11101010: exception = 2'b00;
		8'b11101011: exception = 2'b00;
		8'b11101100: exception = 2'b00;
		8'b11101101: exception = 2'b00;
		8'b11101110: exception = 2'b10;
		8'b11101111: exception = 2'b01;
		8'b11110000: exception = 2'b00;
		8'b11110001: exception = 2'b00;
		8'b11110010: exception = 2'b00;
		8'b11110011: exception = 2'b00;
		8'b11110100: exception = 2'b00;
		8'b11110101: exception = 2'b00;
		8'b11110110: exception = 2'b00;
		8'b11110111: exception = 2'b00;
		8'b11111000: exception = 2'b00;
		8'b11111001: exception = 2'b00;
		8'b11111010: exception = 2'b00;
		8'b11111011: exception = 2'b00;
		8'b11111100: exception = 2'b00;
		8'b11111101: exception = 2'b00;
		8'b11111110: exception = 2'b00;
		8'b11111111: exception = 2'b00;
		8'b00000000: exception = 2'b00;
	default: exception = 8'bx;
	endcase
end*/

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
input exception;
output logic [2:0] thres_out;

logic [4:0] thres_counter_val;
logic count, flush, comp;
logic [2:0] periodic_thres;

THRES_COUNTER thres_count(.flush(flush), .count(count), .counter_out(thres_counter_val), .clk(clk), .rst_n(rst_n));
assign comp = thres_counter_val >= 18;
assign count = meet_thres && thres_count_ext && !comp;
assign flush = thres_flush_ext || (comp && meet_thres);

always_comb begin : thres_func
	periodic_thres[2:1] = 2'b10;
	casez(thres_counter_val)
		5'd0, 5'd2, 5'd5, 5'd8, 5'd10, 5'd13, 5'd16: periodic_thres[0] = 1;
		default: periodic_thres[0] = 0;
	endcase
end

always_comb begin : exception_handling

	/*casez(exception)
		2'b00: thres_out = periodic_thres;
		2'b01: thres_out = 4;
		2'b10: thres_out = 5;
		default: thres_out = 3'bx;
	endcase*/
	thres_out[2:1] = periodic_thres[2:1];
	thres_out[0] = exception ^ periodic_thres[0];
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
input exception_arr [7:0];
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
output logic [7:0] tf_reg;
output logic exception_arr [7:0];
logic [7:0] tf_unit_out_arr[7:0];
logic [3:0] crit;

logic [7:0] tf_unit0_preout;

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
		tf_reg = 8'bx;
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
input [7:0] tf_reg;
input output_ctrl_sig;
output logic [7:0] out_image;

logic [7:0] selected, next_selected;

/*always_ff @(posedge clk or negedge rst_n) begin : out_stage_seq
	if(!rst_n) begin
		selected <= 0;
	end 

	else begin
		selected <= next_selected;
	end
end*/

always_comb begin : next_selected_comb
	if(output_ctrl_sig) next_selected = (tf_reg > 0) ? tf_reg - 1: tf_reg;
	else next_selected = 0;
end

always_comb begin : out_image_comb
	out_image = next_selected;
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
	IDLE = 2'b01,
	INPUT = 2'b00,
	CUMU = 2'b10,
	OUTPUT = 2'b11;

// wires
logic [7:0] in_image_reg [7:0];
logic cumu_reg [7:0];
logic [7:0] tf_reg;
logic [7:0] next_out_image;
logic exception_arr [7:0];
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