/*
 * Allows manual control of a clock's frequency.
 * Inputs:
 * 		speed_up: When high, will increase out_clk frequency every in_clk cycle
 *		speed_down: When high, will decrease out_clk frequency every in_clk cycle
 *		speed_r: When high, will reset the out_clk frequency to the default of 22KHz
 *		in_clk: Input clock and base clock to frequency divider
 * Outputs:
 *		out_clk: Output clock
 */
module Song_Speed_Adjuster(speed_up, speed_down, speed_r, in_clk, out_clk);

	input logic speed_up, speed_down, speed_r, in_clk;
	output logic out_clk;
	reg[31:0] freqDiv = 32'h46e;
	
	Generate_Arbitrary_Divided_Clk32 Gen_Adjustable_clk
	(
	.inclk(in_clk),
	.outclk(out_clk),
	.outclk_Not(),
	.div_clk_count(freqDiv), //change this if necessary to suit your module
	.Reset(1'h1));
	
	always_ff @(posedge in_clk)
		if(speed_r) freqDiv = 32'h46e;
		else if(speed_up) freqDiv -= 10;
		else if(speed_down) freqDiv += 10;
	
endmodule
