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
  shift,
  load_val,
  // Output signals
  counter_out
);

//parameter COUNTERSIZE = 8;

input logic clk, rst_n, count, flush, shift;
input logic [9:0] load_val;
output logic [9 : 0] counter_out;
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
	/*case({count, flush})
		2'b00: next_counter_out = counter_out;
		2'b01: next_counter_out = 0;
		2'b10: next_counter_out = counter_out + 1;
		default: next_counter_out = 1;
	endcase*/
	if(flush) next_counter_out = 0;
	else if(count) next_counter_out = counter_out + 1;
	else if(shift) next_counter_out = load_val;
	else next_counter_out = next_counter_out;
end

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
	shift,
	load_val,
	// Output signals
	cumu_unit_out
);
//parameter CUMUSIZE = 3;

input [7:0] cumu_uint_in;
input [7:0] in_image;
input 	cumu_count_ext, cumu_flush_ext, clk, rst_n, shift;
input [9:0] load_val;
output logic [9:0] cumu_unit_out;

logic count, flush;
logic [9:0] cumu_counter_val;
logic comp;

CUMU_COUNTER cumu_count(.shift(shift), .load_val(load_val), .flush(flush), .count(count), .counter_out(cumu_counter_val), .clk(clk), .rst_n(rst_n));
assign comp = (cumu_counter_val <= 1121);
assign count = comp && cumu_count_ext && (cumu_uint_in >= in_image);
assign flush = cumu_flush_ext;
assign cumu_unit_out = cumu_counter_val;

endmodule

//THRES_UNIT thres_unit0(.thres_flush_ext(thres_flush_ext), .thres_count_ext(thres_count_ext), .meet_thres(cumu_reg[0]), .exception(exception_arr[0]), .thres_out(thres_arr[0]), .clk(clk), .rst_n(rst_n));

CUMU_STAGE cumu_stage(.output_ctrl_sig(output_ctrl_sig), .in_image, .in_image_reg(in_image_reg), .cumu_reg(cumu_reg), .cumu_count_ext(cumu_count_ext), .cumu_flush_ext(cumu_flush_ext), .clk(clk), .rst_n(rst_n));

module CUMU_STAGE(
	// Input signals
	output_ctrl_sig,
	in_image_reg,
	cumu_count_ext,
	cumu_flush_ext,
	clk,
	rst_n,
	in_image,
	// Output signals
	cumu_reg,
);
input [7:0] in_image_reg [7:0];
input 	cumu_count_ext, cumu_flush_ext, clk, rst_n;
input logic [7:0] in_image;
output logic cumu_reg[9:0];

logic [9:0] cumu_arr [7:0];

CUMU_UNIT cumu_unit0 (.load_val(cumu_arr[1]), .shift(output_ctrl_sig) .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_arr[0]), .cumu_uint_in(in_image_reg[0]), .clk(clk), .rst_n(rst_n));
CUMU_UNIT cumu_unit1 (.load_val(cumu_arr[2]), .shift(output_ctrl_sig) .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_arr[1]), .cumu_uint_in(in_image_reg[1]), .clk(clk), .rst_n(rst_n));
CUMU_UNIT cumu_unit2 (.load_val(cumu_arr[3]), .shift(output_ctrl_sig) .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_arr[2]), .cumu_uint_in(in_image_reg[2]), .clk(clk), .rst_n(rst_n));
CUMU_UNIT cumu_unit3 (.load_val(cumu_arr[4]), .shift(output_ctrl_sig) .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_arr[3]), .cumu_uint_in(in_image_reg[3]), .clk(clk), .rst_n(rst_n));
CUMU_UNIT cumu_unit4 (.load_val(cumu_arr[5]), .shift(output_ctrl_sig) .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_arr[4]), .cumu_uint_in(in_image_reg[4]), .clk(clk), .rst_n(rst_n));
CUMU_UNIT cumu_unit5 (.load_val(cumu_arr[6]), .shift(output_ctrl_sig) .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_arr[5]), .cumu_uint_in(in_image_reg[5]), .clk(clk), .rst_n(rst_n));
CUMU_UNIT cumu_unit6 (.load_val(cumu_arr[7]), .shift(output_ctrl_sig) .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_arr[6]), .cumu_uint_in(in_image_reg[6]), .clk(clk), .rst_n(rst_n));
CUMU_UNIT cumu_unit7 (.load_val(cumu_arr[0]), .shift(output_ctrl_sig) .in_image(in_image), .cumu_flush_ext(cumu_flush_ext), .cumu_count_ext(cumu_count_ext), .cumu_unit_out(cumu_arr[7]), .cumu_uint_in(in_image_reg[7]), .clk(clk), .rst_n(rst_n));

assign cumu_reg = cumu_arr[0];

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
	cumu_reg, 
	output_ctrl_sig,
	clk,
	rst_n,
	// Output signals
	out_image
);

input 	clk, rst_n;
input [9:0] cumu_reg;
input output_ctrl_sig;
output logic [7:0] out_image;

always_comb begin : out_image_comb

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
logic cumu_reg [9:0];

// master counter
logic [9:0] master_count_val;

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
CUMU_STAGE cumu_stage(.output_ctrl_sig(output_ctrl_sig), .in_image, .in_image_reg(in_image_reg), .cumu_reg(cumu_reg), .cumu_count_ext(cumu_count_ext), .cumu_flush_ext(cumu_flush_ext), .clk(clk), .rst_n(rst_n));
//TF_STAGE tf_stage(.CUMU_stop(CUMU_stop), .cumu_unit0_out(cumu_reg[0]), .exception_arr(exception_arr), .cumu_reg(cumu_reg), .tf_reg(tf_reg), .master_count_val(master_count_val[2:0]), .tf_count_ext(tf_count_ext), .tf_flush_ext(tf_flush_ext), .clk(clk), .rst_n(rst_n));
OUT_STAGE out_stage(.cumu_reg(cumu_reg), .out_image(out_image), .output_ctrl_sig(output_ctrl_sig), .clk(clk), .rst_n(rst_n));
//THRESHOLD threshold(.thres_count_ext(thres_count_ext), .thres_flush_ext(thres_flush_ext), .exception_arr(exception_arr), .cumu_reg(cumu_reg), .thres_arr(thres_arr), .clk(clk), .rst_n(rst_n));
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