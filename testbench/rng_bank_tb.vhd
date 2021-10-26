library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;
use std.textio.all;

entity rng_bank_tb is
end entity;

architecture behavioural of rng_bank_tb is

	component uniform_rng
		port (
			cap : in std_logic_vector(n_bits - 1 downto 0);
			seed : in std_logic_vector(63 downto 0);
			clk, reset, start_signal : in std_logic;
			random_number : out std_logic_vector(n_bits - 1 downto 0)
		);
	end component;

	component seed_generator is
		port (
			master_seed : in unsigned(31 downto 0);
			clock, reset, start : in std_logic;
			random_number : out unsigned(31 downto 0)
		);
	end component;

	-- -------------------------------- Signals -----------------------------------
	signal clock : std_logic := '1';
	signal reset : std_logic := '0';
	signal rng_out : array_t(0 to a_width - 1);
	constant CLOCK_PERIOD : time := 1 ns;

	signal seed_gen_out : unsigned(31 downto 0);
	signal seed_gen_reset : std_logic := '0';
	signal seed_valid : std_logic_vector(0 to a_width - 1) := (others => '0');

	-- ---------------------------- File Operations -------------------------------
	constant OUTPUT_FILE_NAME : string := "rng_bank_tb_out.txt";
	file file_pointer : text;

	constant USE_SEED_GENERATOR : boolean := false;

begin
	clock <= not clock after CLOCK_PERIOD / 2;

	-- -------------------------------- Stimulus ----------------------------------
  process
		variable line_buffer : line;
		variable number : integer;
	begin

		reset <= '1';
		wait for 5 * CLOCK_PERIOD;
		reset <= '0';
		wait for 10 * CLOCK_PERIOD;

		if USE_SEED_GENERATOR then
			seed_gen_reset <= '1';
			wait for 5 * CLOCK_PERIOD;
			seed_gen_reset <= '0';
			for i in 0 to a_width - 1 loop
				seed_valid(i) <= '1';
				wait until rising_edge(clock);
				seed_valid(i) <= '0';
			end loop;
			seed_valid <= (others => '0');
			wait for 10 * CLOCK_PERIOD;
		end if;


		file_open(file_pointer, OUTPUT_FILE_NAME, write_mode);
		for i in 0 to a_height - 1 loop
			wait until rising_edge(clock);
			for j in 0 to a_width - 1 loop
				write(line_buffer, integer'image(to_integer(rng_out(j))) & " ");
			end loop;
			writeline(file_pointer, line_buffer);
		end loop;
		file_close(file_pointer);

		report "Success, stimulus finished!" severity failure;
	end process;

	uut : for i in 0 to a_width - 1 generate
		rng_bank_conditional_generation : if USE_SEED_GENERATOR generate
			rng : uniform_rng port map (
				seed => std_logic_vector(seed_gen_out),
				-- seed => std_logic_vector(SEEDS(i)),
				cap => std_logic_vector(to_unsigned(max_q, n_bits)),
				clk => clock,
				reset => reset or seed_valid(i),
				unsigned(random_number) => rng_out(i),
				start_signal => '1'
			);

		else generate
			rng : uniform_rng port map (
					-- seed => std_logic_vector(seed_gen_out),
					seed => std_logic_vector(SEEDS(i)),
					cap => std_logic_vector(to_unsigned(max_q, n_bits)),
					clk => clock,
					reset => reset or seed_valid(i),
					unsigned(random_number) => rng_out(i),
					start_signal => '1'
				);
		end generate;
	end generate;

	seed_generator_conditional_generation : if USE_SEED_GENERATOR generate
	seed_gen : seed_generator port map (
		clock => clock,
		reset => seed_gen_reset,
		start => '1',
		master_seed => b"10100011001110100100001100110010",
		random_number => seed_gen_out
	);
	end generate;

end behavioural;
