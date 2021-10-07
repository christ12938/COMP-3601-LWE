-- Prime generation module
-- Uses a block RAM with pre-loaded prime numbers as a lookup table

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;

entity gen_q is
	port (
		clock : in std_logic;
		reset : in std_logic;
		seed : in unsigned(n_bits * 2 - 1 downto 0);
		random_prime : out unsigned(n_bits - 1 downto 0)
	);
end gen_q;

architecture behavioural of gen_q is
	-- Random number generator
	component uniform_rng
		port (
			prime : in std_logic_vector(n_bits - 1 downto 0);
			seed : in std_logic_vector(n_bits * 2 - 1 downto 0);
			clk, reset, start_signal : in std_logic;
			width : in integer := n_bits - 1;
			random_number : out std_logic_vector(n_bits - 1 downto 0)
		);
	end component;

	-- Block RAM for primes configuration 1
	component primes_config_1 is
		port (
			clka : in std_logic;
			addra : in std_logic_vector(primes_bram_address_width - 1 downto 0);
			douta : out std_logic_vector(n_bits - 1 downto 0)
		);
	end component;

	-- Block RAM for primes configuration 2
	component primes_config_2 is
		port (
			clka : in std_logic;
			addra : in std_logic_vector(primes_bram_address_width - 1 downto 0);
			douta : out std_logic_vector(n_bits - 1 downto 0)
		);
	end component;

	-- Block RAM for primes configuration 3
	component primes_config_3 is
		port (
			clka : in std_logic;
			addra : in std_logic_vector(primes_bram_address_width - 1 downto 0);
			douta : out std_logic_vector(n_bits - 1 downto 0)
		);
	end component;

	signal address : unsigned(primes_bram_address_width - 1 downto 0) := to_unsigned(0, primes_bram_address_width);
	signal random_number : unsigned(n_bits - 1 downto 0);
begin
	-- Random number generator
	rng : uniform_rng
	port map (
		clk => clock,
		reset => reset,
		start_signal => '1',

		seed => std_logic_vector(seed),
		prime => std_logic_vector(to_unsigned(num_primes - 1, n_bits)),
		width => n_bits - 1,
		unsigned(random_number) => random_number
	);

	address <= resize(random_number, address'length);

	-- This section uses an if generate because the block RAM was generated via the Vivado UI, so the block RAM VHDL implementation isn't available
	-- Block ROM holding hard coded prime numbers for each configuration
	primes_bram_config_1 : if (CONFIG = 1) generate
		primes_bram_config_1 : primes_config_1
		port map (
			clka => clock,
			addra => std_logic_vector(address),
			unsigned(douta) => random_prime
		);
	end generate;
	primes_bram_config_2 : if (CONFIG = 2) generate
		primes_bram_config_2 : primes_config_2
		port map (
			clka => clock,
			addra => std_logic_vector(address),
			unsigned(douta) => random_prime
		);
	end generate;
	primes_bram_config_3 : if (CONFIG = 3) generate
		primes_bram_config_3 : primes_config_3
		port map (
			clka => clock,
			addra => std_logic_vector(address),
			unsigned(douta) => random_prime
		);
	end generate;
end;
