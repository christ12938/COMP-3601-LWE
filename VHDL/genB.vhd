----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/06/2021 01:20:01 PM
-- Design Name: 
-- Module Name: genB - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use work.data_types.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity genB is
    Port(   Clock, Reset, Start : in std_logic;
            A, S : in array_mul_t (0 to a_width-1);
            Q : in unsigned (n_bits - 1 DOWNTO 0);
            B : out unsigned(n_bits - 1 DOWNTO 0);
            Done : out std_logic);
end genB;

architecture Behavioral of genB is 

    component rowMul is
	   generic (
		  mul_bits : natural := mul_bits
		);
	   Port ( A : in array_mul_t;
            S : in array_mul_t;
            reset, start : in std_logic;
            result : out unsigned);
    end component;
    
    component error_generator is
        Port ( max_cap : in integer;
            clk,reset,start_signal   :in std_logic;
            done     : out std_logic;
            error    : out integer);
    end component;
    
    component modulus is
       generic ( mul_bits : natural := mul_bits;
	             n_bits : natural := n_bits);
	   Port(	Start, Reset, Clock    : IN 		STD_LOGIC;
			Dividend                : IN		UNSIGNED(mul_bits - 1 DOWNTO 0);
			Divisor		            : IN		UNSIGNED(n_bits - 1 DOWNTO 0);
			Remainder               : OUT       UNSIGNED(n_bits - 1 DOWNTO 0);
			Done                    : OUT    STD_LOGIC);
    end component;
    
    type state_type is (S1, S2, S3, S4, S5);
    signal state : state_type;  
    signal modulus_start: std_logic;
    signal errorGen_done : std_logic;
    signal modulus_input: unsigned(mul_bits - 1 DOWNTO 0);    
    signal rowMul_result : unsigned(mul_bits - 1 DOWNTO 0);
    signal errorGen_result : integer;
    signal add_done : std_logic;
    signal modulus_done: std_logic;
    signal modulue_start: std_logic;
    
begin
    
    FSM_transitions: process (Reset, Clock)
    begin
        if Reset = '1'then 
            state <= S1;
        elsif rising_edge(Clock) then
            case state is
                when S1 =>
                    if Start = '0' then state <= S1; else state <= S2; end if;
                when S2 =>
                    if errorGen_done = '1' then state <= S3; else state <= S2; end if;
                when S3 =>
                    if add_done = '1' then state <= S4; else state <= S3; end if;
                when S4 =>
                    if modulus_done = '1' then state <= S5; else state <= S4; end if;
                when S5 =>
                    if Start = '1' then state <= S5; else state <= S1; end if;
            end case;
        end if;
    end process;

    do: process (state)
    begin
        case state is
            when S1 => 
                Done <= '0';
                modulus_start <= '0';  
                add_done <= '0';
                modulue_start <= '0';
            when S2 =>
                modulue_start <= '1';
            when S3 =>
                modulus_input <= rowMul_result + errorGen_result;
                add_done <= '1';
            when S4 =>
                modulus_start <= '1';
            when S5 =>
                Done <= '1';
        end case;
    end process;
    
    row_mul: rowMul port map (
            A => A,
            S => S,
            reset => Reset,
            start => modulue_start,
            result => rowMul_result);
            
    err_gen: error_generator port map (
            max_cap => 1,
            clk => Clock,
            reset => Reset,
            start_signal => modulue_start,
            done => errorGen_done,
            error => errorGen_result);
            
    modu: modulus port map(
            Start => modulus_start,
            Reset => Reset,
            Clock => Clock,
            Dividend => modulus_input,
            Divisor => Q,
            Remainder => B,
            Done => modulus_done);



end Behavioral;
