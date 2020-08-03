module CPU(
    input reset,
    input clk_cpu,
    input clk_mem,
    output reg [7:0] Leds,
    output [7:0] cathodes,
    output [3:0] an
);
parameter TimerControlStart = 3'b000;
parameter TimerStart = 32'h00000000;
// clock relations
    wire clk;
    reg clk_mem_en,clk_cpu_en;
    assign clk = clk_cpu_en && clk_cpu;
    always @(posedge reset or posedge clk_mem)
    if(reset)
        clk_mem_en <= 0;
    else
        clk_mem_en <= 1;
    always @(posedge reset or posedge clk_cpu)
    if(reset)
        clk_cpu_en <= 0;
    else if(clk_mem_en)
        clk_cpu_en <= 1; 
    
// Peripheral - SysTimer
    reg [31:0] SysTick;
    reg [31:0] TimerH, TimerL, TimerL_next;
    reg [2:0] TimerControl, TimerControl_next;
    always @(posedge reset or posedge clk)
    if(reset) begin
        SysTick <= 32'h00000000;
        TimerL_next <= TimerStart;
        TimerControl_next <= TimerControlStart;
    end else begin
        SysTick<=SysTick+1;
        if(TimerControl[0])begin//timer is enabled
            if(TimerL==32'hffffffff)begin
                TimerL_next <= TimerH;
                if(TimerControl[1])  //irq is enabled
                    TimerControl_next<={1'b1, TimerControl[1:0]};
                else 
                    TimerControl_next<=TimerControl;
            end
            else begin 
                TimerL_next <= TimerL +1;
                TimerControl_next<=TimerControl;
            end
        end else begin
            TimerL_next <= TimerL;
            TimerControl_next<=TimerControl;
        end
    end
// Peripheral - LEDs, 7-digits
    reg [11:0] Digits;
    assign cathodes = Digits[7:0];
    assign an = Digits[11:8];
// Control Signals
	wire [1:0] ID_RegDst;
	wire [2:0] ID_PCSrc;
	wire ID_MemRead;
	wire [1:0] ID_MemtoReg;
	wire [3:0] ID_ALUOp;
	wire ID_ExtOp;
	wire ID_LuOp;
	wire ID_MemWrite;
	wire ID_ALUSrc1;
	wire ID_ALUSrc2;
	wire ID_RegWrite;
	wire Exception;
// forwarding
	wire [4:0] EX_rd;
	wire [31:0] EX_ForwardData, MEM_ForwardData, WB_ForwardData;
// load use hazard
    wire Stall;
// IF/ID Registers Definition
    wire IF_Valid;
    reg IFID_Valid;
    reg [31:0] IFID_Instruction;
    reg [31:0] IFID_PC_plus_4, IFID_PC;
// ID/EX Registers Definition
    reg [31:0] IDEX_Register_Data1;
    reg [31:0] IDEX_Register_Data2;
    reg [31:0] IDEX_Offset_lui;
    (* max_fanout = "8" *)reg [4:0] IDEX_rs;
    (* max_fanout = "8" *)reg [4:0] IDEX_rt;
    (* max_fanout = "8" *)reg [4:0] IDEX_rd;
    reg [5:0] IDEX_Funct;
    reg [31:0] IDEX_PC_plus_4, IDEX_PC;
    reg [4:0] IDEX_shamt;
    reg IDEX_ALUSrc1, IDEX_ALUSrc2;
    reg [1:0] IDEX_rd_src;
    reg [3:0] IDEX_ALUOp;
    reg IDEX_MemRead, IDEX_MemWrite;
    reg [1:0] IDEX_MemtoReg;
    reg IDEX_RegWrite;
    reg [5:0] IDEX_OpCode;
// EX/MEM Registers Definition
	wire EX_GoBranch;
    reg [31:0] EXMEM_ALUOut;
    reg [31:0] EXMEM_MemDataIn;
    reg [4:0] EXMEM_rd;
    reg [31:0] EXMEM_PCtoReg;
    reg EXMEM_MemRead, EXMEM_MemWrite;
    reg [1:0] EXMEM_MemtoReg;
    reg EXMEM_RegWrite;
// MEM/WB Registers Definition
    reg [31:0] MEMWB_RFDataIn;
    (* max_fanout = "8" *)reg [4:0] MEMWB_rd;
    reg MEMWB_RegWrite;
// Instruction Fetch and PC Update(IF) START
	reg [31:0] PC;
    wire [31:0] PC_next, PC_plus_4, PC_branch, PC_jump, PC_jr;
	wire [31:0] IF_Instruction, IF_MemOut;

    assign PC_plus_4 = {PC[31], PC[30:0] + 30'd4};
	assign PC_next =   (ID_PCSrc==3'b100)? 32'h80000004:
	                   (ID_PCSrc==3'b101)? 32'h80000008:
	                   (ID_PCSrc==3'b011)? PC_branch:
	                   (ID_PCSrc==3'b001)? PC_jump:
	                   (ID_PCSrc==3'b010)? PC_jr:
	                   PC_plus_4;
	always @(posedge reset or posedge clk)
		if (reset)
			PC <= 32'h80000000;
		else if(~Stall)
		    PC <= PC_next;
	InstructionMemory instruction_memory1(.clk(~clk_cpu),.Addr(PC[30:0]), .Instruction(IF_MemOut));
	assign IF_Instruction = (ID_PCSrc==3'b000)? IF_MemOut: 32'h00000000;
	assign IF_Valid = (ID_PCSrc==3'b000);
// Instruction Fetch and PC Update(IF) END
// IF/ID Registers Update
	always @(posedge reset or posedge clk)
	     if (reset) begin
			IFID_Instruction <= 32'h00000000;
			IFID_PC_plus_4 <= 32'h00000000;
			IFID_PC <= 32'h00000000;
			IFID_Valid <= 1'b1;
	    end else if(~Stall) begin 
		    IFID_PC_plus_4 <= PC_plus_4;
		    IFID_PC <= PC;
		    IFID_Instruction <= IF_Instruction;
		    IFID_Valid <= IF_Valid;
		end
// Instruction Decode, Register Read/Write, Jump Branch(ID) START
    wire [31:0] ID_rs_Data;
    wire [1:0] ID_rs_Src;
    wire [5:0] ID_OpCode, ID_Funct;
    wire [4:0] ID_rs, ID_rt, ID_rd;
    wire [2:0] ID_PCSrc_jump;
    wire [15:0] ID_Imm;
    assign ID_OpCode = IFID_Instruction[31:26];
    assign ID_Funct = IFID_Instruction[5:0];
    assign ID_rs = IFID_Instruction[25:21];
    assign ID_rt = IFID_Instruction[20:16];
    assign ID_rd = IFID_Instruction[15:11];
    assign ID_Imm = IFID_Instruction[15:0];
    
    wire GoIR;
    assign GoIR = TimerControl[2] && (~PC[31]) && IFID_Valid && (~EX_GoBranch);
        
    Control control1(
    .OpCode(ID_OpCode), .Funct(ID_Funct),
    .PCSrc(ID_PCSrc_jump), .RegWrite(ID_RegWrite), .RegDst(ID_RegDst), 
    .MemRead(ID_MemRead),	.MemWrite(ID_MemWrite), .MemtoReg(ID_MemtoReg),
    .ALUSrc1(ID_ALUSrc1), .ALUSrc2(ID_ALUSrc2), .ExtOp(ID_ExtOp), .LuOp(ID_LuOp),
    .ALUOp(ID_ALUOp),.IRQ(GoIR),.Exception(Exception));

    wire [31:0] ID_RFDataOut1, ID_RFDataOut2;
    RegisterFile register_file1(.reset(reset), .clk(~clk_cpu), .RegWrite(MEMWB_RegWrite), 
    .Read_register1(ID_rs), .Read_register2(ID_rt), .Write_register(MEMWB_rd),
    .Write_data(MEMWB_RFDataIn), .Read_data1(ID_RFDataOut1), .Read_data2(ID_RFDataOut2));
    

    assign ID_rs_Data = (ID_rs_Src==2'b11)? EX_ForwardData:
                        (ID_rs_Src==2'b10)? MEM_ForwardData:
                        ID_RFDataOut1;

    IDForward idforward1(.ID_rs(ID_rs),.EX_rd(EX_rd),.MEM_rd(EXMEM_rd),
    .EX_RegWrite(IDEX_RegWrite),.MEM_RegWrite(EXMEM_RegWrite),.ID_rs_Src(ID_rs_Src));
    
    
    assign PC_jump = {PC[31], IFID_PC_plus_4[30:28], IFID_Instruction[25:0], 2'b00};
    assign PC_jr = ID_rs_Data;
    assign ID_PCSrc = EX_GoBranch? 3'b011: 
                      ID_PCSrc_jump;
    
    wire [31:0] ID_Ext_out;
	assign ID_Ext_out = {ID_ExtOp? {16{ID_Imm[15]}}: 16'h0000, ID_Imm};
	
	wire [31:0] ID_LU_out;
	assign ID_LU_out = ID_LuOp? {ID_Imm, 16'h0000}: ID_Ext_out;
// Instruction Decode, Register Read/Write, Jump Branch(ID) END
// ID/EX Registers Update
    wire IDEX_Clean;
    assign IDEX_Clean = EX_GoBranch || Stall;
    always @(posedge reset or posedge clk)
	     if (reset||IDEX_Clean) begin
			IDEX_Register_Data1 <= 32'h00000000;
			IDEX_Register_Data2 <= 32'h00000000;
			IDEX_Offset_lui <= 32'h00000000;
			IDEX_rs <= 5'b00000;
			IDEX_rt <= 5'b00000;
			IDEX_rd <= 5'b00000;
			IDEX_Funct <= 6'b000000;
            IDEX_PC <= 32'h00000000;
            IDEX_PC_plus_4 <= 32'h00000000;
			IDEX_shamt <= 5'b00000;
			IDEX_ALUSrc1 <= 0;
			IDEX_ALUSrc2 <= 0;
			IDEX_rd_src <= 2'b00;
			IDEX_ALUOp <= 4'h0;
			IDEX_MemRead <= 0;
			IDEX_MemWrite <= 0;
			IDEX_MemtoReg <= 2'b00;
			IDEX_RegWrite <= 0;
			IDEX_OpCode <= 6'h00;
	    end else begin 
			IDEX_Register_Data1 <= ID_RFDataOut1;
			IDEX_Register_Data2 <= ID_RFDataOut2;
			IDEX_Offset_lui <= ID_LU_out;
			IDEX_rs <= ID_rs;
			IDEX_rt <= ID_rt;
			IDEX_rd <= ID_rd;
			IDEX_Funct <= ID_Funct;
            IDEX_PC <= IFID_PC;
            IDEX_PC_plus_4 <= IFID_PC_plus_4;
			IDEX_shamt <= IFID_Instruction[10:6];
			IDEX_ALUSrc1 <= ID_ALUSrc1;
			IDEX_ALUSrc2 <= ID_ALUSrc2;
			IDEX_rd_src <= ID_RegDst;
			IDEX_ALUOp <= ID_ALUOp;
			IDEX_MemRead <= ID_MemRead;
			IDEX_MemWrite <= ID_MemWrite;
			IDEX_MemtoReg <= ID_MemtoReg;
			IDEX_RegWrite <= ID_RegWrite;
			IDEX_OpCode <= (GoIR||Exception)? 6'h00 : ID_OpCode;
		end
// Execution(EX) START
	assign EX_rd = (IDEX_rd_src == 2'b00)? IDEX_rt:
	               (IDEX_rd_src == 2'b01)? IDEX_rd: 
	               (IDEX_rd_src == 2'b11)? 5'd26:
	                5'b11111;
		
	wire [4:0] EX_ALUCtl;
	wire EX_Sign;
	ALUControl alu_control1(.ALUOp(IDEX_ALUOp), .Funct(IDEX_Funct), .ALUCtl(EX_ALUCtl), .Sign(EX_Sign));
	
	wire [31:0] EX_rs_Data, EX_rt_Data, EX_ALU_in1, EX_ALU_in2, EX_ALU_out;
	wire [1:0] EX_rs_Src, EX_rt_Src;

    assign EX_rs_Data = (EX_rs_Src==2'b10)? MEM_ForwardData:
                        (EX_rs_Src==2'b01)? WB_ForwardData: 
                        IDEX_Register_Data1;
    assign EX_rt_Data = (EX_rt_Src==2'b10)? MEM_ForwardData:
                        (EX_rt_Src==2'b01)? WB_ForwardData: 
                        IDEX_Register_Data2;
    EXForward exforward1(.EX_rs(IDEX_rs),.EX_rt(IDEX_rt),.MEM_rd(EXMEM_rd),.WB_rd(MEMWB_rd),
    .MEM_RegWrite(EXMEM_RegWrite),.WB_RegWrite(MEMWB_RegWrite),.EX_rs_Src(EX_rs_Src),.EX_rt_Src(EX_rt_Src));
    
	assign EX_ALU_in1 = IDEX_ALUSrc1? {27'h0000000, IDEX_shamt}: EX_rs_Data;
	assign EX_ALU_in2 = IDEX_ALUSrc2? IDEX_Offset_lui: EX_rt_Data;
	ALU alu1(.in1(EX_ALU_in1), .in2(EX_ALU_in2), .ALUCtl(EX_ALUCtl), .Sign(EX_Sign), .out(EX_ALU_out));
	
	assign EX_ForwardData = EX_ALU_out;
	
    BranchCtrl branch1(.in1(EX_rs_Data),.in2(EX_rt_Data), .OpCode(IDEX_OpCode),.IsBranch(EX_GoBranch));
    assign PC_branch = {PC[31],IDEX_PC_plus_4[30:0] + {IDEX_Offset_lui[28:0], 2'b00}};
// Execution(EX) End
// EX/MEM Registers Update
    always @(posedge reset or posedge clk)
	     if (reset) begin
	         EXMEM_ALUOut <= 32'h00000000;
	         EXMEM_MemDataIn <= 32'h00000000;
	         EXMEM_rd <= 5'b00000;
	         EXMEM_PCtoReg <= 32'h00000000;
	         EXMEM_MemRead <= 0;
	         EXMEM_MemWrite <= 0;
	         EXMEM_MemtoReg <= 2'b00;
	         EXMEM_RegWrite <= 0;
	     end else begin
	     	 EXMEM_ALUOut <= EX_ALU_out;
	         EXMEM_MemDataIn <= EX_rt_Data;
	         EXMEM_rd <= EX_rd;
	         EXMEM_PCtoReg <= (IDEX_rd_src==2'b11)?IDEX_PC:IDEX_PC_plus_4;
	         EXMEM_MemRead <= IDEX_MemRead;
	         EXMEM_MemWrite <= IDEX_MemWrite;
	         EXMEM_MemtoReg <= IDEX_MemtoReg;
	         EXMEM_RegWrite <= IDEX_RegWrite;
	     end
// DataRam/Peripheral read/write(MEM) START
    wire [31:0] MEM_Read_data, MEM_RAM_Read_data;
    reg [31:0] Peripheral_Read_data;
    DataMemory data_memory1(.clk(clk_mem), .Addr(EXMEM_ALUOut), .DataIn(EXMEM_MemDataIn), .DataOut(MEM_RAM_Read_data), 
    .MemRead(EXMEM_MemRead), .MemWrite(EXMEM_MemWrite));
    assign MEM_Read_data = (EXMEM_ALUOut[30])?Peripheral_Read_data:MEM_RAM_Read_data;
    //Peripheral START
    always @(*)
    if(EXMEM_MemRead)begin
        case(EXMEM_ALUOut)
            32'h40000000:Peripheral_Read_data <= TimerH;
            32'h40000004:Peripheral_Read_data <= TimerL;
            32'h40000008:Peripheral_Read_data <= {29'b0,TimerControl};
            32'h4000000C:Peripheral_Read_data <= {24'b0,Leds};
            32'h40000010:Peripheral_Read_data <= {20'b0,Digits};
            32'h40000014:Peripheral_Read_data <= SysTick;
            default:Peripheral_Read_data <= 32'b0;
        endcase
    end else
        Peripheral_Read_data <= 32'b0;
        
    always @(posedge reset or posedge clk_mem)
    if(reset) begin
        TimerH <= TimerStart;
        TimerL <= TimerStart;
        TimerControl <= TimerControlStart;
        Digits <= 11'h000;
        Leds <= 8'h00;        
    end else begin
        if(EXMEM_MemWrite && EXMEM_ALUOut==32'h40000000) TimerH <= EXMEM_MemDataIn;
        if(EXMEM_MemWrite && EXMEM_ALUOut==32'h40000004) TimerL <= EXMEM_MemDataIn;
        else TimerL <= TimerL_next;
        if(EXMEM_MemWrite && EXMEM_ALUOut==32'h40000008) TimerControl <= EXMEM_MemDataIn[2:0];
        else TimerControl <= TimerControl_next;
        if(EXMEM_MemWrite && EXMEM_ALUOut==32'h4000000C) Leds <= EXMEM_MemDataIn[7:0];
        if(EXMEM_MemWrite && EXMEM_ALUOut==32'h40000010) Digits <= EXMEM_MemDataIn[11:0];
    end
    //Peripheral END
    wire [31:0] MEM_RegDataIn;
	assign MEM_RegDataIn = (EXMEM_MemtoReg == 2'b01)? MEM_Read_data: MEM_ForwardData;
	assign MEM_ForwardData = (EXMEM_MemtoReg == 2'b10 || EXMEM_MemtoReg == 2'b11)? EXMEM_PCtoReg:
	                         EXMEM_ALUOut;
// DataRam/Peripheral read/write(MEM) END
// MEM/WB  Registers Update
    assign WB_ForwardData = MEMWB_RFDataIn;
    always @(posedge reset or posedge clk)
	     if (reset) begin
            MEMWB_RFDataIn <= 32'h00000000;
            MEMWB_rd <= 5'b00000;
            MEMWB_RegWrite <= 0;
	     end else begin
            MEMWB_RFDataIn <= MEM_RegDataIn;
            MEMWB_rd <= EXMEM_rd;
            MEMWB_RegWrite <= EXMEM_RegWrite;
	     end
//load use hazard START
    wire IS_JR;
    assign IS_JR = (ID_PCSrc==3'b010);
    LoadUse loaduse1(.MEM_MemRead(EXMEM_MemRead),.EX_MemRead(IDEX_MemRead),.MEM_rd(EXMEM_rd),
    .EX_rd(EX_rd),.ID_rs(ID_rs),.ID_rt(ID_rt),.IS_JR(IS_JR), .Stall(Stall));
//load use hazard END
endmodule
	