----------------------------------------------------------------------------------
-- writer:
-- v1 by Farnaz Tavakol
-- v2 by Dongzhu Huang
--
-- Create Date: 25.09.2021 22:15:08
-- Design Name:
-- Module Name: log - Behavioral

-- TODO: return the fraction part of the log (second task/not necessary for the first one)
--
--

----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use work.data_types.all;

entity log is
		port ( input : in std_logic_vector(n_bits - 1 downto 0);
					 res : out integer range 0 to n_bits - 1);
end log;


architecture behavioral of log is

begin
	-- This is essentially a priority encoder with the MSB taking priority
	-- ----------------------------------------------------------------------------
	--                                 Version 2
	-- ----------------------------------------------------------------------------
	process(input)
	begin
		res <= 0;
		for i in 0 to n_bits - 1 loop
			if input(i) = '1' then
				res <= i;
			end if;
		end loop;
	end process;

	-- ----------------------------------------------------------------------------
	--                                 Version 1
	-- ----------------------------------------------------------------------------
	--  get_log : process(input)
	-- 		 variable flag : std_logic := '0';
	--  begin
	-- 		for i in n_bits - 1 downto 0 loop
	-- 			if (input(i) = '1' and flag = '0') then
	-- 				res <= i;
	-- 				flag := '1';
	-- 			end if;
	-- 		 end loop;
	-- 	end process;

end behavioral;
