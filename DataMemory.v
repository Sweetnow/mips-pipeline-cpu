
module DataMemory(
    input clk, 
    input [31:0] Addr,
    input [31:0] DataIn,
    output [31:0] DataOut,
    input MemRead, 
    input MemWrite
);
    parameter MEM_WIDTH = 11;
    parameter OTHER_WIDTH = 32-MEM_WIDTH;
    wire en;
    wire [3:0] we;
    wire [31:0] MemOut;
    wire legal;
    assign legal = (Addr[31:MEM_WIDTH] == {OTHER_WIDTH{1'b0}});
	assign en = legal && (MemRead | MemWrite);
	assign we = (legal && MemWrite)? 4'b1111 : 4'b0000;
	assign DataOut = (MemRead && legal)? MemOut : 32'h00000000;
	data_mem data(clk,en,we,Addr,DataIn,MemOut);
endmodule
