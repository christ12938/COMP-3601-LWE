-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.data_types.all;

entity decrypt_tb is
end;

architecture bench of decrypt_tb is

  component decrypt
      Port(   U, S : in array_mul_t (0 to a_width-1);
              V, Q : in unsigned (n_bits - 1 DOWNTO 0);
              M    : out std_logic);
  end component;

  signal U :  array_mul_t(0 to a_width-1);
  signal S :  array_mul_t(0 to a_width-1):=(TO_UNSIGNED(27, mul_bits), TO_UNSIGNED(58, mul_bits), TO_UNSIGNED(8, mul_bits), TO_UNSIGNED(2, mul_bits));
  signal Q: unsigned(n_bits - 1 DOWNTO 0) := TO_UNSIGNED(79, n_bits);
  signal V: unsigned(n_bits - 1 DOWNTO 0) := TO_UNSIGNED(30, n_bits);
  signal M: std_logic;

begin

  uut: decrypt port map ( U => U,
                          S => S,
                          V => V,
                          Q => Q,
                          M => M );

  stimulus: process
  begin
  
    -- Put initialisation code here

    U <=(TO_UNSIGNED(21, mul_bits), TO_UNSIGNED(73, mul_bits), TO_UNSIGNED(53, mul_bits), TO_UNSIGNED(49, mul_bits));
    wait for 10 ns;
    U <=(TO_UNSIGNED(22, mul_bits), TO_UNSIGNED(73, mul_bits), TO_UNSIGNED(53, mul_bits), TO_UNSIGNED(49, mul_bits));
    -- Put test bench stimulus code here

    wait;
  end process;


end;