module MIPS(
    //Input 
    clk,
    rst_n,
    in_valid,
    instruction,
	output_reg,
    //OUTPUT
    out_valid,
    out_1,
	out_2,
	out_3,
	out_4,
	instruction_fail
);

//Input 
input clk;
input rst_n;
input in_valid;
input [31:0] instruction;
input [19:0] output_reg;
//OUTPUT
output logic out_valid, instruction_fail;
output logic [15:0] out_1, out_2, out_3, out_4;

// control fsm
logic done, fail, is_fail, is_out, is_idle;
logic [1:0] curr_state, state, nxt_state;

parameter IDLE = 0,
          CAL = 1,
          FAIL = 2,
          OUT = 3;

parameter FUNC_ADD = 7'b0100000,
          FUNC_AND = 7'b0100100,
          FUNC_OR = 7'b0100101,
          FUNC_NOR = 7'b0100111,
          FUNC_SL = 7'b0000000,
          FUNC_SR = 7'b0000010,
          FUNC_GCD = 7'b1111000;

parameter REG0_ADDR = 5'b10001,
          REG1_ADDR = 5'b10010,
          REG2_ADDR = 5'b01000,
          REG3_ADDR = 5'b10111,
          REG4_ADDR = 5'b11111,
          REG5_ADDR = 5'b10000;

// input declaration
logic [31:0] ins_buffer, nxt_ins_buffer;
logic [5:0] opcode;
logic R_TYPE;
logic [4:0] RD_ADDR, out_1_addr, out_2_addr, out_3_addr, out_4_addr;
logic [2:0] RS_ADDR, RT_ADDR, nxt_RS_ADDR, nxt_RT_ADDR;
logic [4:0] nxt_out_1_addr, nxt_out_2_addr, nxt_out_3_addr, nxt_out_4_addr;
logic [3:0] SHAMT;
logic [6:0] FUNC;
logic [15:0] IMM;
logic input_en;

// id stage declaration
logic [5:0] load_sig;
logic [15:0] REG[5:0];
logic [15:0] nxt_REG[5:0];
integer i;
logic [15:0] RS_VAL, RT_VAL, RT_REFED;

// fail declaration
logic opcode_fail, r_type_fail, rt_fail, gcd_fail, rd_fail, rs_fail, reg_fail, imm_fail, func_fail;

// output stage declaraton
logic [15:0] out1_val, out2_val, out3_val, out4_val;

// ALU declaration
logic [15:0] rs_rt_add, rtype_result, gcd_result, or_result, ALU_result;
logic cal_done, rtype_done;

//GCD decalaration
logic [15:0] x, y, a, b, nxt_a, nxt_b, remainder;
logic gcd_done, comp;
logic is_gcd;

assign is_gcd = FUNC == FUNC_GCD;
assign is_out = state == OUT;
assign is_fail = state == FAIL;
assign is_idle = state == IDLE;

always_ff @(posedge clk or negedge rst_n) begin : addr_seq
    if(!rst_n)begin
        RS_ADDR <= 0;
        RD_ADDR <= 0;
    end
    else begin
        RS_ADDR <= nxt_RS_ADDR;
        RT_ADDR <= nxt_RT_ADDR;
    end
end

always_comb begin : nxt_addr_comb
    if(in_valid)begin
        nxt_RS_ADDR = RS_ADDR;
        nxt_RT_ADDR = RT_ADDR;
    end
    else begin
        case(instruction[25:21])
            REG0_ADDR: nxt_RS_ADDR = 0;
            REG1_ADDR: nxt_RS_ADDR = 1;
            REG2_ADDR: nxt_RS_ADDR = 2;
            REG3_ADDR: nxt_RS_ADDR = 3;
            REG4_ADDR: nxt_RS_ADDR = 4;
            REG5_ADDR: nxt_RS_ADDR = 5;
            default:nxt_RS_ADDR = 7;
        endcase

        case(instruction[20:16])
            REG0_ADDR: nxt_RT_ADDR = 0;
            REG1_ADDR: nxt_RT_ADDR = 1;
            REG2_ADDR: nxt_RT_ADDR = 2;
            REG3_ADDR: nxt_RT_ADDR = 3;
            REG4_ADDR: nxt_RT_ADDR = 4;
            REG5_ADDR: nxt_RT_ADDR = 5;
            default:nxt_RT_ADDR = 7;
        endcase
    end
end

// done logic
always_comb begin : done_comb
    rtype_done = (is_gcd) ? gcd_done : 1;
    cal_done = R_TYPE ? rtype_done : 1;
    done = cal_done && (state == CAL);
end

// GCD_UNIT
always_ff @(posedge clk or negedge rst_n) begin : gcd_seq
    if(!rst_n)begin
        a <= 0;
        b <= 0;
    end
    else begin
        a <= nxt_a;
        b <= nxt_b;
    end
end

always_comb begin : gcd_comb
    comp = a >= b;
    gcd_done = (a==0) || (b==0);

    x = comp ? a : b;
    y = comp ? b : a;
    remainder = x % y;

    case(state)
        IDLE:begin
            nxt_a = in_valid ? RS_VAL: a;
            nxt_b = in_valid ? RT_REFED : b;
        end

        CAL:begin
            nxt_a = comp ? remainder : a;
            nxt_b = comp ? b : remainder;
        end

        default:begin
            nxt_a = a;
            nxt_b = b;
        end
    endcase
    /*if(is_idle && in_valid)begin
        nxt_a = RS_VAL;
        nxt_b = RT_REFED;
    end
    else if(state == CAL)begin
        nxt_a = comp ? remainder : a;
        nxt_b = comp ? b : remainder;
    end
    else begin
        nxt_a = a;
        nxt_b = b;
    end*/

    gcd_result = comp ? a : b;
end

//ALU logic
always_comb begin : ALU_comb
    rs_rt_add = RS_VAL + RT_VAL;
    or_result = RS_VAL | RT_VAL;

    casez(FUNC)
        FUNC_ADD: rtype_result = rs_rt_add;

        FUNC_AND: rtype_result = RS_VAL & RT_VAL;

        FUNC_OR: rtype_result = or_result;

        FUNC_NOR: rtype_result = ~or_result;

        FUNC_SL: rtype_result = RT_VAL << (SHAMT);

        FUNC_SR: rtype_result = RT_VAL >> (SHAMT);

        FUNC_GCD: rtype_result = gcd_result;

        default: rtype_result = 'bx;
    endcase

    ALU_result = R_TYPE ? rtype_result : rs_rt_add;
end

// output stage logic
always_comb begin : output_stage_comb
    casez(out_1_addr)
        REG0_ADDR: out1_val = REG[0];
        REG1_ADDR: out1_val = REG[1];
        REG2_ADDR: out1_val = REG[2];
        REG3_ADDR: out1_val = REG[3];
        REG4_ADDR: out1_val = REG[4];
        REG5_ADDR: out1_val = REG[5];
        default: out1_val = 'bx;
    endcase
    out_1 = is_out ? out1_val : 0;

    casez(out_2_addr)
        REG0_ADDR: out2_val = REG[0];
        REG1_ADDR: out2_val = REG[1];
        REG2_ADDR: out2_val = REG[2];
        REG3_ADDR: out2_val = REG[3];
        REG4_ADDR: out2_val = REG[4];
        REG5_ADDR: out2_val = REG[5];
        default: out2_val = 'bx;
    endcase
    out_2 = is_out ? out2_val : 0;

    casez(out_3_addr)
        REG0_ADDR: out3_val = REG[0];
        REG1_ADDR: out3_val = REG[1];
        REG2_ADDR: out3_val = REG[2];
        REG3_ADDR: out3_val = REG[3];
        REG4_ADDR: out3_val = REG[4];
        REG5_ADDR: out3_val = REG[5];
        default: out3_val = 'bx;
    endcase
    out_3 = is_out ? out3_val : 0;

    casez(out_4_addr)
        REG0_ADDR: out4_val = REG[0];
        REG1_ADDR: out4_val = REG[1];
        REG2_ADDR: out4_val = REG[2];
        REG3_ADDR: out4_val = REG[3];
        REG4_ADDR: out4_val = REG[4];
        REG5_ADDR: out4_val = REG[5];
        default: out4_val = 'bx;
    endcase
    out_4 = is_out ? out4_val : 0;
end

// load ALU input from reg
always_comb begin : load_ALU_input_comb
    casez(RS_ADDR)
        3'd0: RS_VAL = REG[0];
        3'd1: RS_VAL = REG[1];
        3'd2: RS_VAL = REG[2];
        3'd3: RS_VAL = REG[3];
        3'd4: RS_VAL = REG[4];
        3'd5: RS_VAL = REG[5];
        default: RS_VAL = 'bx;
    endcase

    casez(RT_ADDR)
        3'd0: RT_REFED = REG[0];
        3'd1: RT_REFED = REG[1];
        3'd2: RT_REFED = REG[2];
        3'd3: RT_REFED = REG[3];
        3'd4: RT_REFED = REG[4];
        3'd5: RT_REFED = REG[5];
        default: RT_REFED = 'bx;
    endcase

    RT_VAL = R_TYPE ? RT_REFED : IMM;
end

// reg addr decoder
always_comb begin : reg_addr_decoder_comb
    if(fail || !done)begin
        load_sig = 0;
    end
    else begin
        casez(RD_ADDR)
            REG0_ADDR: load_sig = 6'b000001;
            REG1_ADDR: load_sig = 6'b000010;
            REG2_ADDR: load_sig = 6'b000100;
            REG3_ADDR: load_sig = 6'b001000;
            REG4_ADDR: load_sig = 6'b010000;
            REG5_ADDR: load_sig = 6'b100000;
            default: load_sig = 0;
        endcase
    end
end

always_ff @(posedge clk or negedge rst_n) begin : reg_seq
    if(!rst_n)begin
        for(i=0;i<6;i++)begin
            REG[i] <= 0;
        end
    end
    else begin
        REG[0] <= (load_sig[0]) ? ALU_result : REG[0];
        REG[1] <= (load_sig[1]) ? ALU_result : REG[1];
        REG[2] <= (load_sig[2]) ? ALU_result : REG[2];
        REG[3] <= (load_sig[3]) ? ALU_result : REG[3];
        REG[4] <= (load_sig[4]) ? ALU_result : REG[4];
        REG[5] <= (load_sig[5]) ? ALU_result : REG[5];
    end
end

// fail logic
always_comb begin : fail_comb
    case(opcode)
        6'b000000, 6'b001000: opcode_fail = 0;
        default: opcode_fail = 1;
    endcase
    case (FUNC)
        FUNC_ADD: func_fail = 0;
        FUNC_AND: func_fail = 0;
        FUNC_OR: func_fail = 0;
        FUNC_NOR: func_fail = 0;
        FUNC_SL: func_fail = 0;
        FUNC_SR: func_fail = 0;
        FUNC_GCD: func_fail = 0;
        default: func_fail = 1;
    endcase

    /*case(RS_ADDR)
        REG0_ADDR, REG1_ADDR, REG2_ADDR, REG3_ADDR, REG4_ADDR, REG5_ADDR: rs_fail = 0;
        default: rs_fail = 1;
    endcase*/
    rs_fail = (RS_ADDR == 3'b111);

    /*case(RT_ADDR)
        REG0_ADDR, REG1_ADDR, REG2_ADDR, REG3_ADDR, REG4_ADDR, REG5_ADDR: rt_fail = 0;
        default: rt_fail = 1;
    endcase*/
    rt_fail = (RT_ADDR == 3'b111);

    case(RD_ADDR)
        REG0_ADDR, REG1_ADDR, REG2_ADDR, REG3_ADDR, REG4_ADDR, REG5_ADDR: rd_fail = 0;
        default: rd_fail = 1;
    endcase

    gcd_fail = ((RS_VAL == 0) || (RT_VAL == 0)) && (is_gcd);
    r_type_fail = rs_fail || rt_fail || func_fail || rd_fail || gcd_fail;
    imm_fail = rs_fail || rt_fail;
    reg_fail = R_TYPE ? r_type_fail : imm_fail;
    fail = reg_fail || opcode_fail;
end

// input control
always_ff @(posedge clk or negedge rst_n) begin : input_seq
    if(!rst_n)begin
        ins_buffer <= 0;
        out_1_addr <= 0;
        out_2_addr <= 0;
        out_3_addr <= 0;
        out_4_addr <= 0;
    end
    else begin
        ins_buffer <= nxt_ins_buffer;
        out_1_addr <= nxt_out_1_addr;
        out_2_addr <= nxt_out_2_addr;
        out_3_addr <= nxt_out_3_addr;
        out_4_addr <= nxt_out_4_addr;
    end
end

always_comb begin : nxt_input_comb
    input_en = in_valid && is_idle;
    nxt_ins_buffer = input_en ? instruction : ins_buffer;
    nxt_out_1_addr = input_en ? output_reg[4:0] : out_1_addr;
    nxt_out_2_addr = input_en ? output_reg[9:5] : out_2_addr;
    nxt_out_3_addr = input_en ? output_reg[14:10] : out_3_addr;
    nxt_out_4_addr = input_en ? output_reg[19:15] : out_4_addr;
end

always_comb begin : parse_input_comb
    opcode = ins_buffer[31:26];
    R_TYPE = !opcode[3];
    RS_ADDR = input_en ? instruction[25:21] : ins_buffer[25:21];
    RT_ADDR = input_en ? instruction[20:16] :ins_buffer[20:16];
    RD_ADDR = R_TYPE ? ins_buffer[15:11] : ins_buffer[20:16];
    SHAMT = ins_buffer[10:7];
    FUNC = ins_buffer[6:0];
    IMM = ins_buffer[15:0];
end

// output control

always_comb begin : out_valid_comb
    out_valid = is_out || is_fail;
end

always_comb begin : ins_fail_comb
    instruction_fail = is_fail;
end

// control fsm

always_ff @(posedge clk or negedge rst_n) begin : state_seq
    if(!rst_n)begin
        curr_state <= IDLE;
    end
    else begin
        curr_state <= nxt_state;
    end
end

always_comb begin : nxt_state_comb
    state = curr_state;
    casez (curr_state)
        IDLE: nxt_state = in_valid ? CAL : IDLE;
        CAL:begin
            if(fail) nxt_state = FAIL;
            else if(done) nxt_state = OUT;
            else nxt_state = CAL;
        end
        FAIL: nxt_state = IDLE;
        OUT: nxt_state = IDLE;
        default: nxt_state = 'bx;
    endcase
end

endmodule

