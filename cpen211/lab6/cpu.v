
module cpu (clk, reset, r0out, r1out, r2out, r3out, r4out, r5out);
	input clk, reset;
	output [15:0] r0out, r1out, r2out, r3out, r4out, r5out; // FOR TESTING ON DE1-SOC
	
	// FSM Outputs
	wire [8:0] datapathSet;
	wire [2:0]	nsel;
	wire loadpc, loadir, msel, mwrite;
	
	// IDecoder Outputs
	wire [15:0] sximm8, sximm5;
	wire [2:0] opcode, writenum, readnum;
	wire [1:0] op, shift, ALUop;
	
	
	// PCRAM Outputs
	wire [15:0] mdata, eightnPC, toID;
	
	// Datapath Outputs
	wire [15:0] Bout, Cout;
	wire [2:0] Sout;
	
	controller controllerFSM (
		.clk(clk),
		.reset(reset), 
		.opcode(opcode), 
		.op(op), 
		.nsel(nsel), 
		.loadpc(loadpc), 
		.loadir(loadir), 
		.msel(msel), 
		.mwrite(mwrite), 
		.datapathSet(datapathSet)
	);
	
	datapath datapath (
		.mdata(mdata), 
		.sximm8(sximm8), 
		.eightnPC(eightnPC), 
		.vsel(datapathSet[8:7]), 
		.writenum(writenum), 
		.write(datapathSet[6]), 
		.readnum(readnum), 
		.clk(clk), 
		.loada(datapathSet[5]), 
		.loadb(datapathSet[4]), 
		.shift(shift), 
		.six16(16'b0), 
		.sximm5(sximm5), 
		.asel(datapathSet[3]), 
		.bsel(datapathSet[2]), 
		.ALUop(ALUop), 
		.loadc(datapathSet[1]), 
		.loads(datapathSet[0]), 
		.B(Bout),
		.C(Cout),
		.S(Sout),
		.r0out(r0out),
		.r1out(r1out),
		.r2out(r2out),
		.r3out(r3out),
		.r4out(r4out),
		.r5out(r5out)
	);
	
	memory pcram (
		.clk(clk), 
		.loadpc(loadpc), 
		.reset(reset), 
		.B(Bout),
		.C(Cout[7:0]), 
		.msel(msel), 
		.mwrite(mwrite), 
		.loadir(loadir), 
		.mdata(mdata), 
		.eightnPC(eightnPC), 
		.out(toID)
	);
	
	intructionDecoder instrucDecoder (
		.wIR(toID), 
		.nsel(nsel), 
		.opcode(opcode), 
		.op(op), 
		.ALUop(ALUop), 
		.sximm5(sximm5), 
		.sximm8(sximm8), 
		.shift(shift), 
		.readnum(readnum), 
		.writenum(writenum)
	);

endmodule
