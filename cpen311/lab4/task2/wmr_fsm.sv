module wmr_fsm(
	//input 
	start,
	wren,
	write_data,
	address,
	clk,
	
	//output
	finish,
	out_address,
	out_wren,
	out_write_data
);


//input declaration
input logic start;
input logic clk;
input logic wren;
input logic[31:0] write_data;
input logic[2:0] address;

//output declaration
output logic finish;
output logic out_wren;
output logic[31:0] out_write_data;
output logic[2:0] out_address;


//internal wire
logic[2:0] state;

//state encoding
localparam wait = 3'b00_0;
localparam read = 3'b01_1;
localparam write = 3'b10_1;

//output logic
assign finish = state[0];


//state transition logic
always_ff @(posedge clk) begin
	case(state)
		wait: if(start & wren) begin
				state <= write;
			   end else if (start & ~wren)
			    state <= read;
	 	read: if(~start) state <= wait;
	 	write: if(~start) state <= wait;
	 	default: state <= wait;
	 endcase
end
endmodule