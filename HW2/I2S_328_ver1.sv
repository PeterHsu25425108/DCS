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

logic [32:0] input_buffer;
logic [31:0] next_val;
logic [3:0] next, state;

// store SD when state== L_OUT/R_OUT and in_valid == 1
logic SD_buffer;
logic next_SD_buffer;

parameter IDLE = 3'b000,
          L_READ = 3'b001,
          R_READ = 3'b010,
          L_OUT = 3'b011,
          R_OUT = 3'b100;
          //CLR = 3'b101;

always_comb begin : comb_block

    // next_val
    casez({state, in_valid, WS})
      // will output val in the next clk cycle, input_buffer shouldn't be flushed
      // next = L_OUT/R_OUT(in_valid nededge)
      {L_READ, 2'b0?}, {R_READ, 2'b0?}:
        next_val = input_buffer;

      // don't need to input
      // next = IDLE
      {IDLE, 2'b0?},{L_OUT, 2'b0?}, {R_OUT, 2'b0?}:
        next_val = 0;

      // finish output, flush old val and input val from SD_buffer
      // next = L_READ/R_READ
      {L_OUT, 2'b1?}, {R_OUT, 2'b1?}:
        next_val = {30'd0, SD_buffer, SD};
      
      // read SD into input_buffer
      {IDLE, 2'b1?}:
        next_val = {input_buffer[30:0], SD};

      // read SD into input_buffer
      // next = L_READ/R_READ
      {L_READ, 2'b10}, {R_READ, 2'b11}:
        next_val = {input_buffer[30:0], SD};

    
      // will output val in the next clk cycle, input_buffer shouldn't be flushed
      // next = L_OUT/R_OUT(WS edge)
      {L_READ, 2'b11}, {R_READ, 2'b10}:
        next_val = input_buffer;
      
      default:
        next_val = 32'bx;
    endcase

    // next_SD_buffer
    next_SD_buffer = SD;

    // next state logic
    casez(state)
      IDLE: begin
        out_valid = 0;
        out_left = 0;
        out_right = 0;

        casez({in_valid, WS})
          2'b0?:
            next = IDLE;
          2'b10:
            next = L_READ;
          2'b11:
            next = R_READ;
          default:
            next = 3'bx;
        endcase

      end

      L_READ: begin
        out_valid = 0;
        out_left = 0;
        out_right = 0;
        casez({WS, in_valid})
          2'b?0:
            next = L_OUT;
          2'b01:
            next = L_READ;
          2'b11:
            next = L_OUT;
          default:
            next = 3'bx;
        endcase
      end
      
      R_READ: begin
        out_valid = 0;
        out_left = 0;
        out_right = 0;
        casez({WS, in_valid})
          2'b?0:
            next = R_OUT;
          2'b01:
            next = R_OUT;
          2'b11:
            next = R_READ;
          default:
            next = 3'bx;
        endcase
      end

      L_OUT: begin
        out_valid = 1;
        out_left = input_buffer;
        out_right = 0;

        casez(in_valid)
          0:
            next = IDLE;
          1:
            next = R_READ/*CLR*/;
          default:
            next = 3'bx;
        endcase
      end

      R_OUT: begin
        out_valid = 1;
        out_left = 0;
        out_right = input_buffer;

        casez(in_valid)
          0:
            next = IDLE;
          1:
            next = L_READ/*CLR*/;
          default:
            next = 3'bx;
        endcase
      end

      /*CLR: begin
        out_valid = 0;
        out_left = 0;
        out_right = 0;

        casez(WS)
          0:
            next = L_READ;
          1:
            next = R_READ;
          default:
            next = 3'bx;
        endcase
      end*/

      default: begin
        out_valid = 1'bx;
        out_left = 32'bx;
        out_right = 32'bx;
        next = 3'bx;
      end

    endcase
end

always_ff @(posedge clk, negedge rst_n) begin : seq_block
  if(!rst_n)begin
    input_buffer <= 0;
    state <= IDLE;
    SD_buffer <= 0;
  end
  else begin
    state <= next;
    // dealing with input_buffer
    input_buffer <= next_val;
    SD_buffer <= next_SD_buffer;
  end
end

endmodule