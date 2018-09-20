module regFile (data_in, writenum, write, readnum, clk, data_out, r0out, r1out, r2out, r3out, r4out, r5out);
	input [15:0] data_in;
	input [2:0] writenum, readnum;
	input [0:0] write, clk;
	output [15:0] data_out;
	output [15:0] r0out, r1out, r2out, r3out, r4out, r5out; // FOR TESTING ON DE1-SOC
	wire [15:0] rOut0, rOut1, rOut2, rOut3, rOut4, rOut5, rOut6, rOut7;
	wire [7:0] OHwn, ANDwn;

	// FOR TESTING ON DE1-SOC
	assign r0out = rOut0;
	assign r1out = rOut1;
	assign r2out = rOut2;
	assign r3out = rOut3;
	assign r4out = rOut4;
	assign r5out = rOut5;
	
	// load for the registers
	Dec #(3,8) writenumDec(writenum, OHwn);
	assign ANDwn = OHwn & {8{write}};

	Mux8b #(16) data_outMux(rOut0, rOut1, rOut2, rOut3, rOut4, rOut5, rOut6, rOut7, readnum, data_out);

	register #(16) R0(data_in, ANDwn[0], clk, rOut0);
	register #(16) R1(data_in, ANDwn[1], clk, rOut1);
	register #(16) R2(data_in, ANDwn[2], clk, rOut2);
	register #(16) R3(data_in, ANDwn[3], clk, rOut3);
	register #(16) R4(data_in, ANDwn[4], clk, rOut4);
	register #(16) R5(data_in, ANDwn[5], clk, rOut5);
	register #(16) R6(data_in, ANDwn[6], clk, rOut6);
	register #(16) R7(data_in, ANDwn[7], clk, rOut7);

endmodule

// n to m bit decoder (binary -> one hot)
module Dec(a, b);
	parameter n = 2; // decoding from
	parameter m = 4; // decoding to

	input [n-1:0] a;
	output [m-1:0] b;

	wire [m-1:0] b = 1<<a;
endmodule

// DFF
module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;

  always @(posedge clk)
    Q = D;
endmodule

// 8-input one hot select multiplexer, k-bit inputs
module Mux8a (a0, a1, a2, a3, a4, a5, a6, a7, OHSelect, out);
	parameter k = 1;
	input [k-1:0] a0, a1, a2, a3, a4, a5, a6, a7;
	input [7:0] OHSelect;
	output reg [k-1:0] out;

	always @(*) begin
		case(OHSelect)
			8'b00000001: out = a0;
			8'b00000010: out = a1;
			8'b00000100: out = a2;
			8'b00001000: out = a3;
			8'b00010000: out = a4;
			8'b00100000: out = a5;
			8'b01000000: out = a6;
			8'b10000000: out = a7;
			default: out = {k{1'bx}};
		endcase
	end
endmodule

// 8-input 3-bit binary select multiplexer, k-bit inputs
module Mux8b (b0, b1, b2, b3, b4, b5, b6, b7, binarySelect, out);
	parameter k = 1;
	input [k-1:0] b0, b1, b2, b3, b4, b5, b6, b7;
	input [2:0] binarySelect;
	output [k-1:0] out;
	wire [7:0] oneHot;

	Dec #(3,8) dec38(binarySelect, oneHot);
	Mux8a #(k) mux(b0, b1, b2, b3, b4, b5, b6, b7, oneHot, out);
endmodule

// Single k-bit register
module register (in, load, clk, out);
	parameter k = 1;
	input [k-1:0] in;
	input [0:0] load, clk;
	output [k-1:0] out;
	wire [k-1:0] nextState;

	assign nextState = load ? in : out;	

	vDFF #(k) dff(clk, nextState, out);
endmodule
