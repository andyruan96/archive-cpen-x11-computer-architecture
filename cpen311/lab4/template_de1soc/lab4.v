module lab4(
	clock,
	reset,
	//output
	ledr,
	out_key_value
);
	//input delcaration
	input logic reset;
	input logic clock;
	//output declaration
	output logic[9:0] ledr;
	output logic[23:0] out_key_value;
	
	assign out_key_value = key_value;
	assign not_found = no_key;
	assign found = found_key;
	
	//working memory declaration
	logic[7:0] selected_address;
	logic[4:0] selected_dmaddress;
	logic[7:0] selected_dmdata;
	logic[7:0] selected_data;
	logic[7:0] data_out;
	logic[7:0] dm_out_data;
	logic selected_wren;
	logic selected_dmwren;
	
	//working s
	s_memory working_s(
		.address(selected_address),
		.clock(clock),		
		.data(selected_data),		
		.wren(selected_wren),
		.q(data_out)
	);
	
	//decrypted message ram
	dm_memory dm_ram(
	.address(selected_dmaddress),
	.clock(clock),
	.data(selected_dmdata),
	.wren(selected_dmwren),
	.q(dm_out_data)
	);
	
	//encrypted message rom
	message message(
	.address(task2b_emaddress),
	.clock(clock),
	.q(encrypted_m)
	);
	
	//key generator
	logic no_key;
	logic[23:0] key_value;
	logic increment_key;
	logic key_update_start;
	logic key_update_finish;
	
	key_gen key_gen(
		.clock(clock),	
		.start(key_update_start),
		.reset_state(state[1]),
		.reset(~reset), 
		.full_key(key_value), 
		.ovf(no_key),
		.finish(key_update_finish)
	);
	
	//indicator for no possible key
	assign ledr[5] = no_key;
	
	//task1 logic 
	reg task1_finish=0;
	logic task1_start;
	logic[7:0] task1_address;
	logic[7:0] task1_data;
	logic task1_wren;
	
	//assign task1_start = ~task1_finish & ~no_key & ~not_found;
	assign ledr[0] = task1_start;
	
	task1 task1(
		.start(task1_start),
		.clock(clock),
		.reset(reset_task1_2),
		.finished(task1_finish),
		.address(task1_address),
		.data(task1_data),
		.wren(task1_wren)
	);
	
	//task2_a
	logic start_task2_a;
	reg task2_finish=0;
	logic[7:0] task2_address;
	logic[7:0] task2_data;
	logic task2_wren;
	
	//assign start_task2_a = (task1_finish & ~task2_finish & ~found_key);
	assign ledr[1] = start_task2_a;
	
	task2_a task2_a_init(
	.secret_key_value(key_value),
	.clock(clock),
	.reset(reset_task1_2),
	.start(start_task2_a),
	.in_data(data_out),
	.finish(task2_finish),
	.out_data(task2_data),
	.wren(task2_wren),
	.address(task2_address)
	);
	
	
	//task2_b
	reg start_task2_b=0;
	reg task2b_finish=0;
	logic[7:0] task2b_saddress;
	logic[4:0] task2b_dmaddress;
	logic[4:0] task2b_emaddress;
	logic[7:0] task2b_data;
	logic[7:0] encrypted_m;
	logic task2b_swren;
	logic task2b_dmwren;
	
	//assign start_task2_b = (task2_finish & ~task2b_finish & ~found_key);
	assign ledr[2] = start_task2_b;
	
	task2_b task2_b_init(
	.clock(clock),
	.start(start_task2_b),
	.s_in_data(data_out),
	.reset(reset_task1_2),
	.in_encrypted_m(encrypted_m),
	//output
	.finish(task2b_finish),
	.out_data(task2b_data),
	.s_wren(task2b_swren),
	.dm_wren(task2b_dmwren),
	.s_address(task2b_saddress),
	.dm_address(task2b_dmaddress),
	.em_address(task2b_emaddress)
	);
	
	//task3 message checker
	reg start_task3_checker = 0;
	reg found_key =0;
	logic[7:0] task3_dmddress;
	reg task3_finish;
	//logic update_key;
	
	//assign start_task3_checker =  (task2b_finish & ~reset_all_task);
	assign ledr[3] = start_task3_checker;
	assign ledr[4] = found_key;
	
	message_checker message_checker(
		.clk(clock), 
		.start(start_task3_checker),
		.reset(state[1]),
		.indata(dm_out_data), 
		.out_addr(task3_dmddress), 
		.update_key(increment_key), 
		.found(found_key), 
		.finish(task3_finish),
	);
	
	//state encoding
	localparam update_key_s =   7'b100000_0;
	localparam task1_s      = 	7'b000001_0;
	localparam task2a_s	  = 	7'b000010_0;
	localparam task2b_s	  = 	7'b000100_0;
	localparam task3_s	  = 	7'b001000_1;
	localparam finish_s	  = 	7'b010000_0;
	
	assign task1_start = state[1];
	assign start_task2_a = state[2];
	assign start_task2_b = state[3];
	assign start_task3_checker = state[4];
	assign key_update_start = state[6];
	assign ledr[6] =state[6];
	
	logic reset_task1_2;
	
	assign reset_task1_2 = state[0];
	
	logic[6:0] state;
	//state transition
	always_ff @(posedge clock) begin
		case(state)
			update_key_s: if(no_key) state <= finish_s;
						  else if(key_update_finish) state <= task1_s;
			task1_s: if(task1_finish) state<=task2a_s;
			task2a_s: if(task2_finish) state<=task2b_s;
			task2b_s: if(task2b_finish) state<= task3_s;
			task3_s: if(found_key) state<=finish_s; 
					else if(task3_finish) state<=update_key_s;
			finish_s: if(~reset) state<=task1_s;
			default: state<=update_key_s;
		endcase
	end
	
	//select inputs for the memory
	always_comb begin
		case(state)
			task1_s: begin
					selected_address <= task1_address;
					selected_data <= task1_data;
					selected_wren <= task1_wren;
					selected_dmaddress<=0;
					selected_dmwren<=0;
					selected_dmdata<=0;
					end
		task2a_s: begin
					selected_address <= task2_address;
					selected_data <= task2_data;
					selected_wren <= task2_wren;
					selected_dmaddress<=0;
					selected_dmwren<=0;
					selected_dmdata<=0;
					end
		task2b_s: begin
					selected_address <= task2b_saddress;
					selected_data <= task2b_data;
					selected_wren <= task2b_swren;
					selected_dmaddress<=task2b_dmaddress;
					selected_dmwren<=task2b_dmwren;
					selected_dmdata<=task2b_data;
					end
		task3_s: begin
					selected_address <= 0;
					selected_data <= 0;
					selected_wren <= 0;
					selected_dmaddress<=task3_dmddress;
					selected_dmwren<=0;
					selected_dmdata<=0;
					end
		default: begin
					selected_address <= 0;
					selected_data <= 0;
					selected_wren <= 0;
					selected_dmaddress<=0;
					selected_dmwren<=0;
					selected_dmdata<=0;
				end
		endcase
	end
	
	
endmodule
