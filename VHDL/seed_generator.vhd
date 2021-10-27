-- Seed generator, based on uniform_rng
-- Generates a random 32 bit number
-- DEPRECATED

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.data_types.all;

entity seed_generator_DEPRECATED is
	port (
		master_seed : in unsigned(31 downto 0);
		clock, reset, start : in std_logic;
		random_number : out unsigned(31 downto 0)
	);
end;

architecture behavioural of seed_generator_DEPRECATED is

	signal rand : unsigned(31 downto 0) := MASTER_SEED;
	signal feedback : std_logic;

begin
	feedback <= rand(31) xnor rand(21) xnor rand(1) xnor rand(0);
--	feedback <= rand(30) xnor rand(27);
--	feedback <= rand(63) xnor rand(62) xnor rand(60) xnor rand(59);

	-- Uniform random number generation credit: https://hforsten.com/generating-normally-distributed-pseudorandom-numbers-on-a-fpga.html
	process(clock, reset)
--		variable negate : boolean := false;
	begin
		if reset = '1' then
			rand <= MASTER_SEED;
--			negate := false;
		elsif rising_edge(clock) and start = '1' then
			rand <= feedback & rand(31 downto 1);
--			rand <= rand(62 downto 0) & feedback;
--			negate := not negate;
		end if;

--		if negate then
--			random_number <= not rand;
--		else
--			random_number <= rand;
--		end if;
	end process;

	-- Sample every 2 bits
	assign_output : for i in 0 to 31 generate
		random_number(i) <= rand(i);
	end generate;

end behavioural;
