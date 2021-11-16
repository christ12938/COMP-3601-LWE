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
          --delta:  in UNSIGNED(k_trunc - 1 downto 0);       -- what is the size
           --k       : in integer;                                    -- what is the range
           res :   out UNSIGNED(3+ k_trunc downto 0);   -- how should we return the output ? what is the size of the output after trunctuation
           frac_output:   out unsigned (k_trunc -1  downto 0)); -- replaced with ML

end ecLog;


architecture Behavioral of ecLog is

component log_v2 is
    Port ( input : in std_logic_vector(n_bits - 1 downto 0);
           res : out integer range 0 to n_bits - 1); 
end component; 

component barell_shifter is
    Port ( input : UNSIGNED(n_bits-1 downto 0);    -- what is the type here?
               log : in integer;      -- how many bits to rol by
               output : out UNSIGNED(n_bits-1 downto 0));
end component;
    
    
component log_deltas is
    Port (frac : in unsigned(6 downto 0);
          delta : out unsigned(k_trunc-1 downto 0));
end component;    
--signal log : std_logic_vector ( 
signal log : integer range n_bits to 0;
signal frac : UNSIGNED( n_bits -1 downto 0);   -- will be trunctuated to have k bits
signal delta: unsigned(k_trunc-1 downto 0);
signal lg: unsigned(3+k_trunc downto 0);
signal char : unsigned(3 downto 0);

begin


   get_log: log_v2 port map (input => std_logic_vector(input),
                            res => log);
                            
   get_frac: barell_shifter port map ( input => input,
                                       log => log,
                                       output => frac);

    get_delta: log_deltas port map( frac => frac(n_bits-1 downto n_bits-7), -- replace this with ML
                                    delta => delta);
                            
    char <= TO_UNSIGNED(log,4);        -- converting log to int 
    lg <= char & frac(k_trunc-1 downto 0); -- concatenating char,frac
    res <= lg + delta; --Need to get this here based on the frac 
    frac_output <= frac(n_bits-1 downto n_bits-k_trunc);

    

end Behavioral;
