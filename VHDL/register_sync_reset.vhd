-- Based on the synchronous reset register from COMP3222

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- n-bit register with asynchronous reset
entity register_sync_reset is
	generic (n : positive := 8);
	port (
		d : in std_logic_vector(n - 1 downto 0);
		e : in std_logic;
		reset : in std_logic;
		clock : in std_logic;
		q : out std_logic_vector(n - 1 downto 0)
	);
end register_sync_reset;

architecture behaviour of register_sync_reset is
begin
	process(clock, reset) begin
		if rising_edge(clock) then
			if reset = '1' then
				q <= (others => '0');
			elsif e = '1' then
				q <= d;
			end if;
		end if;
	end process;
end behaviour;
