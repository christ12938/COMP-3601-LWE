// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Thu Nov 18 23:37:56 2021
// Host        : DONGS-PC running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {f:/Library
//               Files/Desktop/Programming/21T3/COMP3601/lwe/VHDL/block_rams/exp_deltas_config_2/exp_deltas_config_2/exp_deltas_config_2_stub.v}
// Design      : exp_deltas_config_2
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k160tlffv676-2L
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2021.1" *)
module exp_deltas_config_2(clka, addra, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,addra[17:0],douta[26:0]" */;
  input clka;
  input [17:0]addra;
  output [26:0]douta;
endmodule
