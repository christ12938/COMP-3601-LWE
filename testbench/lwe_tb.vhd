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

	constant CLOCK_PERIOD : time := 1 ns;
	-- -------------------------------- Signals -----------------------------------
	signal clock : std_logic := '0';
	signal start : std_logic := '0';
	signal reset : std_logic := '0';
	signal key_gen_done, encryption_done : std_logic := '0';

	signal plaintext_in, plaintext_out : std_logic;
	signal cyphertext_in, cyphertext_out : encryptedMsg;

	-- ---------------------------- File Operations -------------------------------
	constant PLAINTEXT_IN_FILE_NAME : string := "plaintext_in.txt";
	constant TEMP_FILE_NAME : string := "temp_file.txt";
	file temp_fp : text;
	file file_pointer : text;

begin
	clock <= not clock after CLOCK_PERIOD / 2;

	-- -------------------------------- Stimulus ----------------------------------
  process
		variable file_line : line;
		variable ascii_character : character;
		variable byte : natural range 0 to 255;
		variable byte_vector : std_logic_vector(7 downto 0);
		-- variable plaintext_in_bit : std_logic;
		variable char_available : boolean := false;

		-- Accuracy analysis
		variable bits_processed : integer := 0;
		variable correct_answer : std_logic := '0';
		variable correct_bits : integer := 0;

	begin
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
		wait for CLOCK_PERIOD;

		file_open(file_pointer, PLAINTEXT_IN_FILE_NAME);
		-- Loop over each line
		while not endfile(file_pointer) loop
			readline(file_pointer, file_line);
			read(file_line, ascii_character, char_available);
			-- Loop over each character in the line
			while char_available loop
				byte := character'pos(ascii_character);
				report "Now processing " & integer'image(byte) & " ('" & ascii_character & "')";

				-- Loop over each bit in the byte
				for i in 0 to 7 loop
					byte_vector := std_logic_vector(to_unsigned(byte, 8));
					plaintext_in <= byte_vector(i);
					correct_answer := plaintext_in;
					start <= '1';
					wait for CLOCK_PERIOD;
					start <= '0';
					wait until encryption_done = '1';

					-- Accuracy analysis
					bits_processed := bits_processed + 1;
					if correct_answer = plaintext_out then
						correct_bits := correct_bits + 1;
					end if;

					report integer'image(bits_processed) & " bits processed, accuracy: " & real'image((real(correct_bits) / real(bits_processed)));

					wait for 10 * CLOCK_PERIOD;

				end loop;



				read(file_line, ascii_character, char_available);
			end loop;

		end loop;
		file_close(file_pointer);

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
