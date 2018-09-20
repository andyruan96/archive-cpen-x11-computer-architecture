
module key_gen(update_key, reset, full_key, ovf);
	
	input logic update_key, reset;
	output logic ovf;
	output logic [9:0] full_key;
	
	reg[7:0] curr_key = 7'b0;
	assign full_key = {2'b0, curr_key};
	
	always_ff @(posedge update_key, posedge reset)
		if(reset) begin
			ovf <= 0;
			curr_key <= 0;
		end
		else if(curr_key == 127) ovf <= 1; 
		else curr_key <= curr_key + 1;
		
endmodule
