----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.11.2021 14:01:54
-- Design Name: 
-- Module Name: barell_shifter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------




library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
USE WORK.DATA_TYPES.ALL;
--use ieee.numeric_std_unsigned.all;



entity barell_shifter is
    Port ( input : UNSIGNED(n_bits-1 downto 0);    -- what is the type here?
           log : in integer;      -- how many bits to rol by
           output : out UNSIGNED(n_bits-1 downto 0)); -- fractional part, what is the type here
end barell_shifter;

architecture Behavioral of barell_shifter is

signal check: integer ;
signal size : integer := n_bits - 3;
signal padding : UNSIGNED(n_bits-1 downto 0) := (others => '0');
begin

--process(input)
--begin
    output <= input(log-1 downto 0) & padding (n_bits-log-1 downto 0);
--end process;

end Behavioral;
