-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

-- should it be n_bits or mul_bits
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
USE WORK.DATA_TYPES.ALL;

entity ecLog_TB is
end;

architecture bench of ecLog_TB is

  component approx_multiplier_combinational
      Port (
             input_a : in unsigned(n_bits-1 downto 0) ;
             input_b : in unsigned(n_bits -1 downto 0);
             output   : out unsigned (mul_bits - 1 downto 0));
  end component;
  


    
    --component log_v2
		--	port ( input : in std_logic_vector(n_bits - 1 downto 0);
			--			 res : out integer range 0 to n_bits - 1);
	--end component;



  signal input_a: unsigned(n_bits-1 downto 0);
  signal input_b: unsigned(n_bits -1 downto 0);
  signal output: unsigned (mul_bits - 1 downto 0);
  signal ecLog_res: UNSIGNED(3+ k_trunc downto 0); 
  signal Start, Reset: STD_LOGIC;
  signal frac : unsigned(k_trunc -1  downto 0);
  signal log_res: Integer;

begin

  uut: approx_multiplier_combinational port map ( input_a => input_a,
                                                  input_b => input_b,
                                                  output  => output );

                            
    --log_first: log_v2 port map (input => std_logic_vector(input_a) ,
      --                    res => log_res);                 
  stimulus: process
  begin
  Start<= '0';
Reset <= '0';
wait for 10 ns;
Start <= '1';
input_A<=  UNSIGNED(TO_SIGNED(100, n_bits));
input_B <= UNSIGNED(TO_SIGNED(3, n_bits));
wait for 10 ns;
input_A<=  UNSIGNED(TO_SIGNED(10, n_bits));
input_B <= UNSIGNED(TO_SIGNED(4, n_bits));
wait for 10 ns;
input_A<=  UNSIGNED(TO_SIGNED(100, n_bits));
input_B <= UNSIGNED(TO_SIGNED(5, n_bits));
    -- Put test bench stimulus code here

    wait;
  end process;



end;
  