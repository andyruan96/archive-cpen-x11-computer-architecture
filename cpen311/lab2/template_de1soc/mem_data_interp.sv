/*
	this module is the fsm communication interface among
	data_address_fsm, kbd_inteface, flash module and audio output
	//input 
	clk_50M: 50M Hz clock
	play_clk: 22KHz clock
	wait_request: check if need to wait for the data to be ready
	data_valid: check if the data valid
	pause: if the user pause
	mem_data: data returned by flash
	mem_updated: indicate an updated mem address
	
	//output
	mem_update_enable : prompt the flash unit to update mem address
	audio_data_out: audio output
	flash_read: prompt the flash to read data
	debug_state: for simulation debug
*/
module mem_interp_fsm(
	//input 
	clk_50M,
	play_clk,
	wait_request,
	data_valid,
	pause,
	mem_data,
	mem_updated,
	
	//output
	mem_update_enable,
	audio_data_out,
	flash_read,
	debug_state
);	

	//external input port
	input logic clk_50M, play_clk;
	input logic data_valid;      
	input logic pause;
	input logic mem_updated;
	input logic wait_request;
	input logic[31:0] mem_data;
	
	//external output port
	output logic[7:0] audio_data_out;
	output logic mem_update_enable;
	output logic flash_read;
	
	//internal wire
	logic [11:0] current_state;
	logic [7:0] audio_reg;
	logic played;
	logic reset_play;
	output logic[11:0] debug_state;
	
	//for simulation debug
	assign debug_state = current_state;
	
	//state encoding
	localparam       idle = 12'b0000000_00000;
	localparam wait_data1 = 12'b0000001_10000;
	localparam read_data1 = 12'b0000010_11000;
	localparam send_data1 = 12'b0000100_10101;
	localparam wait_data2 = 12'b0001000_10000;
	localparam read_data2 = 12'b0010000_11000;
	localparam send_data2 = 12'b0100000_10101;
	localparam update_addr= 12'b1000000_10010;
	
	
	//output logic
	//glitch free argument: all the direct outputs only depend on one state bit
	//or the outputs are registered
	assign mem_update_enable = current_state[1];
	assign flash_read = current_state[4];
	assign reset_play = current_state[3];
	
	always_comb begin
		case(current_state)
			read_data1: begin 
						audio_reg <= mem_data[15:8];
						end
			send_data1: begin 
						audio_reg <= mem_data[15:8];
						end
			read_data2: begin
						audio_reg <= mem_data[31:24];
						end
			send_data2:	begin 
						audio_reg<=mem_data[31:24];
						end
			update_addr: begin 
						audio_reg <=0;
						end
			default: begin
					  audio_reg<=0;
					end
		endcase
	end
	
	//audio output
	always_ff @(posedge play_clk or posedge reset_play) begin
		if(reset_play) begin
			played<=0;
		end else begin
			played <= 1;
			audio_data_out <= audio_reg;
		end
	end
	
	
	//state transition logic
	always_ff @(posedge clk_50M) begin
		case(current_state)

			idle: current_state <= wait_data1;
	  wait_data1:  if(~wait_request & pause)begin
						current_state <= read_data1;
					end 	
	  read_data1:  if(data_valid & pause)begin
						current_state <= send_data1;
						end 
      send_data1:  if(played & pause) begin
						current_state <= read_data2;
						end
		wait_data2:  if(~wait_request & pause)begin
						current_state <= read_data2;
					end
	  read_data2: if(data_valid & pause)begin
					current_state <= send_data2;
					end
	  send_data2: if(played & pause) begin
					current_state <= update_addr;
					end
	 update_addr: if(mem_updated & pause) begin
				current_state <= wait_data1;
				end
	default: current_state <= idle;
	endcase
	end
		
endmodule
