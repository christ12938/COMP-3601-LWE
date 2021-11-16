library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
USE WORK.DATA_TYPES.ALL;

----------------------------------------------------------------------------------
--TODO: ML, ME to the data type based on config
--delta_ecLog_addr: size is mL 
--delta_ecExp_addr: size is Me
--delta_ecLog: size is k
--delta_exExp: size is k
--k =  bitlen*2+1    also define in data type as const switch/case
--bitlen = log q

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity approx_multiplier_combinational is
    Port ( --clk : in STD_LOGIC;
           --reset : in STD_LOGIC;
           --start : in STD_LOGIC;
           input_a : in unsigned(n_bits-1 downto 0) ;
           input_b : in unsigned(n_bits -1 downto 0);
           output   : out unsigned (2*n_bits -1 downto 0));
           --finished_operation  : out std_logic);
           
end approx_multiplier_combinational;

architecture Behavioral of approx_multiplier_combinational is

component ecLog
 
    Port ( input : in UNSIGNED(n_bits - 1 downto 0);
          --delta:  in UNSIGNED(n_bits - 1 downto 0);       -- what is the size
         --  k       : in integer;                                    -- what is the range
           res :   out UNSIGNED(3+ k_trunc downto 0);   -- how should we return the output ? what is the size of the output after trunctuation
           frac_output:   out unsigned (k_trunc-1  downto 0)); -- replaced with ML
 
    end component;
    
    component log_v1 is
    Port ( input : in UNSIGNED(n_bits - 1 downto 0);
           res : out integer range 0 to n_bits - 1); 
    end component; 
    
    component ecExp is port (
            input : in UNSIGNED(n_bits - 1 downto 0);
           --delta:  in UNSIGNED(n_bits - 1 downto 0);       -- what is the size
          -- k       : in integer;                                    -- what is the range
           res :   out UNSIGNED(n_bits - 1 downto 0));
    end component;
    



--	constant BLOCK_RAM_DELAY : positive := 1; -- what is this one 

	
    signal delta_log_A: unsigned(k_trunc - 1 downto 0);
    signal delta_log_B: unsigned (k_trunc -1 downto 0);
   -- signal delta_exp:   unsigned (k_trunc -1 downto 0);
    
    --signal delta_addr_A: unsigned (ml -1 downto 0);
   -- signal delta_addr_B: unsigned (ml -1 downto 0);
    --signal delta_addr_exp: unsigned (me -1 downto 0);
    
--    signal next_state : approx_mul_state;
    
    signal frac_A     : unsigned (k_trunc -1 downto 0);
    signal frac_B     : unsigned (k_trunc -1 downto 0);
    
   
    
    signal approx_log_A:    unsigned (3+ k_trunc downto 0);  -- max integer size: 4 --> 4 + k_trunc (size of frac)
    signal approx_log_B:    unsigned (3+ k_trunc downto 0);  -- max integer size: 4 --> 4 + k_trunc (size of frac)
    
    signal ecExp_input : unsigned (3+ k_trunc downto 0);
    signal exp_output: unsigned (2*mul_bits -1 downto 0);

begin

--get_delta_log: log_v1 port map (input => input,
--                            res => log); 

aLog: ecLog port map ( 
                            
                             input  => input_a,
                             --delta   => delta_log_A, 
                            -- k => k,            -- how are we getting this
                             res => approx_log_A,
                             frac_output => frac_A );  -- why it's "u" ?
                             
bLog: ecLog port map ( 
                            
                             input  => input_b,
                             --delta   => delta_log_B,
                             --k => k,
                             res => approx_log_B,
                             frac_output => frac_A);
                             
ecExp_input <= approx_log_A;
-- + approx_log_B;
 
-- get exp delta
--exp: ecExp port map (
--                            input => ecExp_input,
--                            --delta => delta_exp,
--                            res   => output);

    
end Behavioral;
