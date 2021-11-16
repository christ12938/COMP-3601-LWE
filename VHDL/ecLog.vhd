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

entity log_v1 is
    Port ( input : in UNSIGNED(n_bits - 1 downto 0);
          delta:  in UNSIGNED(k_trunc - 1 downto 0);       -- what is the size
           --k       : in integer;                                    -- what is the range
           res :   out UNSIGNED(n_bits - 1 downto 0);   -- how should we return the output ? what is the size of the output after trunctuation
           frac_output:   out unsigned (mL - 1  downto 0)); -- replaced with ML

end log_v1;


architecture Behavioral of log_v1 is

component log_v1 is
    Port ( input : in UNSIGNED(n_bits - 1 downto 0);
           res : out integer range 0 to n_bits - 1); 
end component; 

component barell_shifter is
    Port ( input : UNSIGNED(n_bits-1 downto 0);    -- what is the type here?
               log : in integer;      -- how many bits to rol by
               output : out UNSIGNED(n_bits-1 downto 0));
end component;
    
--signal log : std_logic_vector ( 
signal log : integer range n_bits to 0;
signal frac : UNSIGNED( n_bits -1 downto 0);   -- will be trunctuated to have k bits

begin


   get_log: log_v1 port map (input => input,
                            res => log);
                            
   get_frac: barell_shifter port map ( input => input,
                                       log => log,
                                       output => frac);
process(input)
variable lg: unsigned(n_bits-1 downto 0);
variable char : unsigned(n_bits downto 0);

begin                              
    char:= TO_UNSIGNED(log,n_bits);        -- converting log to int 
    lg := char(n_bits-k-1 downto 0) & frac(k downto 0); -- concatenating char,frac
    res <= lg + delta; --Need to get this here based on the frac 
    frac_output <= frac;
end process;
    

end Behavioral;
