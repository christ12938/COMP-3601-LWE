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
             output   : out unsigned (2*n_bits -1 downto 0));
  end component;
  
  component ecLog 
   Port ( input : in UNSIGNED(n_bits - 1 downto 0);
          --delta:  in UNSIGNED(k_trunc - 1 downto 0);       -- what is the size
           --k       : in integer;                                    -- what is the range
           res :   out UNSIGNED(3+ k_trunc downto 0);   -- how should we return the output ? what is the size of the output after trunctuation
           frac_output:   out unsigned (k_trunc -1  downto 0)); -- replaced with ML
    end component;
    
    component log_v1 is
    Port ( input : in UNSIGNED(n_bits - 1 downto 0);
           res : out integer range 0 to n_bits - 1); 
    end component; 
    
    component log_v2
			port ( input : in unsigned(n_bits - 1 downto 0);
						 res : out integer range 0 to n_bits - 1);
	end component;



  signal input_a: unsigned(n_bits-1 downto 0);
  signal input_b: unsigned(n_bits -1 downto 0);
  signal output: unsigned (2*n_bits -1 downto 0);
  signal ecLog_res: UNSIGNED(3+ k_trunc downto 0); 
  signal Start, Reset: STD_LOGIC;
  signal frac : unsigned(k_trunc -1  downto 0);
  signal log_res: Integer;

begin

  uut: approx_multiplier_combinational port map ( input_a => input_a,
                                                  input_b => input_b,
                                                  output  => output );
    approx_log: ecLog port map( input => input_a,
                            res => ecLog_res,
                            frac_output => frac);
                            
    log_first: log port map (input => input_a ,
                          res => log_res);                 
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
  