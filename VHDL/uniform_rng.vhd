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
		Port ( cap : in STD_LOGIC_vector (n_bits - 1 downto 0);
					 seed  : in STD_LOGIC_VECTOR (n_bits * 2 - 1 downto 0);  -- initial LFSR state
					 clk,reset,start_signal   :in std_logic;  -- start signal will be set from log
					 random_number : out STD_LOGIC_vector(n_bits - 1 downto 0));
end;

architecture Behavioral of uniform_rng is

    component log
        port ( input: in std_logic_vector(n_bits - 1 downto 0);
           res : out integer range 0 to n_bits - 1);
    end component;
   
signal rand : std_logic_vector(n_bits * 2 - 1 downto 0) := SEED;
signal feedback : std_logic;
signal generated_rand : std_logic_vector(n_bits - 1 downto 0) ; --initilise to 0 (smallet possilbe value=1)
signal generated_rand_int :integer;
signal cap_int : integer;
-- Make sure the width has the - 1 already otherwise Vivado gives you a weird error!
-- e.g. width => n_bits - 1, not width = n_bits
signal width : integer range 0 to n_bits - 1;        -- log of cap which will be used to set the max map cap on the random number max : 2^width
 
begin



    get_log : log port map ( input => cap,
                           res => width);
                           
	feedback <= not((rand(0) xor rand(3)));           -- TODO: replace this with primitive polynomial of degree 24 to have maximum length

	-- uniform random number generation credit: https://hforsten.com/generating-normally-distributed-pseudorandom-numbers-on-a-fpga.html
	process(clk,reset)
	begin
			if reset = '1' then
				rand <= SEED;
			elsif start_signal = '1' then
				rand <= feedback&rand(n_bits * 2 - 1 downto 1);
			end if;
	end process;

		generated_rand_int <= to_integer(unsigned(rand(width downto 0)));
		cap_int <= to_integer(unsigned(cap));

		-- if random number > q: return random number -q
		-- else return padded random number
		process(generated_rand_int,cap_int)
		begin
				if (generated_rand_int >= cap_int) then
					random_number <= std_logic_vector(to_unsigned(generated_rand_int - cap_int, n_bits));
				else
					 random_number <= std_logic_vector(to_unsigned(generated_rand_int, n_bits));
				end if;
		end process;

end Behavioral;
