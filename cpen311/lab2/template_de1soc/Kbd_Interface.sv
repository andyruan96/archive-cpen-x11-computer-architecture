/*
 * FSM which allows control of mem_data_interp and mem_address_update inputs through keyboard inputs.
 * Inputs: 
 *		interface_clk: Input clock to FSM
 *		ascii_key_in: ascii key code of current keyboard input
 * Output:
 * 		control_wires: Output bits to be wired to mem_data_interp and mem_address_update inputs
 */
module Kbd_Interface(interface_clk,kbd_data_ready, reseted, ascii_key_in, control_wires,mem_addr_reset);
	// key_codes
	localparam [7:0] KEY_E = 8'h45;
	localparam [7:0] KEY_R = 8'h52;
	localparam [7:0] KEY_D = 8'h44;
	localparam [7:0] KEY_F = 8'h46;
	localparam [7:0] KEY_B = 8'h42;
	localparam [7:0] KEY_P = 8'h50;
	
	// states
	localparam[3:0] PAUSEFOR = 	4'b0000;
	localparam[3:0] PLAYFOR =	4'b0001;
	localparam[3:0] PAUSEBAC = 	4'b0010;
	localparam[3:0] PLAYBAC = 	4'b0011;
	
	//bonus
	localparam[3:0] RESET =		4'b0100;
	localparam[3:0] SONG  =     4'b1000;
	
	//last mem address for the song
	localparam last_address = 524287;
	
	input logic interface_clk;
	input logic[7:0] ascii_key_in;
	input logic reseted;
	input logic kbd_data_ready;
	
	output logic[22:0] mem_addr_reset;
	output logic[3:0] control_wires;
	
	logic[3:0] state;					// 0 / 1
	logic[3:0] pre_state;
	logic[3:0] control_wires_reg;
	
	assign control_wires[3] = state[3];  //select song
	assign control_wires[2] = state[2]; // reset
	assign control_wires[1] = state[1]; // forward/backward
	assign control_wires[0] = state[0]; // pause/play
	
	always_ff @(posedge interface_clk or posedge reseted) begin
		if(reseted) state <= pre_state; 
		else if(kbd_data_ready) begin 
		case(state)
			PLAYBAC: begin
				if(ascii_key_in === KEY_D) state <= PAUSEBAC;
				else if (ascii_key_in === KEY_F) state <= PLAYFOR;
				else if (ascii_key_in === KEY_R) begin
					state<= RESET;
					pre_state<=PLAYBAC;
					mem_addr_reset <= last_address;
				end else if (ascii_key_in === KEY_P) state <= SONG;
				else state <= PLAYBAC;
				end
			PAUSEBAC: begin
				if(ascii_key_in === KEY_E) state <= PLAYBAC;
				else if (ascii_key_in === KEY_F) state <= PAUSEFOR;
				else if (ascii_key_in === KEY_R) begin
					state<= RESET;
					pre_state<=PAUSEBAC;
					mem_addr_reset <= last_address;
				end else if (ascii_key_in === KEY_P) state <= SONG;
				else state <= PAUSEBAC;
			end
			PLAYFOR: begin
				if(ascii_key_in === KEY_D) state <= PAUSEFOR;
				else if (ascii_key_in === KEY_B) state <= PLAYBAC;
				else if (ascii_key_in === KEY_R) begin
					state<= RESET;
					pre_state<=PLAYFOR;
					mem_addr_reset <= 0; //start address
				end else if (ascii_key_in === KEY_P) state <= SONG;
				else state <= PLAYFOR;
			end
			PAUSEFOR: begin
				if(ascii_key_in === KEY_E) state <= PLAYFOR;
				else if(ascii_key_in === KEY_D) state <= PAUSEFOR;
				else if (ascii_key_in === KEY_B) state <= PAUSEBAC;
				else if (ascii_key_in === KEY_R) begin
					state<= RESET;
					pre_state<=PAUSEFOR;
					mem_addr_reset <= 0; //start address
				end else if (ascii_key_in === KEY_P) state <= SONG;
				else state <= PAUSEFOR;
			end
			RESET: state <= pre_state;
			SONG: begin
				if(ascii_key_in === KEY_E) state <= PLAYFOR;
				else if (ascii_key_in === KEY_B) state <= PAUSEBAC;
				else if (ascii_key_in === KEY_F) state <= PAUSEFOR;
				else if (ascii_key_in === KEY_R) begin
					state<= RESET;
					pre_state<=SONG;
				end else if (ascii_key_in === KEY_P) state <= SONG;
				end
			default: state <= PAUSEFOR;
		endcase
		end
	end
endmodule