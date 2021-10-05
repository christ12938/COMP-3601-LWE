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
entity example_generic is

end example_generic;

architecture behave of example_generic is

  constant c_CLK_PERIOD : time := 10 ns;  -- 100 MHz

  signal r_CLK_TB : std_logic := '0';
--  type t_Row_Mat is array (0 to g_IMAGE_COLS-1) of integer range 0 to 99;
--  type t_Row_Sec is array (0 to g_IMAGE_COLS-1) of integer range 0 to 99;
  signal A : myVector(0 to a_height-1):= ((TO_UNSIGNED(30, mul_bits),TO_UNSIGNED(45, mul_bits),TO_UNSIGNED(75, mul_bits),TO_UNSIGNED(43, mul_bits)),(TO_UNSIGNED(62, mul_bits),TO_UNSIGNED(73, mul_bits),TO_UNSIGNED(43, mul_bits),TO_UNSIGNED(24, mul_bits)),(TO_UNSIGNED(64, mul_bits),TO_UNSIGNED(25, mul_bits),TO_UNSIGNED(30, mul_bits),TO_UNSIGNED(11, mul_bits)),(TO_UNSIGNED(0, mul_bits),TO_UNSIGNED(27, mul_bits),TO_UNSIGNED(74, mul_bits),TO_UNSIGNED(78, mul_bits)),(TO_UNSIGNED(48, mul_bits),TO_UNSIGNED(78, mul_bits),TO_UNSIGNED(41, mul_bits),TO_UNSIGNED(25, mul_bits)),(TO_UNSIGNED(29, mul_bits),TO_UNSIGNED(34, mul_bits),TO_UNSIGNED(13, mul_bits),TO_UNSIGNED(38, mul_bits)),(TO_UNSIGNED(19, mul_bits),TO_UNSIGNED(60, mul_bits),TO_UNSIGNED(17, mul_bits),TO_UNSIGNED(28, mul_bits)),(TO_UNSIGNED(52, mul_bits),TO_UNSIGNED(74, mul_bits),TO_UNSIGNED(12, mul_bits),TO_UNSIGNED(24, mul_bits)));
  --signal a : myVector(0 to g_IMAGE_ROWS-1) := ((1,1,1,1),(1,1,1,1),(1,1,1,1),(1,1,1,1),(1,1,1,1),(1,1,1,1),(1,1,1,1),(1,1,1,1));
  signal S :  array_mul_t(0 to a_width-1):=(TO_UNSIGNED(27, mul_bits),TO_UNSIGNED(58, mul_bits),TO_UNSIGNED(8, mul_bits),TO_UNSIGNED(2, mul_bits));
--  signal sum : unsigned( mul_bits-1 downto 0) := TO_UNSIGNED(0, mul_bits);
  signal sum : array_mul_t(0 to a_height-1) := ( others => TO_UNSIGNED(0, mul_bits));
  signal over : std_logic := '0';
--  signal sum : natural range 0 to g_IMAGE_ROWS := 0;
--  signal product : natural range 0 to g_IMAGE_ROWS := 0;
--  signal r_COL : natural range 0 to g_IMAGE_COLS := 0;
--  component rowMul is
--  generic (
--		g_IMAGE_ROWS : natural := 65535;
--		g_IMAGE_COLS : natural := 5;
--		g_Bits : natural := 32
--		);
--    port( clk : in STD_LOGIC;
--           A : in a_t;
--           S : in a_t;
----           col : in integer;
----           bits : in natural;
--           result : out unsigned);
--  end component;
  component matrixMul is
    Port ( clk : in STD_LOGIC;
            A : in myVector;
            S : in array_mul_t;
           result : out array_mul_t;
           done : out STD_LOGIC);
  end component;
begin

  -- Generates a clock that is used by this example, NOT synthesizable
  p_CLK : process
  begin
    r_CLK_TB <= not(r_CLK_TB);
    wait for c_CLK_PERIOD/2;
  end process p_CLK;



--    rowMultiplier: rowMul
--    generic map(
--    	g_IMAGE_ROWS => g_IMAGE_ROWS,
--		g_IMAGE_COLS => g_IMAGE_COLS,
--		g_Bits => g_Bits
--    )
--    port map(
--        clk => r_CLK_TB,
--        A => A,
--        S => S,
----        col => g_IMAGE_COLS,
----        bits => g_Bits,
--        result => sum
--    );

    matrixMultiplier : matrixMul
    port map(
    clk => r_CLK_TB,
    A => A,
    S => S,
    result => sum,
    done => over
    );



end behave;
