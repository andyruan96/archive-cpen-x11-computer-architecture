// k-bit shifter
// shift | Operation
// 	00	| no change
// 	01	| shifted 1-bit left
// 	10	| shifted 1-bit right
// 	11 | shifted 1-bit right, MSB is copy of B[15]
module shifter (in, shift, out);
	parameter k = 1;
	input [k-1:0] in;
	input [1:0] shift;
	output reg [k-1:0] out;

	always @(*) begin
		case(shift)
			2'b00: out = in;
			2'b01: out = in << 1;
			2'b10: out = in >> 1;
			2'b11: begin 
						out = in >> 1;
						out[k-1] = out[k-2];
			end
		endcase
	end
endmodule
