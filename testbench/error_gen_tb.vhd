-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.data_types.all;
use std.textio.all;

entity error_gen_tb is
end;

architecture bench of error_gen_tb is

	component error_generator is
		Port (
			max_cap : in integer;
			clk,reset,start_signal   : in std_logic;
		 	seed : in unsigned(63 downto 0);
		 	seed_valid : in std_logic;
		 	done     : out std_logic;
		 	error    : out integer
		 );
	end component;

	-- signal U :  array_mul_t(0 to a_width-1);
	-- signal S :  array_mul_t(0 to a_width-1):=(TO_UNSIGNED(27, mul_bits), TO_UNSIGNED(58, mul_bits), TO_UNSIGNED(8, mul_bits), TO_UNSIGNED(2, mul_bits));
	-- signal Q: unsigned(n_bits - 1 DOWNTO 0) := TO_UNSIGNED(79, n_bits);
	-- signal V: unsigned(n_bits - 1 DOWNTO 0) := TO_UNSIGNED(30, n_bits);
	-- signal M: std_logic;

	signal done, reset, start : std_logic;
	signal clock : std_logic := '1';
	signal error : integer;
	constant ERROR_RANGE_CONSTANT : integer := error_range;
	constant CLOCK_PERIOD : time := 1 ns;
	
begin

	uut : error_generator port map (
		reset => reset,
		start_signal => start,
		max_cap => ERROR_RANGE_CONSTANT,
		clk => clock,
		seed => SEEDS(17),
		seed_valid => '0',
		done => done,
		error => error
	);

	clock <= not clock after CLOCK_PERIOD / 2;

	stimulus : process
		constant FILE_NAME : string := "err_gen_tb_out.txt";
		file file_pointer : text;
		variable line_buffer : line;
		
	begin
		file_open(file_pointer, FILE_NAME, write_mode);
		file_close(file_pointer);
		
		reset <= '1';
		start <= '0';
		wait for 10 * CLOCK_PERIOD;
		reset <= '0';
		start <= '1';
				
		while true loop
			wait until done = '1';
			start <= '0';
			
			file_open(file_pointer, FILE_NAME, append_mode);
			write(line_buffer, error);
			writeline(file_pointer, line_buffer);
			file_close(file_pointer);
			
			
			wait for CLOCK_PERIOD;
			start <= '1';
		end loop;
		
		wait;	
	end process;

end;
