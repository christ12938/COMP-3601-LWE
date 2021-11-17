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
           res :   out UNSIGNED(mul_bits -1 downto 0));
end ecExp;

architecture Behavioral of ecExp is

    signal frac : unsigned(k_trunc  downto 0);
    signal substracted : unsigned(k_trunc downto 0);
    signal int : unsigned(3 downto 0) := "0000";
    --signal precise_output : unsigned(n_bits-1 downto 0);
    signal delta: UNSIGNED(k_trunc -1 downto 0);
    signal padding : UNSIGNED(k_trunc - 1 downto 0) := (others => '0');

    signal round : std_logic;

    signal temp : unsigned(mul_bits - 1 downto 0);

    component exp_deltas is
        Port (frac : in unsigned(mE - 1 downto 0);
            delta : out unsigned(k_trunc-1 downto 0));
    end component ;

begin

    int <= input(3+ k_trunc downto k_trunc);
    frac <= resize('1' & input(k_trunc-1 downto 0),k_trunc + 1);

    get_delta: exp_deltas port map (frac => frac(k_trunc - 1 downto k_trunc - mE),
                                    delta => delta);
    substracted <= frac - ('0' & delta);

    round <= substracted(k_trunc-TO_INTEGER(int)-1);


    temp <=
        (others => '0') when int = "0000" else
        RESIZE(substracted(k_trunc downto k_trunc-TO_INTEGER(int)),mul_bits);

    res <=
        temp + 1 when round = '1' else
        temp;


end Behavioral;
