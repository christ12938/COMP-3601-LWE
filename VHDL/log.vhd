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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity log is
    Port ( input : in STD_LOGIC_vector(15 downto 0);
           res : out integer range 0 to 15);
end log;


architecture Behavioral of log is

begin

    get_log : process(input) 
        variable flag : std_logic := '0';
    begin
        for i in 15 downto 0 loop
            
                if (input(i) = '1' and flag = '0') then
                    res <= i;
                    flag := '1';
                end if;
                
        end loop;
     end process;
end Behavioral;
