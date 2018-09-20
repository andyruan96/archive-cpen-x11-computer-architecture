module task2_a(
	//input
	secret_key_value,
	clock,
	start,
	in_data,
	reset,
	
	//output
	finish,
	out_data,
	wren,
	address,
	
	state_debug,
	j_index_debug,
	key_select_debug,
	key_value_debug
);
	
	
	
	//input
	input logic[23:0] secret_key_value;
	input logic[7:0] in_data;
	input logic start;
	input logic clock;
	input logic reset;
	
	//output
	output logic[7:0] out_data;
	output logic[7:0] address;
	output logic wren;
	output logic finish;
	
	//constant for calculation
	localparam key_length = 3;
	
	//internal logic
	reg[7:0] j_index = 0;
	reg[7:0] secret_key_0;
	reg[7:0] secret_key_1;
	reg[7:0] secret_key_2;
	
	output logic[7:0] j_index_debug;
	assign j_index_debug = j_index;
	
	assign secret_key_0 = secret_key_value[23:16];
	assign secret_key_1 = secret_key_value[15:8];
	assign secret_key_2 = secret_key_value[7:0];
	
	//determine which key value to use
	logic[1:0] key_select;
	logic[7:0] selected_secret_key_value;
	
	assign key_select = increment % key_length;
	
	output logic[1:0] key_select_debug;
	assign key_select_debug = key_select;
	
	output logic[7:0] key_value_debug;
	assign key_value_debug = selected_secret_key_value;
	
	always_comb begin
		case(key_select)
			2'b00: selected_secret_key_value <=secret_key_0;
			2'b01: selected_secret_key_value <=secret_key_1;
			2'b10: selected_secret_key_value <=secret_key_2;
			default:selected_secret_key_value <=secret_key_0;
		endcase
	end
	
	//state encoding
	// state bits _ wren
	localparam[12:0] wait_s = 			     13'b000000_000000_0;
	localparam[12:0] send_si_add = 		     13'b000000_000001_0;
	localparam[12:0] store_si = 			 13'b000000_000010_0;
	localparam[12:0] calculate_j = 		     13'b000000_000100_0;
	localparam[12:0] send_sj_add = 		     13'b000000_001000_0;
	localparam[12:0] store_sj =     		 13'b000000_010000_0;
	localparam[12:0] send_si =               13'b000000_100000_1;
	localparam[12:0] send_sj = 			     13'b000001_000000_1;
	localparam[12:0] finish_s = 			 13'b000010_000000_0;
	localparam[12:0] wait_one_olock_writeI = 13'b000100_000000_1;
	localparam[12:0] wait_one_olock_writeJ = 13'b001000_000000_1;
	localparam[12:0] increment_address =     13'b010000_000000_0;
	localparam[12:0] disable_wren = 		 13'b100000_000000_0;
	
	//iterate i fromn 0 to 256
	//and update the address correspondingly
	logic[7:0] count = 255;
	logic[7:0] increment;
	
	counter address_counter(
				  .clk(state[11]),
				  .reset(reset),
				  .q(increment));
				  
	//internal wires
	logic[12:0] state;
	logic[7:0] si_reg;
	logic[7:0] sj_reg;
	logic[7:0] out_data_reg;
	logic finish_reg;
	logic wren_reg;
	logic[7:0] address_reg;
	
	output logic [12:0] state_debug;
	assign state_debug = state;
	
	//output logic
	always_comb begin 
		case(state)
			send_si_add: begin
						finish<=0;
						wren<=0;
						address <= increment;
						out_data<= si_reg;
						end
			store_si: begin
					  	finish<=0;
						wren<=0;
						address <= increment;
						out_data<= si_reg;
					  end
			send_sj_add: begin
						finish<=0;
						wren<=0;
						address<= j_index;
						out_data<= si_reg;
						end
			store_sj: begin
					  	finish<=0;
						wren<=0;
						address<= j_index;
						out_data<= si_reg;
					  end
			send_si: begin 
					finish<=0;
					wren<=1;
					address <= increment;
					out_data <= sj_reg;
					end
			wait_one_olock_writeI: begin
									finish<=0;
									wren<=1;
									address <= increment;
									out_data <= sj_reg;
								   end
			send_sj: begin 
					finish<=0;
					wren<=1;
					address<= j_index;
					out_data<= si_reg;
					end
			wait_one_olock_writeJ: begin
								   finish<=0;
									wren<=1;
									address<= j_index;
									out_data<= si_reg;
								   end
			finish_s:begin 
					finish<=1;
					wren<=0;
					address<= 0;
					out_data<= 0;
					end
			default: begin 
					finish<=0;
					wren<=0;
					address<= 0;
					out_data<= 0;
					end
		endcase
	end
	
		always_ff @(posedge clock) begin
		case(state)
			wait_s: if(start) state <= send_si_add;
			send_si_add:if(start) state <= store_si;
			store_si: if(start) begin 
						state <= calculate_j;
						si_reg <= in_data;
						end 
			calculate_j:if(start)  begin
						state <= send_sj_add;
						j_index <= j_index + si_reg + selected_secret_key_value;
						end
			send_sj_add: if(start) state <= store_sj;
			store_sj: if(start) begin
						state <= send_si;
						sj_reg <= in_data;
						end
			send_si:if(start) state <= wait_one_olock_writeI;
			wait_one_olock_writeI:if(start) state <= disable_wren;
			disable_wren:if(start) state <= send_sj;
			send_sj:if(start) state <= wait_one_olock_writeJ;
			wait_one_olock_writeJ:if(increment < count & start) state <= increment_address;
									else state <=finish_s;
			increment_address:if(start) state <=send_si_add;
			finish_s: if(reset) begin 
							state <= wait_s;
							j_index<=0;
						end
			default: state <= wait_s;
		endcase
	end

endmodule

//counter module from the book
module counter #(parameter S = 8) (input logic clk,
	input logic reset, output logic [S-1:0] q);

	always_ff @(posedge clk, posedge reset) if (reset) q <= 0;
	else q <= q + 1;
endmodule