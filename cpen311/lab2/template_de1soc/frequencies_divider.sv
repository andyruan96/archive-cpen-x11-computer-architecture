//this module is frequencies_divider
//which change the input clock frequencies according to the count value
//inclk: input clock
//outclk: output clock with changed frequencies
//divi_clk_count: factor of the change frequencies
//reset: reset the counter if active
module frequencies_divider #(parameter N = 32)(
	inclk, outclk, outclk_Not, div_clk_count, Reset
);

	input logic inclk;
	input logic [N-1:0] div_clk_count;
	input logic Reset;
	
	output logic outclk;
	output logic outclk_Not;
	
	logic [N-1:0] counter;
	logic reset_counter;
	logic reset_counter_Reset;
	
	//counter that increment the count on clk
	counter #(.S(N)) counter32(.clk(inclk), .reset(reset_counter_Reset), .q(counter));
	
	//reset logic
	assign reset_counter_Reset = Reset ? reset_counter : 1'b1;
	
	//check if counter >= div_clk_count to reset the count value and 
	//output clk value
	always_ff @(posedge inclk)begin
		outclk <= (counter == div_clk_count)?  ~outclk : outclk; 
		reset_counter <= (counter >= div_clk_count)? 1'b1: 1'b0;
	end
	
	assign outclk_Not = ~outclk;
	
endmodule

//counter module from the book
module counter #(parameter S = 8) (input logic clk,
	input logic reset, output logic [S-1:0] q);

	always_ff @(posedge clk, posedge reset) if (reset) q <= 0;
	else q <= q + 1;
endmodule
