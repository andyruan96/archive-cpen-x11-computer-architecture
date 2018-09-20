module message_checker2(clk, start_signal, reset, indata, out_addr, update_key, valid, state, finish);
	
	//state encoding
	localparam IDLE = 5'b0_000;
	localparam INC_ADDRESS = 5'b0_001;
	localparam CHECK_DATA = 5'b1_000;
	localparam INC_KEY = 5'b0_010;
	localparam DONE = 5'b0_100;
	localparam FINISH = 5'b10000;
	
	//input declaration
	input logic clk, start_signal, reset;
	input logic [7:0] indata;
	
	//output declaration
	output logic update_key, valid,finish;
	output logic [4:0] out_addr;
	
	//internal wire;
	logic update_addr;
	reg[4:0] addr = 5'b0;
	output logic[4:0] state;
	
	assign update_addr = state[0];
	assign update_key = state[1];
	assign valid = state[2];
	assign out_addr = addr;
	assign finish = state[4];
	
	always_ff @(posedge update_addr or posedge reset)
		if(reset) addr <= 0;
		else addr <= addr + 1;
	
	always_ff @(posedge clk) begin
		case(state)
			IDLE:
				if(start_signal) state <= CHECK_DATA;
				else state <= IDLE;
			INC_ADDRESS: state <= CHECK_DATA;
			CHECK_DATA: begin
				if((indata >= 97 && indata <= 122) || indata == 32) begin
					if(addr < 31) state <= INC_ADDRESS;
					else state <= DONE;
				end
				else state <= INC_KEY;
			end
			INC_KEY: state <= FINISH;
			FINISH: if(reset) state <= IDLE;
			DONE: state <= DONE;
			default: state <= IDLE;
		endcase
	end
	
endmodule
