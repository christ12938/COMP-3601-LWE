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
    Port ( input : in UNSIGNED(3+ k_trunc  downto 0);
           --delta:  in UNSIGNED(k_trunc -1 downto 0);       
           res :   out UNSIGNED(2*mul_bits -1 downto 0));
end ecExp;

architecture Behavioral of ecExp is

signal frac : unsigned(mul_bits - 1 downto 0);
signal substracted : unsigned(mul_bits-1 downto 0); 
signal int : unsigned(mul_bits-1 downto 0);
signal precise_output : unsigned(mul_bits-1 downto 0);
signal delta: UNSIGNED(k_trunc -1 downto 0);

component exp_deltas is
    Port (frac : in unsigned(10 downto 0);
          delta : out unsigned(k_trunc-1 downto 0));
end component ;
 
begin

int <= resize(input(3+ k_trunc downto k_trunc),mul_bits);
frac <= resize('1' & input(k_trunc-1 downto 0),mul_bits);

get_delta: exp_deltas port map (frac => frac,
                                delta => delta); 
substracted <= frac - delta;
res <= RESIZE(substracted(k_trunc downto k_trunc-TO_INTEGER(int)),2*mul_bits);


end Behavioral;
