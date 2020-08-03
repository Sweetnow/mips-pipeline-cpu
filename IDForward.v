
module IDForward(
    input [4:0] ID_rs,
    input [4:0] EX_rd,
    input [4:0] MEM_rd,
    input EX_RegWrite,
    input MEM_RegWrite,
    output [1:0] ID_rs_Src
    );
wire EX_to_ID_rs, EX_to_ID_rt, MEM_to_ID_rs, MEM_to_ID_rt, WB_to_ID_rs, WB_to_ID_rt;
assign EX_to_ID_rs = EX_RegWrite && (EX_rd != 5'b00000) && (ID_rs == EX_rd);
assign MEM_to_ID_rs = MEM_RegWrite && (MEM_rd != 5'b00000) && (ID_rs == MEM_rd);
// Normal 00
// WB     01
// MEM    10
// EX     11
assign ID_rs_Src = EX_to_ID_rs? 2'b11:
                   MEM_to_ID_rs? 2'b10:
                   2'b00;                       
endmodule
