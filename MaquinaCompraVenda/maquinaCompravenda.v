module ff ( input data, input c, input r, output q);
reg q;
always @(posedge c or negedge r)
begin
 if(r==1'b0)
  q <= 1'b0;
 else
  q <= data;
end
endmodule //End

//registrador onde vamos guardar o saldo
module reg6 ( input [5:0] data, input clk, input rst, input en, output [5:0] q);
reg [5:0] q;
always @(posedge clk or negedge rst)
begin
 if(rst==1'b0)
  q <= 6'b0;
 else if ( en  == 1'b1 ) // enable
  q <= data;
end
endmodule //End

//sera usado para pegar as moedas da memoria e para manter registro do ponteiro para pos na memoria
module reg5 ( input [4:0] data, input clk, input rst, input en, output [4:0] q);
reg [4:0] q;
always @(posedge clk or negedge rst)
begin
 if(rst==1'b0)
  q <= 5'b0;
 else if ( en  == 1'b1 ) // enable
  q <= data;
end
endmodule //End

// ----   FSM alto nível com Case

/*                                 +---------+
                                   |0 5 10 20|
                                   +------+--+
  +----------+--------> +------+          |
  |          |     +----+saldo +-------+  |
  |          |   +-v-+  |      |     +-v--v--+
  |          |   |cmp|  +------+     |       |
  |maquina   |   +-+-+     ^         |   add |
  |          |     |       |         +---+---+
  |          |<----+       |             |
  |          |             +-------------+
  +----------+
*/

module venda(clk, reset, moeda, next, vendeu, soma);
input clk, reset;
input [4:0] moeda;
output next, vendeu;
output [5:0] soma;

reg [1:0] state;
parameter init=3'd0, pedido=3'd1, somar=3'd2, venda=3'd3, proxima=3'd4;
reg [5:0] soma;
wire [5:0] sout;
wire [4:0] moeda;
wire sreset;

assign next = (state == pedido)?1:0; //se o estado for pedido entao next=1 o que faz "compra" pegar outra moeda
assign sreset = (state == init)?0:1;
reg6 saldo(soma, clk, sreset, next, sout);

assign vendeu = (state == venda)?1:0;
assign enS = (state == somar)?1:0;

always @(posedge clk or negedge reset)
  begin
    if(reset==0)
      state = init;
    else
      case (state)
        init:
          state = pedido;
        pedido:
          if(moeda) state = somar;
        somar:
          if(soma >= 40) state = venda;
          else
            state = proxima;
        venda:
          state = init;
        proxima:
          if(next == 0) state = pedido;
      endcase
  end

always @(posedge clk or negedge reset or negedge sreset)
  begin
    if (reset==0 || sreset ==0)
      soma = 6'd0;
    else
      if(moeda)
  	   soma = sout + moeda;
  end

endmodule

module compra(clk, reset, next, vendeu, moeda, ptrOUT);
input clk;
input reset;
input next;
input vendeu;
output [4:0] moeda;
output [4:0] ptrOUT;

reg [1:0] state;
parameter init=3'd0, readmem=3'd1, incrPtr=3'd2, esperaN0=3'd3, esperaN1=3'd4;

wire [4:0] moedaIN;
reg5 PTR(ptrIN, clk, rst, inc, ptrOUT);
memoria mem(ptrIN, moedaIN, rst);
reg5 m(moedaIN, clk, rst, enN, moeda);
reg [4:0] ptrIN;
wire [4:0] ptrOUT;

assign rst = (state == init)?0:1;
assign enN = (state == readmem)?1:0;
assign inc = (state == incrPtr)?1:0;

always @(posedge clk or negedge reset)
  begin
    if(reset==0)
      state = init;
    else
      case (state)
        init:
          if(next) state = readmem;
        readmem:
          if(next) state = incrPtr;
        incrPtr:
          if(next == 0)
            state = esperaN0;
        esperaN0:
          if(next == 0) state = esperaN1;
        esperaN1:
          if(next == 1) state = readmem;
      endcase
  end

always @(posedge clk or negedge reset)
  begin
  if(reset==0)
    ptrIN =0;
  else
    if(vendeu) ptrIN = 0;
    else
      if(next) ptrIN = ptrOUT + 1;
  end

endmodule


module memoria( line,  dout , reset);
input [4:0] line; // 32 linhas
output [4:0] dout;
input reset;
reg [4:0] memory[0:31]; // 32 linhas com 5 bits
reg [4:0] dout;

always @ (*)
  begin
  dout <= memory[line];
  end

always @( posedge reset)
			if(reset) // inicia  para testes
				begin
				  memory[0] <= 5'd5;
				  memory[1] <= 5'd20;
				  memory[2] <= 5'd5;
				  memory[3] <= 5'd10;
				  memory[4] <= 5'd20;
				  memory[5] <= 5'd20;
				  memory[6] <= 5'd10;
				  memory[7] <= 5'd5;
				end
endmodule

module main;
reg c, res;
wire [4:0] moeda;
wire next, vendeu;
wire [4:0] ptr;
wire [5:0] soma;

venda v(c, res, moeda, next, vendeu, soma);
compra cmp(c, res, next, vendeu, moeda, ptr);

initial
  c = 1'b0;
  always
    c = #(1)~c;

initial begin
  $dumpfile ("out.vcd");
  $dumpvars;
  end

  initial
    begin
    $monitor($time, "clk %b res %b moeda %d next %b vendeu %b ptr %d soma %d", c, res, moeda, next, vendeu, ptr, soma);
    #1 res=0;
    #1 res=1;
    #20;
    $finish ;
    end
endmodule
