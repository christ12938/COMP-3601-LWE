-- Based on the synchronous reset register from COMP3222

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- n-bit register with asynchronous reset
entity register_async_reset is
	generic (n : positive := 8);
	port (
		d : in std_logic_vector(n - 1 downto 0);
		e : in std_logic;
		reset : in std_logic;
		clock : in std_logic;
		q : out std_logic_vector(n - 1 downto 0)
	);
end register_async_reset;

architecture behaviour of register_async_reset is
begin
	process(clock) begin
		if reset = '1' then
			q <= (others => '0');
		elsif rising_edge(clock) and e = '1' then
			q <= d;
		end if;
	end process;
end behaviour;
