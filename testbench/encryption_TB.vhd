------------------------------------------------------------------------------------
---- Company:
---- Engineer:
----
---- Create Date: 24.09.2021 16:44:16
---- Design Name:
---- Module Name: row_multiplier - Behavioral
---- Project Name:
---- Target Devices:
---- Tool Versions:
---- Description:
----
---- Dependencies:
----
---- Revision:
---- Revision 0.01 - File Created
---- Additional Comments:
----
------------------------------------------------------------------------------------


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
----use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx leaf cells in this code.
----library UNISIM;
----use UNISIM.VComponents.all;

--entity row_multiplier is
--    Port ( A : in STD_LOGIC;
--           S : in STD_LOGIC;
--           P : out STD_LOGIC);
--end row_multiplier;

--architecture Behavioral of row_multiplier is

--begin


--end Behavioral;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;
entity encryption_TB is

end encryption_TB;

architecture behave of encryption_TB is

  constant c_CLK_PERIOD : time := 10 ns;  -- 100 MHz
  component uniform_rng is
		Port ( cap : in STD_LOGIC_vector (n_bits - 1 downto 0);
					 seed  : in STD_LOGIC_VECTOR (n_bits * 2 - 1 downto 0);  -- initial LFSR state
					 clk,reset,start_signal   :in std_logic;  -- start signal will be set from log
					 random_number : out STD_LOGIC_vector(n_bits - 1 downto 0));
    end component;
    component encryptor is
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
    end component;
--    component encrypt_combinational is
--    Port ( clk : in STD_LOGIC;
--           start_mod : in STD_LOGIC;
--           reset : in STD_LOGIC;
--           A_row : in array_mul_t(0 to a_width-1);
--           B_element : in unsigned(n_bits - 1 downto 0);
--           q : in unsigned(n_bits - 1 downto 0);
--           M : in STD_LOGIC;
--           encryptedM : out encryptedMsg;
--           done : out STD_LOGIC
--           );
--    end component;
  signal r_CLK_TB : std_logic := '0';
 -- signal a_sample : myVector(0 to sample_size-1) := ((TO_UNSIGNED(52,mul_Bits),TO_UNSIGNED(74,mul_Bits),TO_UNSIGNED(12,mul_Bits),TO_UNSIGNED(24,mul_Bits),TO_UNSIGNED(53,mul_Bits),TO_UNSIGNED(75,mul_Bits),TO_UNSIGNED(13,mul_Bits),TO_UNSIGNED(25,mul_Bits)),(TO_UNSIGNED(48,mul_Bits),TO_UNSIGNED(78,mul_Bits),TO_UNSIGNED(41,mul_Bits),TO_UNSIGNED(25,mul_Bits),TO_UNSIGNED(49,mul_Bits),TO_UNSIGNED(77,mul_Bits),TO_UNSIGNED(42,mul_Bits),TO_UNSIGNED(26,mul_Bits)),(TO_UNSIGNED(52,mul_Bits),TO_UNSIGNED(74,mul_Bits),TO_UNSIGNED(12,mul_Bits),TO_UNSIGNED(24,mul_Bits),TO_UNSIGNED(53,mul_Bits),TO_UNSIGNED(75,mul_Bits),TO_UNSIGNED(13,mul_Bits),TO_UNSIGNED(25,mul_Bits)),(TO_UNSIGNED(48,mul_Bits),TO_UNSIGNED(78,mul_Bits),TO_UNSIGNED(41,mul_Bits),TO_UNSIGNED(25,mul_Bits),TO_UNSIGNED(49,mul_Bits),TO_UNSIGNED(77,mul_Bits),TO_UNSIGNED(42,mul_Bits),TO_UNSIGNED(26,mul_Bits)));
  signal a_sample : myVector(0 to a_height-1) := ((TO_UNSIGNED(52,n_Bits),TO_UNSIGNED(74,n_Bits),TO_UNSIGNED(12,n_Bits),TO_UNSIGNED(24,n_Bits),TO_UNSIGNED(53,n_Bits),TO_UNSIGNED(75,n_Bits),TO_UNSIGNED(13,n_Bits),TO_UNSIGNED(25,n_Bits)),(TO_UNSIGNED(48,n_Bits),TO_UNSIGNED(78,n_Bits),TO_UNSIGNED(41,n_Bits),TO_UNSIGNED(25,n_Bits),TO_UNSIGNED(49,n_Bits),TO_UNSIGNED(77,n_Bits),TO_UNSIGNED(42,n_Bits),TO_UNSIGNED(26,n_Bits)),(TO_UNSIGNED(53,n_Bits),TO_UNSIGNED(74,n_Bits),TO_UNSIGNED(12,n_Bits),TO_UNSIGNED(24,n_Bits),TO_UNSIGNED(53,n_Bits),TO_UNSIGNED(75,n_Bits),TO_UNSIGNED(13,n_Bits),TO_UNSIGNED(25,n_Bits)),(TO_UNSIGNED(48,n_Bits),TO_UNSIGNED(78,n_Bits),TO_UNSIGNED(41,n_Bits),TO_UNSIGNED(25,n_Bits),TO_UNSIGNED(49,n_Bits),TO_UNSIGNED(77,n_Bits),TO_UNSIGNED(42,n_Bits),TO_UNSIGNED(26,n_Bits)),(TO_UNSIGNED(54,n_Bits),TO_UNSIGNED(74,n_Bits),TO_UNSIGNED(12,n_Bits),TO_UNSIGNED(24,n_Bits),TO_UNSIGNED(53,n_Bits),TO_UNSIGNED(75,n_Bits),TO_UNSIGNED(13,n_Bits),TO_UNSIGNED(25,n_Bits)),(TO_UNSIGNED(48,n_Bits),TO_UNSIGNED(78,n_Bits),TO_UNSIGNED(41,n_Bits),TO_UNSIGNED(25,n_Bits),TO_UNSIGNED(49,n_Bits),TO_UNSIGNED(77,n_Bits),TO_UNSIGNED(42,n_Bits),TO_UNSIGNED(26,n_Bits)),(TO_UNSIGNED(55,n_Bits),TO_UNSIGNED(74,n_Bits),TO_UNSIGNED(12,n_Bits),TO_UNSIGNED(24,n_Bits),TO_UNSIGNED(53,n_Bits),TO_UNSIGNED(75,n_Bits),TO_UNSIGNED(13,n_Bits),TO_UNSIGNED(25,n_Bits)),(TO_UNSIGNED(48,n_Bits),TO_UNSIGNED(78,n_Bits),TO_UNSIGNED(41,n_Bits),TO_UNSIGNED(25,n_Bits),TO_UNSIGNED(49,n_Bits),TO_UNSIGNED(77,n_Bits),TO_UNSIGNED(42,n_Bits),TO_UNSIGNED(26,n_Bits)));
  signal b_sample : array_t(0 to a_height-1) := (TO_UNSIGNED(72,n_bits),TO_UNSIGNED(37,n_bits),TO_UNSIGNED(62,n_bits),TO_UNSIGNED(35,n_bits),TO_UNSIGNED(72,n_bits),TO_UNSIGNED(37,n_bits),TO_UNSIGNED(62,n_bits),TO_UNSIGNED(35,n_bits));
--  signal A : myVector(0 to g_IMAGE_ROWS-1):= ((TO_UNSIGNED(30,g_Bits),TO_UNSIGNED(45,g_Bits),TO_UNSIGNED(75,g_Bits),TO_UNSIGNED(43,g_Bits)),(TO_UNSIGNED(62,g_Bits),TO_UNSIGNED(73,g_Bits),TO_UNSIGNED(43,g_Bits),TO_UNSIGNED(24,g_Bits)),(TO_UNSIGNED(64,g_Bits),TO_UNSIGNED(25,g_Bits),TO_UNSIGNED(30,g_Bits),TO_UNSIGNED(11,g_Bits)),(TO_UNSIGNED(0,g_Bits),TO_UNSIGNED(27,g_Bits),TO_UNSIGNED(74,g_Bits),TO_UNSIGNED(78,g_Bits)),(TO_UNSIGNED(48,g_Bits),TO_UNSIGNED(78,g_Bits),TO_UNSIGNED(41,g_Bits),TO_UNSIGNED(25,g_Bits)),(TO_UNSIGNED(29,g_Bits),TO_UNSIGNED(34,g_Bits),TO_UNSIGNED(13,g_Bits),TO_UNSIGNED(38,g_Bits)),(TO_UNSIGNED(19,g_Bits),TO_UNSIGNED(60,g_Bits),TO_UNSIGNED(17,g_Bits),TO_UNSIGNED(28,g_Bits)),(TO_UNSIGNED(52,g_Bits),TO_UNSIGNED(74,g_Bits),TO_UNSIGNED(12,g_Bits),TO_UNSIGNED(24,g_Bits)));
--  signal S :  A_t(0 to g_IMAGE_COLS-1):=(TO_UNSIGNED(27,g_Bits),TO_UNSIGNED(58,g_Bits),TO_UNSIGNED(8,g_Bits),TO_UNSIGNED(2,g_Bits));
  signal encrptOutput : encryptedMsg;
  signal msg : std_logic := '1';
  signal start : std_logic;
  signal reset : std_logic := '0';
  signal over : std_logic := '0';
  signal q_prime : unsigned(n_bits-1 downto 0) := TO_UNSIGNED(79 , n_bits);
  signal index_a : unsigned(b_bram_address_width - 1 downto 0);
  signal index_b : unsigned(b_bram_address_width - 1 downto 0);
  signal data_a : array_t(0 to a_width-1);
  signal data_b : unsigned(n_bits -1 downto 0);
  
begin

  -- Generates a clock that is used by this example, NOT synthesizable
  p_CLK : process
  begin   
    r_CLK_TB <= not(r_CLK_TB);
    wait for c_CLK_PERIOD/2;
  end process p_CLK;

resetP : process
begin
    reset <= '1';
    start <= '0';
    wait for 5 ns;
    reset <= '0';
    wait for 5 ns;
    start <= '1';
    wait for 100 ns;
    reset <='1';
    start <= '0';
 end process ;
    
--encryptor : encrypt
--port map(
--    clk =>  r_CLK_TB ,
--    start => start,
--    sampleA => a_sample,
--    sampleB => b_sample,
--    q => q_prime,
--    M => msg,
--    encryptedM => encrptOutput,
--    done => over
--);
 
encryption : encryptor port map(
  clk => r_CLK_TB,
  start => start,
  reset => reset,
  data_a => data_a,
  data_b => data_b,
  q => q_prime,
  M => msg,
  index_a => index_a,
  index_b => index_b,
  encrypted_m => encrptOutput,
  done => over
);
--random_generator : uniform_rng port map(
--    cap => std_logic_vector(TO_UNSIGNED(127 ,n_bits)),
--    seed => std_logic_vector(SEED),
--    clk => r_CLK_TB,
--    reset => reset,
--    start_signal => start,
--    unsigned(random_number) => index_a
--);
process(index_a,index_b,over)
begin
    if over = '0'and start = '1' then
        data_a <= a_sample(to_integer(index_a));
        data_b <= b_sample(TO_INTEGER(index_b));
    end if;
end process;

end behave;
