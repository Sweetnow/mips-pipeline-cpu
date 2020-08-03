
module LoadUse(
    input MEM_MemRead,
    input EX_MemRead,
    input [4:0] MEM_rd,
    input [4:0] EX_rd,
    input [4:0] ID_rs,
    input [4:0] ID_rt,
    input IS_JR,
    output Stall
    );
wire EX_Stall, MEM_Stall;
assign EX_Stall = EX_MemRead && (EX_rd != 5'b00000) && (EX_rd==ID_rs || EX_rd==ID_rt);         // common lw use
assign MEM_Stall = MEM_MemRead && (MEM_rd != 5'b00000) && (MEM_rd==ID_rs);     // lw -> jr
assign Stall =  EX_Stall || (IS_JR && MEM_Stall);
endmodule
