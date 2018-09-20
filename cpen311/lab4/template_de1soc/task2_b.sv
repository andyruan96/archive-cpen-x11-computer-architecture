module task2_b(
	//input
	clock,
	start,
	reset,
	s_in_data,
	in_encrypted_m,
	
	//output
	finish,
	out_data,
	s_wren,
	dm_wren,
	s_address,
	dm_address,
	em_address

);

//input declaration
input logic clock;
input logic start;
input logic reset;
input logic[7:0] s_in_data;
input logic[7:0] in_encrypted_m;

//output declaration
output logic finish;
output logic s_wren;
output logic dm_wren;
output logic[7:0] out_data;
output logic[7:0] s_address;
output logic[4:0] dm_address;
output logic[4:0] em_address;

//state encoding
localparam wait_s = 						17'b00000_00000_00000_00;
localparam increment_i =					17'b00000_00000_00000_01;
localparam send_si_address=					17'b00000_00000_00000_10;
localparam store_si=						17'b00000_00000_00001_00;
localparam calculate_j=						17'b00000_00000_00010_00;
localparam send_sj_address=					17'b00000_00000_00100_00;
localparam store_sj=						17'b00000_00000_01000_00;
localparam write_si=						17'b00000_00000_10000_00;
localparam wait_one_clock_writeI=			17'b00000_00001_00000_00;
localparam write_sj=						17'b00000_00010_00000_00;
localparam wait_one_clock_writeJ=			17'b00000_00100_00000_00;
localparam sum_si_sj=						17'b00000_01000_00000_00;
localparam send_f_address=					17'b00000_10000_00000_00;
localparam store_f=							17'b00001_00000_00000_00;
localparam xor_f_send_k=					17'b00010_00000_00000_00;
localparam wait_one_clock_writeDK=			17'b00100_00000_00000_00;
localparam increment_k=						17'b01000_00000_00000_00;
localparam finish_s=						17'b10000_00000_00000_00;

//internal wire declaration
logic[16:0] state;
reg[7:0] i=0;
reg[7:0] j=0;
logic[7:0] si;
logic[7:0] sj;
logic[7:0] f;
logic[7:0] sum_si_sj_address;
reg[4:0] k=0;
logic increment_k_bit;
logic increment_i_bit;
logic[7:0] decrypted_message;
logic[7:0] in_encrypted_m_reg;


//looping logic
logic [4:0]k_end = 31;
//reg k_loop = 0;

assign increment_i_bit = state[0];
assign increment_k_bit = state[15];
//assign k_loop = (k==k_end)? k_loop+1 :k_loop;

counter k_address_counter(
				  .clk(increment_k_bit),
				  .reset(reset),
				  .q(k));

counter i_address_counter(
				  .clk(increment_i_bit),
				  .reset(reset),
				  .q(i));



//output logic
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
							dm_wren<=1;
							s_address<=0;
							dm_address<=k;
							em_address<=k;
						end
			wait_one_clock_writeDK:begin
							finish<=0;
							out_data<=decrypted_message;
							s_wren<=0;
							dm_wren<=1;
							s_address<=0;
							dm_address<=k;
							em_address<=k;
						end
			finish_s:begin
							finish<=1;
							out_data<=0;
							s_wren<=0;
							dm_wren<=0;
							s_address<=0;
							dm_address<=0;
							em_address<=0;
						end
				default:	begin
							finish<=0;
							out_data<=0;
							s_wren<=0;
							dm_wren<=0;
							s_address<=0;
							dm_address<=k;
							em_address<=k;
				end
	endcase
end

always_ff@(posedge clock) begin
	case(state)
		wait_s : if(start) state<= increment_i;
		increment_i:if(start)state<=send_si_address;
		send_si_address	:if(start) state<=store_si;
		store_si	:if(start) begin
					state<=calculate_j;
					si<=s_in_data;
					in_encrypted_m_reg<=in_encrypted_m;
					end
		calculate_j	:if(start)begin 
					state<=send_sj_address;
					j <= j + si;
					end
		send_sj_address	:if(start)state<=store_sj;
		store_sj	:if(start) begin 
								state<= write_si;
								sj<=s_in_data;
							end
		write_si	:if(start)state<= wait_one_clock_writeI;
		wait_one_clock_writeI	:if(start)state<=write_sj;
		write_sj: if(start)   state<= wait_one_clock_writeJ;
		wait_one_clock_writeJ:if(start) state<= sum_si_sj;
		sum_si_sj	:if(start) begin
						state<=send_f_address;
						sum_si_sj_address = si + sj;
						end
		send_f_address	:if(start)state<=store_f;
		store_f		:if(start)begin 
						state<=xor_f_send_k;
						f<=s_in_data;
					end
		xor_f_send_k	:if(start) begin
						state<=wait_one_clock_writeDK;
						decrypted_message <= f^in_encrypted_m_reg;
						end
		wait_one_clock_writeDK		:if( k<k_end & start ) state<=increment_k;
										else state<=finish_s;
		increment_k		:if(start)state<=increment_i;
		finish_s: if(reset) begin
							state<=wait_s;
							j<=0;
							end
		default: state<=wait_s;
	endcase
end

endmodule