----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2021 18:00:53
-- Design Name: 
-- Module Name: ecExp - Behavioral
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

entity ecExp is
    Port ( input : in UNSIGNED(n_bits - 1 downto 0);
           delta:  in UNSIGNED(n_bits - 1 downto 0);       -- what is the size
           k       : in integer;                                    -- what is the range
           res :   out UNSIGNED(n_bits - 1 downto 0));
end ecExp;

architecture Behavioral of ecExp is
component barell_shifter is
    Port ( input : UNSIGNED(n_bits-1 downto 0);    -- what is the type here?
               log : in integer;      -- how many bits to rol by
               output : out UNSIGNED(n_bits-1 downto 0));
end component;
signal frac : unsigned(n_bits - 1 downto 0);
signal substracted : unsigned(n_bits-1 downto 0); 
signal int : unsigned(n_bits-1 downto 0);
signal precise_output : unsigned(n_bits-1 downto 0);
 
begin

int <= resize(input(n_bits-1 downto k),n_bits);
frac <= resize('1' & input(k-1 downto 0),n_bits);
substracted <= frac - delta;
res <= RESIZE(substracted(k downto k-TO_INTEGER(int)),n_bits);


end Behavioral;
