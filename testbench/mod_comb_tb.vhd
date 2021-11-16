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
  			Dividend                : IN		signed(mul_bits - 1 DOWNTO 0);
  			Divisor		            : IN		UNSIGNED(n_bits - 1 DOWNTO 0);
  			Modulo               : OUT       UNSIGNED(n_bits - 1 DOWNTO 0));
  end component;
  
  
  component mod_v2 is
  	generic (
  		dividend_width : positive := mul_bits;
  		divisor_width : positive := n_bits
  	);
  	port (
  		dividend : in signed(dividend_width - 1 downto 0);
  		divisor : in unsigned(divisor_width - 1 downto 0);
  		modulo : out unsigned(divisor_width - 1 downto 0)
  	);
  end component;

  -- signal Start, Reset: STD_LOGIC;
  signal Dividend: signed(mul_bits - 1 DOWNTO 0);
  signal Divisor: UNSIGNED(n_bits - 1 DOWNTO 0) := to_unsigned(1, n_bits);
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
--    wait for 10 ns;
    -- Start <= '1';
    Dividend<=  signed(TO_SIGNED(-307, mul_bits));
    Divisor<=  TO_UNSIGNED(3, n_bits);
    wait for 10 ns;
    Dividend<=  signed(TO_SIGNED(-5293, mul_bits));
    Divisor<=  TO_UNSIGNED(79, n_bits);
    wait for 10 ns;
    Dividend<=  signed(TO_SIGNED(0, mul_bits));
    Divisor<=  TO_UNSIGNED(79, n_bits);
    wait for 10 ns;
    Dividend<=  signed(TO_SIGNED(47, mul_bits));
    Divisor<=  TO_UNSIGNED(6, n_bits);
    wait for 10 ns;
    dividend <= signed(to_signed(1, mul_bits));
    divisor <= to_unsigned(29, n_bits);
    wait for 10 ns;
    dividend <= signed(to_signed(-16, mul_bits));
    divisor <= to_unsigned(65535, n_bits);
    wait;
  end process;


end;
