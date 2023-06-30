module inter(
  // Input signals
  clk,
  rst_n,
  in_valid_1,
  in_valid_2,
  data_in_1,
  data_in_2,
  ready_slave1,
  ready_slave2,
  // Output signals
  valid_slave1,
  valid_slave2,
  addr_out,
  value_out,
  handshake_slave1,
  handshake_slave2
);

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid_1, in_valid_2; // in_valid from master to sender
input [6:0] data_in_1, data_in_2;  // data from master, format = [6] -> slave(0->slave1) [5:3] -> addr [2:0] -> value
input ready_slave1, ready_slave2; // slave to sender , indicate that slave is ready

output logic valid_slave1, valid_slave2; // from sender to slave, indicate that sender output is valid 
output logic [2:0] addr_out, value_out; 
output logic handshake_slave1, handshake_slave2;

parameter S_IDLE = 2'b00,
          S_master1 = 2'b01, 
          S_master2 = 2'b10,
          S_handshake = 2'b11;

// comb terms
logic [1:0] next_state;
logic [6:0] next_data1, next_data2;

// ff
logic [1:0] state;
logic [6:0] data1, data2;
logic in1, in2;
logic /*next_valid_slave1, next_valid_slave2,*/ next_in1, next_in2;

always_comb begin : comb_block
  if(in_valid_1) next_data1 = data_in_1;
  else next_data1 = data1;

  if(in_valid_2) next_data2 = data_in_2;
  else next_data2 = data2;

  casez(state)
    S_IDLE: begin
      // next_state
      if(in1) next_state = S_master1;
      else if(in2) next_state = S_master2;
      else next_state = S_IDLE;

      // next_in
      if(in_valid_1 || in_valid_2) begin
        next_in1 = in_valid_1;
        next_in2 = in_valid_2;
      end
      else begin
        next_in1 = in1;
        next_in2 = in2;
      end

      // next_valid_slave
      /*if(in1) begin // take input from data1
        next_valid_slave1 = !data1[6];
        next_valid_slave2 = data1[6];
      end
      else if(in2) begin // take input from data2
        next_valid_slave1 = !data2[6];
        next_valid_slave2 = data2[6];
      end
      else begin // next_valid_slave
        next_valid_slave1 = 0;
        next_valid_slave2 = 0;
      end*/
      valid_slave1 = 0;
      valid_slave2 = 0;

      // addr_out
      addr_out = 0;

      // value_out
      value_out = 0;

      // handshake
      handshake_slave1 = 0;
      handshake_slave2 = 0;

    end

    S_master1: begin // take input from data1
      // next_state
      if(!data1[6]) begin
        if(valid_slave1 && ready_slave1) begin
          next_state = S_handshake;
        end
        else begin
          next_state = S_master1;
        end
      end
      else begin
        if(valid_slave2 && ready_slave2) begin
          next_state = S_handshake;
        end
        else begin
          next_state = S_master1;
        end
      end

      // next_in
      next_in1 = in1;
      next_in2 = in2;

      // next_valid_slave
      valid_slave1 = !data1[6];
      valid_slave2 = data1[6];


      // addr_out
      addr_out = data1[5:3];

      // value_out
      value_out = data1[2:0];
      
      // handshake
      handshake_slave1 = 0;
      handshake_slave2 = 0;
    end

    S_master2: begin // take input from data2
      // next_state
      if(!data2[6]) begin
        if(valid_slave1 && ready_slave1) begin
          next_state = S_handshake;
        end
        else begin
          next_state = S_master2;
        end
      end
      else begin
        if(valid_slave2 && ready_slave2) begin
          next_state = S_handshake;
        end
        else begin
          next_state = S_master2;
        end
      end

      // next_in
      next_in1 = in1;
      next_in2 = in2;

      // next_valid_slave
      valid_slave1 = !data2[6];
      valid_slave2 = data2[6];

      // addr_out
      addr_out = data2[5:3];

      // value_out
      value_out = data2[2:0];
      
      // handshake
      handshake_slave1 = 0;
      handshake_slave2 = 0;
    end

    S_handshake: begin
      // next_state
      next_state = S_IDLE;

      // next_in
      casez({in1, in2})
        2'b01: begin
          next_in1 = 0;
          next_in2 = 0;
        end
        2'b10: begin
          next_in1 = 0;
          next_in2 = 0;
        end
        2'b11: begin
          next_in1 = 0;
          next_in2 = 1;
        end

        default: begin
          next_in1 = 1'bx;
          next_in2 = 1'bx;
        end

      endcase

      // next_valid_slave
      if(in1) begin // take input from data1
        valid_slave1 = !data1[6];
        valid_slave2 = data1[6];
      end
      else if(in2) begin // take input from data2
        valid_slave1 = !data2[6];
        valid_slave2 = data2[6];
      end
      else begin // next_valid_slave
        valid_slave1 = 0;
        valid_slave2 = 0;
      end

      // value_out, addr_out
      casez({in1, in2})
        2'b1?: begin
          addr_out = data1[5:3];
          value_out = data1[2:0];
        end
        2'b01: begin
          addr_out = data2[5:3];
          value_out = data2[2:0];
        end

        default: begin
          addr_out = 3'bx;
          value_out = 3'bx;
        end

      endcase
      
      // handshake
      casez({in1, in2})
        2'b01: begin
          handshake_slave1 = 0;
          handshake_slave2 = 1;
        end
        2'b10: begin
          handshake_slave1 = 1;
          handshake_slave2 = 0;
        end
        2'b11: begin
          handshake_slave1 = 1;
          handshake_slave2 = 0;
        end

        default: begin
          handshake_slave1 = 1'bx;
          handshake_slave2 = 1'bx;
        end

      endcase
    end

    default: begin
      
    end

  endcase
end

always_ff @(posedge clk, negedge rst_n) begin : seq_block
  if(!rst_n)begin
    state <= S_IDLE;
    data1 <= 0;
    data2 <= 0;
    in1 <= 0;
    in2 <= 0;
    /*valid_slave1 <= 0;
    valid_slave2 <= 0;*/
  end
  else begin
    state <= next_state;
    in1 <= next_in1;
    in2 <= next_in2;
    data1 <= next_data1;
    data2 <= next_data2;
    /*valid_slave1 <= next_valid_slave1;
    valid_slave2 <= next_valid_slave2;*/
  end
end

endmodule
