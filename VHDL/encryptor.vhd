----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.10.2021 14:23:51
-- Design Name: 
-- Module Name: encryptor - Behavioral
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
use work.data_types.all;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity encryptor is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           reset : in STD_LOGIC;
           data_a : in array_t(0 to a_width-1);
           data_b : in unsigned(n_bits - 1 downto 0);
           q : in  unsigned(n_bits - 1 downto 0);
           M : in STD_LOGIC;
           index_a : out unsigned(b_bram_address_width - 1 downto 0);
           index_b : out unsigned(b_bram_address_width - 1 downto 0);
           encrypted_m : out encryptedMsg;
           done : out STD_LOGIC);
end encryptor;

architecture Behavioral of encryptor is
    component uniform_rng is
        Port ( cap : in STD_LOGIC_vector (n_bits - 1 downto 0);
            seed  : in STD_LOGIC_VECTOR (n_bits * 2 - 1 downto 0);  -- initial LFSR state
            clk,reset,start_signal   :in std_logic;  -- start signal will be set from log
            -- Make sure the width has the - 1 already otherwise Vivado gives you a weird error!
            -- e.g. width => n_bits - 1, not width = n_bits
            random_number : out STD_LOGIC_vector(n_bits - 1 downto 0));
    end component;
    
    component encrypt_combinational is
        Port ( clk : in STD_LOGIC;
               start : in std_logic;
               start_mod : in STD_LOGIC;
               reset : in STD_LOGIC;
               A_row : in array_t(0 to a_width-1);
               B_element : in unsigned(n_bits - 1 downto 0);
               q : in unsigned(n_bits - 1 downto 0);
               M : in STD_LOGIC;
               encryptedM : out encryptedMsg;
               done : out STD_LOGIC
               );
    end component;
    
    signal index : std_logic_vector(n_bits - 1 downto 0);
    signal got_all_data : std_logic;
begin

random_index_generator : uniform_rng port map(
    cap => std_logic_vector(TO_UNSIGNED(a_height-1,n_bits)),
    seed => std_logic_vector(SEED),
    clk => clk,
    reset => reset,
    start_signal => start,
    random_number => index
);
process(clk,reset)
variable count : integer := 0;
begin
    if reset = '1' then
        count := 0;
        got_all_data <= '0';
--        index <= (others => '0');
    elsif start = '1' and rising_edge(clk) then
        if count = sample_size then
            got_all_data <= '1';
        else
            index_a <= unsigned(index);
            index_b <= unsigned(index);  
            count := count + 1;              
        end if;   
    end if;
end process;

encryption : encrypt_combinational port map(
    clk => clk,
    start => start,
    start_mod => got_all_data,
    reset => reset,
    A_row => data_a,
    B_element => data_b,
    q => q,
    M => M,
    encryptedM => encrypted_m,
    done => done
);

end Behavioral;
