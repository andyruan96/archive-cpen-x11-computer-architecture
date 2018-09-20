
module memory (clk, loadpc, reset, C, msel, B, mwrite, loadir, mdata, eightnPC, out);
	input clk, loadpc, reset, msel, mwrite, loadir;
	input [15:0] B;
	input [7:0] C;
	output [15:0] mdata, out;
	output [15:0] eightnPC;

	wire[7:0] w1, w2, w3, w4, w5;
	
	assign w1 = w4 + 1'b1;
	assign eightnPC = {8'b0, w4};
	
	RAM #(16, 8) ram(.clk(clk), .read_address(w5), .write_address(w5), .write(mwrite), .din(B), .dout(mdata));
	
	register #(16) IR(.clk(clk), .in(mdata), .load(loadir), .out(out));
	vDFF #(8) PC(.clk(clk), .D(w3), .Q(w4));
	
	Mux #(8) mux0(.xin(w1), .yin(w4), .sel(loadpc), .out(w2));
	Mux #(8) mux1(.xin(8'b0), .yin(w2), .sel(reset), .out(w3));
	Mux #(8) mux2(.xin(C), .yin(w4), .sel(msel), .out(w5));
	
endmodule

module RAM (clk, read_address, write_address, write, din, dout);
	parameter data_width = 32;
	parameter addr_width = 4;
	parameter filename = "data.txt";
	
	input clk;
	input [addr_width-1:0] read_address, write_address;
	input write;
	input [data_width-1:0] din;
	output reg [data_width-1:0] dout;
	
	reg [data_width-1:0] mem [2**addr_width-1:0];
	
	initial $readmemb(filename, mem);
	
	always @(posedge clk) begin
		if (write)
			mem[write_address] <= din;
		dout <= mem[read_address];
	
	end
endmodule
