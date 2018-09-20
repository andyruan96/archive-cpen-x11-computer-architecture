module datapath(mdata, sximm8, eightnPC, vsel, writenum, write, readnum, clk, 
  loada, loadb, shift, six16, sximm5, asel, bsel, ALUop, loadc, loads, B, C, S,
  r0out, r1out, r2out, r3out, r4out, r5out);

  input [15:0] six16, sximm5;
  input write, clk, loada, loadb, asel, bsel, loadc, loads;
  input [2:0] writenum, readnum;
  input [1:0] vsel, shift, ALUop;
  output [15:0] B, C;
  output [2:0] S;
  output [15:0] r0out, r1out, r2out, r3out, r4out, r5out; // FOR TESTING ONLY ON DE1-SOC
  wire [15:0] data_in, data_out, w3t6, w8t7, Ain, Bin, w2t5;
  wire [2:0] w2t10;
  // changes to above: modified name:sximm5, vsel(from 1b to 2b), modified name: C

  // lab6 Modification 2 
  input [15:0] mdata, sximm8, eightnPC;

  MuxOf4Inputs #(16) mx9(mdata, sximm8, eightnPC, C, vsel, data_in);
  regFile regFile0(data_in, writenum, write, readnum, clk, data_out, r0out, r1out, r2out, r3out, r4out, r5out);
  register #(16) regA(data_out, loada, clk, w3t6);
  register #(16) regB(data_out, loadb, clk, B);
  shifter #(16) shifter0(B, shift, w8t7);
  Mux #(16) mx6(six16, w3t6, asel, Ain);
  Mux #(16) mx7(sximm5, w8t7, bsel, Bin);
  ALU alu0(Ain, Bin, ALUop, w2t5, w2t10);
  register #(16) regC(w2t5, loadc, clk, C);
  register #(3) status(w2t10, loads, clk, S);//input changed to 3bits

endmodule

module Mux(xin, yin, sel, out);
  parameter k = 16 ;
  input [k-1:0] xin, yin; 
  input sel;
  output[k-1:0] out ;
  
  assign out = sel ? xin : yin;
  
endmodule

module MuxOf4Inputs(win, xin, yin, zin, sel, out);
  parameter k = 16 ;
  input [k-1:0] win, xin, yin, zin; 
  input [1:0] sel;
  output[k-1:0] out ;
  reg [k-1:0] out ;

  always @(*)begin
    case(sel)
	2'b00: out = win;
	2'b01: out = xin;
	2'b10: out = yin;
	2'b11: out = zin;
    endcase
  end
endmodule
