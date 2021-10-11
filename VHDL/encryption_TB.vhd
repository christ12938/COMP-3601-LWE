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
    component encrypt is
        Port ( clk : in STD_LOGIC;
               start : in STD_LOGIC;
               sampleA : in myVector;
               sampleB : in array_t;
               q : in unsigned;
               M : in STD_LOGIC;
               encryptedM : out encryptedMsg;
               done : out STD_LOGIC
               );
    end component;
  signal r_CLK_TB : std_logic := '0';
  signal a_sample : myVector(0 to sample_size-1) := ((TO_UNSIGNED(52,mul_Bits),TO_UNSIGNED(74,mul_Bits),TO_UNSIGNED(12,mul_Bits),TO_UNSIGNED(24,mul_Bits),TO_UNSIGNED(53,mul_Bits),TO_UNSIGNED(75,mul_Bits),TO_UNSIGNED(13,mul_Bits),TO_UNSIGNED(25,mul_Bits)),(TO_UNSIGNED(48,mul_Bits),TO_UNSIGNED(78,mul_Bits),TO_UNSIGNED(41,mul_Bits),TO_UNSIGNED(25,mul_Bits),TO_UNSIGNED(49,mul_Bits),TO_UNSIGNED(77,mul_Bits),TO_UNSIGNED(42,mul_Bits),TO_UNSIGNED(26,mul_Bits)),(TO_UNSIGNED(52,mul_Bits),TO_UNSIGNED(74,mul_Bits),TO_UNSIGNED(12,mul_Bits),TO_UNSIGNED(24,mul_Bits),TO_UNSIGNED(53,mul_Bits),TO_UNSIGNED(75,mul_Bits),TO_UNSIGNED(13,mul_Bits),TO_UNSIGNED(25,mul_Bits)),(TO_UNSIGNED(48,mul_Bits),TO_UNSIGNED(78,mul_Bits),TO_UNSIGNED(41,mul_Bits),TO_UNSIGNED(25,mul_Bits),TO_UNSIGNED(49,mul_Bits),TO_UNSIGNED(77,mul_Bits),TO_UNSIGNED(42,mul_Bits),TO_UNSIGNED(26,mul_Bits)));
  signal b_sample : array_t(0 to sample_size-1) := (TO_UNSIGNED(72,n_bits),TO_UNSIGNED(37,n_bits),TO_UNSIGNED(62,n_bits),TO_UNSIGNED(35,n_bits));
--  signal A : myVector(0 to g_IMAGE_ROWS-1):= ((TO_UNSIGNED(30,g_Bits),TO_UNSIGNED(45,g_Bits),TO_UNSIGNED(75,g_Bits),TO_UNSIGNED(43,g_Bits)),(TO_UNSIGNED(62,g_Bits),TO_UNSIGNED(73,g_Bits),TO_UNSIGNED(43,g_Bits),TO_UNSIGNED(24,g_Bits)),(TO_UNSIGNED(64,g_Bits),TO_UNSIGNED(25,g_Bits),TO_UNSIGNED(30,g_Bits),TO_UNSIGNED(11,g_Bits)),(TO_UNSIGNED(0,g_Bits),TO_UNSIGNED(27,g_Bits),TO_UNSIGNED(74,g_Bits),TO_UNSIGNED(78,g_Bits)),(TO_UNSIGNED(48,g_Bits),TO_UNSIGNED(78,g_Bits),TO_UNSIGNED(41,g_Bits),TO_UNSIGNED(25,g_Bits)),(TO_UNSIGNED(29,g_Bits),TO_UNSIGNED(34,g_Bits),TO_UNSIGNED(13,g_Bits),TO_UNSIGNED(38,g_Bits)),(TO_UNSIGNED(19,g_Bits),TO_UNSIGNED(60,g_Bits),TO_UNSIGNED(17,g_Bits),TO_UNSIGNED(28,g_Bits)),(TO_UNSIGNED(52,g_Bits),TO_UNSIGNED(74,g_Bits),TO_UNSIGNED(12,g_Bits),TO_UNSIGNED(24,g_Bits)));
--  signal S :  A_t(0 to g_IMAGE_COLS-1):=(TO_UNSIGNED(27,g_Bits),TO_UNSIGNED(58,g_Bits),TO_UNSIGNED(8,g_Bits),TO_UNSIGNED(2,g_Bits));
  signal encrptOutput : encryptedMsg;
  signal msg : std_logic := '1';
  signal start : std_logic := '1';
  signal over : std_logic := '0';
  signal q_prime : unsigned(n_bits-1 downto 0) := TO_UNSIGNED(79 , n_bits);
  
begin

  -- Generates a clock that is used by this example, NOT synthesizable
  p_CLK : process
  begin
    r_CLK_TB <= not(r_CLK_TB);
    wait for c_CLK_PERIOD/2;
  end process p_CLK;


encryptor : encrypt
port map(
    clk =>  r_CLK_TB ,
    start => start,
    sampleA => a_sample,
    sampleB => b_sample,
    q => q_prime,
    M => msg,
    encryptedM => encrptOutput,
    done => over
);
   
end behave;
