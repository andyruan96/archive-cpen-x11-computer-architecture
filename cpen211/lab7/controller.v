
module controller (clk, reset, opcode, op, nsel, loadpc, loadir, msel, mwrite, tsel, execb, datapathSet);
	`define IDLE 5'd0
	`define LOADIR 5'd1
	`define UPDATEPC 5'd2
	`define DECODE 5'd3
	`define WRITE 5'd4
	`define ALULOADRN 5'd5
	`define ALU 5'd6
	`define MOVLOADC 5'd7
	`define MEMLOADC 5'd8
	`define MEMSPLIT 5'd9
	`define LDR 5'd10
	`define STR 5'd11
	`define FIRSTIR 5'd12
	`define UPDATEMDATA 5'd13
	`define BL 5'd15
	`define BX 5'd16
	`define BLX1 5'd17
	`define BLX2 5'd18
	
	
	input clk, reset;
	input [2:0] opcode;
	input [1:0] op;
	
	output loadpc, loadir, msel, mwrite;
	output reg [2:0] nsel; // one hot back to Decoder Block
	output reg [8:0] datapathSet; // {vsel[8:7], write, loada, loadb, asel, bsel, loadc, loads}
	output reg [1:0] execb;
	output reg tsel;
	
	wire [4:0] presentState;
	reg [4:0] nextState;
	
	reg [3:0] pcRamSet; // {loadpc, loadir, msel, mwrite}
	assign loadpc = pcRamSet[3];
	assign loadir = pcRamSet[2];
	assign msel = pcRamSet[1];
	assign mwrite = pcRamSet[0];
	
	vDFF #(5) controllerDFF(.clk(clk), .D(nextState), .Q(presentState));
	
	always @(*) begin
		casex({presentState, opcode, op, reset})

			// Before first reset
			{`IDLE, 5'bx, 1'b0} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`IDLE, 19'b0}; // Before reset
			{`IDLE, 5'bx, 1'b1} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`FIRSTIR, 19'b0}; // Start after reset is pressed
			{`FIRSTIR, 6'bx} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`LOADIR, 4'b0100, 15'b0}; // mdata available
			
			// First steps for all instructions
			{`LOADIR, 6'bx} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`UPDATEPC, 4'b0100, 15'b0}; // mdata -> IR
			{`UPDATEPC, 6'bx} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`DECODE, 4'b1000, 15'b0}; // Update PC
			
			// MOV Rn, #<imm8>
			{`DECODE, 6'b11010x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`LOADIR, 4'b0, 9'b011000000, 3'b001, 3'b0}; // sximm8 -> R[Rn]
			
			// MOV Rd,Rm{,<sh_op>}
			{`DECODE, 6'b11000x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`MOVLOADC, 4'b0, 9'b000010000, 3'b100, 3'b0}; // Rm -> B
			{`MOVLOADC, 6'bx} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`WRITE, 4'b0, 9'b000001010, 3'b100, 3'b0}; // shifted B -> C
			{`WRITE, 6'b11000x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`LOADIR, 4'b0, 9'b111000000, 3'b010, 3'b0}; // C -> R[Rd]
			
			// ALU
			{`DECODE, 6'b101xxx} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`ALULOADRN, 4'b0, 9'b000010000, 3'b100, 3'b0}; // R[Rm] -> B
			{`ALULOADRN, 6'bx} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`ALU, 4'b0, 9'b000100000, 3'b001, 3'b0}; // R[Rn] -> A
			{`ALU, 6'b10100x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`WRITE, 4'b0, 9'b000000010, 3'b001, 3'b0}; // ADD: A + shB -> C
			{`ALU, 6'b10101x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`LOADIR, 4'b0, 9'b000000001, 3'b001, 3'b0}; // CMP: f(A - shB) -> status
			{`ALU, 6'b10110x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`WRITE, 4'b0, 9'b000000010, 3'b001, 3'b0}; // AND: A & shB -> C
			{`ALU, 6'b10111x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`WRITE, 4'b0, 9'b000001010, 3'b001, 3'b0}; // MVN: ~shB -> C
			{`WRITE, 6'b101xxx} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`LOADIR, 4'b0000, 9'b111000000, 3'b010, 3'b0}; // C -> R[Rd]
			
			// LDR Rd, [Rn{,#<imm5>}] start
			{`DECODE, 6'b01100x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`MEMLOADC, 4'b0000, 9'b000100000, 3'b001, 3'b0}; // R[Rn] -> A
			// STR Rd, [RN{,#<imm5>}] start
			{`DECODE, 6'b10000x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`MEMLOADC, 4'b0000, 9'b000100000, 3'b001, 3'b0}; // R[Rn] -> A
			// Load C
			{`MEMLOADC, 6'bx} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`MEMSPLIT, 4'b0000, 9'b000000110, 3'b001, 3'b0}; // A + sximm5 -> C
			
			// LDR
			{`MEMSPLIT, 6'b01100x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`LDR, 4'b0010, 9'b0, 3'b001, 3'b0}; // msel = 1
			{`LDR, 6'b01100x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`LOADIR, 4'b0, 9'b001000000, 3'b010, 3'b0}; // mdata -> R[Rd], msel = 0
			// STR
			{`MEMSPLIT, 6'b10000x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`STR, 4'b0010, 9'b000010000, 3'b010, 3'b0}; // R[Rd] -> B
			{`STR, 6'b10000x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`UPDATEMDATA, 4'b0011, 9'b0, 3'b010, 3'b0}; // B -> MEM
			{`UPDATEMDATA, 6'b10000x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`LOADIR, 4'b0000, 9'b0, 3'b010, 3'b0}; // update mdata
			
			// Branch Instructions
			{`DECODE, 6'b00100x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`UPDATEMDATA, 4'b0, 9'b0, 3'b001, 3'b101}; // checking to branch
			{`UPDATEMDATA, 6'b00100x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`LOADIR, 4'b0, 9'b0, 3'b0, 3'b0}; // mdata available

			// Function Calls
			// BL <label>
			{`DECODE, 6'b01011x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`BL, 4'b0, 9'b101000000, 3'b001, 3'b0}; // PC -> R7
			{`BL, 6'b01011x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`UPDATEMDATA, 4'b0, 9'b0, 3'b001, 3'b110}; // PC+sx(<imm8>) -> PC
			{`UPDATEMDATA, 6'b01011x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`LOADIR, 4'b0, 9'b0, 3'b001, 3'b0}; // mdata available
			// BX Rd
			{`DECODE, 6'b01000x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`BX, 4'b0, 9'b000100000, 3'b010, 3'b0}; // Rd -> A
			{`BX, 6'bx} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`UPDATEMDATA, 4'b0, 9'b0, 3'b010, 3'b010}; // A -> PC
			{`UPDATEMDATA, 6'b01000x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`LOADIR, 4'b0, 9'b0, 3'b010, 3'b0}; // mdata available
			// BLX Rd
			{`DECODE, 6'b01010x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`BLX1, 4'b0, 9'b101000000, 3'b001, 3'b0}; // PC -> R7
			{`BLX1, 6'bx} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`BLX2, 4'b0, 9'b100100000, 3'b010, 3'b0}; // Rd -> A
			{`BLX2, 6'bx} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`UPDATEMDATA, 4'b0, 9'b0, 3'b010, 3'b010}; // A -> PC
			{`UPDATEMDATA, 6'b01010x} : {nextState, pcRamSet, datapathSet, nsel, tsel, execb} = {`LOADIR, 4'b0, 9'b0, 3'b010, 3'b0}; // mdata available
						
			default: nextState = `IDLE; // Before reset is pressed
		endcase
	end
endmodule

