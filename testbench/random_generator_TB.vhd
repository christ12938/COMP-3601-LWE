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



entity random_generator_TB is
end entity random_generator_TB ;

architecture bench of random_generator_TBb is

component uniform_rng
      GENERIC (
          rand_width : Integer);
      Port ( prime : in STD_LOGIC_vector (15 downto 0);
             seed  : in STD_LOGIC_VECTOR ( 31 downto 0);
             clk,reset   :in std_logic; 
             random_number : out STD_LOGIC_vector(15 downto 0));
  end component;

  signal prime: STD_LOGIC_vector (14 downto 0);
  signal seed: STD_LOGIC_VECTOR ( 31 downto 0);
  signal clk,reset: std_logic;
  signal random_number: STD_LOGIC_vector(15 downto 0);

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  -- Insert values for generic parameters !!
  uut: uniform_rng generic map ( rand_width    => 5  )
                      port map ( prime         => prime,
                                 seed          => seed,
                                 clk           => clk,
                                 reset         => reset,
                                 random_number => random_number );

  stimulus: process
  begin
  
    -- Put initialisation code here

    reset <= '1';
    wait for 5 ns;
    reset <= '0';
    wait for 100 ns;

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


