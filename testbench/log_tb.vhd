-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;

entity log_tb is
end;

architecture bench of log_tb is

	component log
			port ( input : in std_logic_vector(n_bits - 1 downto 0);
						 res : out integer range 0 to n_bits - 1);
	end component;

	signal input: STD_LOGIC_vector(n_bits - 1 downto 0) := (others => '0');
	signal res: integer range 0 to n_bits - 1;

begin

	uut: log port map ( input => input,
						res   => res );

	stimulus: process
		constant DELAY : time := 10 ns;
	begin
		input <= std_logic_vector(to_unsigned(127, n_bits));
		wait for DELAY;
		input <= std_logic_vector(to_unsigned(128, n_bits));
		wait for DELAY;
		input <= std_logic_vector(to_unsigned(2, n_bits));
		wait for DELAY;
		input <= std_logic_vector(to_unsigned(4, n_bits));
		wait for DELAY;
		input <= std_logic_vector(to_unsigned(8, n_bits));
		wait for DELAY;
		input <= std_logic_vector(to_unsigned(7, n_bits));
		wait for DELAY;
		input <= std_logic_vector(to_unsigned(127, n_bits));
		wait for DELAY;
		input <= std_logic_vector(to_unsigned(128, n_bits));
		wait for DELAY;
		input <= std_logic_vector(to_unsigned(126, n_bits));
		wait for DELAY;
		input <= std_logic_vector(to_unsigned(65535, n_bits));
		wait;
	end process;


end;
