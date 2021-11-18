----------------------------------------------------------------------------------
-- writer: Farnaz Tavakol
--
-- Create Date: 25.09.2021 22:15:08
-- Design Name:
-- Module Name: log - Behavioral

-- TODO: return the fraction part of the log (second task/not necessary for the first one)
--
--

----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
USE WORK.DATA_TYPES.ALL;

entity ecLog is
    Port ( input : in UNSIGNED(n_bits - 1 downto 0);
           clock : in std_logic;
          --delta:  in UNSIGNED(k_trunc - 1 downto 0);       -- what is the size
           --k       : in integer;                                    -- what is the range
           res :   out UNSIGNED(3+ k_trunc downto 0)   -- how should we return the output ? what is the size of the output after trunctuation
           );

end ecLog;


architecture Behavioral of ecLog is

    component log_v2 is
        Port ( input : in std_logic_vector(n_bits - 1 downto 0);
            res : out integer range 0 to n_bits - 1);
    end component;

	component log_deltas_config_2 is
		port (
			clka : in std_logic;
			addra : in std_logic_vector(mL - 1 downto 0);
			douta : out std_logic_vector(k_trunc - 1 downto 0)
		);
	end component;


    component log_deltas is
        Port (frac : in unsigned(mL - 1 downto 0);
            delta : out unsigned(k_trunc-1 downto 0));
    end component;

    --signal log : std_logic_vector (
    signal log : integer range 0 to n_bits; --TODO
    signal frac : UNSIGNED( k_trunc - 1 downto 0);   -- will be trunctuated to have k bits
    signal delta: unsigned(k_trunc-1 downto 0);
    signal lg: unsigned(3+k_trunc downto 0);
    signal char : unsigned(3 downto 0);

    signal not_clock : std_logic;

begin
	not_clock <= not clock;

   get_log: log_v2 port map (input => std_logic_vector(input),
                            res => log);

    get_deltas : if CONFIG = 1 or CONFIG = 2 generate
        get_deltas_lut : log_deltas port map (
            frac => frac(k_trunc - 1 downto k_trunc - mL),
            delta => delta
        );
    end generate;

    -- get_deltas_config_2 : if CONFIG = 2 generate
    --     ge_deltas_2 : log_deltas_config_2 port map (
    --         clka => not_clock,
    --         addra => std_logic_vector(frac(k_trunc - 1 downto k_trunc - mL)),
    --         unsigned(douta) => delta
    --     );
    -- end generate;

    frac <= (others=>'0') when log = 0 else
            unsigned(shift_left(resize(unsigned(input), k_trunc), k_trunc - log));

    char <= TO_UNSIGNED(log,4);  --?      -- converting log to int
    lg <= char & frac; -- concatenating char,frac
    res <= lg + delta; --Need to get this here based on the frac



end Behavioral;
