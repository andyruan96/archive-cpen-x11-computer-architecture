/*
 * Sends the most significant 8 bits of each half of the 32 bits of indata to outdata before sending a finish bit.
 *
 * Inputs:
 * indata: 32 bits of audio data
 * clk: Sampling rate of song
 *
 * Outputs:
 * outdata: 8 bits to be sent to audio DAC
 * finish: bit represents when current indata is ready to be changed
 *
 * Note: Module which reads data for indata should have a faster clock
 * than this module and only detect the rising edge of the finish bit.
 */
module Audio_FSM(indata, outdata, finish, clk);
	
	// state encodings
	localparam SEND_FIRST = 3'b000;
	localparam SEND_SECOND = 3'b111;
	
	input logic [31:0] indata;
	input logic clk;
	
	output logic[7:0] outdata;
	output logic finish;
	
	
	logic[15:0] audio_data;
	logic reg_clk;
	logic[7:0] reg_audio_data;
	logic[2:0] state;
	
	assign audio_data = {indata[31:23], indata[7:0]};
	assign reg_clk =  ~state[1];
	assign finish = state[0];
	
	widereg #(.width(8)) audioSecondPartReg( .indata(audio_data[7:0]), .outdata(reg_audio_data), .inclk(reg_clk) );
	
	always_ff @(posedge clk)
		case(state)
			SEND_FIRST: state <= SEND_SECOND;
			SEND_SECOND: state <= SEND_FIRST;
		endcase
	
	assign outdata = state[2] ? audio_data[15:7] : reg_audio_data;
	
endmodule
