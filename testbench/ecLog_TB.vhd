----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.11.2021 15:28:35
-- Design Name: 
-- Module Name: ecLog_TB - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
USE WORK.DATA_TYPES.ALL;

entity ecLog_TB is
end;

architecture bench of ecLog_TB is

  component ecLog
 
    Port ( input : in UNSIGNED(n_bits - 1 downto 0);
           delta:  in UNSIGNED(n_bits - 1 downto 0);       -- what is the size
           k       : in integer;                                    -- what is the range
           res :   out UNSIGNED(n_bits - 1 downto 0));   -- how should we return the output ? what is the size of the output after trunctuation
    end component;
    
    component barell_shifter is
    Port ( input : UNSIGNED(n_bits-1 downto 0);    -- what is the type here?
               log : in integer;      -- how many bits to rol by
               output : out UNSIGNED(n_bits-1 downto 0));
    end component;
       
    component log_v1 is
    Port ( input : in UNSIGNED(n_bits - 1 downto 0);
           res : out integer range 0 to n_bits - 1); 
    end component; 

  signal Start, Reset: STD_LOGIC;
  signal input: UNSIGNED(n_bits - 1 DOWNTO 0);
  signal delta: UNSIGNED(n_bits - 1 DOWNTO 0) := (others => '0');
  signal k: integer := 0;
  signal frac: UNSIGNED(n_bits - 1 DOWNTO 0);
  signal log : integer;
  signal res: UNSIGNED(n_bits - 1 DOWNTO 0);


begin

  -- Insert values for generic parameters !!


  stimulus: process
  begin
  
    -- Put initialisation code here
Start<= '0';
Reset <= '0';
wait for 10 ns;
Start <= '1';
input<=  UNSIGNED(TO_SIGNED(20, n_bits));
wait for 10 ns;
input <=  UNSIGNED(TO_SIGNED(7, n_bits));
wait for 10 ns;
input<=  UNSIGNED(TO_SIGNED(0, n_bits));
    -- Put test bench stimulus code here

    wait;
  end process;

  uut: ecLog port map ( 
                            
                             input  => input,
                             delta   => delta,
                             k => k,
                             res => res );  -- why it's "u" ?
                             
  get_log: log_v1 port map (input => input,
                            res => log);  
                                                     
  uut2: barell_shifter port map ( input => input,
                                       log => log,
                                       output => frac);

end;
