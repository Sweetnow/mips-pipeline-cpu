// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Thu Aug 29 20:30:50 2019
// Host        : Sweetnow running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/zhang/Desktop/THU19Summer/CPU/CPU/CPU.srcs/sources_1/ip/instruction_mem/instruction_mem_stub.v
// Design      : instruction_mem
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module instruction_mem(clka, addra, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,addra[31:0],douta[31:0]" */;
  input clka;
  input [31:0]addra;
  output [31:0]douta;
endmodule
