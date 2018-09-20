module task2_b(
	//input
	clock,
	start,
	s_in_data,
	in_encrypted_m,
	
	//output
	finish,
	out_data,
	s_wren,
	dm_wren,
	s_address,
	dm_address,
	em_address,

);

//input declaration
input logic clock;
input logic start;
input logic[7:0] s_in_data;
input logic[7:0] in_encrypted_m;

//output declaration
output logic finish;
output logic s_wren;
output logic dm_wren;
output logic[7:0] s_address;
output logic[7:0] dm_address;
output logic[7:0] em_address;
//output logic[7:0] out_decrypted_m;

//state encoding
localparam wait_s
localparam increment_i 
localparam send_si_address
localparam store_si
localparam calculate_j
localparam send_sj_address
localparam store_sj
localparam write_si
localparam wait_one_clock_writeI
localparam write_sj
localparam wait_one_clock_writeJ
localparam sum_si_sj
localparam send_f_address
localparam store_f
localparam xor_f_send_k
localparam wait_one_clock_writeDK
localparam increment_k
localparam finish_s

//internal wire declaration
reg[7:0] i;
reg[7:0] j;
logic[7:0] si;
logic[7:0] sj;
logic[7:0] f;
logic[7:0] sum_si_sj_address;
reg[4:0] k=0;
logic increment_k;
logic increment_i;
logic[7:0] decrypted_message;


//looping logic
logic k_end = 31;
reg k_loop = 0;

assign k_loop = (k==k_end)? k_loop+1 :k_loop;

counter k_address_counter(
				  .clk(increment_k),
				  .reset(0),
				  .q(k));

counter i_address_counter(
				  .clk(increment_i),
				  .reset(0),
				  .q(i));



//output logic

assign sum_si_sj_address = si + sj;
assign decrypted_message = f^in_encrypted_m;

always_comb begin
	case(state)
		send_si_address: begin
							finish<=0;
							out_data<=0;
							s_wren<=0;
							dm_wren<=0;
							s_address<=i;
							dm_address<=k;
							em_address<=k;
						end
		store_si:begin
							finish<=0;
							out_data<=0;
							s_wren<=0;
							dm_wren<=0;
							s_address<=i;
							dm_address<=k;
							em_address<=k;
						end
		send_sj_address:begin
							finish<=0;
							out_data<=0;
							s_wren<=0;
							dm_wren<=0;
							s_address<=j;
							dm_address<=k;
							em_address<=k;
						end
			store_sj:begin
							finish<=0;
							out_data<=0;
							s_wren<=0;
							dm_wren<=0;
							s_address<=j;
							dm_address<=k;
							em_address<=k;
						end
			write_si:begin
							finish<=0;
							out_data<=sj;
							s_wren<=1;
							dm_wren<=0;
							s_address<=i;
							dm_address<=k;
							em_address<=k;
						end
			wait_one_clock_writeI:begin
							finish<=0;
							out_data<=sj;
							s_wren<=1;
							dm_wren<=0;
							s_address<=i;
							dm_address<=k;
							em_address<=k;
						end
			write_sj:begin
							finish<=0;
							out_data<=si;
							s_wren<=1;
							dm_wren<=0;
							s_address<=j;
							dm_address<=k;
							em_address<=k;
						end
			wait_one_clock_writeJ:begin
							finish<=0;
							out_data<=si;
							s_wren<=1;
							dm_wren<=0;
							s_address<=j;
							dm_address<=k;
							em_address<=k;
						end
			send_f_address:begin
							finish<=0;
							out_data<=0;
							s_wren<=0;
							dm_wren<=0;
							s_address<=sum_si_sj_address;
							dm_address<=k;
							em_address<=k;
						end
			store_f:begin
							finish<=0;
							out_data<=0;
							s_wren<=0;
							dm_wren<=0;
							s_address<=sum_si_sj_address;
							dm_address<=k;
							em_address<=k;
						end
			xor_f_send_k:begin
							finish<=0;
							out_data<=decrypted_message;
							s_wren<=0;
							dm_wren<=0;
							s_address<=0;
							dm_address<=k;
							em_address<=k;
						end
			wait_one_clock_writeDK:begin
							finish<=0;
							out_data<=decrypted_message;
							s_wren<=0;
							dm_wren<=0;
							s_address<=0;
							dm_address<=k;
							em_address<=k;
						end		
	endcase
end

//state transition logic
always_ff@(posedge clock) begin
	case(state)
		wait_s : if(start) state<= increment_i;
		increment_i:if(start) state<=send_si_address;
		send_si_address	:if(start) state<=store_si;
		store_si	:if(start) begin
					state<=calculate_j;
					si<=s_in_data;
					end
		calculate_j	:if(start) state<=send_sj_address;
		send_sj_address	:if(start) begin
						state<=store_sj;
						j<= j + si;
						end
		store_sj	:if(start) begin 
								state<= write_si;
								sj<=s_in_data;
							end
		write_si	:if(start) state<= wait_one_clock_writeI;
		wait_one_clock_writeI	:if(start) state<=write_sj;
		write_sj:    if(start) state<= wait_one_clock_writeJ;
		wait_one_clock_writeJ: state<= sum_si_sj;
		sum_si_sj	:if(start) state<=send_f_address;
		send_f_address	:if(start) state<=store_f;
		store_f		:if(start) begin 
						state<=xor_f_send_k;
						f<=s_in_data;
					end
		xor_f_send_k	:if(start) state<=wait_one_clock_writeDK;
		wait_one_clock_writeDK		:if(start) state<=increment_k;
		increment_k		:if(start & ~loop) state<=increment_i;
						else state<=finish_s;
		default: state<=wait_s;
	endcase
end


endmodule