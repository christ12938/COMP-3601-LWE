library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;


entity key_generation_tb is
end key_generation_tb;

architecture behavioural of key_generation_tb is
component key_generation is
	port (
		reset : in std_logic;
		clock : in std_logic;

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
end component;

	constant CLOCK_PERIOD : time := 20 ns;
	signal clock, reset, start, done : std_logic := '0';
	
	signal a_in, s_in : array_t(0 to a_width - 1) := (others => (others => '0'));
	signal q_in : unsigned(n_bits - 1 downto 0) := (others => '0');
	
	signal q_out, b_out : unsigned(n_bits - 1 downto 0);
	signal a_out : array_t(0 to a_width - 1);
	signal s_out : array_t(0 to s_height - 1);
	signal a_valid, b_valid, s_valid, q_valid : std_logic;

	
begin
	clock <= not clock after CLOCK_PERIOD / 2;
	
	-- Stimulus
	process begin
		reset <= '1';
		wait for CLOCK_PERIOD * 10;
		reset <= '0';
		
		wait for CLOCK_PERIOD * 10;
		start <= '1';
		wait;
	end process;

	UTT : key_generation
	port map (
		clock => clock,
		reset => reset,
		start => start,
		a_in => a_in,
		q_in => q_in,
		s_in => s_in,
		done => done,
		q_out => q_out,
		a_out => a_out,
		b_out => b_out,
		s_out => s_out,
		q_valid => q_valid,
		a_valid => a_valid,
		b_valid => b_valid,
		s_valid => s_valid		
	);
end behavioural;
