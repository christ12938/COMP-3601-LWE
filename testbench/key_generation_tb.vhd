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
	end component;

	-- Block RAM for storing matrix A in configuration 1
	component a_bram_config_1 is
		port (
			addra : in std_logic_vector(a_bram_address_width - 1 downto 0);
			clka: in std_logic;
			dina : in std_logic_vector(a_bram_data_width - 1 downto 0);
			douta : out std_logic_vector(a_bram_data_width - 1 downto 0);
			wea : in std_logic_vector(0 to 0);
			rsta : in std_logic;
			rsta_busy : out std_logic
		);
	end component;
	-- Block RAM for storing matrix A in configuration 2
	component a_bram_config_2 is
		port (
			addra : in std_logic_vector(a_bram_address_width - 1 downto 0);
			clka: in std_logic;
			dina : in std_logic_vector(a_bram_data_width - 1 downto 0);
			douta : out std_logic_vector(a_bram_data_width - 1 downto 0);
			wea : in std_logic_vector(0 to 0);
			rsta : in std_logic;
			rsta_busy : out std_logic
		);
	end component;
	-- Block RAM for storing matrix A in configuration 3
	component a_bram_config_3 is
		port (
			addra : in std_logic_vector(a_bram_address_width - 1 downto 0);
			clka: in std_logic;
			dina : in std_logic_vector(a_bram_data_width - 1 downto 0);
			douta : out std_logic_vector(a_bram_data_width - 1 downto 0);
			wea : in std_logic_vector(0 to 0);
			rsta : in std_logic;
			rsta_busy : out std_logic
		);
	end component;

	-- Block RAM for storing vector B in configuration 1
	component b_bram_config_1 is
		port (
			addra : in std_logic_vector(b_bram_address_width - 1 downto 0);
			clka: in std_logic;
			dina : in std_logic_vector(n_bits - 1 downto 0);
			douta : out std_logic_vector(n_bits - 1 downto 0);
			wea : in std_logic_vector(0 to 0);
			rsta : in std_logic;
			rsta_busy : out std_logic
		);
	end component;
	-- Block RAM for storing vector B in configuration 2
	component b_bram_config_2 is
		port (
			addra : in std_logic_vector(b_bram_address_width - 1 downto 0);
			clka: in std_logic;
			dina : in std_logic_vector(n_bits - 1 downto 0);
			douta : out std_logic_vector(n_bits - 1 downto 0);
			wea : in std_logic_vector(0 to 0);
			rsta : in std_logic;
			rsta_busy : out std_logic
		);
	end component;
	-- Block RAM for storing vector B in configuration 3
	component b_bram_config_3 is
		port (
			addra : in std_logic_vector(b_bram_address_width - 1 downto 0);
			clka: in std_logic;
			dina : in std_logic_vector(n_bits - 1 downto 0);
			douta : out std_logic_vector(n_bits - 1 downto 0);
			wea : in std_logic_vector(0 to 0);
			rsta : in std_logic;
			rsta_busy : out std_logic
		);
	end component;

	component register_async_reset is
		generic (n : positive := 8);
		port (
			d : in std_logic_vector(n - 1 downto 0);
			e, reset, clock : in std_logic;
			q : out std_logic_vector(n - 1 downto 0)
		);
	end component;

	signal clock, reset, start, done : std_logic := '0';

	signal a_in, s_in : array_t(0 to a_width - 1) := (others => (others => '0'));
	signal q_in : unsigned(n_bits - 1 downto 0) := (others => '0');

	signal q_out, b_out : unsigned(n_bits - 1 downto 0);
	signal a_out : array_t(0 to a_width - 1);
	signal s_out : array_t(0 to s_height - 1);
	signal a_valid, b_valid, s_valid, q_valid : std_logic;

	signal a_bram_data_in_array, a_bram_data_out_array : array_t(0 to a_width - 1);
	signal a_bram_data_in, a_bram_data_out : std_logic_vector(a_bram_data_width - 1 downto 0);
	signal a_bram_address : unsigned(a_bram_address_width - 1 downto 0);
	signal a_bram_write_enable : std_logic := '0';

	signal b_bram_data_in, b_bram_data_out : unsigned(n_bits - 1 downto 0);
	signal b_bram_address : unsigned(b_bram_address_width - 1 downto 0);
	signal b_bram_write_enable : std_logic := '0';

	constant CLOCK_PERIOD : time := 1 ns;

begin
	clock <= not clock after CLOCK_PERIOD / 2;

	a_bram_write_enable <= a_valid;
	a_bram_data_in_array <= a_out;
	a_in <= a_bram_data_out_array;
	a_bram_signal_conversion : for i in 0 to a_width - 1 generate
		a_bram_data_in((i + 1) * n_bits - 1 downto i * n_bits) <= std_logic_vector(a_bram_data_in_array(i));
		a_bram_data_out_array(i) <= unsigned(a_bram_data_out((i + 1) * n_bits - 1 downto i * n_bits));
	end generate;

	b_bram_data_in <= b_out;
	b_bram_write_enable <= b_valid;

	-- Stimulus
	process begin
		reset <= '1';
		wait for CLOCK_PERIOD * 10;
		reset <= '0';

		wait for CLOCK_PERIOD * 10;
		start <= '1';
		wait;
	end process;

	UUT : key_generation
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
		s_valid => s_valid,
		a_bram_address => a_bram_address,
		b_bram_address => b_bram_address
	);

	-- q register
	q_reg : register_async_reset
	generic map (n => n_bits)
	port map (
		d => std_logic_vector(q_out),
		e => q_valid,
		reset => reset,
		clock => clock,
		unsigned(q) => q_in
	);

	-- s registers
	s_registers_generate : for i in 0 to s_height - 1 generate
		s_register : register_async_reset
		generic map (n => n_bits)
		port map (
			d => std_logic_vector(s_out(i)),
			e => s_valid,
			reset => reset,
			clock => clock,
			unsigned(q) => s_in(i)
		);
	end generate;

	-- This section uses an if generate because the block RAM was generated via the Vivado UI, so the block RAM VHDL implementation isn't available
	-- Block RAM for matrix A
	a_bram_config_1_generate : if (CONFIG = 1) generate
		a_bram : a_bram_config_1
		port map (
			addra => std_logic_vector(a_bram_address),
			clka => clock,
			dina => std_logic_vector(a_bram_data_in),
			unsigned(douta) => a_bram_data_out,
			wea(0) => a_bram_write_enable,
			rsta => reset
		);
	end generate;
	a_bram_config_2_generate : if (CONFIG = 2) generate
		a_bram : a_bram_config_2
		port map (
			addra => std_logic_vector(a_bram_address),
			clka => clock,
			dina => std_logic_vector(a_bram_data_in),
			unsigned(douta) => a_bram_data_out,
			wea(0) => a_bram_write_enable,
			rsta => reset
		);
	end generate;
	a_bram_config_3_generate : if (CONFIG = 3) generate
		a_bram : a_bram_config_3
		port map (
			addra => std_logic_vector(a_bram_address),
			clka => clock,
			dina => std_logic_vector(a_bram_data_in),
			unsigned(douta) => a_bram_data_out,
			wea(0) => a_bram_write_enable,
			rsta => reset
		);
	end generate;

	-- Block RAM for vector B in configuration
	b_bram_config_1_generate : if (CONFIG = 1) generate
		a_bram : b_bram_config_1
		port map (
			addra => std_logic_vector(b_bram_address),
			clka => clock,
			dina => std_logic_vector(b_bram_data_in),
			unsigned(douta) => b_bram_data_out,
			wea(0) => b_bram_write_enable,
			rsta => reset
		);
	end generate;
	b_bram_config_2_generate : if (CONFIG = 2) generate
		a_bram : b_bram_config_2
		port map (
			addra => std_logic_vector(b_bram_address),
			clka => clock,
			dina => std_logic_vector(b_bram_data_in),
			unsigned(douta) => b_bram_data_out,
			wea(0) => b_bram_write_enable,
			rsta => reset
		);
	end generate;
	b_bram_config_3_generate : if (CONFIG = 3) generate
		a_bram : b_bram_config_3
		port map (
			addra => std_logic_vector(b_bram_address),
			clka => clock,
			dina => std_logic_vector(b_bram_data_in),
			unsigned(douta) => b_bram_data_out,
			wea(0) => b_bram_write_enable,
			rsta => reset
		);
	end generate;
end behavioural;
