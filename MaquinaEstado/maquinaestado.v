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

// ----   FSM alto nível com Case
module statem(clk, reset, a, saida);

input clk, reset, a;
output [2:0] saida;
reg [2:0] state;
parameter zero=3'b010, tres=3'b110, dois=3'b100, quatro=3'b101, cinco =3'b111;

assign saida = (state == zero)? 3'd2:
           (state == dois)? 3'd4:
	         (state == tres)? 3'd6:
	         (state == quatro)? 3'd5:3'd7;

always @(posedge clk or negedge reset)
  begin
    if(reset == 0)
      state = zero;
    else
      case(state)
        zero: state = tres;
        tres: if(a==1) state = cinco;
              else state = dois;
        quatro: if(a == 1) state = tres;
                else state = zero;
        dois: state = quatro;
        cinco: state = dois;
      endcase
  end
endmodule

module statePorta(input clk, input res, input a, output [2:0] s);
wire [2:0] e;
wire [2:0] p;
assign s = e;  // saida = estado atual
assign p[0]  =  ~e[1]&~e[0] | a&e[2]&~e[0]; //7 operadores
assign p[1]  = ~e[2] | ~e[1]&e[0] | a&e[1]&~e[0];//8operadores
assign p[2] =  ~e[0] | e[1] | a; //3operadores -> total 18
ff  e0(p[0],clk,res,e[0]);
ff  e1(p[1],clk,res,e[1]);
ff  e2(p[2],clk,res,e[2]);
endmodule

module stateMem(input clk,input res, input a, output [2:0] saida);
reg [5:0] StateMachine [0:15]; // 16 linhas e 6 bits de largura
initial
begin
StateMachine[0] = 6'o42;
StateMachine[1] = 6'o42;
StateMachine[2] = 6'd50;
StateMachine[3] = 6'o42;
StateMachine[4] = 6'o54;
StateMachine[5] = 6'o25;
StateMachine[6] = 6'o46;
StateMachine[7] = 6'o47;
StateMachine[8] = 6'o42;
StateMachine[9] = 6'o42;
StateMachine[10] = 6'd50;
StateMachine[11] = 6'o42;
StateMachine[12] = 6'o54;
StateMachine[13] = 6'o65;
StateMachine[14] = 6'o76;
StateMachine[15] = 6'o47;
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

module main;
reg c,res,a;
wire [2:0] saida;
wire [2:0] saida1;
wire [2:0] saida2;

statem FSM(c,res,a,saida);
// statePorta FSM(c,res,g,r,y);
statePorta FSM1(c,res,a,saida2);
stateMem FSM2(c,res,a,saida1);


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
      #8 a=1;
      #16 a=0;
      #12 a=1;
      #4;
      $finish ;
    end
endmodule

//y = p
// A = a, B = e[2], C = e[1], D = e[0]


// p2 = ~e[0] + e[1] + a
//    -     -     -     -
// A  A  B  B  C  C  D  D
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  o-----------------------------------|
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
//    -     -     -     -                                   |
// A  A  B  B  C  C  D  D                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |                *  *  *
// |  |  |  |  |  |  |  |                                   |                 *          *
// |  |  |  |  |  |  |  |                                   |                  *              *
// |  |  |  |  |  |  |  |                                   |                   *                 *
// |  |  |  |  |  |  |  |                                   |-------------------*                    *
// |  |  |  |  o----------------------------------------------------------------*                     *--------
// |  |  |  |  |  |  |  |                                   |-------------------*                    *
// |  |  |  |  |  |  |  |                                   |                   *                 *
// |  |  |  |  |  |  |  |                                   |                  *              *
// |  |  |  |  |  |  |  |                                   |                 *          *
// |  |  |  |  |  |  |  |                                   |                *  *  *
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
//    -     -     -     -                                   |
// A  A  B  B  C  C  D  D                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// o--------------------------------------------------------|
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |

// p[1] = ~e[2] + ~e[1]&e[0] + a&e[1]&~e[0]
//    -     -     -     -
// A  A  B  B  C  C  D  D
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  o-----------------------------------------------|
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
//    -     -     -     -                                   |
// A  A  B  B  C  C  D  D                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |      ****************             |                *  *  *
// |  |  |  |  |  |  |  |      *                *           |                 *          *
// |  |  |  |  |  |  |  |      *                  *         |                  *              *
// |  |  |  |  |  o------------*                    *       |                   *                 *
// |  |  |  |  |  |  |  |      *                     *      |-------------------*                    *
// |  |  |  |  |  |  |  |      *                     *--------------------------*                     *--------
// |  |  |  |  |  |  |  |      *                     *      |-------------------*                    *
// |  |  |  |  |  |  o---------*                    *       |                   *                 *
// |  |  |  |  |  |  |  |      *                  *         |                  *              *
// |  |  |  |  |  |  |  |      *                *           |                 *          *
// |  |  |  |  |  |  |  |      ****************             |                *  *  *
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
//    -     -     -     -                                   |
// A  A  B  B  C  C  D  D                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |      ****************             |
// |  |  |  |  |  |  |  |      *                *           |
// o---------------------------*                  *         |
// |  |  |  |  |  |  |  |      *                    *       |
// |  |  |  |  |  |  |  |      *                     *      |
// |  |  |  |  o---------------*                     *------|
// |  |  |  |  |  |  |  |      *                     *
// |  |  |  |  |  |  |  |      *                    *
// |  |  |  |  |  |  |  o------*                  *
// |  |  |  |  |  |  |  |      *                *
// |  |  |  |  |  |  |  |      ****************
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |

// y = C'D' + ABD'
//    -     -     -     -
// A  A  B  B  C  C  D  D
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |      ****************
// |  |  |  |  |  |  |  |      *                *
// |  |  |  |  |  |  |  |      *                  *
// |  |  |  |  |  o------------*                    *
// |  |  |  |  |  |  |  |      *                     *
// |  |  |  |  |  |  |  |      *                     *------|
// |  |  |  |  |  |  |  |      *                     *      |
// |  |  |  |  |  |  |  o------*                    *       |
// |  |  |  |  |  |  |  |      *                  *         |
// |  |  |  |  |  |  |  |      *                *           |
// |  |  |  |  |  |  |  |      ****************             |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
//    -     -     -     -                                   |
// A  A  B  B  C  C  D  D                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |                                   |
// |  |  |  |  |  |  |  |      ****************             |                *  *  *
// |  |  |  |  |  |  |  |      *                *           |                 *          *
// o---------------------------*                  *         |                  *              *
// |  |  |  |  |  |  |  |      *                    *       |                   *                 *
// |  |  |  |  |  |  |  |      *                     *      |-------------------*                    *
// |  |  o---------------------*                     *--------------------------*                     *--------
// |  |  |  |  |  |  |  |      *                     *                          *                    *
// |  |  |  |  |  |  |  |      *                    *                           *                 *
// |  |  |  |  |  |  |  o------*                  *                            *              *
// |  |  |  |  |  |  |  |      *                *                             *          *
// |  |  |  |  |  |  |  |      ****************                              *  *  *
// |  |  |  |  |  |  |  |
// |  |  |  |  |  |  |  |
