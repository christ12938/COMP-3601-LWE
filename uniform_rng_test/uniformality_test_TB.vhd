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
use STD.textio.all;
use ieee.std_logic_textio.all;

entity TB is
end entity TB ;

architecture bench of TB is

component uniform_rng

      Port ( cap : in STD_LOGIC_vector (n_bits - 1 downto 0);
             seed  : in STD_LOGIC_VECTOR ( n_bits * 2 - 1 downto 0);
             clk,reset,start_signal   :in std_logic;
             random_number : out STD_LOGIC_vector(n_bits - 1 downto 0));
  end component;

-- Change your output file location (relative path)
  constant path :string  := "../../../../../comp3601/uniform_rng_test/vhdl_output.txt";
-- Change Cap Manually
  signal cap: STD_LOGIC_vector (n_bits - 1 downto 0):= std_logic_vector(to_unsigned(79, n_bits));
  
  signal clk,reset,rng_start: std_logic :='0';
  signal random_number: STD_LOGIC_vector(n_bits - 1 downto 0);
--  signal error: integer;
  constant clock_period: time := 1 ns;
  signal stop_the_clock: boolean;
  file file_RESULTS : text;
begin

  uut: uniform_rng  port map ( cap         => cap,
                                 seed          => STD_LOGIC_VECTOR(SEED),
                                 clk           => clk,
                                 reset         => reset,
                                 start_signal  => rng_start,
                                 random_number => random_number );


  stimulus: process
  begin
    -- Put initialisation code here
    file_open(file_RESULTS, path, write_mode);
    file_close(file_RESULTS);
    reset <= '1';
    wait for 5 ns;
    reset <= '0';
    wait for 5 ns;
    rng_start <= '1';
    -- Put test bench stimulus code here
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
  
process (clk)
    variable v_OLINE     : line;
     
  begin
    if reset = '0' then 
        file_open(file_RESULTS, path, append_mode);

        write(v_OLINE, std_logic_vector (random_number), right, n_bits);
        writeline(file_RESULTS, v_OLINE);
    
        file_close(file_RESULTS);
    end if;
  end process;
end;
