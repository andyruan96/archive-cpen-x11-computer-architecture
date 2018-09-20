module intructionDecoder(wIR, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);

  input [15:0] wIR;
  input [2:0] nsel;//one-hot code
  output [2:0] opcode, readnum, writenum;
  output [1:0] op, ALUop, shift;
  output [15:0] sximm5, sximm8;
  reg [15:0] sximm5, sximm8;
  wire [7:0] imm8;
  wire [4:0] imm5;
  wire [2:0] Rn, Rd, Rm, muxOut;

  assign opcode = wIR[15:13];
  assign op = wIR[12:11];
  assign Rn = wIR[10:8];
  assign Rd = wIR[7:5];
  assign Rm = wIR[2:0];
  MuxOf3Inputs #(3) mux(Rn, Rd, Rm, nsel, muxOut);
  assign readnum = muxOut;
  assign writenum = muxOut;
  assign shift = wIR [4:3];
  assign ALUop = wIR [12:11];
  assign imm8 = wIR [7:0];
  assign imm5 = wIR[4:0];
  
  //assign sximm8
  always @(*)begin
    casex(imm8)
      8'b0xxxxxxx: {sximm8} = {8'b00000000, imm8};
      8'b1xxxxxxx: {sximm8} = {8'b11111111, imm8};
    endcase
  end

  //assign sximm5
  always @(*)begin
    casex(imm5)
      5'b0xxxx: {sximm5} = {11'b00000000000, imm5};
      5'b1xxxx: {sximm5} = {11'b11111111111, imm5};
    endcase
  end

endmodule


module MuxOf3Inputs(xin, yin, zin, sel, out);
  parameter k = 3;
  input [k-1:0] xin, yin, zin; 
  input [2:0] sel;//one-hot code
  output[k-1:0] out ;
  reg [k-1:0] out ;

  always @(*)begin
    case(sel)
	3'b001: out = xin;
	3'b010: out = yin;
	3'b100: out = zin;
	default: out ={k{1'bx}};
    endcase
  end
endmodule