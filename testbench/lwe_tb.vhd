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
			cyphertext_out : out encryptedMsg;

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

	signal plaintext_in, plaintext_out : std_logic := '0';
	signal cyphertext_in, cyphertext_out : encryptedMsg;

	-- ---------------------------- File Operations -------------------------------
	constant plaintext_in_file : string := "plaintext_in.txt";
	file file_pointer : text;

begin
	clock <= not clock after CLOCK_PERIOD / 2;

	-- -------------------------------- Stimulus ----------------------------------
  process begin
		wait for 4 * CLOCK_PERIOD;
		reset <= '1';
		wait for 10 * CLOCK_PERIOD;
		reset <= '0';
		start <= '1';

		wait until key_gen_done = '1';
		report "TB: Key generation finished" severity note;
		
		
		wait for 100 * CLOCK_PERIOD;
		report "Stopping" severity failure;
		wait;
	end process;
	-- process
	-- 	variable file_status : file_open_status;
	-- 	variable file_line : line;
	-- 	variable data : integer;
	-- begin
	-- 	file_open(file_pointer, plaintext_in_file);
	-- 	while not endfile(file_pointer) loop
	-- 		readline(file_pointer, file_line);
	-- 		read(file_line, data);
	-- 		report integer'image(data) severity note;
	-- 	end loop;
	-- 	file_close(file_pointer);
	-- 	wait;
	-- end process;

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
