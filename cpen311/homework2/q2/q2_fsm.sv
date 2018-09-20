
module q2_fsm(restart, pause, goto_third, clk, terminal, Out1, Out2, even, odd);
	// state encoding format is 8'bterminal_out1_out2_even
	// bits 2, 4, 5 are flipped in order to avoid invalid initial states by allow FIRST = 8'b0
	localparam FIRST = 8'b0_000_000_0;
	localparam SECOND = 8'b0_110_110_1;
	localparam THIRD = 8'b0_001_101_0;
	localparam FOURTH = 8'b0_101_001_1;
	localparam FIFTH = 8'b1_110_000_0;
	
	input logic restart, pause, goto_third, clk;
	output logic terminal, even, odd;
	output logic[2:0] Out1, Out2;
	
	assign terminal = state[7];
	assign even = state[0];
	assign odd = ~state[0];
	assign Out1 = {state[6], ~state[5:4]};
	assign Out2 = {state[3], ~state[2], state[1]};
	
	logic[7:0] state;
	
	always_ff @(posedge clk)
		case(state)
			FIRST: 
				if(restart | pause) state <= FIRST;
				else state <= SECOND;
			SECOND:
				if(restart) state <= FIRST;
				else if(pause) state <= SECOND;
				else state <= THIRD;
			THIRD:
				if(restart) state <= FIRST;
				else if(pause) state <= THIRD;
				else state <= FOURTH;
			FOURTH:
				if(restart) state <= FIRST;
				else if(pause) state <= FOURTH;
				else state <= FIFTH;
			FIFTH:
				if(goto_third) state <= THIRD;
				else if(restart) state <= FIRST;
				else if(pause) state <= FIFTH;
				else state <= FIRST;
			default: state <= FIRST;
		endcase
endmodule
