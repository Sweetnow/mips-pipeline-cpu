
module Control(
	input [5:0] OpCode,
	input [5:0] Funct,
	output [2:0] PCSrc,
	output RegWrite,
	output [1:0] RegDst,
	output MemRead,
	output MemWrite,
	output [1:0] MemtoReg,
	output ALUSrc1,
	output ALUSrc2,
	output ExtOp,
	output LuOp,
	output [3:0] ALUOp,
	input IRQ,
	output reg Exception
);

	// Your code below
	wire Branch;
	wire link;
	wire R_Command, I_Command;
	assign link = (OpCode == 6'h03 || (OpCode == 6'h00 && Funct == 6'h09));    // jal jalr 
	assign R_Command = (OpCode == 6'h00);
	assign I_Command = ~R_Command;
	
	assign PCSrc = 
	   IRQ? 3'b100:
	   Exception? 3'b101:
	   (OpCode == 6'h02 || OpCode == 6'h03)? 3'b001:                    // j jal
	   (OpCode == 6'h00 && (Funct == 6'h08 || Funct == 6'h09))? 3'b010: // jr jalr
	   3'b000;

	assign Branch = ~IRQ && ((OpCode == 6'b000100) ||               // beq
	                (OpCode == 6'b000101) ||               // bne
	                (OpCode == 6'b000110) ||               // blez
	                (OpCode == 6'b000111) ||               // bgtz
	                (OpCode == 6'b000001));                 // bltz
	                
	assign RegWrite = IRQ || Exception ||
	   ~(OpCode == 6'h2b ||                                            // sw
	     Branch ||                                                     // branch
	     OpCode == 6'h02 ||                                            // j
	     (OpCode == 6'h00 && Funct == 6'h08));                         // jr
	     
	assign RegDst = 
	   (IRQ||Exception)? 2'b11:
	   link? 2'b10:// jal jalr
	   R_Command? 2'b01:                                       // R-command
	   2'b00;
	   
	assign MemRead = (OpCode == 6'h23) && ~(IRQ || Exception);                                // lw
	assign MemWrite = (OpCode == 6'h2b) && ~(IRQ || Exception);                               // sw
	
	assign MemtoReg =
	   (IRQ || Exception)? 2'b11: 
	   link? 2'b10:                                                    // jal jalr
	   (OpCode == 6'h23)? 2'b01:                                       // lw
	   2'b00;
	   
	assign ALUSrc1 = R_Command &&
	   (Funct == 6'h00 ||                                              // sll
	    Funct == 6'h02 ||                                              // srl
	    Funct == 6'h03);                                               // sra
	    
	 assign ALUSrc2 = (I_Command && OpCode != 6'h04);                  // I-command without beq
	 
	 assign ExtOp = (I_Command && OpCode != 6'h0c &&  OpCode != 6'h0d); // I-command without andi/ori
	 
	 assign LuOp = (OpCode == 6'h0f);                                  // lui

	// Your code above
	
	assign ALUOp[2:0] = 
		(OpCode == 6'h00)? 3'b010: 
		(OpCode == 6'h04)? 3'b001: 
		(OpCode == 6'h0c)? 3'b100: 
		(OpCode == 6'h0d)? 3'b110:        // ori
		(OpCode == 6'h0a || OpCode == 6'h0b)? 3'b101: 
		3'b000;
		
	assign ALUOp[3] = OpCode[0];
	

	always @(*) begin
	   if(R_Command) begin
	       case(Funct)
	           6'h20: Exception <= 0;
	           6'h21: Exception <= 0;
	           6'h22: Exception <= 0;
	           6'h23: Exception <= 0;
	           6'h24: Exception <= 0;
	           6'h25: Exception <= 0;
	           6'h26: Exception <= 0;
	           6'h27: Exception <= 0;
	           6'h2a: Exception <= 0;
	           6'h2b: Exception <= 0;
	           6'h08: Exception <= 0;
	           6'h09: Exception <= 0;
	           6'h00: Exception <= 0;
	           6'h02: Exception <= 0;
	           6'h03: Exception <= 0;
	           default: Exception <= 1;
	       endcase
	   end else begin
	       case(OpCode)
	           6'h23: Exception <= 0;
	           6'h2b: Exception <= 0;
	           6'h0f: Exception <= 0;
	           6'h08: Exception <= 0;
	           6'h09: Exception <= 0;
	           6'h0c: Exception <= 0;
	           6'h0a: Exception <= 0;
	           6'h0b: Exception <= 0;
	           6'h0d: Exception <= 0;
	           6'h01: Exception <= 0;
	           6'h02: Exception <= 0;
	           6'h03: Exception <= 0;
	           6'h04: Exception <= 0;
	           6'h05: Exception <= 0;
	           6'h06: Exception <= 0;
	           6'h07: Exception <= 0;   

	           default:Exception <= 1;
	       endcase
	   end
	end
	
endmodule