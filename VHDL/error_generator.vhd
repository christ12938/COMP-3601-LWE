----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.10.2021 10:45:53
-- Design Name: 
-- Module Name: error_generator - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity error_generator is
    Port ( max_cap : in integer;
          
          -- min_cap : in integer;    -- assuming that min cap is -map cap
           height : in integer;
           clk,reset,start_signal   :in std_logic;
           error    : out integer);
end error_generator;

architecture Behavioral of error_generator is
    component uniform_rng
  
      Port ( prime : in STD_LOGIC_vector (15 downto 0);
             seed  : in STD_LOGIC_VECTOR ( 31 downto 0);
             clk,reset,start_signal   :in std_logic; 
             width        :in integer;
             random_number : out STD_LOGIC_vector(15 downto 0));
  end component;
  
 component log 
    port ( input: in std_logic_vector(15 downto 0);
            res : out integer range 0 to 15;
            rng_start: out std_logic);
    end component;
    signal rn_range : integer;
    signal rn_range_vector : std_logic_vector(15 downto 0);
    signal width: integer;
    signal fake_signal: std_logic;
    --signal random_number: integer;
    signal random_number_signal: std_logic_vector(15 downto 0);
begin
    rn_range <= 2 * max_cap;
    rn_range_vector <=  std_logic_vector(to_unsigned(rn_range,16));
   
    get_log : log port map ( input => rn_range_vector,
                            res => width,
                            rng_start => fake_signal );
                            
    uut: uniform_rng  port map ( prime         => rn_range_vector,
                                 seed          => x"ABCDE111",
                                 clk           => clk,
                                 reset         => reset,
                                 start_signal  => fake_signal,
                                 width         => width,
                                 random_number => random_number_signal );
    
    process(clk)
        variable result: std_logic_vector(15 downto 0) := (others => '0');
        variable sample :integer := 0;
    begin
        if reset = '1' then
            result := (others => '0');
            sample := 0;
        elsif rising_edge(clk) and start_signal = '1' then
            result := result or random_number_signal;
            sample := sample +1;
        end if;
        if sample = height then
            error <= to_integer(unsigned(result));
        end if;
    end process;
    

end Behavioral;
