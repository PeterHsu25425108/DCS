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
logic done, fail, is_fail, is_out, is_idle, is_cal;
logic [1:0] curr_state, state, nxt_state;

parameter IDLE = 3, CAL = 2, FAIL = 1, OUT = 0;/*IDLE = 0,
          CAL = 1,
          FAIL = 2,
          OUT = 3;*/

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
logic [25:0] ins_buffer, nxt_ins_buffer;
//logic [5:0] opcode;
logic R_TYPE, R_TYPE_BUFFER, nxt_R_TYPE_BUFFER;
logic [4:0] RS_ADDR, RT_ADDR, RD_ADDR, out_1_addr, out_2_addr, out_3_addr, out_4_addr;
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
logic opcode_fail,nxt_opcode_fail, r_type_fail, rt_fail, gcd_fail, rd_fail, rs_fail, reg_fail, imm_fail, func_fail;

// output stage declaraton
logic [15:0] out1_val, out2_val, out3_val, out4_val;

// ALU declaration
logic [15:0] rs_rt_add, rtype_result, gcd_result, or_result, ALU_result;
logic cal_done, rtype_done;

//GCD decalaration
logic [15:0] x, y, a, b, nxt_a, nxt_b, gcd_preresult, c, d, sub_result;
logic gcd_done, comp;
logic is_gcd;
logic a_even, b_even, a_z, b_z, x_even, y_even, a_isone, b_isone, equal;
logic [3:0] mul2, nxt_mul2;
logic in_valid_buffer;
logic change_val;

assign is_gcd = (is_cal) ? FUNC == FUNC_GCD : (instruction[6:0] == FUNC_GCD);
assign is_out = state == OUT;
assign is_fail = state == FAIL;
assign is_idle = state == IDLE;
assign is_cal = state == CAL;

// done logic
always_comb begin : done_comb
    rtype_done = (is_gcd) ? gcd_done : 1;
    cal_done = R_TYPE ? rtype_done : 1;
    done = cal_done && is_cal;
end

// GCD_UNIT
always_ff @(posedge clk or negedge rst_n) begin : gcd_seq
    if(!rst_n)begin
        a <= 0;
        b <= 0;
        mul2 <= 0;
        //in_valid_buffer <= 0;
    end
    else begin
        a <= nxt_a;
        b <= nxt_b;
        mul2 <= nxt_mul2;
        //in_valid_buffer <= in_valid;
    end
end

logic [3:0] shift_num_x;
logic [3:0] shift_num_y;
logic [3:0] shift_num_z;
logic [3:0] shift_num;
logic [15:0] shifted_x;
logic [15:0] shifted_y;
logic [15:0] shifted_z;
always_comb begin : gcd_comb
    
    x = in_valid ? RS_VAL : a;
    y = in_valid ? RT_VAL : b;
    comp = x >= y;
    c = comp ? x : y;
    d = comp ? y : x;
    sub_result = (c-d)/*/2*/;
    
    x_even = ~x[0]/*(x[0]==0)*/;
    y_even = ~(y[0]);
    a_isone = (x==1);
    b_isone = (y==1);
    a_z = (x==0);
    b_z = (y==0);
    equal = (x==y);
    gcd_done = a_isone || b_isone || a_z || b_z || equal;
    change_val = !(is_cal && gcd_done);

    // --- steins algo ---

    casez(x)
        16'b??????????????10: shift_num_x = 1;
        16'b?????????????100: shift_num_x = 2;
        16'b????????????1000: shift_num_x = 3;
        16'b???????????10000: shift_num_x = 4;
        16'b??????????100000: shift_num_x = 5;
        16'b?????????1000000: shift_num_x = 6;
        16'b????????10000000: shift_num_x = 7;
        16'b???????100000000: shift_num_x = 8;
        16'b??????1000000000: shift_num_x = 9;
        16'b?????10000000000: shift_num_x = 10;
        16'b????100000000000: shift_num_x = 11;
        16'b???1000000000000: shift_num_x = 12;
        16'b??10000000000000: shift_num_x = 13;
        16'b?100000000000000: shift_num_x = 14;
        16'b1000000000000000: shift_num_x = 15;
        default: shift_num_x = 0;
    endcase
    shifted_x = x >> shift_num_x;

    casez(y)
        16'b??????????????10: shift_num_y = 1;
        16'b?????????????100: shift_num_y = 2;
        16'b????????????1000: shift_num_y = 3;
        16'b???????????10000: shift_num_y = 4;
        16'b??????????100000: shift_num_y = 5;
        16'b?????????1000000: shift_num_y = 6;
        16'b????????10000000: shift_num_y = 7;
        16'b???????100000000: shift_num_y = 8;
        16'b??????1000000000: shift_num_y = 9;
        16'b?????10000000000: shift_num_y = 10;
        16'b????100000000000: shift_num_y = 11;
        16'b???1000000000000: shift_num_y = 12;
        16'b??10000000000000: shift_num_y = 13;
        16'b?100000000000000: shift_num_y = 14;
        16'b1000000000000000: shift_num_y = 15;
        default: shift_num_y = 0;
    endcase
    shifted_y = y >> shift_num_y;

    casez(sub_result)
        16'b??????????????10: shift_num_z = 1;
        16'b?????????????100: shift_num_z = 2;
        16'b????????????1000: shift_num_z = 3;
        16'b???????????10000: shift_num_z = 4;
        16'b??????????100000: shift_num_z = 5;
        16'b?????????1000000: shift_num_z = 6;
        16'b????????10000000: shift_num_z = 7;
        16'b???????100000000: shift_num_z = 8;
        16'b??????1000000000: shift_num_z = 9;
        16'b?????10000000000: shift_num_z = 10;
        16'b????100000000000: shift_num_z = 11;
        16'b???1000000000000: shift_num_z = 12;
        16'b??10000000000000: shift_num_z = 13;
        16'b?100000000000000: shift_num_z = 14;
        16'b1000000000000000: shift_num_z = 15;
        default: shift_num_z = 0;
    endcase
    shifted_z = sub_result >> shift_num_z;

    shift_num = (shift_num_x > shift_num_y) ? shift_num_y : shift_num_x;

    if(change_val)begin
        /*if(x_even)begin
            nxt_a = x>>1;
        end
        else if(y_even)begin
            nxt_a = x;
        end
        else begin
            nxt_a = (c-d) >> 1;
        end*/
        case({x_even, y_even})
            2'b00:begin
                nxt_a = comp ? /*sub_result*/shifted_z : x;
                nxt_b = comp ? y : /*sub_result*/shifted_z;
            end 
            2'b01:begin
                nxt_a = x;
                nxt_b = shifted_y/*y >> shift_num_y*/;
            end

            2'b10:begin
                nxt_a = shifted_x/*x >> shift_num_x*/;
                nxt_b = y;
            end

            2'b11:begin
                nxt_a = /*x >>shift_num_x*/shifted_x;
                nxt_b = /*y >>shift_num_y*/shifted_y;
            end

            default:begin
                nxt_a = x;
                nxt_b = y;
            end
        endcase
    end
    else begin
        nxt_a = x;
        nxt_b = y;
    end

    //nxt_b = y_even && change_val ? y >> 1 : y;
    nxt_mul2 =  is_gcd ? mul2 + /*{3'b0, x_even && y_even}*/shift_num : 0;

    if(a_isone || b_isone)begin
        gcd_preresult = 1;
    end
    else if(a==b)begin
        gcd_preresult = a;
    end
    else begin
        gcd_preresult = a_z ? b : a;
    end

    gcd_result = gcd_preresult << mul2;

    // -------------------

    /*
    x = comp ? a : b;
    y = comp ? b : a;
    remainder = x % y;

    case(state)
        IDLE:begin
            nxt_a = in_valid ? RS_VAL : a;
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
    endcase*/
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

    //gcd_result = comp ? a : b;
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

        //FUNC_SR: rtype_result = RT_VAL >> (SHAMT);

        FUNC_GCD/*default*/: rtype_result = gcd_result;

        default: rtype_result = RT_VAL >> (SHAMT);
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
    out_1 = /*is_out ? out1_val : 0*/out1_val & {16{is_out}};

    casez(out_2_addr)
        REG0_ADDR: out2_val = REG[0];
        REG1_ADDR: out2_val = REG[1];
        REG2_ADDR: out2_val = REG[2];
        REG3_ADDR: out2_val = REG[3];
        REG4_ADDR: out2_val = REG[4];
        REG5_ADDR: out2_val = REG[5];
        default: out2_val = 'bx;
    endcase
    out_2 = is_out ? out2_val : 0/*out2_val & {16{is_out}}*/;

    casez(out_3_addr)
        REG0_ADDR: out3_val = REG[0];
        REG1_ADDR: out3_val = REG[1];
        REG2_ADDR: out3_val = REG[2];
        REG3_ADDR: out3_val = REG[3];
        REG4_ADDR: out3_val = REG[4];
        REG5_ADDR: out3_val = REG[5];
        default: out3_val = 'bx;
    endcase
    out_3 = /*is_out ? out3_val : 0*/out3_val & {16{is_out}};

    casez(out_4_addr)
        REG0_ADDR: out4_val = REG[0];
        REG1_ADDR: out4_val = REG[1];
        REG2_ADDR: out4_val = REG[2];
        REG3_ADDR: out4_val = REG[3];
        REG4_ADDR: out4_val = REG[4];
        REG5_ADDR: out4_val = REG[5];
        default: out4_val = 'bx;
    endcase
    out_4 = /*is_out ? out4_val : 0*/out4_val & {16{is_out}};
end

// load ALU input from reg
always_comb begin : load_ALU_input_comb
    casez(RS_ADDR)
        REG0_ADDR: RS_VAL = REG[0];
        REG1_ADDR: RS_VAL = REG[1];
        REG2_ADDR: RS_VAL = REG[2];
        REG3_ADDR: RS_VAL = REG[3];
        REG4_ADDR: RS_VAL = REG[4];
        REG5_ADDR: RS_VAL = REG[5];
        default: RS_VAL = 'bx;
    endcase

    casez(RT_ADDR)
        REG0_ADDR: RT_REFED = REG[0];
        REG1_ADDR: RT_REFED = REG[1];
        REG2_ADDR: RT_REFED = REG[2];
        REG3_ADDR: RT_REFED = REG[3];
        REG4_ADDR: RT_REFED = REG[4];
        REG5_ADDR: RT_REFED = REG[5];
        default: RT_REFED = 'bx;
    endcase

    RT_VAL = R_TYPE ? RT_REFED : IMM;
end

// reg addr decoder
logic [5:0] pre_load_sig;
logic load_en;
always_comb begin : reg_addr_decoder_comb
    /*if(fail || !done)begin
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
    end*/
    load_en = !fail && done;
    casez(RD_ADDR)
            REG0_ADDR: pre_load_sig = 6'b000001;
            REG1_ADDR: pre_load_sig = 6'b000010;
            REG2_ADDR: pre_load_sig = 6'b000100;
            REG3_ADDR: pre_load_sig = 6'b001000;
            REG4_ADDR: pre_load_sig = 6'b010000;
            REG5_ADDR: pre_load_sig = 6'b100000;
            default: pre_load_sig = 0;
    endcase

    load_sig = pre_load_sig & {6{load_en}};

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

always_ff @(posedge clk or negedge rst_n) begin : opcode_fail_seq
    if(!rst_n)begin
        opcode_fail <= 0;
    end
    else begin
        opcode_fail <= nxt_opcode_fail;
    end
end

// fail logic
logic [5:0] opcode_input;

always_comb begin : fail_comb
    opcode_input = instruction[31:26];

    if(!input_en)begin
        nxt_opcode_fail = opcode_fail;
    end
    else begin
        casez(opcode_input)
            6'b001000:begin
                nxt_opcode_fail = 0;
            end
            6'b000000: begin
                nxt_opcode_fail = 0;
            end
            default: begin 
                nxt_opcode_fail = 1;
            end
        endcase
    end

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

    case(RS_ADDR)
        REG0_ADDR, REG1_ADDR, REG2_ADDR, REG3_ADDR, REG4_ADDR, REG5_ADDR: rs_fail = 0;
        default: rs_fail = 1;
    endcase

    case(RT_ADDR)
        REG0_ADDR, REG1_ADDR, REG2_ADDR, REG3_ADDR, REG4_ADDR, REG5_ADDR: rt_fail = 0;
        default: rt_fail = 1;
    endcase

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
        R_TYPE_BUFFER<=0;
    end
    else begin
        ins_buffer <= nxt_ins_buffer;
        out_1_addr <= nxt_out_1_addr;
        out_2_addr <= nxt_out_2_addr;
        out_3_addr <= nxt_out_3_addr;
        out_4_addr <= nxt_out_4_addr;
        R_TYPE_BUFFER <= nxt_R_TYPE_BUFFER;
    end
end

always_comb begin : nxt_input_comb
    input_en = in_valid && is_idle;
    nxt_ins_buffer = input_en ? instruction : ins_buffer;
    nxt_out_1_addr = input_en ? output_reg[4:0] : out_1_addr;
    nxt_out_2_addr = input_en ? output_reg[9:5] : out_2_addr;
    nxt_out_3_addr = input_en ? output_reg[14:10] : out_3_addr;
    nxt_out_4_addr = input_en ? output_reg[19:15] : out_4_addr;
    nxt_R_TYPE_BUFFER = input_en ? !instruction[29] : R_TYPE_BUFFER;
end

always_comb begin : parse_input_comb
    //opcode = ins_buffer[31:26];
    R_TYPE = input_en ? !instruction[29] : R_TYPE_BUFFER/*!opcode[3]*/;
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
        default: nxt_state = IDLE;
        //default: nxt_state = 'bx;
    endcase
end

endmodule

