
module RegisterFile(
    input reset, 
    input clk, 
    input RegWrite, 
    input [4:0] Read_register1,
    input [4:0] Read_register2,
    input [4:0] Write_register, 
    input [31:0] Write_data, 
    output [31:0] Read_data1, 
    output [31:0] Read_data2
);
    wire [31:0] RF_DataOut1, RF_DataOut2;
    Registers register1(clk,RegWrite,Write_register,Write_data,clk,Read_register1,RF_DataOut1);
    Registers register2(clk,RegWrite,Write_register,Write_data,clk,Read_register2,RF_DataOut2);
 	assign Read_data1 = (Read_register1 == 5'b00000)? 32'h00000000: 
 	                    (RegWrite && Read_register1==Write_register)?Write_data:
 	                    RF_DataOut1;
	assign Read_data2 = (Read_register2 == 5'b00000)? 32'h00000000: 
                        (RegWrite && Read_register2==Write_register)?Write_data:
                        RF_DataOut2;

endmodule
			