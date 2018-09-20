
module memory (clk, reset, C, msel, B, mwrite, loadir, mdata, eightnPC, incp, sximm8, A, tsel, execb, status, cond, irout);
	input clk, reset, msel, mwrite, loadir, incp, tsel;
	input [1:0] execb;
	input [15:0] B;
	input [7:0] A, C, sximm8;
	input [2:0] status, cond;
	output [15:0] mdata, irout;
	output [15:0] eightnPC;

	wire[7:0] w1, w2, w3, w4, w5, pc_next, pctgt, pcrel;
	
	// Lab 7 changes
	wire loadpc, taken;
	assign loadpc = taken | incp;
	assign pcrel = sximm8 + w4;
	
	assign w1 = w4 + 1'b1;
	assign eightnPC = {8'b0, w4};
	
	RAM #(16, 8) ram(.clk(clk), .read_address(w5), .write_address(w5), .write(mwrite), .din(B), .dout(mdata));
	
	register #(16) IR(.clk(clk), .in(mdata), .load(loadir), .out(irout));
	vDFF #(8) PC(.clk(clk), .D(w3), .Q(w4));
	branchUnit bunit (.execb(execb), .status(status), .cond(cond), .taken(taken));
	
	Mux #(8) lab7a (.xin(pcrel), .yin(A), .sel(tsel), .out(pctgt));
	Mux #(8) lab7b (.xin(w1), .yin(pctgt), .sel(incp), .out(pc_next));
	Mux #(8) mux0(.xin(pc_next), .yin(w4), .sel(loadpc), .out(w2));
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

module branchUnit(execb, status, cond, taken);
  input [1:0] execb;
  input [2:0] status, cond;
  output taken;
  reg tf;

  `define B 3'b000
  `define BEQ 3'b001
  `define BNE 3'b010
  `define BLT 3'b011
  `define BLE 3'b100

  assign taken = execb[1] | (execb[0] & tf);
  always @(*)begin
    case(cond)
      `B: tf = 1'b1;
      `BEQ: tf = status[2]; 
      `BNE: tf = ~status[2];
      `BLT: tf = status[1];
      `BLE: tf = status[1] | status[2];
    endcase
  end
endmodule
