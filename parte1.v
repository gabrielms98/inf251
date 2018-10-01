module ff ( input data, input c, input r, output q);
reg q;
always @(posedge c or negedge r)
begin
 if(r==1'b0)
  q <= 1'b0;
 else
  q <= data;
end
endmodule

module statem(clk, reset, a, saida);

input clk, reset, a;
output [2:0] saida;
reg [2:0] state;
parameter zero =3'b000, um =3'b001, dois =3b'010, tres1 =3'b011, tres2 =3'b111, quatro =3'b100, cinco =3'b101, seis =3'b110 ;

assign saida = (state == zero)? 3'd0:
           (state == um)? 3'd1:
           (state == dois)? 3'd2:
	         (state == tres1)? 3'd3:
           (state == tres2)? 3'd7:
	         (state == quatro)? 3'd4:
           (state == cinco)? 3'd4: 3'd6;

always @(posedge clk or negedge reset)
  begin
    if(reset == 0)
      state = zero;
    else
      case(state)
        zero: state = um;
        um: if(a==0) state = dois;
            else if(a == 2) state = tres1;
        dois: if(a==0) state = zero;
              else if(a == 2) state = tres2;
        tres1: state = dois;
        tres2: state = um;
        quatro: state = tres1;
        cinco: state = seis;
        seis: state = tres1;
      endcase
  end
endmodule

module stateMem(input clk,input res, input [1:0]a, output [2:0] saida);
reg [5:0] StateMachine [0:15]; // 16 linhas e 6 bits de largura
initial
begin
StateMachine[0] = 6'o10; StateMachine[16] = 6'o00;
StateMachine[1] = 6'o21; StateMachine[17] = 6'o31;
StateMachine[2] = 6'o02; StateMachine[18] = 6'o32;
StateMachine[3] = 6'o00; StateMachine[19] = 6'o23;
StateMachine[4] = 6'o00; StateMachine[20] = 6'o00;
StateMachine[5] = 6'o00; StateMachine[21] = 6'o00;
StateMachine[6] = 6'o00; StateMachine[22] = 6'o00;
StateMachine[7] = 6'o00; StateMachine[23] = 6'o13;
StateMachine[8] = 6'o00; StateMachine[24] = 6'o00;
StateMachine[9] = 6'o00; StateMachine[25] = 6'o00;
StateMachine[10] = 6'd42; StateMachine[26] = 6'o00;
StateMachine[11] = 6'o23; StateMachine[27] = 6'o53;
StateMachine[12] = 6'o34; StateMachine[28] = 6'o00;
StateMachine[13] = 6'o00; StateMachine[29] = 6'o65;
StateMachine[14] = 6'o00; StateMachine[30] = 6'o36;
StateMachine[15] = 6'o00; StateMachine[31] = 6'o00;
end
wire [3:0] address;  // 16 linhas = 4 bits de endereco
wire [5:0] dout; // 6 bits de largura 3+3 = proximo estado + saida
assign address[3] = a;
assign dout = StateMachine[address];
assign saida = dout[2:0];
ff st0(dout[3],clk,res,address[0]);
ff st1(dout[4],clk,res,address[1]);
ff st2(dout[5],clk,res,address[2]);
endmodule

module statePorta(input clk, input res, input [1:0]a, output [2:0] s);
wire [2:0] e;
wire [2:0] p;
assign s = e;  // saida = estado atual
assign p[0]  =  ~e[1]&~e[2] | ~a[1]&e[0] | a[0]&~e[2] | a[0]&~a[1]&~e[1] | a[0]&a[1]&~e[0]; //7 operadores
assign p[1]  = a[1]&e[0] | ~a[0]&e[2] | a[0]&~a[1]&~e[0];//8operadores
assign p[2] =  a[0]&a[1]&e[2] | a[0]&~a[1]&~e[2] | a[1]&~e[0]&~e[2]; //3operadores -> total 18
ff  e0(p[0],clk,res,e[0]);
ff  e1(p[1],clk,res,e[1]);
ff  e2(p[2],clk,res,e[2]);
endmodule

module main;
reg c,res,a;
wire [2:0] saida;
wire [2:0] saida1;
wire [2:0] saida2;

statem FSM(c,res,a,saida);
stateMem FSM2(c,res,a,saida1);

// matricula = 92539 decimal-> binario = 10110100101111011
//1-1-0-0-1-1-1-0-1

initial
    c = 1'b0;
  always
    c= #(1) ~c;

// visualizar formas de onda usar gtkwave out.vcd
initial  begin
     $dumpfile ("out.vcd");
     $dumpvars;
   end

  initial
    begin
     $monitor($time," c %b res %b a %b s %d smem %d sporta %d",c,res,a,saida,saida1,saida2);
      #1 res=0; a=0;
      #1 res=1;
      #1 a=1;
      #1 a=1;
      #1 a=0;
      #1 a=0;
      #1 a=1;
      #1 a=1;
      #1 a=1;
      #1 a=0;
      #1 a=1;
      $finish ;
    end
endmodule
