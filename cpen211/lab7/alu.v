
module ALU (Ain,Bin,ALUop,w2t5,w2t10);
  input [15:0] Ain, Bin;
  input [1:0] ALUop;
  output [15:0] w2t5;
  output [2:0] w2t10;
  reg [15:0] w2t5;
  reg [2:0] w2t10;//[2]= zero flag, [1]= negative flag, [0]= overflow flag
  wire [15:0] s;  
  wire ovf;
  wire isSub;

  `define Addab 2'b00
  `define Subab 2'b01
  `define Andab 2'b10
  `define Notb 2'b11

  assign isSub = (ALUop == `Subab);
  AddSub #(16) checkOvf(Ain,Bin,isSub,s,ovf);

  always @(*) begin
    case(ALUop)
	`Addab: w2t5 = s;//Ain + Bin;
	`Subab: w2t5 = s;//Ain - Bin;
	`Andab: w2t5 = Ain & Bin;
	`Notb: w2t5 = ~Bin;
	default: w2t5 = 16'b0;
    endcase
  w2t10[2] = w2t5 == 0;
  w2t10[1] = w2t5[15];
  w2t10[0] = ovf;
  end

endmodule



module AddSub(a,b,sub,s,ovf);
  parameter n = 16 ;
  input [n-1:0] a, b ;
  input sub ;           // subtract if sub=1, otherwise add
  output [n-1:0] s ;
  output ovf ;          // 1 if overflow
  wire c1, c2 ;         // carry out of last two bits
  wire ovf = c1 ^ c2 ;  // overflow if signs don't match

  // add non sign bits
  Adder1 #(n-1) ai(a[n-2:0],b[n-2:0]^{n-1{sub}},sub,c1,s[n-2:0]) ;
  // add sign bits
  Adder1 #(1)   as(a[n-1],b[n-1]^sub,c1,c2,s[n-1]) ;
endmodule



module Adder1(a,b,cin,cout,s) ;
  parameter n = 15 ;
  input [n-1:0] a, b ;
  input cin ;
  output [n-1:0] s ;
  output cout ;
  wire [n-1:0] s;
  wire cout ;

  assign {cout, s} = a + b + cin ;
endmodule 
