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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uniform_rng is
    GENERIC (
        rand_width : Integer);
    Port ( prime : in STD_LOGIC_vector (15 downto 0);
           seed  : in STD_LOGIC_VECTOR ( 30 downto 0);
           clk   : std_logic; 
           reset : std_logic;
           random_number : out STD_LOGIC_vector(15 downto 0));
end uniform_rng;

architecture Behavioral of uniform_rng is

    component log is
     Port ( input : in STD_LOGIC_vector(15 downto 0);
            res : out integer range 0 to 15);
     end component;
     
signal rand : std_logic_vector(30 downto 0) := SEED;
signal feedback : std_logic;
signal generated_rand : std_logic_vector(rand_width downto 0) ; --initilise to 0 (smallet possilbe value=1)
signal generated_rand_int :integer;
signal prime_int : integer;
begin
    
  feedback <= not((rand(0) xor rand(3)));
  

--  get_log_of_prime : log
--  port map ( input   => prime,
--             res     => log_of_prime );

  -- uniform random number generation credit: https://hforsten.com/generating-normally-distributed-pseudorandom-numbers-on-a-fpga.html
  process(clk,reset)
  begin
      if reset = '1' then
        rand <= SEED;
      elsif rising_edge(clk) then
          rand <= feedback&rand(30 downto 1);
      end if;
  end process;

    generated_rand <= rand(rand_width downto 0);
    
    generated_rand_int <= to_integer(unsigned(generated_rand));
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
