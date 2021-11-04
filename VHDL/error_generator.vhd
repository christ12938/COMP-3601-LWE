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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.data_types.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity error_generator is
    Port ( max_cap : in integer;    -- max cap === min cap
           clk,reset,start_signal   :in std_logic;
           seed : in unsigned(63 downto 0);
           seed_valid : in std_logic;
           done     : out std_logic;
           error    : out integer);
end error_generator;

architecture Behavioral of error_generator is
    component uniform_rng

      Port ( cap : in STD_LOGIC_vector (n_bits - 1 downto 0);
             seed  : in STD_LOGIC_VECTOR ( 63 downto 0);
             clk,reset,start_signal   :in std_logic;
             random_number : out STD_LOGIC_vector(n_bits - 1 downto 0));
  end component;

    signal rn_range : integer;
    signal rn_range_vector : std_logic_vector(n_bits - 1 downto 0);
    signal width: integer;
    signal fake_signal: std_logic;
    signal random_number_signal: std_logic_vector(n_bits - 1 downto 0);

begin
    rn_range <= 2 * max_cap;
    rn_range_vector <=  std_logic_vector(to_unsigned(rn_range, n_bits));

--    get_log : log port map ( input => rn_range_vector,
--                            res => width,
--                            rng_start => fake_signal );

    uniform_generator : uniform_rng port map ( cap         => rn_range_vector,
                                 seed          => std_logic_vector(seed),
                                 clk           => clk,
                                 reset         => reset or seed_valid,
                                 start_signal  => fake_signal,
                                 random_number => random_number_signal );

    process(clk, reset)
        variable sample :integer := 0;
        variable var: integer;
        variable result: std_logic_vector(n_bits - 1 downto 0);

    begin
        if reset = '1' or start_signal = '0' then
            result := (others => '0');
            done <= '0';
            sample := 0;
        elsif rising_edge(clk) and start_signal = '1' and sample < 5 then
            result := result + random_number_signal;
            if (to_integer(unsigned(result)) > rn_range) then
                result := result - rn_range;
            end if;
            sample := sample +1;
            if sample = 5 then         -- summing 10 uniform random numbers to get a random number
                var := to_integer(unsigned(result));
--                          if (var > rn_range) then
--                          var := var - rn_range;
--                          end if;
                error <= var - max_cap;
                done <= '1';
            end if;
        end if;
    end process;


end Behavioral;
