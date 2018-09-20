
module Song_Speed_Adjuster(speed_up, speed_down, speed_r, in_clk, out_clk, freqDiv);

	input logic speed_up, speed_down, speed_r, in_clk;
	output logic out_clk;
	output logic[31:0] freqDiv = 32'h46e;
	
	frequencies_divider #(32) generate_tempo( .inclk(in_clk), .outclk(out_clk), .outclk_Not(), .div_clk_count(freqDiv), .Reset(1'b1) );
	/*Generate_Arbitrary_Divided_Clk32 Gen_Adjustable_clk
	(
	.inclk(in_clk),
	.outclk(out_clk),
	.outclk_Not(),
	.div_clk_count(32'h46e), //change this if necessary to suit your module
	.Reset(1'h1));*/
	
	always_ff @(posedge in_clk)
		if(speed_r) freqDiv = 32'h46e;
		else if(speed_up) freqDiv -= 100;
		else if(speed_down) freqDiv += 100;
	
endmodule
