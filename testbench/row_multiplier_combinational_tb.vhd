------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date: 24.09.2021 16:44:16
---- Design Name: 
---- Module Name: row_multiplier - Behavioral
---- Project Name: 
---- Target Devices: 
---- Tool Versions: 
---- Description: 
---- 
---- Dependencies: 
---- 
---- Revision:
---- Revision 0.01 - File Created
---- Additional Comments:
---- 
------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;

entity example_generic is
end example_generic;
 
architecture behave of example_generic is
 
  constant c_CLK_PERIOD : time := 10 ns;  -- 100 MHz
 
  signal r_CLK_TB : std_logic := '0';

  signal A : array_mul_t(0 to a_width - 1):= (TO_UNSIGNED(25,mul_bits),TO_UNSIGNED(2,mul_bits),TO_UNSIGNED(127,mul_bits),TO_UNSIGNED(98,mul_bits));
  signal S : array_mul_t(0 to a_width - 1):=(TO_UNSIGNED(111,mul_bits),TO_UNSIGNED(29,mul_bits),TO_UNSIGNED(127,mul_bits),TO_UNSIGNED(24,mul_bits));
  signal sum : unsigned(mul_bits-1 downto 0) := TO_UNSIGNED(0,mul_bits);
  signal start : std_logic := '1';
  signal resetn : std_logic := '0';
  signal done : std_logic;

component row_mul_combinational is
	generic (
		mul_bits : natural := mul_bits
		);
	Port ( A : in array_mul_t(0 to a_width - 1);
           S : in array_mul_t(0 to a_width - 1);
          --  reset, start : in std_logic;
           result : out unsigned(mul_bits - 1 downto 0));
end component;
    
begin
 
  -- Generates a clock that is used by this example, NOT synthesizable
  p_CLK : process
  begin
    r_CLK_TB <= not(r_CLK_TB);
    wait for c_CLK_PERIOD/2;
  end process p_CLK;
   
 
------------ ROW MULTIPLIER ---------
    rowMultiplier: row_mul_combinational
    Port map ( A => A,
               S => S,
              --  reset, start : in std_logic;
               result =>sum);
------------ |ROW MULTIPLIER| ---------

   
end behave;