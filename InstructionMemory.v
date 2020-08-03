
module InstructionMemory(
    input clk,  
	input [30:0] Addr,
	output [31:0] Instruction
);
    parameter MEM_WIDTH = 11;
    parameter OTHER_WIDTH = 32-MEM_WIDTH;
    
    instruction_mem mem(clk,{{OTHER_WIDTH{1'b0}},Addr[MEM_WIDTH-1:0]},Instruction);
endmodule
