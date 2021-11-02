----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 13.10.2021 14:23:51
-- Design Name:
-- Module Name: encryptor - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use work.data_types.all;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity encryptor is
	Port ( clk : in STD_LOGIC;
		   start : in STD_LOGIC;
		   reset : in STD_LOGIC;
		   rng_reset : in std_logic;
		   data_a : in array_t(0 to a_width-1);
		   data_b : in unsigned(n_bits - 1 downto 0);
		   q : in  unsigned(n_bits - 1 downto 0);
		   M : in STD_LOGIC;
		   index_a : out unsigned(a_bram_address_width - 1 downto 0);
		   index_b : out unsigned(b_bram_address_width - 1 downto 0);
		   encrypted_m : out encryptedMsg;
		   done : out STD_LOGIC);
end encryptor;

architecture Behavioral of encryptor is
	component uniform_rng is
		Port ( cap : in STD_LOGIC_vector (n_bits - 1 downto 0);
			seed  : in STD_LOGIC_VECTOR (63 downto 0);  -- initial LFSR state
			clk,reset,start_signal   :in std_logic;  -- start signal will be set from log
			random_number : out STD_LOGIC_vector(n_bits - 1 downto 0));
	end component;

	component encrypt_combinational is
		Port ( clk : in STD_LOGIC;
			   start : in std_logic;
			   start_mod : in STD_LOGIC;
			   reset : in STD_LOGIC;
			   A_row : in array_t(0 to a_width-1);
			   B_element : in unsigned(n_bits - 1 downto 0);
			   q : in unsigned(n_bits - 1 downto 0);
			   M : in STD_LOGIC;
			   encryptedM : out encryptedMsg;
			   done : out STD_LOGIC
			   );
	end component;

	signal index : std_logic_vector(a_bram_address_width - 1 downto 0);
	signal got_all_data : std_logic;
	signal rng_out : std_logic_vector(n_bits - 1 downto 0);

	signal DEBUG_COUNT : integer;
	signal DEBUG_SAMPLE_SIZE : natural;
	signal index_temp : unsigned(a_bram_address_width - 1 downto 0);
	signal encrypted_message_temp : encryptedMsg;
	signal done_temp : std_logic;
begin
	DEBUG_SAMPLE_SIZE <= sample_size - 1;

random_index_generator : uniform_rng port map(
	cap => std_logic_vector(TO_UNSIGNED(a_height-1,n_bits)),
	seed => std_logic_vector(SEEDS(19)),
	clk => clk,
	reset => rng_reset,
	start_signal => start,
	random_number => rng_out
);
index <= std_logic_vector(resize(unsigned(rng_out), index'length));

process(clk,reset)
	variable count : integer := 0;
begin
	DEBUG_COUNT <= count;
	if reset = '1' then
		count := 0;
		got_all_data <= '0';
		-- index <= (others => '0');
	elsif start = '1' and rising_edge(clk) then
		if count = sample_size - 1 then
			got_all_data <= '1';
		else
			index_temp <= unsigned(index);
			index_a <= unsigned(index);
			index_b <= unsigned(index);
			count := count + 1;
		end if;
	end if;
end process;

-- ------------------------ Matrix Printing for Debug --------------------------
process
	-- This should be run with lwe_tb
	constant DO_PRINT : boolean := false;	-- Enable the printing
	constant FILE_NAME : string := "encryptor_debug_bit_";	-- Base file name
	constant MAX_FILES : integer := 16;	-- Number of matricies to print

	file file_pointer : text;

	variable file_number : integer := 0;
	variable line_buffer : line;
	variable number : integer;
	variable temp : unsigned(n_bits - 1 downto 0);
	variable working : boolean := false;
	variable encryption_stage : boolean := false;
	variable clearing_complete : boolean := false;
begin
	if DO_PRINT then
		if not clearing_complete then
			-- Clears the debug files
			for i in 0 to MAX_FILES - 1 loop
				file_open(file_pointer, FILE_NAME & integer'image(i) & ".txt", write_mode);
				file_close(file_pointer);
			end loop;
			clearing_complete := true;
		end if;

		wait until rising_edge(clk);

		if file_number >= MAX_FILES then
			report "Max files reached";
			wait;	-- Don't write any more files
		end if;

		if start = '1' then
			encryption_stage := true;
		end if;

		if encryption_stage then
			if got_all_data = '0' and start = '1' then
				working := true;
			end if;

			if working then
				if got_all_data = '1' then
					wait until done_temp = '1';
					file_open(file_pointer, FILE_NAME & integer'image(file_number) & ".txt", append_mode);

					-- Writes u
					for i in 0 to a_width - 1 loop
						write(line_buffer, integer'image(to_integer(encrypted_message_temp.u(i))) & " ");
					end loop;

					-- Writes v
					write(line_buffer, integer'image(to_integer(encrypted_message_temp.v)) & " ");

					-- Writes m
					write(line_buffer, integer'image(to_integer(unsigned'('0' & M))) & " ");
					writeline(file_pointer, line_buffer);
					file_close(file_pointer);

					-- Stop writing and move on to the next file when got_all_data is asserted
					working := false;
					file_number := file_number + 1;

				else
					file_open(file_pointer, FILE_NAME & integer'image(file_number) & ".txt", append_mode);
					write(line_buffer, integer'image(to_integer(unsigned(index_temp))) & " ");	-- Writes generated index
					-- Writes the A row
					for i in 0 to a_width - 1 loop
						write(line_buffer, integer'image(to_integer(data_a(i))) & " ");
					end loop;
					-- Writes the B element
					write(line_buffer, integer'image(to_integer(data_b)) & " ");
					writeline(file_pointer, line_buffer);
					file_close(file_pointer);
				end if;
			end if;
		end if;
	else
		wait;
	end if;
end process;

encryption : encrypt_combinational port map(
	clk => clk,
	start => start,
	start_mod => got_all_data,
	reset => reset,
	A_row => data_a,
	B_element => data_b,
	q => q,
	M => M,
	encryptedM => encrypted_message_temp,
	done => done_temp
);
encrypted_m <= encrypted_message_temp;
done <= done_temp;
end Behavioral;
