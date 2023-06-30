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
output logic [/*COUNTERSIZE-1*/3 : 0] counter_out;
logic [/*COUNTERSIZE-1*/3 : 0] next_counter_out;

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
output logic [1:0] exception;
logic count, flush;
logic [/*TFSIZE-1*/7:0] tf_counter_val;

TF_COUNTER tf_count(.flush(flush), .count(count), .counter_out(tf_counter_val), .clk(clk), .rst_n(rst_n));
assign count = ((tf_counter_val < 255) && tf_count_ext) && tf_uint_in;
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
	cumu_reg
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
	// Output signals
	tf_reg,
	exception_arr
);
input clk, rst_n, tf_count_ext, tf_flush_ext;
input [3:0] master_count_val;
input cumu_reg [7:0];
output logic [7:0] tf_reg;
output logic [1:0] exception_arr [7:0];
logic [7:0] tf_unit_out_arr[7:0];

TF_UNIT tf_unit0 (.exception(exception_arr[0]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit_out_arr[0]), .tf_uint_in(cumu_reg[0]), .clk(clk), .rst_n(rst_n));
TF_UNIT tf_unit1 (.exception(exception_arr[1]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit_out_arr[1]), .tf_uint_in(cumu_reg[1]), .clk(clk), .rst_n(rst_n));
TF_UNIT tf_unit2 (.exception(exception_arr[2]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit_out_arr[2]), .tf_uint_in(cumu_reg[2]), .clk(clk), .rst_n(rst_n));
TF_UNIT tf_unit3 (.exception(exception_arr[3]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit_out_arr[3]), .tf_uint_in(cumu_reg[3]), .clk(clk), .rst_n(rst_n));
TF_UNIT tf_unit4 (.exception(exception_arr[4]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit_out_arr[4]), .tf_uint_in(cumu_reg[4]), .clk(clk), .rst_n(rst_n));
TF_UNIT tf_unit5 (.exception(exception_arr[5]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit_out_arr[5]), .tf_uint_in(cumu_reg[5]), .clk(clk), .rst_n(rst_n));
TF_UNIT tf_unit6 (.exception(exception_arr[6]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit_out_arr[6]), .tf_uint_in(cumu_reg[6]), .clk(clk), .rst_n(rst_n));
TF_UNIT tf_unit7 (.exception(exception_arr[7]), .tf_flush_ext(tf_flush_ext), .tf_count_ext(tf_count_ext), .tf_unit_out(tf_unit_out_arr[7]), .tf_uint_in(cumu_reg[7]), .clk(clk), .rst_n(rst_n));

always_comb begin : tf_stage_output_selection
	casez(master_count_val)
		4'd0: tf_reg = tf_unit_out_arr[0];
		4'd1: tf_reg = tf_unit_out_arr[1];
		4'd2: tf_reg = tf_unit_out_arr[2];
		4'd3: tf_reg = tf_unit_out_arr[3];
		4'd4: tf_reg = tf_unit_out_arr[4];
		4'd5: tf_reg = tf_unit_out_arr[5];
		4'd6: tf_reg = tf_unit_out_arr[6];
		4'd7: tf_reg = tf_unit_out_arr[7];
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

always_ff @(posedge clk or negedge rst_n) begin : out_stage_seq
	if(!rst_n) begin
		selected <= 0;
	end 

	else begin
		selected <= next_selected;
	end
end

always_comb begin : next_selected_comb
	if(output_ctrl_sig) next_selected = (tf_reg > 0) ? tf_reg - 1: tf_reg;
	else next_selected = 0;
end

always_comb begin : out_image_comb
	out_image = selected/*(selected > 0) ? selected - 1: selected*/;
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
logic IO_stop; // on when master counter val == 8
logic master_flush, master_count; // count/flush for master counter
logic cumu_flush_ext, cumu_count_ext; // count/flush for cumu counter
logic tf_flush_ext, tf_count_ext; // count/flush for tf counter
logic output_ctrl_sig, input_ctrl_sig; // decide whether i/o stage will be active

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
logic [7:0] tf_reg;
logic [7:0] next_out_image;
logic [1:0] exception_arr [7:0];
logic [2:0] thres_arr [7:0];
logic thres_count_ext, thres_flush_ext;

// master counter
logic [/*MASTERSIZE-1*/3:0] master_count_val;

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
			output_ctrl_sig = !IO_stop;
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

// master_flush
always_comb begin : master_flush_comb
	casez (state)
		IDLE: begin
			master_flush = !in_valid;
		end

		INPUT: begin
			master_flush = 0;
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

		CUMU, OUTPUT:begin
			master_count = !IO_stop;
		end

		/*OUTPUT: begin
			master_count = !IO_stop;
		end*/

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
TF_STAGE tf_stage(.exception_arr(exception_arr), .cumu_reg(cumu_reg), .tf_reg(tf_reg), .master_count_val(master_count_val), .tf_count_ext(tf_count_ext), .tf_flush_ext(tf_flush_ext), .clk(clk), .rst_n(rst_n));
OUT_STAGE out_stage(.tf_reg(tf_reg), .out_image(out_image), .output_ctrl_sig(output_ctrl_sig), .clk(clk), .rst_n(rst_n));
THRESHOLD threshold(.thres_count_ext(thres_count_ext), .thres_flush_ext(thres_flush_ext), .exception_arr(exception_arr), .cumu_reg(cumu_reg), .thres_arr(thres_arr), .clk(clk), .rst_n(rst_n));
//---------------------------------------------------------------------
//   out_valid logic                                         
//---------------------------------------------------------------------

always_comb begin : out_valid_comb
	if(state == OUTPUT) out_valid = 1;
	else out_valid = 0;
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
			casez({in_valid, IO_stop})
				2'b00: next_state = OUTPUT;
				2'b01: next_state = CUMU;
				2'b11: next_state = CUMU;
				default: next_state = 2'bx;
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