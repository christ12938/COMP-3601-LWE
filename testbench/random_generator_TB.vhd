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


entity TB is
end entity TB ;

architecture bench of TB is

component uniform_rng

      Port ( cap : in STD_LOGIC_vector (n_bits - 1 downto 0);
             seed  : in STD_LOGIC_VECTOR ( n_bits * 2 - 1 downto 0);
             clk,reset,start_signal   :in std_logic;
--             width        :in integer;
             random_number : out STD_LOGIC_vector(n_bits - 1 downto 0));
  end component;

--component log
--   port ( input: in std_logic_vector(n_bits - 1 downto 0);
--           res : out integer range 0 to n_bits - 1;
--           rng_start: out std_logic);
--   end component;

 component error_generator
    Port ( max_cap : in integer;
          clk,reset,start_signal   :in std_logic;
          error    : out integer);
   end component;

  signal prime: STD_LOGIC_vector (n_bits - 1 downto 0):= std_logic_vector(to_unsigned(13, n_bits));
  signal seed: STD_LOGIC_VECTOR ( n_bits * 2 - 1 downto 0):= std_logic_vector(to_unsigned(123, n_bits * 2));
  signal clk,reset,rng_start: std_logic :='0';
  signal random_number: STD_LOGIC_vector(n_bits - 1 downto 0);
  signal log_res :  integer range 0 to n_bits - 1;
  signal error: integer;
  constant clock_period: time := 1 ns;
  signal stop_the_clock: boolean;

begin


--  get_log : log port map ( input => prime,
--                           res => log_res,
--                           rng_start => rng_start);

  uut: uniform_rng  port map ( cap         => prime,
                                 seed          => seed,
                                 clk           => clk,
                                 reset         => reset,
                                 start_signal  => rng_start,
--                                 width         => log_res,
                                 random_number => random_number );

  erro: error_generator port map  ( max_cap =>5,
                                   clk => clk,
                                   reset => reset,
                                   start_signal => rng_start,
                                   error => error);


  stimulus: process
  begin
    -- Put initialisation code here

    reset <= '1';
    wait for 5 ns;
    reset <= '0';
    rng_start <= '1';
    wait for 1000 ns;

    -- Put test bench stimulus code here

    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
