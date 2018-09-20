
module ALU (Ain,Bin,ALUop,w2t5,w2t10);
  input [15:0] Ain, Bin;
  input [1:0] ALUop;
  output [15:0] w2t5;
  output w2t10;
  reg [15:0] w2t5;
  reg w2t10;

  `define Addab 2'b00
  `define Subab 2'b01
  `define Andab 2'b10
  `define Notb 2'b11

  always @(*) begin
    case(ALUop)
	`Addab: {w2t5, w2t10}  = {(Ain + Bin), (((Ain + Bin) == 16'b0)? 1'b1 : 1'b0)};
	`Subab: {w2t5, w2t10} = {(Ain - Bin), (((Ain - Bin) == 16'b0)? 1'b1 : 1'b0)};
	`Andab: {w2t5, w2t10} = {(Ain & Bin), (((Ain & Bin) == 16'b0)? 1'b1 : 1'b0)};
	`Notb: {w2t5, w2t10} = {~Bin, ((~Bin == 16'b0)? 1'b1 : 1'b0)};
	default: {w2t5, w2t10} = {16'b0, 1'b0};
    endcase
  end
endmodule