library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.data_types.all;

entity rowMul_tb is
end;

architecture bench of rowMul_tb is

  component rowMul
  	generic (
  		mul_bits : natural := mul_bits
  		);
  	Port ( A : in array_mul_t;
             S : in array_mul_t;
             reset, start : in std_logic;
             result : out unsigned);
  end component;

  signal A: array_mul_t;
  signal S: array_mul_t;
  signal reset, start: std_logic;
  signal result: unsigned;

begin

  -- Insert values for generic parameters !!
  uut: rowMul generic map ( mul_bits => 8  )
                 port map ( A        => A,
                            S        => S,
                            reset    => reset,
                            start    => start,
                            result   => result );

  stimulus: process
  begin
  
    -- Put initialisation code here


    -- Put test bench stimulus code here

    wait;
  end process;


end;