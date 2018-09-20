
module homework1 (vcc, async_sg, outclk, clr, out_sync_sg);
	input logic vcc, async_sg, outclk, clr;
	output logic out_sync_sg;
	logic q0, q1, q2, q3;
	
	assign out_sync_sg = q2;
	
	fdc fdc0(.d(vcc), .clk(async_sg), .clr(q3), .q(q0));
	fdc fdc1(.d(q0), .clk(outclk), .clr(clr), .q(q1));
	fdc fdc2(.d(q1), .clk(outclk), .clr(clr), .q(q2));
	fdc fdc_1(.d(q2), .clk(outclk), .clr(clr), .q(q3));
endmodule


module fdc(d, clk, clr, q);
	input logic d, clk, clr;
	output logic q;
	
	always_ff @(posedge clk or posedge clr)
		if(clr) q <= 0;
		else q <= d;
		
endmodule
