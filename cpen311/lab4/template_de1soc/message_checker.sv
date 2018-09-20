module message_checker(
	//input
	clk, 
	start, 
	reset, 
	indata, 
	//output
	out_addr, 
	update_key, 
	found, 
	finish
);

//input declaration

input logic clk;
input logic reset;
input logic start;
input logic[7:0] indata;

//output declaration
output logic[4:0] out_addr;
output logic update_key;
output logic found;
output logic finish;

//state encoding
localparam wait_s				= 6'b000000;
localparam send_address			= 6'b000001;
localparam verify_data			= 6'b000010;
localparam increment_address	= 6'b000100;
localparam increment_key		= 6'b001000;
localparam finish_s				= 6'b010000;
localparam found_s				= 6'b100000;

//internal wire

logic[5:0] state;
reg[4:0] address = 0;

//output logic 
always_comb begin
	case(state)
		increment_key:begin
						found <=0;
						out_addr<=address;
						finish<=0;
						update_key<=1;
					  end
		finish_s: begin
						found <=0;
						out_addr<=address;
						finish<=1;
						update_key<=0;
					  end
		default: begin
						found <=0;
						out_addr<=address;
						finish<=0;
						update_key<=0;
					  end
	endcase
end	

counter address_counter(
				  .clk(state[2]),
				  .reset(reset),
				  .q(address));


//state transition

always_ff@(posedge clk) begin
	case(state)
		wait_s: if(start) state <= send_address;
		send_address: if(start) state <= verify_data;
		verify_data: if(start) begin
					if((indata >= 97 && indata <= 122) || indata == 32) begin
					if(address < 31) state <= increment_address;
					else state <= found_s;
					end else state <= increment_key;
					end
		increment_address: if(start) state <= send_address;
		increment_key: if(start) state<=finish_s;
		finish_s: if(reset) state<=wait_s;
		default: state <= wait_s;
	endcase
end

endmodule