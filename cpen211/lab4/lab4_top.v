module lab4_top(SW,KEY,HEX0);
	input [9:0] SW;
	input [3:0] KEY;
	output reg [6:0] HEX0;
	
	`define SS 5
	`define Sa 5'b00001
	`define Sb 5'b00010
	`define Sc 5'b00100
	`define Sd 5'b01000
	`define Se 5'b10000
	`define DirF 1'b1 //advance forwards
	`define DirB 1'b0 //advance backwards

	wire [4:0] present_state, next_state_reset;
	wire [5:0] present_state_dir;
	wire [4:0] default_next_state;
	reg [4:0] next_state;

	assign next_state_reset = KEY[1] ? next_state : `Sa; //sets next state
	assign present_state_dir = {SW[0], present_state}; //concatenate's direction input
	
	//finds the initial next state
	assign default_next_state[0] = 0;
	assign default_next_state[1] = SW[0];
	assign default_next_state[2] = 0;
	assign default_next_state[3] = 0;
	assign default_next_state[4] = ~SW[0];

	vDFF #(`SS) STATE(KEY[0], next_state_reset, present_state);

	always @(*) begin
		case(present_state_dir)
			{`DirF,`Sa} : {next_state, HEX0} = {`Sb, 7'b0000010}; // 6
			{`DirF,`Sb} : {next_state, HEX0} = {`Sc, 7'b1000000}; // 0
			{`DirF,`Sc} : {next_state, HEX0} = {`Sd, 7'b0011001}; // 4
			{`DirF,`Sd} : {next_state, HEX0} = {`Se, 7'b0000000}; // 8
			{`DirF,`Se} : {next_state, HEX0} = {`Sa, 7'b0110000}; // 3

			{`DirB,`Sa} : {next_state, HEX0} = {`Se, 7'b0000010}; // 6
			{`DirB,`Sb} : {next_state, HEX0} = {`Sa, 7'b1000000}; // 0
			{`DirB,`Sc} : {next_state, HEX0} = {`Sb, 7'b0011001}; // 4
			{`DirB,`Sd} : {next_state, HEX0} = {`Sc, 7'b0000000}; // 8
			{`DirB,`Se} : {next_state, HEX0} = {`Sd, 7'b0110000}; // 3

			default: {next_state, HEX0} = {default_next_state, 7'b0000010}; //initial
		endcase
	end
  // put your state machine code here!
endmodule

//D Flip-Flop
module vDFF (clk, in, out);
	parameter n = 1;
	input clk;
	input [n-1:0] in;
	output [n-1:0] out;
	reg [n-1:0] out;

	always @(posedge clk)
		out = in;
endmodule