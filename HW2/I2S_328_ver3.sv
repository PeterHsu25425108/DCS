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

    // next_SD_buffer
    next_SD_buffer = SD;

    // next state logic
    casez(state)
      IDLE: begin
        out_valid = 0;
        out_left = 0;
        out_right = 0;

       /* casez({in_valid, WS})
          2'b0?:
            next = IDLE;
            next_val = 0;
          2'b10:
            next = L_READ;
            next_val = {input_buffer[30:0], SD};
          2'b11:
            next = R_READ;
            next_val = {input_buffer[30:0], SD};
          default:
            next = 3'bx;
            next_val = 32'bx;
        endcase*/

        if(!in_valid) begin
          next = IDLE;
          next_val = 0;
        end
        else  begin
          next_val = {input_buffer[30:0], SD};

          if(WS) begin
            next = R_READ;
          end
          else begin
            next = L_READ;
          end
        end

      end

      L_READ: begin
        out_valid = 0;
        out_left = 0;
        out_right = 0;
        /*casez({WS, in_valid})
          2'b?0:
            next = L_OUT;
          2'b01:
            next = L_READ;
          2'b11:
            next = L_OUT;
          default:
            next = 3'bx;
        endcase*/

        if(!in_valid) begin
          next = L_OUT;
          next_val = input_buffer;
        end
        else if(WS) begin
          next = L_OUT;
          next_val = input_buffer;
        end
        else begin
          next = L_READ;
          next_val = {input_buffer[30:0], SD};
        end

      end
      
      R_READ: begin
        out_valid = 0;
        out_left = 0;
        out_right = 0;

        /*casez({WS, in_valid})
          2'b?0:
            next = R_OUT;
          2'b01:
            next = R_OUT;
          2'b11:
            next = R_READ;
          default:
            next = 3'bx;
        endcase*/

        if(!in_valid) begin
          next = R_OUT;
          next_val = input_buffer;
        end

        else if(WS) begin
          next = R_READ;
          next_val = {input_buffer[30:0], SD};
        end
        else begin
          next = R_OUT;
          next_val = input_buffer;
        end
      end

      L_OUT: begin
        out_valid = 1;
        out_left = input_buffer;
        out_right = 0;

        casez(in_valid)
          0:
          begin
            next = IDLE;
            next_val = 0;
          end
          1:begin
            next = R_READ;
            next_val = {30'd0, SD_buffer, SD};
          end
          default:
            next = 3'bx;
            //next_val = 32'bx;
        endcase

      end

      R_OUT: begin
        out_valid = 1;
        out_left = 0;
        out_right = input_buffer;

        casez(in_valid)
          0: begin
            next = IDLE;
            next_val = 0;
          end
          1: begin
            next = L_READ;
            next_val = {30'd0, SD_buffer, SD};
          end
          default:
            next = 3'bx;
            //next_val = 32'bx;
        endcase
      end

      default: begin
        out_valid = 1'bx;
        out_left = 32'bx;
        out_right = 32'bx;
        next = 3'bx;
        next_val = 32'bx;
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