----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 28.09.2021 12:43:23
-- Design Name:
-- Module Name: random_generator_TB - Behavioral
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
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.data_types.all;


entity seed_generator_tb is
end entity seed_generator_tb;

architecture bench of seed_generator_tb is

	component seed_generator
		Port (
			master_seed : in unsigned(31 downto 0);
			clock, reset, start : in std_logic;
			random_number : out unsigned(31 downto 0)
		);
	end component;

	signal clock, reset, start : std_logic := '0';
	signal rng_out : unsigned(31 downto 0);

	constant CLOCK_PERIOD : time := 1 ns;

begin

	clock <= not clock after CLOCK_PERIOD / 2;

	stimulus : process begin
		wait for 10 * CLOCK_PERIOD;
		reset <= '1';
		wait for 10 * CLOCK_PERIOD;
		reset <= '0';
		start <= '1';
		wait;
	end process;

	uut : seed_generator
	port map (
		master_seed => MASTER_SEED,
		clock => clock,
		reset => reset,
		start => start,
		random_number => rng_out
	);

end;
