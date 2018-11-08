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
