-- Key generation module

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;

entity key_generation is
	port (
		reset_n : in std_logic;
		clock : in std_logic;

		-- Starts the state machine
		start : in std_logic;

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
			prime : in std_logic_vector(15 downto 0);
			seed : in std_logic_vector(31 downto 0);
			clk, reset, start_signal : in std_logic;
			width : in integer := 16;
			random_number : out std_logic_vector(15 downto 0)
		);
	end component;
	
	component unsigned_counter is
		generic (
			BIT_WIDTH : positive := 32
		);
		port (
			clock : in std_logic;
			reset_n : in std_logic;
			enable : in std_logic;
			
			count : out unsigned(BIT_WIDTH - 1 DOWNTO 0)
		);
	end component;
	
	signal reset : std_logic := '1';

	type rng_vec_t is array(natural range <>) of std_logic_vector(15 downto 0);
	signal rng_vector : rng_vec_t(0 to a_width - 1);

	type key_gen_state is (idle, gen_q, gen_s, gen_a, gen_b, finished);
	signal current_state : key_gen_state := idle;
	signal next_state : key_gen_state := idle;

	signal gen_q_valid : std_logic := '0';
	signal gen_q_start : std_logic := '0';

	signal counter : unsigned(a_bram_address_width - 1 downto 0);
	signal counter_enable : std_logic := '0';
	signal counter_reset_n : std_logic := '0';
begin
	reset <= not reset_n;

	-- Generate a_width generators, these generators are used for A and s
	a_row_generators : for i in 0 to a_width - 1 generate
		a_row_generator : uniform_rng
		port map (
			seed => std_logic_vector(SEED + i),
			prime => std_logic_vector(to_unsigned(max_q, RNG_BIT_WIDTH)),
			clk => clock,
			reset => reset,
			random_number => rng_vector(i),
			start_signal => '1'
		);
		
		-- uniform_rng always gives 16 bit numbers so it must be resized to n_bits
		a_out(i) <= resize(unsigned(rng_vector(i)), n_bits);
		s_out(i) <= resize(unsigned(rng_vector(i)), n_bits);
	end generate;

	-- Counter for block RAM addressing
	address_counter : unsigned_counter
	generic map (BIT_WIDTH => a_bram_address_width)
	port map (
		clock => clock,
		reset_n => counter_reset_n,
		enable => counter_enable,
		count => counter
	);

	-- State transition
	process(clock, reset_n)
	begin
		if reset_n = '0' then
			current_state <= idle;
			next_state <= idle;
		elsif rising_edge(clock) then
			current_state <= next_state;
		end if;
	end process;

	-- State outputs
	process
	begin
		-- Default behaviours
		next_state <= current_state;
		done <= '0';
		gen_q_start <= '0';
		gen_q_valid <= '0';
		q_valid <= '0';
		a_valid <= '0';
		b_valid <= '0';
		s_valid <= '0';
		counter_enable <= '0';
		counter_reset_n <= '1';
		case current_state is
		when idle =>
			if start = '1' then
				next_state <= gen_q;
			end if;
		when gen_q =>
			if gen_q_valid = '1' then
				-- q generation is finished
				q_valid <= '1';
				next_state <= gen_s;
			else
				-- q generation hasn't finished or is starting
				gen_q_start <= '1';
			end if;
		when gen_s =>
			-- The random number generators are connected to s_out
			s_valid <= '1';
			next_state <= gen_a;
		when gen_a =>
			-- TODO
		when gen_b =>
			-- TODO
		when finished =>
			-- TODO
		when others =>
		end case;

	end process;
end behavioural;
