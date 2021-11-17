library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;
use std.textio.all;

entity encryption_v2 is
	port (
		clock, start, reset : in std_logic;
		data_a_in : in array_t(0 to a_width - 1);
		data_b_in : in unsigned(n_bits - 1 downto 0);
		q_in : in unsigned(n_bits - 1 downto 0);
		m_in : in std_logic;

		address_a_out : out unsigned(a_bram_address_width - 1 downto 0);
		address_b_out : out unsigned(b_bram_address_width - 1 downto 0);
		cyphertext_out : out encryptedMsg;
		done : out std_logic
	);
end encryption_v2;

architecture behavioural of encryption_v2 is
	-- ----------------------------------------------------------------------------
	--                                 Components
	-- ----------------------------------------------------------------------------
	-- -------------------------------- Register ----------------------------------
	component register_async_reset is
		generic (n : positive := 8);
		port (
			d : in std_logic_vector(n - 1 downto 0);
			e, reset, clock : in std_logic;
			q : out std_logic_vector(n - 1 downto 0)
		);
	end component;

	-- ------------------------ Random Number Generator ---------------------------
	component uniform_rng
		port (
			cap : in std_logic_vector(n_bits - 1 downto 0);
			seed : in std_logic_vector(63 downto 0);
			clk, reset, start_signal : in std_logic;
			random_number : out std_logic_vector(n_bits - 1 downto 0)
		);
	end component;

	-- ------------------------- Modulus Combinational ----------------------------
	component modulus_combinational is
		generic (
			dividend_width : natural := mul_bits;
			divisor_width : natural := mul_bits
		);
		port (
			dividend : in signed(dividend_width - 1 downto 0);
			divisor : in unsigned(divisor_width - 1 downto 0);
			modulo : out unsigned(divisor_width - 1 downto 0)
		);
	end component;

	-- ----------------------------------------------------------------------------
	--                                  Signals
	-- ----------------------------------------------------------------------------
	type fsm_state is (
		S_IDLE,
--		S_WAIT,
		S_BRAM,
		S_DONE
	);

	type array_sum_t is array(natural range <>) of unsigned(mul_bits - 1 downto 0);

	signal current_state : fsm_state := S_IDLE;
	signal next_state : fsm_state := S_IDLE;

	signal counter_enable : std_logic := '0';
	signal counter : integer range 0 to a_height := 0;
	signal counter_reset_synchronous : std_logic := '0';

	signal rng_out : unsigned(n_bits - 1 downto 0) := (others => '0');

	signal a_reg_in, a_reg_out : array_sum_t(0 to a_width - 1) := (others => (others => '0'));
	signal a_reg_write_enable : std_logic := '0';

	signal b_reg_in, b_reg_out : unsigned(mul_bits - 1 downto 0) := (others => '0');
	signal b_reg_write_enable : std_logic := '0';

	signal u_mod_out : array_t(0 to a_width - 1) := (others => (others => '0'));
	signal v_mod_out : unsigned(n_bits - 1 downto 0) := (others => '0');

	signal u_mod_temp : array_sum_t(0 to a_width - 1) := (others => (others => '0'));
	signal v_mod_temp : unsigned(mul_bits - 1 downto 0) := (others => '0');

	signal a_reg_reset_synchronous, b_reg_reset_synchronous : std_logic := '0';

	signal b_sum_temp_calculation : unsigned(mul_bits - 1 downto 0) := (others => '0');

begin

	b_sum_temp_calculation <=
		b_reg_out - q_in / 2 when m_in = '1' else
		b_reg_out;

	cyphertext_out.u <= u_mod_out;
	cyphertext_out.v <= v_mod_out;

	-- --------------------------------- Adders -----------------------------------
	a_adder : for i in 0 to a_width - 1 generate
		a_reg_in(i) <= a_reg_out(i) + resize(data_a_in(i), a_reg_in(i)'length);
	end generate;

	b_adder : b_reg_in <= b_reg_out + resize(data_b_in, b_reg_in'length);

	-- -------------------------------- Modders -----------------------------------
	u_modder_generate : for i in 0 to a_width - 1 generate
		u_modder : modulus_combinational port map (
			dividend => signed(a_reg_out(i)),
			divisor => resize(q_in, mul_bits),
			modulo => u_mod_temp(i)
		);
		u_mod_out(i) <= resize(u_mod_temp(i), u_mod_out(i)'length);
	end generate;

	v_modder : modulus_combinational port map (
		dividend => signed(b_sum_temp_calculation),
		divisor => resize(q_in, mul_bits),
		modulo => v_mod_temp
	);
	v_mod_out <= resize(v_mod_temp, v_mod_out'length);

	-- ------------------------------- A Register ---------------------------------
	a_register : process(clock, reset) begin
		if reset = '1' then
			a_reg_out <= (others => (others => '0'));
		elsif rising_edge(clock) then
			if a_reg_reset_synchronous = '1' then
				a_reg_out <= (others => (others => '0'));
			elsif a_reg_write_enable = '1'then
				a_reg_out <= a_reg_in;
			end if;
		end if;
	end process;

	-- ------------------------------- B Register ---------------------------------
	b_register : process(clock, reset) begin
		if reset = '1' then
			b_reg_out <= (others => '0');
		elsif rising_edge(clock) then
			if b_reg_reset_synchronous = '1' then
				b_reg_out <= (others => '0');
			elsif b_reg_write_enable = '1' then
				b_reg_out <= b_reg_in;
			end if;
		end if;
	end process;

	-- -------------------------------- Counter -----------------------------------
	counter_process : process(clock, reset)
		variable counter_variable : integer range 0 to a_height := 0;
	begin
		if reset = '1' then
			counter_variable := 0;
		elsif rising_edge(clock) then
			if counter_reset_synchronous = '1' then
				counter_variable := 0;
			elsif counter_enable = '1' then
				counter_variable := counter_variable + 1;
			end if;
		end if;
		counter <= counter_variable;
	end process;

	-- -------------------------- Finite State Machine ----------------------------
	fsm_state_transition : process(clock, reset) begin
		if reset = '1' then
			current_state <= S_IDLE;
		elsif rising_edge(clock) then
			current_state <= next_state;
		end if;
	end process;

	state_logic : process(start, current_state, counter)
	begin
		next_state <= current_state;
		counter_reset_synchronous <= '0';
		counter_enable <= '0';
		done <= '0';
		a_reg_write_enable <= '0';
		b_reg_write_enable <= '0';
		a_reg_reset_synchronous <= '0';
		b_reg_reset_synchronous <= '0';

		case current_state is
		when S_IDLE =>
			a_reg_reset_synchronous <= '1';
			b_reg_reset_synchronous <= '1';
			if start = '1' then
				next_state <= S_BRAM;
			end if;
		-- when S_WAIT =>
			-- next_state <= S_BRAM;

		when S_BRAM =>
			counter_enable <= '1';
			if counter = a_height / 4 then
				-- All values from block RAM retrieved
				done <= '1';
				next_state <= S_IDLE;
				counter_reset_synchronous <= '1';
			else
				-- Still getting values from block RAM
				a_reg_write_enable <= '1';
				b_reg_write_enable <= '1';

			end if;

--		when S_DONE =>
--			done <= '1';

--			if start = '0' then
--				next_state <= S_IDLE;
--			end if;

		when others =>
			report "Encryption in invalid state" severity error;

		end case;
	end process;

	-- ----------------- Random Number Generator for Addresses --------------------
	address_generator : uniform_rng
	port map (
		cap => std_logic_vector(to_unsigned(a_height / 4 - 1, n_bits)),
		seed => std_logic_vector(SEEDS(18)),
		clk => clock,
		reset => reset,
		start_signal => '1',
		unsigned(random_number) => rng_out
	);
	address_a_out <= resize(rng_out, address_a_out'length);
	address_b_out <= resize(rng_out, address_b_out'length);

	-- ----------------------------- Debug Printing -------------------------------
	debug_printing : process

		constant DO_PRINT : boolean := true;
		
		constant FILE_NAME : string := "encryption_v2_debug_bit_";
		constant MAX_FILES : integer := 16;

		file file_pointer : text;

		variable file_number : integer := 0;
		variable line_buffer : line;
		variable file_cleared : boolean := false;
		variable cyphertext_output : encryptedMsg;
	begin
		if DO_PRINT then
			if not file_cleared then
				for i in 0 to MAX_FILES - 1 loop
					file_open(file_pointer, FILE_NAME & integer'image(i) & ".txt", write_mode);
					file_close(file_pointer);
				end loop;
				file_cleared := true;
			end if;

			-- For each file
			for i in 0 to MAX_FILES - 1 loop
				wait until current_state = S_BRAM;

				file_open(file_pointer, FILE_NAME & integer'image(i) & ".txt", append_mode);

				-- For each row of block RAM
				for j in 0 to a_height / 4 - 1 loop
					wait until rising_edge(clock);
					-- Writes index
					write(line_buffer, integer'image(to_integer(rng_out)) & " ");

					-- For each number in the row
					for k in 0 to a_width - 1 loop
						-- Writes A row
						write(line_buffer, integer'image(to_integer(data_a_in(k))) & " ");
					end loop;

					-- Writes B
					write(line_buffer, integer'image(to_integer(data_b_in)) & " ");

					writeline(file_pointer, line_buffer);
				end loop;

				wait until rising_edge(clock);
				-- Assign u and v
				cyphertext_output.u := u_mod_out;
				cyphertext_output.v := resize(v_mod_temp, cyphertext_output.v'length);

				-- Writes u
				for j in 0 to a_width - 1 loop
					write(line_buffer, integer'image(to_integer(cyphertext_output.u(j))) & " ");
				end loop;

				-- Writes v
				write(line_buffer, integer'image(to_integer(cyphertext_output.v)) & " ");

				-- Writes m
				write(line_buffer, std_logic'image(m_in) & " ");

				writeline(file_pointer, line_buffer);
				file_close(file_pointer);
			end loop;
			wait;
		else
			wait;
		end if;
	end process;
end behavioural;
