// area 5501.865664
module Sort (
    input logic [5:0] in_num0, in_num1, in_num2, in_num3, in_num4, 
    output logic  [5:0] out_num0, out_num1, out_num2, out_num3, out_num4
);

logic [5:0] inter_wire [2:0][4:0];
logic comp_01, comp_34, comp_03, comp_14,comp_13;

//1st layer
assign comp_01 = in_num0 <= in_num1;
assign comp_34 = in_num3 <= in_num4;

assign inter_wire[0][0] = (comp_01) ? in_num0 : in_num1;
assign inter_wire[0][1] = (comp_01) ? in_num1 : in_num0;
assign inter_wire[0][2] = in_num2;
assign inter_wire[0][3] = (comp_34) ? in_num3 : in_num4;
assign inter_wire[0][4] = (comp_34) ? in_num4 : in_num3;

//2nd layer
assign comp_03 = inter_wire[0][0] <= inter_wire[0][3];
assign comp_14 = inter_wire[0][1] <= inter_wire[0][4];

assign inter_wire[1][0] = (comp_03) ? inter_wire[0][0] : inter_wire[0][3];
assign inter_wire[1][1] = (comp_14) ? inter_wire[0][1] : inter_wire[0][4];
assign inter_wire[1][2] = inter_wire[0][2];
assign inter_wire[1][3] = (comp_03) ? inter_wire[0][3] : inter_wire[0][0];
assign inter_wire[1][4] = (comp_14) ? inter_wire[0][4] : inter_wire[0][1];

//3rd layer
assign comp_13 = inter_wire[1][1] <= inter_wire[1][3];

assign inter_wire[2][0] = inter_wire[1][0];
assign inter_wire[2][1] = (comp_13) ? inter_wire[1][1] : inter_wire[1][3];
assign inter_wire[2][2] = inter_wire[1][2];
assign inter_wire[2][3] = (comp_13) ? inter_wire[1][3] : inter_wire[1][1];
assign inter_wire[2][4] = inter_wire[1][4];

always_comb begin
    // output selection
    if(inter_wire[2][2] > inter_wire[2][4])begin
        out_num0 = inter_wire[2][0];
        out_num1 = inter_wire[2][1];
        out_num2 = inter_wire[2][3];
        out_num3 = inter_wire[2][4];
        out_num4 = inter_wire[2][2];
    end
    else if(inter_wire[2][2] > inter_wire[2][3])begin
        out_num0 = inter_wire[2][0];
        out_num1 = inter_wire[2][1];
        out_num2 = inter_wire[2][3];
        out_num3 = inter_wire[2][2];
        out_num4 = inter_wire[2][4];
    end
    else if(inter_wire[2][2] > inter_wire[2][1])begin
        out_num0 = inter_wire[2][0];
        out_num1 = inter_wire[2][1];
        out_num2 = inter_wire[2][2];
        out_num3 = inter_wire[2][3];
        out_num4 = inter_wire[2][4];
    end
    else if(inter_wire[2][2] > inter_wire[2][0])begin
        out_num0 = inter_wire[2][0];
        out_num1 = inter_wire[2][2];
        out_num2 = inter_wire[2][1];
        out_num3 = inter_wire[2][3];
        out_num4 = inter_wire[2][4];
    end
    else begin
        out_num0 = inter_wire[2][2];
        out_num1 = inter_wire[2][0];
        out_num2 = inter_wire[2][1];
        out_num3 = inter_wire[2][3];
        out_num4 = inter_wire[2][4];
    end
end

endmodule

module SMJ(
    // Input signals
    hand_n0,
    hand_n1,
    hand_n2,
    hand_n3,
    hand_n4,
    // Output signals
    out_data
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [5:0] hand_n0;
input [5:0] hand_n1;
input [5:0] hand_n2;
input [5:0] hand_n3;
input [5:0] hand_n4;
output logic [1:0] out_data;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [5:0] sorted_hand[4:0];

logic invalid_check[4:0];
logic invalid_term_exist;
logic tri_plus_pair;
logic seq_plus_pair;
logic is_honor [4:0];

logic equal_01, equal_24, equal_34, equal_02, equal_13, diff_01, diff_12, diff_23, diff_34;


logic pair_01, pair_34;
logic seq_012, seq_234, seq_01_34;
logic tri_012, tri_123, tri_234;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

// Sort all input

Sort sort_ins(.in_num0 (hand_n0), .in_num1 (hand_n1), .in_num2 (hand_n2), .in_num3 (hand_n3),.in_num4 (hand_n4),
                .out_num0 (sorted_hand[0]), .out_num1 (sorted_hand[1]), .out_num2 (sorted_hand[2]), .out_num3 (sorted_hand[3]), .out_num4 (sorted_hand[4]));

always_comb begin
    // these indicate a pair
    equal_01 = sorted_hand[0]==sorted_hand[1];
    equal_34 = sorted_hand[3]==sorted_hand[4];

    // these indicate a triplet
    equal_02 = sorted_hand[0]==sorted_hand[2];
    equal_13 = sorted_hand[1]==sorted_hand[3];
    equal_24 = sorted_hand[2]==sorted_hand[4];

    // 01_12(!is_honor[2]), 12_23(!is_honor[2]), 23_34(!is_honor[2]) indicates a seq
    diff_01 = sorted_hand[1]==sorted_hand[0]+1;
    diff_12 = sorted_hand[2]==sorted_hand[1]+1;
    diff_23 = sorted_hand[3]==sorted_hand[2]+1;
    diff_34 = sorted_hand[4]==sorted_hand[3]+1;

    // Check if input contains invalid terms
    for(int i=0;i<5;i++) begin
        is_honor[i] = (sorted_hand[i][5:4]==2'b00);
        invalid_check[i] = (is_honor[i] ? sorted_hand[i][3:0]>6 : sorted_hand[i][3:0]>8);
    end

    invalid_term_exist = invalid_check[0] || invalid_check[1] || invalid_check[2] || invalid_check[3] || invalid_check[4] || (equal_02 & equal_24);

    pair_01 = equal_01;
    pair_34 = equal_34;

    seq_012 = diff_01 & diff_12;
    seq_234 = diff_23 & diff_34;
    seq_01_34 = diff_01 & diff_34 & equal_13;

    tri_012 = equal_02;
    tri_123 = equal_13;
    tri_234 = equal_24;

    if(invalid_term_exist)begin
        out_data = 2'b01;
    end
    else if((tri_012 && pair_34)||(tri_234 && pair_01))begin
        out_data = 2'b11;
    end
    else if(is_honor[2])begin
        out_data = 2'b00;
    end
    else if((pair_01 && seq_234)||(seq_012 && pair_34)||(seq_01_34 &&tri_123))begin
        out_data = 2'b10;
    end
    else begin
        out_data = 2'b00;
    end

end

endmodule
