library ieee;
use ieee.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.data_types.all;

entity gen_q_tb is
	port (
		random_prime : out unsigned(n_bits - 1 downto 0)
	);
end;

architecture behavioural of gen_q_tb is
	component gen_q
	port (
		clock : in std_logic;
		reset : in std_logic;
		seed : in unsigned(n_bits * 2 - 1 downto 0);
		random_prime : out unsigned(n_bits - 1 downto 0)
	);
	end component;

	constant CLOCK_PERIOD : time := 20 ns;

	signal clock : std_logic := '0';
	signal reset : std_logic := '0';
begin
	-- Clock
	clock <= not clock after CLOCK_PERIOD / 2;

	-- Stimulus
	process begin
		reset <= '1';
		wait for 5 * CLOCK_PERIOD;
		reset <= '0';
		wait;
	end process;

	UUT : gen_q
	port map (
		clock => clock,
		reset => reset,
		seed => SEED,
		random_prime => random_prime
	);


end behavioural;
