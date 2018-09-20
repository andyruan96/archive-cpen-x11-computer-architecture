module task1(
 //input
 start,
 clock,
 reset,
 //output
 finished,
 address,
 wren,
 data
);
	
		//input
	input logic start;
	input logic clock;
	input logic reset;
	
	//output
	output logic[7:0] address;
	output logic[7:0] data;
	output logic finished;
	output logic wren;
	
	//internal wires
	reg finished_reg=0;

	logic[7:0] count = 255;
	logic[7:0] i;
	logic increment_i;
	logic[3:0] state;
	
	assign increment_i = state[2];
				  
	counter address_counter(
				  .clk(increment_i),
				  .reset(reset),
				  .q(i));
	
	//state encoding
	localparam wait_s  				 = 4'b0000;
	localparam send_address_data	 = 4'b0001;
	localparam wait_one_oclock		 = 4'b0010;
	localparam update_address_data   = 4'b0100;
	localparam finish_s				 = 4'b1000;
	
	//output logic
	always_comb begin
		case(state)
			send_address_data: begin
								finished <=0;
								wren <= 1;
								address <= i;
								data <= i;
								end
			wait_one_oclock: begin
								finished <=0;
								wren <= 1;
								address <= i;
								data <= i;
								end
			finish_s: 			begin
								finished <=1;
								wren <= 0;
								address <= 0;
								data <= 0;
								end
			default:		 begin
								finished <=0;
								wren <= 0;
								address <= 0;
								data <= 0;
								end
		endcase
	end
	
	//state transition
	always_ff @(posedge clock) begin
		case(state)
			wait_s: if(start) state<=send_address_data;
			send_address_data:if(start) state<=wait_one_oclock;
			wait_one_oclock: if(i<count&start) state<=update_address_data;
							 else state<= finish_s;
			update_address_data:if(start) state<=send_address_data;
			finish_s:if(reset)state<=wait_s;
			default: state<= wait_s;
		endcase
	end
	
	
				  
endmodule

