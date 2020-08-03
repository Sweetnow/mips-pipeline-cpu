
module BranchCtrl(
    input [31:0] in1,
    input [31:0] in2,
    input [5:0] OpCode,
    output reg IsBranch
    );
    
always @(*) begin 
    case(OpCode)
        6'b000100: IsBranch <= in1==in2;
        6'b000101: IsBranch <= in1!=in2;
        6'b000110: IsBranch <= in1<=0;
        6'b000111: IsBranch <= in1>0;
        6'b000001: IsBranch <= in1<0;
        default: IsBranch <= 0;
    endcase 
end

endmodule
