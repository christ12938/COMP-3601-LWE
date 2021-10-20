library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;


entity lwe is
	port (
		main_clock, decryption_clock : in std_logic;

		-- ----------------------------- Data Signals --------------------------------
		plaintext_in : in std_logic;
		cyphertext_in : in encryptedMsg;

		plaintext_out : out std_logic;
		cyphertext : out encryptedMsg;

		-- ---------------------------- Control Signals ------------------------------
		start : in std_logic;
		reset : in std_logic;
		key_generation_done_out, encryption_done_out : out std_logic
	);
end lwe;


architecture behavioural of lwe is
	-- ----------------------------------------------------------------------------
	--                                 Components
	-- ----------------------------------------------------------------------------
	-- ----------------------------- Key Generation -------------------------------
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

	-- ------------------------------- Block RAMs ---------------------------------
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

	-- ------------------------------- Encryption ---------------------------------
	component encryptor is
		port (
			clk : in std_logic;
			start : std_logic;
			reset : std_logic;
			data_a : in array_t(0 to a_width - 1);
			data_b : in unsigned(n_bits - 1 downto 0);
			q : in unsigned(n_bits - 1 downto 0);
			m : in std_logic;
			index_a : out unsigned(a_bram_address_width - 1 downto 0);
			index_b : out unsigned(b_bram_address_width - 1 downto 0);
			encrypted_m : out encryptedMsg;
			done : out std_logic
		);
	end component;

	-- -------------------- Register with Asynchronous Reset ----------------------
	component register_async_reset is
		generic (n : positive := 8);
		port (
			d : in std_logic_vector(n - 1 downto 0);
			e, reset, clock : in std_logic;
			q : out std_logic_vector(n - 1 downto 0)
		);
	end component;

	-- ----------------------------------------------------------------------------
	--                                  Signals
	-- ----------------------------------------------------------------------------
	signal start_key_generation, start_encryption, key_generation_done, encryption_done : std_logic := '0';
	signal reset_encryption : std_logic := '0';

	signal q_reg_in, q_reg_out : unsigned(n_bits - 1 downto 0);
	signal s_reg_in, s_reg_out : array_t(0 to s_height - 1);

	signal a_valid, b_valid, s_valid, q_valid : std_logic;

	signal key_gen_done_reg_out, key_gen_done_reg_enable : std_logic := '0';

	signal a_bram_data_in_array, a_bram_data_out_array : array_t(0 to a_width - 1);
	signal a_bram_data_in, a_bram_data_out : std_logic_vector(a_bram_data_width - 1 downto 0);
	signal a_bram_address : unsigned(a_bram_address_width - 1 downto 0);
	signal a_bram_write_enable : std_logic := '0';

	signal b_bram_data_in, b_bram_data_out : unsigned(n_bits - 1 downto 0);
	signal b_bram_address : unsigned(b_bram_address_width - 1 downto 0);
	signal b_bram_write_enable : std_logic := '0';

	signal a_bram_address_key_gen, a_bram_address_encrypt : unsigned(a_bram_address_width - 1 downto 0);
	signal b_bram_address_key_gen, b_bram_address_encrypt : unsigned(b_bram_address_width - 1 downto 0);

	type bram_address_control_t is (
		-- NO_CONTROL,
		KEY_GENERATION_CONTROL,
		ENCRYPTION_CONTROL
	);
	signal bram_address_control : bram_address_control_t;

	signal encryption_synchronous_reset : std_logic := '0';
	-- ----------------------------------------------------------------------------
	--                                 FSM States
	-- ----------------------------------------------------------------------------
	type fsm_state is (
		S_KEY_GEN_IDLE,
		S_KEY_GEN_WORK,
		S_ENCRYPT_IDLE,
		S_ENCRYPT_WORK
	);

	signal current_state, next_state : fsm_state := S_KEY_GEN_IDLE;

begin
	-- ------------------------------- Master FSM ---------------------------------
	-- State transition
	process(main_clock, reset) begin
		if reset = '1' then
			current_state <= S_KEY_GEN_IDLE;
		elsif rising_edge(main_clock) then
			current_state <= next_state;
		end if;
	end process;

	-- State logic
	process(current_state, main_clock, start, key_generation_done, encryption_done)
	begin
		next_state <= current_state;
		start_key_generation <= '0';
		start_encryption <= '0';
		key_gen_done_reg_enable <= '0';
		bram_address_control <= ENCRYPTION_CONTROL;
		encryption_done_out <= '0';
		encryption_synchronous_reset <= '0';

		case current_state is
		when S_KEY_GEN_IDLE =>
			if start = '1' then
				start_key_generation <= '1';
				next_state <= S_KEY_GEN_WORK;
				bram_address_control <= KEY_GENERATION_CONTROL;
			end if;

		when S_KEY_GEN_WORK =>
			bram_address_control <= KEY_GENERATION_CONTROL;
			if key_generation_done = '1' then
				next_state <= S_ENCRYPT_IDLE;
				key_gen_done_reg_enable <= '1';
			end if;

		when S_ENCRYPT_IDLE =>
			if start = '1' then
				start_encryption <= '1';
				next_state <= S_ENCRYPT_WORK;
			end if;

		when S_ENCRYPT_WORK =>
			bram_address_control <= ENCRYPTION_CONTROL;
			start_encryption <= '1';

			if encryption_done = '1' then
				encryption_synchronous_reset <= '1';
				start_encryption <= '0';
				next_state <= S_ENCRYPT_IDLE;
				encryption_done_out <= '1';
			end if;

		when others =>
			report "Master FSM in an invalid state" severity error;
		end case;
	end process;

	-- --------------------- Block RAM Address Multiplexers -----------------------
	a_bram_address <=
		a_bram_address_key_gen when bram_address_control = KEY_GENERATION_CONTROL else
		a_bram_address_encrypt when bram_address_control = ENCRYPTION_CONTROL else
		(others => '0');
	b_bram_address <=
		b_bram_address_key_gen when bram_address_control = KEY_GENERATION_CONTROL else
		b_bram_address_encrypt when bram_address_control = ENCRYPTION_CONTROL else
		(others => '0');

	a_bram_write_enable <= a_valid;
	a_bram_signal_conversion : for i in 0 to a_width - 1 generate
		a_bram_data_in((i + 1) * n_bits - 1 downto i * n_bits) <= std_logic_vector(a_bram_data_in_array(i));
		a_bram_data_out_array(i) <= unsigned(a_bram_data_out((i + 1) * n_bits - 1 downto i * n_bits));
	end generate;

	b_bram_write_enable <= b_valid;

	key_gen : key_generation
	port map (
		clock => main_clock,
		reset => reset,
		start => start,
		a_in => a_bram_data_out_array,
		q_in => q_reg_out,
		s_in => s_reg_out,
		done => key_generation_done,
		q_out => q_reg_in,
		a_out => a_bram_data_in_array,
		b_out => b_bram_data_in,
		s_out => s_reg_in,
		q_valid => q_valid,
		a_valid => a_valid,
		b_valid => b_valid,
		s_valid => s_valid,
		a_bram_address => a_bram_address_key_gen,
		b_bram_address => b_bram_address_key_gen
	);

	encryption : encryptor
	port map (
		clk => main_clock,
		start => start_encryption,
		reset => reset_encryption,
		data_a => a_bram_data_out_array,
		data_b => b_bram_data_out,
		q => q_reg_out,
		m => plaintext_in,
		index_a => a_bram_address_encrypt,
		index_b => b_bram_address_encrypt,
		encrypted_m => cyphertext,
		done => encryption_done
	);
	reset_encryption <= reset or encryption_synchronous_reset;

	q_register : register_async_reset
	generic map (n => n_bits)
	port map (
		d => std_logic_vector(q_reg_in),
		e => q_valid,
		reset => reset,
		clock => main_clock,
		unsigned(q) => q_reg_out
	);

	-- Key generation done register
	key_gen_done_register : register_async_reset
	generic map (n => 1)
	port map (
		d(0) => '1',
		e => key_gen_done_reg_enable,
		reset => reset,
		clock => main_clock,
		q(0) => key_gen_done_reg_out
	);
	key_generation_done_out <= key_gen_done_reg_out;
	-- s registers
	s_registers_generate : for i in 0 to s_height - 1 generate
		s_register : register_async_reset
		generic map (n => n_bits)
		port map (
			d => std_logic_vector(s_reg_in(i)),
			e => s_valid,
			reset => reset,
			clock => main_clock,
			unsigned(q) => s_reg_out(i)
		);
	end generate;

	-- This section uses an if generate because the block RAM was generated via the Vivado UI, so the block RAM VHDL implementation isn't available
	-- Block RAM for matrix A
	a_bram_config_1_generate : if (CONFIG = 1) generate
		a_bram : a_bram_config_1
		port map (
			addra => std_logic_vector(a_bram_address),
			clka => main_clock,
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
			clka => main_clock,
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
			clka => main_clock,
			dina => std_logic_vector(a_bram_data_in),
			douta => a_bram_data_out,
			wea(0) => a_bram_write_enable,
			rsta => reset
		);
	end generate;

	-- Block RAM for vector B in configuration
	b_bram_config_1_generate : if (CONFIG = 1) generate
		a_bram : b_bram_config_1
		port map (
			addra => std_logic_vector(b_bram_address),
			clka => main_clock,
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
			clka => main_clock,
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
			clka => main_clock,
			dina => std_logic_vector(b_bram_data_in),
			unsigned(douta) => b_bram_data_out,
			wea(0) => b_bram_write_enable,
			rsta => reset
		);
	end generate;
end behavioural;
