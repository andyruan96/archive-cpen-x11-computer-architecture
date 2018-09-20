module datapath(datapath_in, vsel, writenum, write, readnum, clk, loada, loadb, shift, six16, seven11dp, asel, bsel, ALUop, loadc, loads, status, datapath_out);

  input [15:0] datapath_in, six16, seven11dp;
  input vsel, write, clk, loada, loadb, asel, bsel, loadc, loads;
  input [2:0] writenum, readnum;
  input [1:0] shift, ALUop;
  output [15:0] datapath_out;
  output status;
  wire [15:0] data_in, data_out, w3t6, w4t8, w8t7, Ain, Bin, w2t5;
  wire w2t10;


  Mux #(16) mx9(datapath_in, datapath_out, vsel, data_in);
  regFile regFile0(data_in, writenum, write, readnum, clk, data_out);
  register #(16) regA(data_out, loada, clk, w3t6);
  register #(16) regB(data_out, loadb, clk, w4t8);
  shifter #(16) shifter0(w4t8, shift, w8t7);
  Mux #(16) mx6(six16, w3t6, asel, Ain);
  Mux #(16) mx7(seven11dp, w8t7, bsel, Bin);
  ALU alu0(Ain, Bin, ALUop, w2t5, w2t10);
  register #(16) regC(w2t5, loadc, clk, datapath_out);
  register #(1) statusblock(w2t10, loads, clk, status);//where does "out" go?

endmodule

module Mux(xin, yin, sel, out) ;
  parameter k = 16 ;
  input [k-1:0] xin, yin; 
  input sel ; 
  output[k-1:0] out ;
  reg [k-1:0] out ;

  always @(*)begin
    case(sel)
	1'b1: out = xin;
	1'b0: out = yin;
    endcase
  end
endmodule
