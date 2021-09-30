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

entity uniform_rng is
    Port ( prime : in STD_LOGIC_vector (15 downto 0);
           seed  : in STD_LOGIC_VECTOR ( 31 downto 0);  -- initial LFSR state
           clk,reset,start_signal   :in std_logic;  -- start signal will be set from log
           width        : in integer :=16;          -- log of prime which will be used to set the max map cap on the random number max : 2^width
           random_number : out STD_LOGIC_vector(15 downto 0));
end;

architecture Behavioral of uniform_rng is
     
signal rand : std_logic_vector(31 downto 0) := SEED;
signal feedback : std_logic;
signal generated_rand : std_logic_vector(15 downto 0) ; --initilise to 0 (smallet possilbe value=1)
signal generated_rand_int :integer;
signal prime_int : integer;
begin
    
  feedback <= not((rand(0) xor rand(3)));           -- TODO: replace this with primitive polynomial of degree 24 to have maximum length
  
  -- uniform random number generation credit: https://hforsten.com/generating-normally-distributed-pseudorandom-numbers-on-a-fpga.html
  process(clk,reset)
  begin
      if reset = '1' then
        rand <= SEED;
      elsif rising_edge(clk) and start_signal = '1' then
          rand <= feedback&rand(31 downto 1);
      end if;
  end process;
  
    generated_rand_int <= to_integer(unsigned(rand(width downto 0)));
    prime_int <= to_integer(unsigned(prime));

    -- if random number > q: return random number -q
    -- else return padded random number 
    process(generated_rand_int,prime_int)
    begin
        if (generated_rand_int >= prime_int) then
          random_number <= std_logic_vector(to_unsigned(generated_rand_int - prime_int,16));
        else 
           random_number <= std_logic_vector(to_unsigned(generated_rand_int,16));
        end if;
    end process;

end Behavioral;
