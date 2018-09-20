module task2(
	//input
	secret_key,
	encrypted_mes_slice,
	processing_mes_slice,
	
	//output
	encrypted_mes_adr,
	working_mes_adr,
	working_data,
	wmr_trigger,
	decrypted_adr,
	decrypted_data,
	dmr_trigger
);
	
	//input declaration
	input logic [23:0] secret_key;
	input logic [31:0] encrypted_mes_slice;
	input logic [31:0] processing_mes_slice;
	
	//output declaration
	output logic[2:0] encrypted_mes_adr;
	output logic[2:0] working_mes_adr;
	output logic[2:0] decrypted_adr;
	output logic[31:0] working_data;
	output logic[31:0]decrypted_data;
	output logic wmr_trigger;
	output logic dmr_trigger;
	
	//internal wires
	
	

endmodule