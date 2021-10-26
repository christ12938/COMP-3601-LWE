-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
USE WORK.DATA_TYPES.ALL;

entity mod_comb_tb is
end;

architecture bench of mod_comb_tb is

  component modulus_combinational
  	GENERIC (  dividend_width : NATURAL;
  	           divisor_width : NATURAL);
  	PORT(
  			Dividend                : IN		UNSIGNED(mul_bits - 1 DOWNTO 0);
  			Divisor		            : IN		UNSIGNED(n_bits - 1 DOWNTO 0);
  			Modulo               : OUT       UNSIGNED(n_bits - 1 DOWNTO 0));
  end component;

  -- signal Start, Reset: STD_LOGIC;
  signal Dividend: UNSIGNED(mul_bits - 1 DOWNTO 0);
  signal Divisor: UNSIGNED(n_bits - 1 DOWNTO 0);
  signal Modulo: UNSIGNED(n_bits - 1 DOWNTO 0);

begin

  -- Insert values for generic parameters !!
  uut: modulus_combinational generic map ( dividend_width  => mul_bits,
                             divisor_width    =>  n_bits)
                  port map (
                             Dividend  => Dividend,
                             Divisor   => Divisor,
                             Modulo => Modulo );

  stimulus: process
  begin
    -- Put initialisation code here
    -- Start<= '0';
    -- Reset <= '0';
    wait for 10 ns;
    -- Start <= '1';
    Dividend<=  UNSIGNED(TO_SIGNED(-307, mul_bits));
    Divisor<=  TO_UNSIGNED(3, n_bits);
    wait for 10 ns;
    Dividend<=  UNSIGNED(TO_SIGNED(-5293, mul_bits));
    Divisor<=  TO_UNSIGNED(79, n_bits);
    wait for 10 ns;
    Dividend<=  UNSIGNED(TO_SIGNED(0, mul_bits));
    Divisor<=  TO_UNSIGNED(79, n_bits);
    wait for 10 ns;
    Dividend<=  UNSIGNED(TO_SIGNED(47, mul_bits));
    Divisor<=  TO_UNSIGNED(6, n_bits);
    wait for 10 ns;
    dividend <= unsigned(to_signed(1, mul_bits));
    divisor <= unsigned(to_signed(29, n_bits));
    wait;
  end process;


end;
