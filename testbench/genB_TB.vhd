library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.data_types.all;

entity genB_tb is
end;
 
architecture bench of genB_tb is

  component genB
      Port(   Clock, Reset, Start : in std_logic;
              A, S : in array_t;
              Q : in unsigned (n_bits - 1 DOWNTO 0);
              B : out unsigned(n_bits - 1 DOWNTO 0);
              Done : out std_logic);
  end component;

  signal Clock, Reset, Start: std_logic;
  signal A :  array_t(0 to a_width-1);
  signal S :  array_t(0 to a_width-1);
  signal Q: unsigned(n_bits - 1 DOWNTO 0) := TO_UNSIGNED(79,n_bits);
  signal B: unsigned(n_bits - 1 DOWNTO 0);
  signal Done: std_logic ;


  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: genB port map ( Clock => Clock,
                       Reset => Reset,
                       Start => Start,
                       A     => A,
                       S     => S,
                       Q     => Q,
                       B     => B,
                       Done  => Done );

  stimulus: process
  begin
  
    Reset <= '1';
    Start <= '0';
    wait for clock_period;
    Reset <= '0';
    wait for 100 * clock_period;
--    A <= (TO_UNSIGNED(0, n_bits), TO_UNSIGNED(0, n_bits), TO_UNSIGNED(0, n_bits), TO_UNSIGNED(0, n_bits));
--    S <= (TO_UNSIGNED(0, n_bits), TO_UNSIGNED(0, n_bits), TO_UNSIGNED(0, n_bits), TO_UNSIGNED(0, n_bits));
    Start <= '1';
--    wait for clock_period * 4;
--    Start <= '0';
--    wait for 10ns;
    A <= (TO_UNSIGNED(30, n_bits), TO_UNSIGNED(45, n_bits), TO_UNSIGNED(75, n_bits), TO_UNSIGNED(43, n_bits));
    S <= (TO_UNSIGNED(27, n_bits), TO_UNSIGNED(58, n_bits), TO_UNSIGNED(8, n_bits), TO_UNSIGNED(2, n_bits));
--    Start <= '1';
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
  