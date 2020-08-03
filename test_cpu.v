`timescale 1ns / 1ps
module test_cpu();

reg reset;
reg sysclk;
wire memclk;
wire ctrlclk;
wire [31:0] PC, Inst, IFID_Instruction;
wire IsBranch;
clk_wiz_0 c(.clk_in1(sysclk),.clk_out1(ctrlclk),.clk_mem(memclk));
CPU cpu1(reset,ctrlclk,memclk);
assign PC = cpu1.PC;
assign Inst = cpu1.IF_Instruction;
assign IFID_Instruction=cpu1.IFID_Instruction;
assign IsBranch=cpu1.EX_GoBranch;
initial begin
	reset = 0;
	sysclk = 0;
	#1 reset = 1;
	#1 reset = 0;
    #10000 reset = 1;
    #1 reset = 0;
end
always #5 sysclk = ~sysclk;
//always #10 memclk = ~memclk;
		
endmodule
