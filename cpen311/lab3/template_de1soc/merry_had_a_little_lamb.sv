/*
 * FSM which outputs the Merry Had A Little Lamb melody given a 50Hz base clock
 * 
 * Inputs:
 * clk_50: 50MHz clock
 * 
 * Outputs:
 * songClkOut: Output clock of melody to be wired to line out
 * songReset: Resets the FSM if in HIGH state
 */
module merry_had_a_little_lamb(clk_50, songClkOut, songReset);
	
	// Frequency divider values
	// notes/tones
	parameter DO = 32'hBAB7;
	parameter RE = 32'hA65B;
	parameter ME = 32'h942E;
	parameter SO = 32'h7CB6;
	parameter REST_NOTE = 32'd24999998;	// effectively silent
	// delays
	parameter REST = 32'd12499998;
	parameter SHORT_REST = 32'd1562498;
	
	input logic clk_50, songReset;
	logic [5:0] nextState, state;
	logic restClk;		// determines how long the note will be played
	logic [31:0] noteDiv, restDiv;
	output logic songClkOut;
	
	// one divider to play the correct note, another one to determine how long to play that note for
	frequencies_divider #(32) noteClkGenerator( .inclk(clk_50), .outclk(songClkOut), .outclk_Not(), .div_clk_count(noteDiv), .Reset(1'b1) );
	frequencies_divider #(32) restClkGenerator( .inclk(clk_50), .outclk(restClk), .outclk_Not(), .div_clk_count(restDiv), .Reset(1'b1) );
	
	// next state logic does not depend on inputs, only moves foward and resets
	always_ff @( posedge restClk ) begin
		if (songReset || state >= 6'd39)
			state <= 6'b0;
		else
			state <= nextState;
	end
	
	assign nextState = state + 6'd1;
	
	// melody
	always_comb begin
		case(state)
			0: begin noteDiv = REST; restDiv = REST; end
			
			1: begin noteDiv = ME; restDiv = REST; end
			2: begin noteDiv = RE; restDiv = REST; end
			3: begin noteDiv = DO; restDiv = REST; end
			4: begin noteDiv = RE; restDiv = REST; end
	
			5: begin noteDiv = ME; restDiv = REST; end
			6: begin noteDiv = REST_NOTE; restDiv = SHORT_REST; end
			7: begin noteDiv = ME; restDiv = REST; end
			8: begin noteDiv = REST_NOTE; restDiv = SHORT_REST; end
			9: begin noteDiv = ME; restDiv = REST; end
			10: begin noteDiv = REST_NOTE; restDiv = SHORT_REST; end
			
			11: begin noteDiv = RE; restDiv = REST; end
			12: begin noteDiv = REST_NOTE; restDiv = SHORT_REST; end
			13: begin noteDiv = RE; restDiv = REST; end
			14: begin noteDiv = REST_NOTE; restDiv = SHORT_REST; end
			15: begin noteDiv = RE; restDiv = REST; end
			16: begin noteDiv = REST_NOTE; restDiv = SHORT_REST; end
			
			17: begin noteDiv = ME; restDiv = REST; end
			18: begin noteDiv = REST_NOTE; restDiv = SHORT_REST; end
			19: begin noteDiv = SO; restDiv = REST; end
			20: begin noteDiv = REST_NOTE; restDiv = SHORT_REST; end
			21: begin noteDiv = SO; restDiv = REST; end
			22: begin noteDiv = REST_NOTE; restDiv = SHORT_REST; end
			
			23: begin noteDiv = ME; restDiv = REST; end
			24: begin noteDiv = RE; restDiv = REST; end
			25: begin noteDiv = DO; restDiv = REST; end
			26: begin noteDiv = RE; restDiv = REST; end
	
			27: begin noteDiv = ME; restDiv = REST; end
			28: begin noteDiv = REST_NOTE; restDiv = SHORT_REST; end
			29: begin noteDiv = ME; restDiv = REST; end
			30: begin noteDiv = REST_NOTE; restDiv = SHORT_REST; end
			31: begin noteDiv = ME; restDiv = REST; end
			32: begin noteDiv = REST_NOTE; restDiv = SHORT_REST; end
			
			33: begin noteDiv = RE; restDiv = REST; end
			34: begin noteDiv = REST_NOTE; restDiv = SHORT_REST; end
			35: begin noteDiv = RE; restDiv = REST; end
			36: begin noteDiv = REST_NOTE; restDiv = SHORT_REST; end
			37: begin noteDiv = ME; restDiv = REST; end
			38: begin noteDiv = RE; restDiv = REST; end
			39: begin noteDiv = DO; restDiv = REST; end
			
			default: begin noteDiv = REST_NOTE; restDiv = REST; end
		endcase
	end
	
endmodule
