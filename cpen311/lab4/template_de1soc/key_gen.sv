module key_gen(start, clock, reset,reset_state, full_key, ovf, finish);
	
	input logic start, reset,clock,reset_state;
	output logic ovf,finish;
	output logic [9:0] full_key;
	logic[21:0] count = 2097151;
	
	reg[21:0] curr_key;
	assign full_key = {2'b00, curr_key};
	
	counter #(24) address_counter(
				  .clk(state[0]),
				  .reset(reset),
				  .q(curr_key));
				  
	//state encoding
	localparam wait_s		 = 3'b000;
	localparam increment_s	 = 3'b001;
	localparam finish_s		 = 3'b010;
	localparam no_key_s		 = 3'b100;
	
	//internal wire
	logic[2:0] state;
	
	//output logic
	assign finish = state[1];
	assign ovf =state[2];
	
	
	//state transition
	always_ff @(posedge clock) begin
		case(state)
			wait_s:if(start) begin 
				   if(curr_key < count) state<= increment_s;
				   else state <= no_key_s;
					end
			increment_s:if(start) state<= finish_s;
			finish_s: if(reset_state) state<=wait_s;
			no_key_s: if(reset) state<=wait_s;
			default: state<=wait_s;
		endcase
	end
		
endmodule
