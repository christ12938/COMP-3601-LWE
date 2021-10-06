library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unsigned_counter is
	generic (
		BIT_WIDTH : positive := 32
	);
	port (
		clock : in std_logic;
		reset_n : in std_logic;
		enable : in std_logic;
		
		count : out unsigned(BIT_WIDTH - 1 DOWNTO 0)
	);
end unsigned_counter;

architecture behavioural of unsigned_counter is
	signal internal_count : unsigned(BIT_WIDTH - 1 DOWNTO 0) := to_unsigned(0, BIT_WIDTH);
begin
	process(clock, reset_n)
	begin
		if reset_n = '0' then
			internal_count <= to_unsigned(0, internal_count'length);
		elsif rising_edge(clock) and enable = '1' then
			internal_count <= internal_count + 1;
		end if;
	end process;
	count <= internal_count;
end behavioural;
