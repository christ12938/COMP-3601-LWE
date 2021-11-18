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
    Port (
        input : in UNSIGNED(4+ k_trunc  downto 0);
        clock : in std_logic;
        --delta:  in UNSIGNED(k_trunc -1 downto 0);
        res :   out UNSIGNED(mul_bits -1 downto 0)
    );
end ecExp;

architecture Behavioral of ecExp is

    signal frac : unsigned(k_trunc  downto 0);
    signal substracted : unsigned(k_trunc downto 0);
    signal int : unsigned(4 downto 0) := "00000";
    --signal precise_output : unsigned(n_bits-1 downto 0);
    signal delta: UNSIGNED(k_trunc -1 downto 0);
    signal padding : UNSIGNED(k_trunc - 1 downto 0) := (others => '0');

    signal round : std_logic;

    signal temp : unsigned(mul_bits - 1 downto 0);

    component exp_deltas is
        Port (frac : in unsigned(mE - 1 downto 0);
            delta : out unsigned(k_trunc-1 downto 0));
    end component;

    component exp_deltas_config_2 is
    port (
        clka : in std_logic;
        addra : in std_logic_vector(mE - 1 downto 0);
        douta : out std_logic_vector(k_trunc - 1 downto 0)
    );
	end component;

	signal not_clock : std_logic;
begin
	not_clock <= not clock;

    int <= input(4+ k_trunc downto k_trunc);
    frac <= resize('1' & input(k_trunc-1 downto 0),k_trunc + 1);

   get_deltas_config_1 : if CONFIG = 1 generate
       get_delta_1 : exp_deltas port map (
           frac => frac(k_trunc - 1 downto k_trunc - mE),
           delta => delta
       );
   end generate;

    get_deltas_config_2 : if CONFIG = 2 generate
        get_delta_2 : exp_deltas_config_2 port map (
            clka => not_clock,
            addra => std_logic_vector(frac(k_trunc - 1 downto k_trunc - mE)),
            unsigned(douta) => delta
        );
    end generate;

    substracted <= frac - ('0' & delta);

    round <= substracted(k_trunc-TO_INTEGER(int)-1);


    temp <=
        (others => '0') when int = "0000" else
        RESIZE(substracted(k_trunc downto k_trunc-TO_INTEGER(int)),mul_bits);

    res <=
        temp + 1 when round = '1' else
        temp;


end Behavioral;
