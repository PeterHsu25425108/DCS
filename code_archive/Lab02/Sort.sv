module comp(
    input [5:0] ai,bi, 
    output logic [5:0] ao,bo
);

    always_comb begin : comp_module
        ao = (ai < bi) ? ai : bi;
        bo = (ai < bi) ? bi : ai;
    end

endmodule

module Sort (
    input [5:0] in_num0, in_num1, in_num2, in_num3, in_num4, 
    output [5:0] out_num
);
    //inter_wire[layer][row]
    logic [5:0] inter_wire [4:0][4:0];

    // 1st layer
    comp c1(in_num0, in_num1, inter_wire[0][0],inter_wire[0][1]);
    comp c2(in_num2, in_num3, inter_wire[0][2],inter_wire[0][3]);
    assign inter_wire[0][4] = in_num4;

    // 2nd layer
  	assign inter_wire[1][0] = inter_wire[0][0];
    comp c3(inter_wire[0][1], inter_wire[0][2], inter_wire[1][1],inter_wire[1][2]);
    comp c4(inter_wire[0][3], inter_wire[0][4], inter_wire[1][3], inter_wire[1][4]);

    // 3nd layer
    assign inter_wire[2][4] = inter_wire[1][4];
    comp c5(inter_wire[1][0], inter_wire[1][1], inter_wire[2][0],inter_wire[2][1]);
    comp c6(inter_wire[1][2], inter_wire[1][3], inter_wire[2][2], inter_wire[2][3]);

    // 4nd layer
    assign inter_wire[3][0] = inter_wire[2][0];
    comp c7(inter_wire[2][1], inter_wire[2][2], inter_wire[3][1],inter_wire[3][2]);
    comp c8(inter_wire[2][3], inter_wire[2][4], inter_wire[3][3], inter_wire[3][4]);

    // 5th layer
    assign inter_wire[4][4] = inter_wire[3][4];
    comp c9(inter_wire[3][0], inter_wire[3][1], inter_wire[4][0],inter_wire[4][1]);
  	comp c10(inter_wire[3][2], inter_wire[3][3], inter_wire[4][2], inter_wire[4][3]);

    // output
    assign out_num = inter_wire[4][2];

endmodule