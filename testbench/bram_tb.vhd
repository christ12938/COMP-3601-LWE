library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;
use std.textio.all;

entity bram_tb is
end bram_tb;

architecture behavioral of bram_tb is
	component uniform_rng is
		Port (
			cap : in STD_LOGIC_vector (n_bits - 1 downto 0);
			seed  : in STD_LOGIC_VECTOR (63 downto 0);
			clk,reset,start_signal   :in std_logic;
			random_number : out STD_LOGIC_vector(n_bits - 1 downto 0)
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

	constant CLOCK_PERIOD : time := 1 ms;

	-- -------------------------------- Signals -----------------------------------
	signal clock : std_logic := '1';
	signal clock_bram : std_logic := '1';
	signal reset : std_logic := '0';

	signal a_bram_data_in_array, a_bram_data_out_array : array_t(0 to a_width - 1);
	signal a_bram_data_in, a_bram_data_out : std_logic_vector(a_bram_data_width - 1 downto 0);
	signal a_bram_address : unsigned(a_bram_address_width - 1 downto 0);
	signal a_bram_write_enable : std_logic := '0';
	
	signal reading : std_logic := '0';

	signal rng_out : array_t(0 to a_width - 1);
begin
	clock <= not clock after CLOCK_PERIOD;
	clock_bram <= not clock;
	-- Stimulus
 	process
--		variable counter_a : integer := 0;
		variable flag : boolean := false;

		constant FILE_NAME : string := "bram_tb_debug_out.txt";
		variable line_buffer : line;
		file file_pointer : text;
	begin
		a_bram_address <= to_unsigned(0, a_bram_address'length);
		reset <= '1';
		wait for 10 * CLOCK_PERIOD;
		reset <= '0';
		wait for 10 * CLOCK_PERIOD;

		for i in 0 to a_height - 1 loop
			a_bram_write_enable <= '1';
			a_bram_address <= to_unsigned(i, a_bram_address'length);
			wait until rising_edge(clock);
		end loop;
		a_bram_write_enable <= '0';

		wait for 10 * CLOCK_PERIOD;
		
		file_open(file_pointer, FILE_NAME, write_mode);
		for i in 0 to a_height - 1 loop
			a_bram_address <= to_unsigned(i, a_bram_address'length);
			wait until rising_edge(clock);
			write(line_buffer, integer'image(i) & ": ");
			for j in 0 to a_width - 1 loop
				reading <= '1';
				write(line_buffer, integer'image(to_integer(a_bram_data_out_array(j))) & " ");
			end loop;
			writeline(file_pointer, line_buffer);
--			wait until rising_edge(clock);
		end loop;
		file_close(file_pointer);
		reading <= '0';
		
		wait for 10 * CLOCK_PERIOD;
		
		for i in 0 to 100 loop
			if flag then
				a_bram_address <= (others => '0');
			else
				a_bram_address <= (others => '1');
			end if;
			flag := not flag;
			wait until rising_edge(clock);
--			wait until rising_edge(clock);
		end loop;
		wait;
	end process;

	a_bram_signal_conversion : for i in 0 to a_width - 1 generate
		a_bram_data_in((i + 1) * n_bits - 1 downto i * n_bits) <= std_logic_vector(a_bram_data_in_array(i));
		a_bram_data_out_array(i) <= unsigned(a_bram_data_out((i + 1) * n_bits - 1 downto i * n_bits));
	end generate;

	-- Generate a_width generators, these generators are used for A and s
	rng_bank : for i in 0 to a_width - 1 generate
		rng : uniform_rng
		port map (
			-- seed => std_logic_vector(seed_gen_out),
			seed => std_logic_vector(SEEDS(i)),
			cap => std_logic_vector(to_unsigned(max_q, n_bits)),
			clk => clock,
			reset => reset,
			unsigned(random_number) => rng_out(i),
			start_signal => '1'
		);
	end generate;
	a_bram_data_in_array <= rng_out;
	
	-- -------------------- Block RAM Conditional Generation ----------------------
	a_bram_config_1_generate : if (CONFIG = 1) generate
		a_bram : a_bram_config_1
		port map (
			addra => std_logic_vector(a_bram_address),
			clka => clock_bram,
			dina => std_logic_vector(a_bram_data_in),
			douta => a_bram_data_out,
			wea(0) => a_bram_write_enable,
			rsta => reset
		);
	end generate;
	a_bram_config_2_generate : if (CONFIG = 2) generate
		a_bram : a_bram_config_2
		port map (
			addra => std_logic_vector(a_bram_address),
			clka => clock_bram,
			dina => std_logic_vector(a_bram_data_in),
			douta => a_bram_data_out,
			wea(0) => a_bram_write_enable,
			rsta => reset
		);
	end generate;
	a_bram_config_3_generate : if (CONFIG = 3) generate
		a_bram : a_bram_config_3
		port map (
			addra => std_logic_vector(a_bram_address),
			clka => clock_bram,
			dina => std_logic_vector(a_bram_data_in),
			douta => a_bram_data_out,
			wea(0) => a_bram_write_enable,
			rsta => reset
		);
	end generate;

end behavioral;
