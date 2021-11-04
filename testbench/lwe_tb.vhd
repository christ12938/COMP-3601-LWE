library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;
use std.textio.all;

entity lwe_tb is
end lwe_tb;

architecture behavioural of lwe_tb is

	component lwe is
		port (
			clock_a, clock_b, clock_c : in std_logic;

			-- ----------------------------- Data Signals --------------------------------
			plaintext_in : in std_logic;
			cyphertext_in : in encryptedMsg;

			plaintext_out : out std_logic;
			cyphertext_out : inout encryptedMsg;

			-- ---------------------------- Control Signals ------------------------------
			start : in std_logic;
			reset : in std_logic;
			key_generation_done_out, encryption_done_out : out std_logic
		);
	end component;

	constant CLOCK_PERIOD : time := 100 ns;

	-- -------------------------------- Signals -----------------------------------
	signal clock : std_logic := '0';
	signal start : std_logic := '0';
	signal reset : std_logic := '0';
	signal key_gen_done, encryption_done : std_logic := '0';

	signal plaintext_in, plaintext_out : std_logic;
	signal cyphertext_in, cyphertext_out : encryptedMsg;

	-- ------------------------------- Functions ----------------------------------
	procedure clear_file(file_name : string) is
		file file_pointer : text;
	begin
		file_open(file_pointer, file_name, write_mode);
		file_close(file_pointer);
  end;

begin
	clock <= not clock after CLOCK_PERIOD / 2;
	cyphertext_in <= cyphertext_out;
	-- -------------------------------- Stimulus ----------------------------------
  process

		-- Accuracy analysis
		variable bits_processed : integer := 0;
		variable correct_answer : std_logic := '0';
		variable correct_bits : integer := 0;


		-- ---------------------------- File Operations -------------------------------
		constant PRINT_CYPHERTEXT : boolean := true;
		constant PRINT_PLAINTEXT : boolean := true;

		variable ascii_character_in, ascii_character_out : character;
		variable byte_in, byte_out : natural range 0 to 255;
		variable byte_vector_in, byte_vector_out : std_logic_vector(7 downto 0);
		variable char_available : boolean := false;

		constant PLAINTEXT_IN_FILE_NAME : string := "plaintext_in.txt";
		constant CYPHERTEXT_FILE_NAME : string := "cyphertext.txt";
		constant PLAINTEXT_OUT_FILE_NAME : string := "plaintext_out.txt";
		file file_pointer_a, file_pointer_b, file_pointer_c : text;
		variable line_buffer_a, line_buffer_b, line_buffer_c : line;

	begin
		-- Clear files if required
		if PRINT_CYPHERTEXT then
			clear_file(CYPHERTEXT_FILE_NAME);
		end if;
		if PRINT_PLAINTEXT then
			clear_file(PLAINTEXT_OUT_FILE_NAME);
		end if;

		wait for 4 * CLOCK_PERIOD;
		-- Assert reset
		reset <= '1';
		wait for 10 * CLOCK_PERIOD;
		-- Start key generation
		reset <= '0';
		start <= '1';
		wait for CLOCK_PERIOD;
		start <= '0';

		wait until key_gen_done = '1';
		report "TB: Key generation finished";
		wait for 10 * CLOCK_PERIOD;

		file_open(file_pointer_a, PLAINTEXT_IN_FILE_NAME);
		-- Loop over each line
		while not endfile(file_pointer_a) loop
			readline(file_pointer_a, line_buffer_a);
			read(line_buffer_a, ascii_character_in, char_available);
			-- Loop over each character in the line
			while char_available loop
				byte_in := character'pos(ascii_character_in);
				report "Now processing " & integer'image(byte_in) & " ('" & ascii_character_in & "')";

				-- Loop over each bit in the byte
				for i in 0 to 7 loop
					byte_vector_in := std_logic_vector(to_unsigned(byte_in, 8));
					plaintext_in <= byte_vector_in(i);
					correct_answer := byte_vector_in(i);
					start <= '1';
					wait for CLOCK_PERIOD;
					start <= '0';


					wait until encryption_done = '1';

					-- Print to cyphertext file if enabled
					if PRINT_CYPHERTEXT then
						file_open(file_pointer_b, CYPHERTEXT_FILE_NAME, append_mode);
						for j in 0 to a_width - 1 loop
							-- Writes u
							write(line_buffer_b, integer'image(to_integer(cyphertext_out.u(j))) & " ");
						end loop;
						-- Writes v
						write(line_buffer_b, integer'image(to_integer(cyphertext_out.v)));
						writeline(file_pointer_b, line_buffer_b);
						file_close(file_pointer_b);
					end if;

					-- Accuracy analysis
					bits_processed := bits_processed + 1;
					report "Expected: " & std_logic'image(correct_answer) & ", actual: " & std_logic'image(plaintext_out);
					if correct_answer = plaintext_out then
						correct_bits := correct_bits + 1;
						report "Correct!";
					else
						report "Incorrect";
					end if;
					report integer'image(bits_processed) & " bits processed, accuracy: " & real'image((real(correct_bits) / real(bits_processed)));

					-- Save the plaintext out bit to build an ASCII byte
					byte_vector_out(i) := plaintext_out;

					wait for 4 * CLOCK_PERIOD;

				end loop;

				-- Convert to an ASCII byte and write it to the line buffer
				ascii_character_out := character'val(to_integer(unsigned(byte_vector_out)));
				write(line_buffer_c, ascii_character_out);

				read(line_buffer_a, ascii_character_in, char_available);
			end loop;

			file_open(file_pointer_c, PLAINTEXT_OUT_FILE_NAME, append_mode);
			writeline(file_pointer_c, line_buffer_c);
			file_close(file_pointer_c);
		end loop;

		file_close(file_pointer_a);

		wait for 100 * CLOCK_PERIOD;
		report "Process finished, stopping... (not a failure)" severity failure;
		wait;
	end process;


	uut : lwe
	port map (
		start => start,
		reset => reset,

		clock_a => clock,
		clock_b => clock,
		clock_c => clock,

		plaintext_in => plaintext_in,
		plaintext_out => plaintext_out,

		cyphertext_in => cyphertext_in,
		cyphertext_out => cyphertext_out,
		key_generation_done_out => key_gen_done,
		encryption_done_out => encryption_done
	);

end behavioural;
