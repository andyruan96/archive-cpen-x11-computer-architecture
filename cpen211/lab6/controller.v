
module controller (clk, reset, opcode, op, nsel, loadpc, loadir, msel, mwrite, datapathSet);
	`define IDLE 4'd0
	`define LOADIR 4'd1
	`define UPDATEPC 4'd2
	`define DECODE 4'd3
	`define WRITE 4'd4
	`define ALULOADRN 4'd5
	`define ALU 4'd6
	`define MOVLOADC 4'd7
	`define MEMLOADC 4'd8
	`define MEMSPLIT 4'd9
	`define LDR 4'd10
	`define STR 4'd11
	`define FIRSTIR 4'd12
	`define LDR0 4'd13
	`define PRELOADIR 4'd14
	
	input clk, reset;
	input [2:0] opcode;
	input [1:0] op;
	
	output loadpc, loadir, msel, mwrite;
	output reg [2:0] nsel; // one hot back to Decoder Block
	output reg [8:0] datapathSet; // {vsel[8:7], write, loada, loadb, asel, bsel, loadc, loads}
	
	wire [3:0] presentState;
	reg [3:0] nextState;
	
	reg [3:0] pcRamSet; // {loadpc, loadir, msel, mwrite}
	assign loadpc = pcRamSet[3];
	assign loadir = pcRamSet[2];
	assign msel = pcRamSet[1];
	assign mwrite = pcRamSet[0];
	
	vDFF #(4) controllerDFF(.clk(clk), .D(nextState), .Q(presentState));
	
	always @(*) begin
		casex({presentState, opcode, op, reset})

			{`IDLE, 5'bx, 1'b0} : {nextState, pcRamSet, datapathSet, nsel} = {`IDLE, 16'b0}; // Before reset
			{`IDLE, 5'bx, 1'b1} : {nextState, pcRamSet, datapathSet, nsel} = {`FIRSTIR, 16'b0}; // LOADIR after reset is pressed
			{`FIRSTIR, 6'bx} : {nextState, pcRamSet, datapathSet, nsel} = {`LOADIR, 4'b0100, 12'b0};
			//{`FIRSTPC, 6'bx} : {nextState, pcRamSet, datapathSet, nsel} = {`LOADIR, 4'b1000, 12'bx};
			{`LOADIR, 6'bx} : {nextState, pcRamSet, datapathSet, nsel} = {`UPDATEPC, 4'b0100, 12'b0}; // Load IR
			{`UPDATEPC, 6'bx} : {nextState, pcRamSet, datapathSet, nsel} = {`DECODE, 4'b1000, 12'b0}; // Update PC
			
			// MOV Rn, #<imm8>
			{`DECODE, 6'b11010x} : {nextState, pcRamSet, datapathSet, nsel} = {`LOADIR, 4'b0, 9'b011000000, 3'b001}; // sximm8 -> R[Rn]
			//{`WRITE, 6'bx} : {nextState, pcRamSet, datapathSet, nsel} = {`LOADIR, 4'b0, 9'b011xxxxxx, 3'b001}; // write mdata into Rn
			
			// MOV Rd,Rm{,<sh_op>}
			{`DECODE, 6'b11000x} : {nextState, pcRamSet, datapathSet, nsel} = {`MOVLOADC, 4'b0, 9'b000010000, 3'b100}; // Rm -> B
			{`MOVLOADC, 6'bx} : {nextState, pcRamSet, datapathSet, nsel} = {`WRITE, 4'b0, 9'b000000010, 3'b100}; // shifted B -> C
			{`WRITE, 6'b11000x} : {nextState, pcRamSet, datapathSet, nsel} = {`LOADIR, 4'b0, 9'b111000000, 3'b010}; // C -> R[Rd]
			
			// ALU
			{`DECODE, 6'b101xxx} : {nextState, pcRamSet, datapathSet, nsel} = {`ALULOADRN, 4'b0, 9'b000010000, 3'b100}; // R[Rm] -> B
			{`ALULOADRN, 6'bx} : {nextState, pcRamSet, datapathSet, nsel} = {`ALU, 4'b0, 9'b000100000, 3'b001}; // R[Rn] -> A
			{`ALU, 6'b10100x} : {nextState, pcRamSet, datapathSet, nsel} = {`WRITE, 4'b0, 9'b000000010, 3'b001}; // ADD: A + shB -> C
			{`ALU, 6'b10101x} : {nextState, pcRamSet, datapathSet, nsel} = {`LOADIR, 4'b0, 9'b000000001, 3'b001}; // CMP: f(A - shB) -> status
			{`ALU, 6'b10110x} : {nextState, pcRamSet, datapathSet, nsel} = {`WRITE, 4'b0, 9'b000000010, 3'b001}; // AND: A & shB -> C
			{`ALU, 6'b10111x} : {nextState, pcRamSet, datapathSet, nsel} = {`WRITE, 4'b0, 9'b000001010, 3'b001}; // MVN: ~shB -> C
			{`WRITE, 6'b101xxx} : {nextState, pcRamSet, datapathSet, nsel} = {`LOADIR, 4'b0000, 9'b111000000, 3'b010}; // C -> R[Rd]
			
			// LDR Rd, [Rn{,#<imm5>}] start
			{`DECODE, 6'b01100x} : {nextState, pcRamSet, datapathSet, nsel} = {`MEMLOADC, 4'b0000, 9'b000100000, 3'b001}; // R[Rn] -> A
			// STR Rd, [RN{,#<imm5>}] start
			{`DECODE, 6'b10000x} : {nextState, pcRamSet, datapathSet, nsel} = {`MEMLOADC, 4'b0000, 9'b000100000, 3'b001}; // R[Rn] -> A
			// Load C
			{`MEMLOADC, 6'bx} : {nextState, pcRamSet, datapathSet, nsel} = {`MEMSPLIT, 4'b0000, 9'b000000110, 3'b001}; // A + sximm5 -> C
			
			// LDR
			{`MEMSPLIT, 6'b01100x} : {nextState, pcRamSet, datapathSet, nsel} = {`LDR, 4'b0010, 9'b0, 3'b001}; // msel = 1
			{`LDR, 6'b01100x} : {nextState, pcRamSet, datapathSet, nsel} = {`LOADIR, 4'b0, 9'b001000000, 3'b010}; // mdata -> R[Rd], msel = 0
			// STR
			{`MEMSPLIT, 6'b10000x} : {nextState, pcRamSet, datapathSet, nsel} = {`STR, 4'b0010, 9'b000010000, 3'b010}; // R[Rd] -> B
			{`STR, 6'bx} : {nextState, pcRamSet, datapathSet, nsel} = {`PRELOADIR, 4'b0011, 9'b0, 3'b010}; // B -> MEM
			{`PRELOADIR, 6'bx} : {nextState, pcRamSet, datapathSet, nsel} = {`LOADIR, 4'b0000, 9'b0, 3'b010}; // update mdata
			
			default: nextState = `IDLE; // Before reset is pressed
		endcase
	end
endmodule

