
module EXForward(
    input [4:0] EX_rs,
    input [4:0] EX_rt,
    input [4:0] MEM_rd,
    input [4:0] WB_rd,
    input MEM_RegWrite,
    input WB_RegWrite,
    output [1:0] EX_rs_Src,
    output [1:0] EX_rt_Src
    );
wire MEM_to_EX_rs, MEM_to_EX_rt, WB_to_EX_rs, WB_to_EX_rt;
assign MEM_to_EX_rs = MEM_RegWrite && (MEM_rd != 5'b00000) && (EX_rs == MEM_rd);
assign MEM_to_EX_rt = MEM_RegWrite && (MEM_rd != 5'b00000) && (EX_rt == MEM_rd);
assign WB_to_EX_rs = WB_RegWrite && (WB_rd != 5'b00000) && (EX_rs == WB_rd);
assign WB_to_EX_rt = WB_RegWrite && (WB_rd != 5'b00000) && (EX_rt == WB_rd);
// Normal 00
// WB     01
// MEM    10
// EX     11
assign EX_rs_Src = MEM_to_EX_rs? 2'b10:
                   WB_to_EX_rs? 2'b01:
                   2'b00;
assign EX_rt_Src = MEM_to_EX_rt? 2'b10:
                   WB_to_EX_rt? 2'b01:
                   2'b00; 
     
endmodule