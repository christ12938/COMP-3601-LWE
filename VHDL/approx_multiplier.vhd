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


entity approx_multiplier is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start : in STD_LOGIC;
           input_a : in unsigned(mul_bits-1 downto 0) ;
           input_b : in unsigned(mul_bits -1 downto 0);
           res   : out unsigned (2*mul_bits -1 downto 0);
           finished_operation  : out std_logic);
           
end approx_multiplier;

architecture Behavioral of approx_multiplier is

component ecLog
 
    Port ( input : in UNSIGNED(n_bits - 1 downto 0);
          delta:  in UNSIGNED(n_bits - 1 downto 0);       -- what is the size
         --  k       : in integer;                                    -- what is the range
           res :   out UNSIGNED(n_bits - 1 downto 0);   -- how should we return the output ? what is the size of the output after trunctuation
           frac_output:   out unsigned (mL - 1  downto 0)); -- replaced with ML
 
    end component;
    
    component log_v1 is
    Port ( input : in UNSIGNED(n_bits - 1 downto 0);
           res : out integer range 0 to n_bits - 1); 
    end component; 
    
    component ecExp is Port ( input : in UNSIGNED(3+ k_trunc  downto 0);
           delta:  in UNSIGNED(k_trunc -1 downto 0);       
           res :   out UNSIGNED(2*mul_bits -1 downto 0));
    end component;
    
type approx_mul_state is (
		idle,
		get_log_delta,
		get_delta_exp,
		final
	);

	constant BLOCK_RAM_DELAY : positive := 1; -- what is this one 

	signal current_state : approx_mul_state := idle;
    signal delta_log_A: unsigned(k_trunc - 1 downto 0);
    signal delta_log_B: unsigned (k_trunc -1 downto 0);
    signal delta_exp:   unsigned (k_trunc -1 downto 0);
    
    signal delta_addr_A: unsigned (ml -1 downto 0);
    signal delta_addr_B: unsigned (ml -1 downto 0);
    signal delta_addr_exp: unsigned (me -1 downto 0);
    
    signal next_state : approx_mul_state;
    
    signal frac_A     : unsigned (k_trunc -1 downto 0);
    signal frac_B     : unsigned (k_trunc -1 downto 0);
    
    signal delta_addr_exp_valid: std_logic;
    signal delta_addr_A_valid: std_logic;
    signal delta_addr_B_valid: std_logic;
    
    signal approx_log_A:    unsigned (3+ k_trunc downto 0);  -- max integer size: 4 --> 4 + k_trunc (size of frac)
    signal approx_log_B:    unsigned (3+ k_trunc downto 0);  -- max integer size: 4 --> 4 + k_trunc (size of frac)
    
    signal ecExp_input : unsigned (3+ k_trunc downto 0);
    signal done        : std_logic;

begin

--get_log: log_v1 port map (input => input,
--                            res => log); 

aLog: ecLog port map ( 
                            
                             input  => input_a,
                             delta   => delta_log_A, 
                            -- k => k,            -- how are we getting this
                             res => approx_log_A,
                             frac_output => frac_A );  -- why it's "u" ?
                             
bLog: ecLog port map ( 
                            
                             input  => input_b,
                             delta   => delta_log_B,
                             --k => k,
                             res => approx_log_B);

exp: ecExp port map (
                            input => ecExp_input,
                            delta => delta_exp,
                            res   => res);

 
 fms: process(clk, current_state, start, delta_addr_A, delta_addr_B, delta_addr_exp)
	begin
        		delta_addr_A_valid <= '0';
        		delta_addr_B_valid <= '0';
        		delta_addr_exp_valid <= '0';

		-- Default behaviours
		next_state <= current_state;
		done <= '0';

		case current_state is
            when idle =>
                if start = '1' then
                    next_state <= get_log_delta;
                end if;

            when get_log_delta =>
                
                -- pass the addresses to the two seperate block rams
                delta_addr_A_valid <= '1';
                delta_addr_B_valid <= '1';
                next_state <= get_delta_exp;


            when get_delta_exp =>
                -- The random number generators are connected to s_out and are always running
                -- We just take the random number at this clock cycle
                delta_addr_A_valid <= '0';
                delta_addr_B_valid <= '0';
                delta_addr_exp_valid <= '1';
                next_state <= final;

            when final =>
                delta_addr_exp_valid <= '0';
                done <= '1';

        end case;
    end process;

-- this is the logic for loading the delta from block ram given the addr
logic: process(current_state)

variable ecExp_input_var : unsigned(3 + k_trunc  downto 0);

begin

    if delta_addr_A_valid = '1' and delta_addr_B_valid = '1' then
       -- access block ram
       delta_addr_A <= frac_A;
       delta_addr_A <= frac_B;

    
    elsif delta_addr_exp_valid = '1' then

        -- read the value into the signal 
        delta_log_A <= (others => '0'); -- replace this with the value from block ram
        delta_log_B <= (others => '0'); -- replace this with the value from block ram

        -- ecLog is combination so we can use the values
        ecExp_input_var := approx_log_A + approx_log_B; 
        ecExp_input <= ecExp_input_var;

        delta_addr_exp  <= ecExp_input_var(k_trunc -1 downto 0);
        -- delta_addr_exp <= delta_addr_A + delta_addr_B;

    elsif done = '1' then
        delta_exp <= (others => '0');  -- replace this with the value from block ram 
        finished_operation <= '1';
        
    end if;
end process;
                                             

    
end Behavioral;
