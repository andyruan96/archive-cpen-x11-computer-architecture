/*
 this module represents the fsm used to update mem address according to the user inputs
 	//input
	current_addr: current mem address
 	direction: play forward or backward
	clk: clock
	next_addr: next mem address
	mem_update_enable: signal from mem_data_interp to update the mem address
	mem_updated: indicate to mem_data_interp that the signal is updated
*/
module mem_address_fsm(
	
	//input
	current_addr,
	direction,
	clk,
	mem_update_enable,
	
	//output
	mem_updated,
	next_addr,
);

	//input
	input logic [22:0] current_addr;
	input logic direction;
	input logic clk;
	input logic mem_update_enable;
	
	//output	
	output logic [22:0] next_addr;
	output logic mem_updated;
	
	//internal wires
	logic [22:0] next_addr_reg;
	logic state,mem_updated_reg;
	logic [22:0] up_value;
	logic [22:0] down_value;
	
	localparam last_address = 524287; 
	
	assign up_value = (current_addr <= last_address)? current_addr + 1 : 0;
	assign down_value = (current_addr > 0)? current_addr - 1 : last_address; 
	
	//state encoding
	parameter idle = 1'b0;
	parameter read = 1'b1;
	
	//output 
	//glitch free argument: all the output only depend on one state bit and stable input
	assign mem_updated = state;
	
	 always_comb begin
		case(state) 
			read: begin 
				next_addr <= direction? up_value : down_value;
				end
			default: next_addr<= current_addr;
		endcase
	end 
	
	//next state logic
	always_ff @(posedge clk) begin
		case(state)
			idle: state <= mem_update_enable ? read : idle;
			read: state <= idle;
			default: state <= idle;
		endcase
	end
	
	
	
endmodule 