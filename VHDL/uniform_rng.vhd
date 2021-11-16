----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 25.09.2021 21:54:10
-- Design Name:
-- Module Name: uniform_rng - Behavioral
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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.data_types.all;

entity uniform_rng is
	Port (
		cap : in STD_LOGIC_vector (n_bits - 1 downto 0);
		seed  : in STD_LOGIC_VECTOR (63 downto 0);
		clk,reset,start_signal   :in std_logic;
		random_number : out STD_LOGIC_vector(n_bits - 1 downto 0)
	);
end;

architecture Behavioral of uniform_rng is

	-- uniform_rng uses a custom width modulus
	component modulus_combinational is
		generic (
			dividend_width : natural;
			divisor_width : natural
		);
		port (
			Dividend : IN SIGNED(dividend_width - 1 DOWNTO 0);
			Divisor : IN UNSIGNED(divisor_width - 1 DOWNTO 0);
			Modulo : OUT UNSIGNED(divisor_width - 1 DOWNTO 0)
		);
	end component;

	signal internal_state : std_logic_vector(63 downto 0);
	signal sampled_down_internal_state : std_logic_vector(31 downto 0);
	signal feedback : std_logic;
	signal modded_random_number : UNSIGNED(n_bits - 1 downto 0);

begin
	-- Maximal polynomial for 64 bits
	feedback <= internal_state(63) xnor internal_state(62) xnor internal_state(60) xnor internal_state(59);

	-- uniform random number generation credit: https://hforsten.com/generating-normally-distributed-pseudorandom-numbers-on-a-fpga.html
	process(clk,reset)
	begin
		if reset = '1' then
			internal_state <= seed;
		elsif start_signal = '1' and rising_edge(clk) then
			internal_state <= internal_state(62 downto 0) & feedback;
		end if;
	end process;

	sample_down : for i in 31 downto 0 generate
		sampled_down_internal_state(i) <= internal_state(i * 2);
	end generate;

	modulus : modulus_combinational
	generic map (
		dividend_width => 32,
		divisor_width => n_bits
	)
	port map (
		Dividend => SIGNED(sampled_down_internal_state),
		Divisor => UNSIGNED(cap),
		Modulo => modded_random_number
	);

	random_number <= std_logic_vector(modded_random_number);
end Behavioral;
