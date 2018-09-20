
module message_checker(clk, start_signal, indata, out_addr, update_key, valid, state);
	localparam IDLE = 4'b0_000;
	localparam INC_ADDRESS = 4'b0_001;
	localparam CHECK_DATA = 4'b1_000;
	localparam INC_KEY = 4'b0_010;
	localparam DONE = 4'b0_100;
	
	input logic clk, start_signal;
	input logic [7:0] indata;
	
	output logic update_key, valid;
	output logic [4:0] out_addr;
	
	logic update_addr;
	reg[4:0] addr = 5'b0;
	output logic[3:0] state = IDLE;
	
	assign update_addr = state[0];
	assign update_key = state[1];
	assign valid = state[2];
	assign out_addr = addr;
	
	always_ff @(posedge update_addr, posedge update_key)
		if(update_key) addr <= 0;
		else addr <= addr + 1;
	
	always_ff @(posedge clk) begin
		case(state)
			IDLE:
				if(start_signal) state <= CHECK_DATA;
				else state <= IDLE;
			INC_ADDRESS: state <= CHECK_DATA;
			CHECK_DATA: begin
				if((indata >= 97 && indata <= 122) || indata == 32) begin
					if(addr == 31) state <= DONE;
					else state <= INC_ADDRESS;
				end
				else state <= INC_KEY;
			end
			INC_KEY: state <= IDLE;
			DONE: state <= DONE;
			default: state <= IDLE;
		endcase
	end
	
endmodule
