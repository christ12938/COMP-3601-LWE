-- Key generation module

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;

entity key_generation is
	port (
		reset : in std_logic;
		clock : in std_logic;

--		seed_in : in unsigned(n_bits * 2 - 1 downto 0);

		-- Starts the state machine
		start : in std_logic;

		a_in : in array_t(0 to a_width - 1);
		q_in : in unsigned(n_bits - 1 downto 0);
		s_in : in array_t(0 to s_height - 1);

		-- Asserts when the state machine is finished
		done : out std_logic;

		-- Block RAM addresses
		a_bram_address : out unsigned(a_bram_address_width - 1 downto 0);
		b_bram_address : out unsigned(b_bram_address_width - 1 downto 0);

		q_out : out unsigned(n_bits - 1 downto 0);
		q_valid : out std_logic;
		a_out : out array_t(0 to a_width - 1);
		a_valid : out std_logic;
		b_out : out unsigned(n_bits - 1 downto 0);
		b_valid : out std_logic;
		s_out : out array_t(0 to s_height - 1);
		s_valid : out std_logic
	);
end key_generation;

architecture behavioural of key_generation is
	component uniform_rng
		port (
			cap : in std_logic_vector(n_bits - 1 downto 0);
			seed : in std_logic_vector(63 downto 0);
			clk, reset, start_signal : in std_logic;
			random_number : out std_logic_vector(n_bits - 1 downto 0)
		);
	end component;

	component gen_q is
		port (
			clock : in std_logic;
			reset : std_logic;
			seed : in unsigned(63 downto 0);
			seed_valid : in std_logic;
			random_prime : out unsigned(n_bits - 1 downto 0)
		);
	end component;

	component genB is
		port (
			clock, reset, start : in std_logic;
			A, S : in array_t(0 to a_width - 1);
			seed : in unsigned(63 downto 0);
			seed_valid : in std_logic;
			Q : in unsigned(n_bits - 1 downto 0);
			B : out unsigned(n_bits - 1 downto 0);
			done : out std_logic
		);
	end component;

	-- component seed_generator is
	-- 	port (
	-- 		master_seed : in unsigned(63 downto 0);
	-- 		clock, reset, start : in std_logic;
	-- 		random_number : out unsigned(31 downto 0)
	-- 	);
	-- end component;

	-- Seed generation signals
	signal rng_bank_seed_valid : std_logic_vector(0 to a_width - 1) := (others => '0');
	signal gen_q_seed_valid, gen_b_seed_valid : std_logic := '0';
	signal seed_gen_out : unsigned(31 downto 0);
	-- Number of random number generators that need seeding
	-- +2 for gen_q and gen_b
	constant NUM_GENERATORS : positive := a_width + 2;

	signal rng_out : array_t(0 to a_width - 1);

	type key_gen_state is (
		s_idle,
		s_gen_seeds,
		s_gen_q,
		s_gen_s,
		s_gen_a,
		s_gen_b_wait,
		s_gen_b_work,
		s_finished
	);
	constant S_GEN_B_WAIT_DURATION : positive := 2;

	signal current_state : key_gen_state := s_idle;
	signal next_state : key_gen_state := s_idle;

	signal gen_b_start : std_logic := '0';
	signal gen_b_done : std_logic := '0';

	-- Counter to count to matrix height for A block RAM
	signal counter_a_enable : std_logic := '0';
	signal counter_a : integer range 0 to a_height := 0;
	signal counter_a_reset_synchronous : std_logic := '0';

	-- Counter to count to vector height for B block RAM
	signal counter_b_enable : std_logic := '0';
	signal counter_b : integer range 0 to b_height := 0;
	signal counter_b_reset_synchronous : std_logic := '0';

	-- Counter to count how many clocks gen_b is taking
	constant GEN_B_CLOCKS : positive := 5;
	signal counter_c_enable : std_logic := '0';
	signal counter_c : integer range 0 to GEN_B_CLOCKS := 0;
	signal counter_c_reset_synchronous : std_logic := '0';
begin
	-- Seed generation
	-- seed_gen : seed_generator
	-- port map (
	-- 	master_seed => MASTER_SEED,
	-- 	clock => clock,
	-- 	reset => reset,
	-- 	start => '1',
	-- 	random_number => seed_gen_out
	-- );


	-- Prime generation
	prime_generator : gen_q
	port map (
		clock => clock,
		reset => reset,
		-- seed => seed_gen_out,
		seed => SEEDS(16),
		seed_valid => gen_q_seed_valid,
		random_prime => q_out
	);

	-- Generate a_width generators, these generators are used for A and s
	rng_bank : for i in 0 to a_width - 1 generate
		rng : uniform_rng
		port map (
			-- seed => std_logic_vector(seed_gen_out),
			seed => std_logic_vector(SEEDS(i)),
			cap => std_logic_vector(to_unsigned(max_q, n_bits)),
			clk => clock,
			reset => reset or rng_bank_seed_valid(i),
			unsigned(random_number) => rng_out(i),
			start_signal => '1'
		);
	end generate;
	-- a_out and s_out are directly connected to the RNG output, only use when a_valid and s_valid are asserted
	a_out <= rng_out;
	s_out <= rng_out;

	-- State transition
	process(clock, reset) begin
		if reset = '1' then
			current_state <= s_idle;
--			next_state <= current_state;
		elsif rising_edge(clock) then
			current_state <= next_state;
		end if;
	end process;

	-- Vector B generation module
	gen_b : genB
	port map (
		Clock => clock,
		Reset => reset,
		Start => gen_b_start,
		seed => SEEDS(17),
		seed_valid => gen_b_seed_valid,
		A => a_in,
		S => s_in,
		Q => q_in,
		B => b_out,
		Done => gen_b_done
	);

	-- Counter for matrix A height
	count_a : process(clock, reset)
		variable counter_a_variable : integer range 0 to a_height := 0;
	begin
		if reset = '1' then
			counter_a_variable := 0;
		elsif rising_edge(clock) then
			if counter_a_reset_synchronous = '1' then
				counter_a_variable := 0;
			elsif counter_a_enable = '1' then
				counter_a_variable := counter_a_variable + 1;
			end if;
		end if;
		counter_a <= counter_a_variable;
	end process;

	-- Counter for vector B height
	count_b : process(clock, reset)
		variable counter_b_variable : integer range 0 to GEN_B_CLOCKS := 0;
	begin
		if reset = '1' then
			counter_b_variable := 0;
		elsif rising_edge(clock) then
			if counter_b_reset_synchronous = '1' then
				counter_b_variable := 0;
			elsif counter_b_enable = '1' then
				counter_b_variable := counter_b_variable + 1;
			end if;
		end if;
		counter_b <= counter_b_variable;
	end process;

	-- Counter for clocks taken by gen_b
	count_c : process(clock, reset)
		variable counter_c_variable : integer range 0 to b_height := 0;
	begin
		if reset = '1' then
			counter_c_variable := 0;
		elsif rising_edge(clock) then
			if counter_c_reset_synchronous = '1' then
				counter_c_variable := 0;
			elsif counter_c_enable = '1' then
				counter_c_variable := counter_c_variable + 1;
			end if;
		end if;
		counter_c <= counter_c_variable;
	end process;

	a_bram_address <= to_unsigned(counter_a, a_bram_address'length);
	b_bram_address <= to_unsigned(counter_b, b_bram_address'length);

	-- State outputs
	process(clock, current_state, start, counter_a, counter_b, counter_c)
	begin

		-- Default behaviours
		next_state <= current_state;
		done <= '0';
		a_valid <= '0';
		q_valid <= '0';
		b_valid <= '0';
		s_valid <= '0';
		gen_b_start <= '0';

		counter_a_enable <= '0';
		counter_b_enable <= '0';
		counter_c_enable <= '0';
		counter_a_reset_synchronous <= '0';
		counter_b_reset_synchronous <= '0';
		counter_c_reset_synchronous <= '0';

		gen_q_seed_valid <= '0';
		gen_b_seed_valid <= '0';
		rng_bank_seed_valid <= (others => '0');

		case current_state is
		when s_idle =>
			if start = '1' then
				next_state <= s_gen_q;
			end if;

		-- when s_gen_seeds =>
		-- 	-- Seed generation
		-- 	-- Use counter A
		-- 	counter_a_enable <= '1';

		-- 	if counter_a = NUM_GENERATORS - 1 then
		-- 		-- Counter done, everything has been seeded
		-- 		counter_a_reset_synchronous <= '1';
		-- 		next_state <= s_gen_q;
		-- 	end if;

		-- 	if counter_a = NUM_GENERATORS - 1 - 1 then
		-- 		-- gen_q's turn for seed
		-- 		gen_q_seed_valid <= '1';
		-- 	end if;

		-- 	if counter_a = NUM_GENERATORS - 1 - 2 then
		-- 		-- gen_b's turn for seed
		-- 		gen_b_seed_valid <= '1';
		-- 	end if;

		-- 	if counter_a < a_width then
		-- 		-- rng_bank's turn for seed
		-- 		rng_bank_seed_valid(counter_a) <= '1';
		-- 	end if;

		when s_gen_q =>
			-- The random number generators are connected to q_out and are always running
			-- We just take the random number at this clock cycle
			q_valid <= '1';
			next_state <= s_gen_s;


		when s_gen_s =>
			-- The random number generators are connected to s_out and are always running
			-- We just take the random number at this clock cycle
			s_valid <= '1';
			next_state <= s_gen_a;

		when s_gen_a =>
			-- As long as we're still in gen_a state, a is valid
			a_valid <= '1';

			if counter_a = a_height - 1 then
				-- Counter done
				next_state <= s_gen_b_wait;

				-- Ready the counters for the next state
				counter_a_reset_synchronous <= '1';
				counter_b_reset_synchronous <= '1';
				counter_c_reset_synchronous <= '1';
			else
				counter_a_enable <= '1';
			end if;

		when s_gen_b_wait =>
			-- 2 clock cycle to wait for the block RAM A to have the right output ready
			-- Just use counter c
			counter_c_enable <= '1';
			if counter_c = S_GEN_B_WAIT_DURATION - 1 then
				-- If it's been 2 clock cycles, move on
				counter_c_reset_synchronous <= '1';
				next_state <= s_gen_b_work;
			end if;

		when s_gen_b_work =>
			gen_b_start <= '1';
			counter_c_enable <= '1';

			if counter_b = b_height - 1 and counter_c = GEN_B_CLOCKS - 1 then
				-- Everything is done
				next_state <= s_finished;

				counter_a_reset_synchronous <= '1';
				counter_b_reset_synchronous <= '1';
				counter_c_reset_synchronous <= '1';
			end if;

			if counter_c = GEN_B_CLOCKS - 1 then
				-- gen_b has done a full cycle
				counter_b_enable <= '1';
				counter_c_reset_synchronous <= '1';
				b_valid <= '1';
			end if;

			if counter_c = GEN_B_CLOCKS - 1 - 1 then
				-- Pre-emptively increment the A block RAM address 1 clock before gen_b is expected to finish (because the block RAM takes 2 clocks to update)
				counter_a_enable <= '1';
			end if;

			-- if gen_b_done = '1' then
			-- 	-- gen_b is finished
			-- 	-- Acknowledge by de-asserting gen_b_start
			-- 	gen_b_start <= '0';
			-- 	-- Tell external components gen_b is valid
			-- 	b_valid <= '1';

			-- 	if counter = b_height - 1 then
			-- 		-- Counter is done, meaning we've written all of vector B
			-- 		next_state <= s_finished;
			-- 		counter_reset_synchronous <= '1';
			-- 	else
			-- 		-- Counter isn't done, so continue with the next element of vector B
			-- 		-- Increment the counter
			-- 		counter_enable <= '1';
			-- 		-- Go wait a clock cycle for the block RAM to work
			-- 		next_state <= s_gen_b_wait;
			-- 	end if;
			-- end if;
				-- gen_b is still working

		when s_finished =>
			done <= '1';
			-- report "Key generation finished" severity note;

		when others =>
			report "Key generation in an invalid state" severity error;
		end case;

	end process;
end behavioural;
