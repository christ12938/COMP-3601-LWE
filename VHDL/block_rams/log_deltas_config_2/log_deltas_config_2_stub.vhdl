-- Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
-- Date        : Thu Nov 18 23:38:51 2021
-- Host        : DONGS-PC running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub {f:/Library
--               Files/Desktop/Programming/21T3/COMP3601/lwe/VHDL/block_rams/log_deltas_config_2/log_deltas_config_2/log_deltas_config_2_stub.vhdl}
-- Design      : log_deltas_config_2
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k160tlffv676-2L
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity log_deltas_config_2 is
  Port ( 
    clka : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 12 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 26 downto 0 )
  );

end log_deltas_config_2;

architecture stub of log_deltas_config_2 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,addra[12:0],douta[26:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_4_4,Vivado 2021.1";
begin
end;
