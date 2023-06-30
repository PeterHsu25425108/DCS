/*adder:
Combinational area:               2548.022449
Buf/Inv area:                      209.563208
Noncombinational area:            7351.344070
Macro/Black Box area:                0.000000
Net Interconnect area:      undefined  (No wire load specified)

Total cell area:                  9899.366520
*/

/*bitshift:
Combinational area:               2192.097652
Buf/Inv area:                       29.937601
Noncombinational area:            9164.232086
Macro/Black Box area:                0.000000
Net Interconnect area:      undefined  (No wire load specified)

Total cell area:                 11356.329739

*/

`define adder_config

module I2S(
  // Input signals
  clk,
  rst_n,
  in_valid,
  SD,
  WS,
  // Output signals
  out_valid,
  out_left,
  out_right
);

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input SD, WS;

output logic out_valid;
output logic [31:0] out_left, out_right;

// Sequential terms
logic [31:0] input_buffer;
logic WS_buffer;// doesn't have to reset
logic in_valid_buffer;

// Comb term
logic next_out_valid; // determined by WS_buffer, WS, in_valid, in_valid_buffer
//logic [31:0] next_out; // determined by input_count
logic buffer_sufficient; // see if there's at least 5 value in the buffer


`ifdef adder_config

  // Sequential term
  logic [2:0] input_count;

  always @(posedge clk, negedge rst_n) begin : seq_block

      if(!rst_n)begin
        input_buffer <= 0;
        out_valid <= 0;
        out_left <= 0;
        out_right <= 0;
        input_count <= 0;
      end

      else begin
        // handling input

        // WS_buffer
        WS_buffer <= WS;

        // in_valid_buffer
        in_valid_buffer <= in_valid;

        if(in_valid)begin

          input_buffer <= {input_buffer[30:0], SD};

          if(!buffer_sufficient) begin
            input_count <= input_count + 1;
          end
          else begin
            input_count <= input_count;
          end

        end
        else begin

          input_count <= 0;
          // clear input buffer, make room for the next wave of input
          input_buffer <= 0;
        end

        // out valid
        out_valid <= next_out_valid;

        // out left/right

        // output the data in the buffer
        if(next_out_valid)begin
          if(WS_buffer)begin
            out_left <= 0;
            out_right <= input_buffer;
          end
          else begin
            out_left <= input_buffer;
            out_right <= 0;
          end

          // clear input buffer after output, and then input the SD value at that moment if it's still accepting input
          if(in_valid) begin
            input_buffer <= {31'b0, SD};
            input_count <= 1;
          end
          else begin
            input_buffer <= 0;
            input_count <= 0;
          end
        end

        // output void
        else begin
          out_left <= 0;
          out_right <= 0;
        end
      end
  end

  always_comb begin : comb_block
      /*logic next_out_valid; // determined by WS_buffer, WS, in_valid, in_valid_buffer, input_count >= 5
      logic [31:0] next_out; // determined by input_count*/

      // buffer_sufficient
      buffer_sufficient = !(input_count[2] || input_count[0]);

      // out_valid

      // impossible: 
      // WS rising, in_valid = 0
      // WS rising, in_valid falling
      casez({WS_buffer, WS, in_valid_buffer, in_valid})

        // WS unchanged , in_valid = 0
        4'b0000: next_out_valid = 0;
        4'b1100: next_out_valid = 0;

        // WS unchanged , in_valid = 1
        4'b0011: next_out_valid = 0;
        4'b1111: next_out_valid = 0;

        // WS unchanged, in_valid rising
        4'b0001: next_out_valid = 0;
        4'b1101: next_out_valid = 0;

        //  WS unchanged in_valid falling
        4'b0010: next_out_valid = buffer_sufficient;
        4'b1110: next_out_valid = buffer_sufficient;

        // WS rising, in_valid = 1
        4'b0111: next_out_valid = buffer_sufficient;
        // WS rising, in_valid rising
        4'b0101: next_out_valid = 0;

        // WS falling, in_valid = 0
        4'b1000: next_out_valid = 0;
        // WS falling, in_valid = 1
        4'b1011: next_out_valid = buffer_sufficient;
        // WS falling, in_valid rising
        4'b1001: next_out_valid = 0;

        // WS falling, in_valid falling
        4'b1010: next_out_valid = buffer_sufficient;
        default: next_out_valid = 1'bx;
  
      endcase

      // next_out
      //next_out = input_buffer;
      /*case(input_count)
        5: next_out = {27'd0, input_buffer[4:0]};
        6: next_out = {26'd0, input_buffer[5:0]};
        7: next_out = {25'd0, input_buffer[6:0]};
        8: next_out = {24'd0, input_buffer[7:0]};
        9: next_out = {23'd0, input_buffer[8:0]};
        10: next_out = {22'd0, input_buffer[9:0]};
        11: next_out = {21'd0, input_buffer[10:0]};
        12: next_out = {20'd0, input_buffer[11:0]};
        13: next_out = {19'd0, input_buffer[12:0]};
        14: next_out = {18'd0, input_buffer[13:0]};
        15: next_out = {17'd0, input_buffer[14:0]};
        16: next_out = {16'd0, input_buffer[15:0]};
        17: next_out = {15'd0, input_buffer[16:0]};
        18: next_out = {14'd0, input_buffer[17:0]};
        19: next_out = {13'd0, input_buffer[18:0]};
        20: next_out = {12'd0, input_buffer[19:0]};
        21: next_out = {11'd0, input_buffer[20:0]};
        22: next_out = {10'd0, input_buffer[21:0]};
        23: next_out = {9'd0, input_buffer[22:0]};
        24: next_out = {8'd0, input_buffer[23:0]};
        25: next_out = {7'd0, input_buffer[24:0]};
        26: next_out = {6'd0, input_buffer[25:0]};
        27: next_out = {5'd0, input_buffer[26:0]};
        28: next_out = {4'd0, input_buffer[27:0]};
        29: next_out = {3'd0, input_buffer[28:0]};
        30: next_out = {2'd0, input_buffer[29:0]};
        31: next_out = {1'd0, input_buffer[30:0]};
        32: next_out = input_buffer;
        default: next_out = 1'bx;
      endcase*/

  end

`else

  // Sequential term
  logic [4:0] input_count;

  always @(posedge clk, negedge rst_n) begin : seq_block

    if(!rst_n)begin
      input_buffer <= 0;
      out_valid <= 0;
      out_left <= 0;
      out_right <= 0;
      input_count <= 0;
    end

    else begin
      // handling input

      // WS
      WS_buffer <= WS;

      // in_valid_buffer
      in_valid_buffer <= in_valid;

      if(in_valid)begin

        input_buffer <= {input_buffer[30:0], SD};
        input_count <= {input_count[3:0], 1'b1};

      end
      else begin
        input_count <= 0;
        input_buffer <= 0;
      end

        // out valid
        out_valid <= next_out_valid;

        // out left/right

        // output the data in the buffer
        if(next_out_valid)begin
          if(WS_buffer)begin
            out_left <= 0;
            out_right <= input_buffer;
          end
          else begin
            out_left <= input_buffer;
            out_right <= 0;
          end

          // clear input buffer after output, and then input the SD value at that moment if it's still accepting input
          if(in_valid) begin
            input_buffer <= {31'b0, SD};
            input_count <= 1;
          end
          else begin
            input_buffer <= 0;
            input_count <= 0;
          end
        end

        // output void
        else begin
          out_left <= 0;
          out_right <= 0;
        end
      end
  end


  always_comb begin : comb_block
      // buffer_sufficient
        buffer_sufficient = &input_count;

        // out_valid

        // impossible: 
        // WS rising, in_valid = 0
        // WS rising, in_valid falling
        casez({WS_buffer, WS, in_valid_buffer, in_valid})

          // WS unchanged , in_valid = 0
          4'b0000: next_out_valid = 0;
          4'b1100: next_out_valid = 0;

          // WS unchanged , in_valid = 1
          4'b0011: next_out_valid = 0;
          4'b1111: next_out_valid = 0;

          // WS unchanged, in_valid rising
          4'b0001: next_out_valid = 0;
          4'b1101: next_out_valid = 0;

          //  WS unchanged in_valid falling
          4'b0010: next_out_valid = buffer_sufficient;
          4'b1110: next_out_valid = buffer_sufficient;

          // WS rising, in_valid = 1
          4'b0111: next_out_valid = buffer_sufficient;
          // WS rising, in_valid rising
          4'b0101: next_out_valid = 0;

          // WS falling, in_valid = 0
          4'b1000: next_out_valid = 0;
          // WS falling, in_valid = 1
          4'b1011: next_out_valid = buffer_sufficient;
          // WS falling, in_valid rising
          4'b1001: next_out_valid = 0;

          // WS falling, in_valid falling
          4'b1010: next_out_valid = buffer_sufficient;
          default: next_out_valid = 1'bx;
    
        endcase

        // next_out
        //next_out = input_buffer;
  end

`endif

endmodule