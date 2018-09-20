module task2_a_calculate_j(
	//input
	i,
	start,
	in_data,
	secrete_key_value,
	clk,
	
	//output
	j,
	finish,
	wren,
	out_address
);
	
	//input
	//todo: need to determine the length later
	input logic[7:0] in_data;
	input logic[7:0] secret_key_value;
	input logic[3:0] i;
	input logic start;
	input logic clk;
	
	//output
	output[3:0] j;
	output logic finish;
	
	//constant for calculation
	localparam key_length = 3;
	
	//initialize j to be zero
	reg[3:0] j_reg = 0;
	
	//state encoding
	// state bits _ wren
	localparam wait = 2'b000000_;
	localparam calculate = 2'b000001_0;
	localparam store_si = 'b000010_0
	localparam store_sj = 'b000100_0
	localparam send_si = 'b001000_1
	localparam send_sj ='b010000_1
	localparam finish = 'b100000_0;
	
	//internal wires
	logic[6:0] state;
	logic[7:0] si_reg;
	logic[7:0] sj_reg;
	
	//output
	assign finish = state[1];
	assign j = j_reg;
	
	always_comb begin
		case(state)  
			store_si : si_reg <= si_value;
			store_sj : sj_reg <= sj_value;
			send_si	 : out_address <= i;
			send_sj  : out_address <= j;
			default: begin
						si_reg <= si_reg;
						sj_reg <= sj_reg;
					 end
	end
	
	//this module might need to change later
	always@(state[0]) begin
		if(state[0]) j_reg = j_reg + si_reg + secret_key_value;
	end
	
	//state transition logic
	always_ff @(posedge clk) begin
		case(state)
			wait: if(start) state <= calculate;
			calculate: if(start) state <= finish;
			finish: if(~start) state <= wait;
			default: state <= wait;
		endcase
	end

endmodule
