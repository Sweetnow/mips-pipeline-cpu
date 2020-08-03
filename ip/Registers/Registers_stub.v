// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Tue Aug 27 19:49:04 2019
// Host        : Sweetnow running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top Registers -prefix
//               Registers_ Registers_stub.v
// Design      : Registers
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module Registers(clka, wea, addra, dina, clkb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[4:0],dina[31:0],clkb,addrb[4:0],doutb[31:0]" */;
  input clka;
  input [0:0]wea;
  input [4:0]addra;
  input [31:0]dina;
  input clkb;
  input [4:0]addrb;
  output [31:0]doutb;
endmodule
