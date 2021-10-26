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
                     seed  : in STD_LOGIC_VECTOR (63 downto 0);  -- initial LFSR state
                     clk,reset,start_signal   :in std_logic;  -- start signal will be set from log
                     random_number : out STD_LOGIC_vector(n_bits - 1 downto 0));
end;

architecture Behavioral of uniform_rng is

--    component log
--        port ( input: in std_logic_vector(n_bits - 1 downto 0);
--           res : out integer range 0 to n_bits - 1);
--    end component;
  component modulus_combinational is
       generic ( mul_bits : natural := mul_bits;
                 n_bits : natural := n_bits);
       Port(
            Dividend                : IN        UNSIGNED(mul_bits - 1 DOWNTO 0);
            Divisor                    : IN        UNSIGNED(n_bits - 1 DOWNTO 0);
            Modulo               : OUT       UNSIGNED(n_bits - 1 DOWNTO 0));
    end component;


signal rand : std_logic_vector(63 downto 0);
signal feedback : std_logic;
signal generated_rand : UNSIGNED(n_bits - 1 downto 0) ; --initilise to 0 (smallet possilbe value=1)
signal modulus_dividend : std_logic_vector (mul_bits - 1 downto 0);
begin



    --get_log : log port map ( input => cap,
                           --res => width);

    feedback <= rand(63) xnor rand(62) xnor rand(60) xnor rand(59);           -- TODO: replace this with primitive polynomial of degree 24 to have maximum length
    
    -- uniform random number generation credit: https://hforsten.com/generating-normally-distributed-pseudorandom-numbers-on-a-fpga.html
    process(clk,reset)
    begin
            if reset = '1' then
                rand <= seed;
            elsif start_signal = '1' then
                rand <= rand(62 downto 0) & feedback ;  
            end if;
    end process;
    
    modulus_dividend <= "000000000000000000000" & rand;
    
    modu0: modulus_combinational port map(
            Dividend => UNSIGNED(modulus_dividend),
            Divisor => UNSIGNED(cap),
            Modulo => generated_rand);

        random_number <= std_logic_vector (generated_rand);

        -- if random number > q: return random number -q
        -- else return padded random number
--        process(generated_rand_int,cap_int)
--        begin
--                if (generated_rand_int >= cap_int) then
--                    random_number <= std_logic_vector(to_unsigned(generated_rand_int - cap_int, n_bits));
--                else
--                     random_number <= std_logic_vector(to_unsigned(generated_rand_int, n_bits));
--                end if;
--        end process;

end Behavioral;