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

package my_pkg is
  constant g_IMAGE_ROWS : natural := 8;
  constant g_IMAGE_COLS : natural := 4;
  constant g_Bits : natural := 32;
  type a_t is array(natural range <>) of integer;
  type myMatrix is array(natural range <>, natural range <>) of integer;
  type myVector is array(natural range <>) of a_t(0 to g_IMAGE_COLS-1);
end package my_pkg;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_pkg.all;
entity example_generic is
  
end example_generic;
 
architecture behave of example_generic is
 
  constant c_CLK_PERIOD : time := 10 ns;  -- 100 MHz
 
  signal r_CLK_TB : std_logic := '0';
--  type t_Row_Mat is array (0 to g_IMAGE_COLS-1) of integer range 0 to 99;
--  type t_Row_Sec is array (0 to g_IMAGE_COLS-1) of integer range 0 to 99;
  signal A : myVector(0 to g_IMAGE_ROWS-1):= ((30,45,75,43),(62,73,43,24),(64,25,30,11),(0,27,74,78),(48,78,41,25),(29,34,13,38),(19,60,17,28),(52,74,12,24));
  --signal a : myVector(0 to g_IMAGE_ROWS-1) := ((1,1,1,1),(1,1,1,1),(1,1,1,1),(1,1,1,1),(1,1,1,1),(1,1,1,1),(1,1,1,1),(1,1,1,1));
  signal S :  A_t(0 to g_IMAGE_COLS-1):=(27,58,8,2);
--  signal sum : unsigned(g_Bits-1 downto 0) := TO_UNSIGNED(0,g_Bits);
  signal sum : a_t(0 to g_IMAGE_ROWS-1) := ( others => 0);
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
            S : in a_t;
           result : out a_t;
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