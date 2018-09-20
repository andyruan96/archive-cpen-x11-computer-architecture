
module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);
  input [3:0] KEY;
  input [9:0] SW;
  input CLOCK_50;
  
  output [9:0] LEDR; 
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  
  wire [15:0] r0out, r1out, r2out, r3out, r4out, r5out; // FOR TESTING ON DE1 SOC
  
  assign LEDR = r0out[9:0]; // LEDs get first 10 bits of register 0
  
  cpu lab6(.clk(CLOCK_50), .reset(~KEY[0]), .r0out(r0out), .r1out(r1out), .r2out(r2out), .r3out(r3out), .r4out(r4out), .r5out(r5out) );
  assignHex hex(HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, r0out, r1out, r2out, r3out, r4out, r5out); 
  
endmodule


module assignHex (hex0, hex1, hex2, hex3, hex4, hex5, in0, in1, in2, in3, in4, in5);
	input [15:0] in0, in1, in2, in3, in4, in5;
	output [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
	
	sseg h0(in0, hex0);
	sseg h1(in1, hex1);
	sseg h2(in2, hex2);
	sseg h3(in3, hex3);
	sseg h4(in4, hex4);
	sseg h5(in5, hex5);
	
endmodule


// Modified sseg from default lab5_top to run the HEX displays
module sseg(in,segs);
  `define ZERO 7'b1000000
  `define ONE 7'b1111001
  `define TWO 7'b0100100
  `define THREE 7'b0110000
  `define FOUR 7'b0011001
  `define FIVE 7'b0010010
  `define SIX 7'b0000010
  `define SEVEN 7'b1111000
  `define EIGHT 7'b0000000
  `define NINE 7'b0010000
  `define TEN 7'b0001000
  `define ELEVEN 7'b1000011
  `define TWELVE 7'b1000110
  `define THIRTEEN 7'b0100001
  `define FOURTEEN 7'b0000110
  `define FIFTEEN 7'b0001110
  `define TOOBIG 7'b0011100
  
  input [15:0] in;
  output reg [6:0] segs;

	always @(*) begin
		case(in)
			16'd0 : segs = `ZERO;
			16'd1 : segs = `ONE;
			16'd2 : segs = `TWO;
			16'd3 : segs = `THREE;
			16'd4 : segs = `FOUR;
			16'd5 : segs = `FIVE;
			16'd6 : segs = `SIX;
			16'd7 : segs = `SEVEN;
			16'd8 : segs = `EIGHT;
			16'd9 : segs = `NINE;
			16'd10: segs = `TEN;
			16'd11: segs = `ELEVEN;
			16'd12: segs = `TWELVE;
			16'd13: segs = `THIRTEEN;
			16'd14: segs = `FOURTEEN;
			16'd89: segs = `FIFTEEN;
			default: segs = `TOOBIG;
		endcase
	end

endmodule
