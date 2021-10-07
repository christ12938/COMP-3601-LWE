-- Key generation module

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;

entity key_generation is
	port (
		reset : in std_logic;
		clock : in std_logic;

		seed_in : in unsigned(n_bits * 2 - 1 downto 0);

		-- Starts the state machine
		start : in std_logic;

		a_in : in array_t(0 to a_width - 1);
		q_in : in unsigned(n_bits - 1 downto 0);
		s_in : in array_t(0 to s_height - 1);

		-- Asserts when the state machine is finished
		done : out std_logic;

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
			prime : in std_logic_vector(n_bits - 1 downto 0);
			seed : in std_logic_vector(n_bits * 2 - 1 downto 0);
			clk, reset, start_signal : in std_logic;
			width : in integer := n_bits;
			random_number : out std_logic_vector(n_bits - 1 downto 0)
		);
	end component;

	component unsigned_counter is
		generic (
			BIT_WIDTH : positive := 32
		);
		port (
			clock : in std_logic;
			reset : in std_logic;
			enable : in std_logic;

			count : out unsigned(BIT_WIDTH - 1 DOWNTO 0)
		);
	end component;

	component genB is
		port (
			clock, reset, start : in std_logic;
			A, S : in array_t(0 to a_width - 1);
			Q : in unsigned(n_bits - 1 downto 0);
			B : out unsigned(n_bits - 1 downto 0);
			done : out std_logic
		);
	end component;

--	signal reset : std_logic;

	signal rng_out : array_t(0 to a_width - 1);

	type key_gen_state is (
		idle,
		gen_q,
		gen_s,
		gen_a,
		gen_b_init,	gen_b_wait, gen_b_work,
		finished
	);
	
	signal seed : unsigned(n_bits * 2 - 1 downto 0);
	
	signal current_state : key_gen_state := idle;
	signal next_state : key_gen_state := idle;

	signal gen_q_done : std_logic := '0';
	signal gen_q_start : std_logic := '0';

	signal gen_b_start : std_logic := '0';
	signal gen_b_done : std_logic := '0';

	signal counter : unsigned(a_bram_address_width - 1 downto 0);
	signal counter_enable : std_logic := '0';
	signal counter_reset_n : std_logic := '1';
	signal counter_done : std_logic := '0';
begin
--	reset <= not reset_n;
	-- Generate a_width generators, these generators are used for A and s
	a_row_generators : for i in 0 to a_width - 1 generate
		-- Vivado complains if I don't do this with a separate signal
		seed <= seed_in + i;
		a_row_generator : uniform_rng
		port map (
			seed => std_logic_vector(seed),
			prime => std_logic_vector(to_unsigned(max_q, n_bits)),
			clk => clock,
			reset => reset,
			unsigned(random_number) => rng_out(i),
			start_signal => '1'
		);
	end generate;
	-- a_out and s_out are directly connected to the RNG output, only use when a_valid and s_valid are asserted
	a_out <= rng_out;
	s_out <= rng_out;

	-- Counter for block RAM addressing
	address_counter : unsigned_counter
	generic map (BIT_WIDTH => a_bram_address_width)
	port map (
		clock => clock,
		reset => counter_reset_n,
		enable => counter_enable,
		count => counter
	);
	-- Check for counter done
	process(counter) begin
		if counter = a_height then
			counter_done <= '1';
		else
			counter_done <= '0';
		end if;
	end process;

	-- State transition
	process(clock, reset) begin
		if reset = '1' then
			current_state <= idle;
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
		A => a_in,
		S => s_in,
		Q => q_in,
		B => b_out,
		Done => gen_b_done
	);

	-- State outputs
	process(current_state, start, gen_q_done, counter_done, gen_b_done) begin
		-- Default behaviours
		next_state <= current_state;
		done <= '0';
		a_valid <= '0';
		q_valid <= '0';
		b_valid <= '0';
		s_valid <= '0';

		gen_q_start <= '0';
		gen_b_start <= '0';

		counter_enable <= '0';
		counter_reset_n <= '0';

		case current_state is
		when idle =>
			if start = '1' then
				next_state <= gen_q;
			end if;

		when gen_q =>
			if gen_q_done = '1' then
				-- q generation is finished
				q_valid <= '1';
				next_state <= gen_s;
			else
				-- q generation hasn't finished or is starting
				gen_q_start <= '1';
			end if;

		when gen_s =>
			-- The random number generators are connected to s_out and is always running
			-- We just take the random number at this clock cycle
			s_valid <= '1';
			next_state <= gen_a;

		when gen_a =>
			-- As long as we're still in gen_a state, a is valid
			a_valid <= '1';
			-- Counter should not be reset whenever we're in gen_a state
			counter_reset_n <= '1';

			if counter_done = '1' then
				-- Counter is done
				next_state <= gen_b_init;
			else
				-- Counter is still going or it hasn't started
				counter_enable <= '1';

			end if;

		when gen_b_init =>
			-- Reset the counter
			counter_reset_n <= '0';
			next_state <= gen_b_wait;

		when gen_b_wait =>
			-- 1 clock cycle to wait for the block RAM to have the right output ready
			-- Don't reset the counter
			counter_reset_n <= '1';
			-- Tell gen_b to start working
			gen_b_start <= '1';

			next_state <= gen_b_work;

		when gen_b_work =>
			-- Don't reset the counter
			counter_reset_n <= '1';

			if gen_b_done = '1' then
				-- gen_b is finished
				-- Acknowledge by de-asserting gen_b_start
				gen_b_start <= '0';
				-- Tell external components gen_b is valid
				b_valid <= '1';

				if counter_done = '1' then
					-- Counter is done, meaning we've written all of vector B
					next_state <= finished;
				else
					-- Counter isn't done, so continue with the next element of vector B
					-- Increment the counter
					counter_enable <= '1';
					-- Go wait a clock cycle for the block RAM to work
					next_state <= gen_b_wait;
				end if;
			else
				gen_b_start <= '1';
			end if;

		when finished =>
			done <= '1';
			report "Key generation finished" severity note;
		when others =>
			report "Key generation in an invalid state" severity error;
		end case;

	end process;
end behavioural;
