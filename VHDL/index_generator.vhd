----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/27/2021 10:45:15 AM
-- Design Name: 
-- Module Name: index_generator - Behavioral
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
use ieee.numeric_std.all;
use work.data_types.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity index_generator is
    Port (  Start, Reset, Clock : in std_logic;
            index_list : out array_index;
            Done : out std_logic);
end index_generator;

architecture Behavioral of index_generator is

    component uniform_rng is
        Port ( cap : in STD_LOGIC_vector (n_bits - 1 downto 0);
            seed  : in STD_LOGIC_VECTOR (63 downto 0);  -- initial LFSR state
            clk,reset,start_signal   :in std_logic;  -- start signal will be set from log
            random_number : out STD_LOGIC_vector(n_bits - 1 downto 0));
    end component;

    type state_type is (Init, Generate_Random, End_State);
    signal state: state_type;
    signal start_rng : std_logic;
    signal count : natural;
    signal random_number : STD_LOGIC_vector(n_bits - 1 downto 0);
begin

random_index_generator : uniform_rng port map(
    cap => std_logic_vector(TO_UNSIGNED(a_height,n_bits)),
    seed => std_logic_vector(SEEDS(19)),
    clk => Clock,
    reset => Reset,
    start_signal => start_rng,
    random_number => random_number
);

FSM_transitions: process (Reset, Clock)
begin
    if Reset = '1' then 
        state <= Init;
    elsif rising_edge (Clock) then
       case state is
        when Init =>
            if Start = '1' then state <= Generate_Random; else state <= Init; end if;
        when Generate_Random =>
            if count = sample_size then state <= End_State; else state <= Generate_Random; end if;
        when End_State =>
            if Start = '0' then state <= Init; else state <= End_State; end if;
       end case;
    end if;
    
end process;

FSM_do : process (state, random_number)
begin
    case state is
        when Init =>
            start_rng <= '0';
            count <= 0;
            Done <= '0';
        when Generate_Random =>
            start_rng <= '1';
            index_list(count) <= unsigned(random_number(a_height_bits - 1 downto 0));
            count <= count + 1;
        when End_State =>
            start_rng <= '0';
            Done <= '1';
    end case;
end process;

end Behavioral;
