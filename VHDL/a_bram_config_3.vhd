--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
--Date        : Sat Sep 25 00:44:44 2021
--Host        : DONGS-PC running 64-bit major release  (build 9200)
--Command     : generate_target a_bram_config_3.bd
--Design      : a_bram_config_3
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity a_bram_config_3 is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 14 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 255 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 255 downto 0 );
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
end a_bram_config_3;

architecture STRUCTURE of a_bram_config_3 is
  component bram is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 14 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 255 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 255 downto 0 );
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component bram;
begin
bram_i: component bram
     port map (
      BRAM_PORTA_0_addr(14 downto 0) => BRAM_PORTA_0_addr(14 downto 0),
      BRAM_PORTA_0_clk => BRAM_PORTA_0_clk,
      BRAM_PORTA_0_din(255 downto 0) => BRAM_PORTA_0_din(255 downto 0),
      BRAM_PORTA_0_dout(255 downto 0) => BRAM_PORTA_0_dout(255 downto 0),
      BRAM_PORTA_0_we(0) => BRAM_PORTA_0_we(0)
    );
end STRUCTURE;
