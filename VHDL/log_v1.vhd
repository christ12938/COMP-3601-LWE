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
           res : out integer range 0 to n_bits - 1);   --start signal for random number generator
           
end log_v1;


architecture Behavioral of log_v1 is

begin

    get_log : process(input)
        variable flag : std_logic := '0';
    begin
        for i in n_bits - 1 downto 0 loop

                if (input(i) = '1' and flag = '0') then
                    res <= i;
                    flag := '1';
                end if;

        end loop;
     end process;

end Behavioral;
