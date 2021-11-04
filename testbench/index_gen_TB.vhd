-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.data_types.all;

entity index_generator_tb is
end;

architecture bench of index_generator_tb is

  component index_generator
      Port (  Start, Reset, Clock : in std_logic;
              index_list : out array_index;
              Done : out std_logic);
  end component;

  signal Start, Reset, Clock: std_logic;
  signal index_list: array_index;
  signal Done: std_logic;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: index_generator port map ( Start      => Start,
                                  Reset      => Reset,
                                  Clock      => Clock,
                                  index_list => index_list,
                                  Done       => Done );

  stimulus: process
  begin
  
    -- Put initialisation code here

    Reset <= '1';
    start <= '0';
    wait for 5 ns;
    Reset <= '0';
    wait for 5 ns;
    start <= '1';
    wait for 500 ns;
    start <= '0';
    wait for 5 ns;
    start <= '1';
    -- Put test bench stimulus code here

    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      Clock <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;