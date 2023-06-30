// Code your testbench here
// or browse Examples
`timescale 1ns/10ps
`define CYCLE_TIME 4.5
//integer  CYCLE_TIME = `CYCLE_TIME;
integer PATNUM = 10; 
integer i, j;

/*logic [46:0] input_arr [PATNUM-1:0];

for(i=0;i<PATNUM;i++)begin
    for(j=0;j<4;j++)
    {
        input_arr[i][j] = $urandom_range()
    }
end*/

module merge_sort_tb;

  logic[46:0] in_1 = 2;
  logic[46:0] in_2 = 3;
  logic[46:0] in_3 = 4;
  logic[46:0] in_4 = 5;
  logic in_valid;
  
  logic out_valid;
  logic [95:0] out;
    
  /*logic[5:0] out0;
  logic[5:0] out1;
  logic[5:0] out2;
  logic[5:0] out3;
  logic[5:0] out4;*/
  //logic [1:0] out;

    logic clk, rst_n;

    initial begin
      	rst_n = 1;
        clk = 0;

        #2
        rst_n = 0;
        #`CYCLE_TIME
        rst_n = 1;

        forever begin
            #`CYCLE_TIME  
            clk = !clk;
        end
    end
    
    logic [95:0] ans_arr[9:0];

    initial 
    begin
      
        
      	in_valid = 0;
      	i=0;
        #6.5
    	in_valid = 1;
      
        in_1 = 35;
        in_2 = 62;
        in_3 = 4;
        in_4 = 33;
        ans_arr[i] = (in_1 + in_2)*(in_3 + in_4);
        i= i+1;
        #`CYCLE_TIME
    
        in_1 = 22;
        in_2 = 46;
        in_3 = 18;
        in_4 = 16;
        ans_arr[i] = (in_1 + in_2)*(in_3 + in_4);
        i= i+1;
        #`CYCLE_TIME

        in_1 = 49;
        in_2 = 49;
        in_3 = 59;
        in_4 = 41;
        ans_arr[i] = (in_1 + in_2)*(in_3 + in_4);
        i= i+1;
        #`CYCLE_TIME
    
        in_1 = 51;
        in_2 = 38;
        in_3 = 27;
        in_4 = 60;
        ans_arr[i] = (in_1 + in_2)*(in_3 + in_4);
        i= i+1;
        #`CYCLE_TIME

        in_1 = 12;
        in_2 = 62;
        in_3 = 25;
        in_4 = 36;
        ans_arr[i] = (in_1 + in_2)*(in_3 + in_4);
        i= i+1;
        #`CYCLE_TIME
    
        in_1 = 13;
 in_2 = 28;
        in_3 = 6;
        in_4 = 55;
        ans_arr[i] = (in_1 + in_2)*(in_3 + in_4);
        i= i+1;
        #`CYCLE_TIME

        in_1 = 30;
 in_2 = 51;
        in_3 = 18;
        in_4 = 13;
        ans_arr[i] = (in_1 + in_2)*(in_3 + in_4);
        i= i+1;
        #`CYCLE_TIME

        in_1 = 3;
 in_2 = 59;
        in_3 = 11;
        in_4 = 38;
        ans_arr[i] = (in_1 + in_2)*(in_3 + in_4);
        i= i+1;
        #`CYCLE_TIME
    
        in_1 = 3;
 in_2 = 26;
        in_3 = 61;
        in_4 = 9;
        ans_arr[i] = (in_1 + in_2)*(in_3 + in_4);
        i= i+1;
        #`CYCLE_TIME
    
        in_1 = 37;
 in_2 = 31;
        in_3 = 29;
        in_4 = 20;
        ans_arr[i] = (in_1 + in_2)*(in_3 + in_4);
        i= i+1;
      	#`CYCLE_TIME
      	
      	in_valid = 0;
      #`CYCLE_TIME*5
      
      
      for(i=0;i<10;i++)begin
        $display(ans_arr[i]);
      end
    end
initial
    begin            
        $dumpfile("wave.vcd");        
        $dumpvars(0, merge_sort_tb);    
    end
  	
   	P_MUL pp(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .in_1(in_1),
        .in_2(in_2),
  		.in_3(in_3),
        .in_4(in_4),
        .in_valid(in_valid),
        //output
        .out_valid(out_valid),
        .out(out)
    );

endmodule