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
  type a_t is array(natural range <>) of integer;
end package my_pkg;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_pkg.all;
entity example_generic is
  generic (
    g_DEBUG      : natural := 0;        -- 0 = no debug, 1 = print debug
    g_IMAGE_ROWS : natural := 65535;
    g_IMAGE_COLS : natural := 6;
    g_Bits : natural := 32
    );
end example_generic;
 
architecture behave of example_generic is
 
  constant c_CLK_PERIOD : time := 10 ns;  -- 100 MHz
 
  signal r_CLK_TB : std_logic := '0';
--  type t_Row_Mat is array (0 to g_IMAGE_COLS-1) of integer range 0 to 99;
--  type t_Row_Sec is array (0 to g_IMAGE_COLS-1) of integer range 0 to 99;
  signal A : a_t(0 to g_IMAGE_COLS-1):= (30,45,75,43,1,1);
  signal S : a_t(0 to g_IMAGE_COLS-1):=(27,58,8,2,1,1);
  signal sum : unsigned(g_Bits-1 downto 0) := TO_UNSIGNED(0,g_Bits);
--  signal sum : natural range 0 to g_IMAGE_ROWS := 0;
--  signal product : natural range 0 to g_IMAGE_ROWS := 0;
--  signal r_COL : natural range 0 to g_IMAGE_COLS := 0;
  component rowMul is
  generic (
		g_DEBUG      : natural := 0;        -- 0 = no debug, 1 = print debug
		g_IMAGE_ROWS : natural := 65535;
		g_IMAGE_COLS : natural := 5;
		g_Bits : natural := 32
		);
    port( clk : in STD_LOGIC;
           A : in a_t;
           S : in a_t;
--           col : in integer;
--           bits : in natural;
           result : out unsigned);
  end component;
begin
 
  -- Generates a clock that is used by this example, NOT synthesizable
  p_CLK : process
  begin
    r_CLK_TB <= not(r_CLK_TB);
    wait for c_CLK_PERIOD/2;
  end process p_CLK;
   
 
  -- Keeps track of row/col counters, limits set by generics
  -- This process is synthesizable
--  p_IMAGE : process (r_CLK_TB)
--  begin
--    if rising_edge(r_CLK_TB) then
--      if(r_COL = g_IMAGE_COLS) then
--        r_COL <= 0;
--        sum <= 0;
--      else
--        product <= A(r_COL) * S(r_COL);
--        sum <= sum + product;
--        r_COL <= r_COL + 1;
--      end if;
--    end if;
--  end process;
--  p_IMAGE : process (r_CLK_TB)
--    variable productTemp : natural range 0 to g_IMAGE_ROWS := 0;
--    variable sumTemp : natural range 0 to g_IMAGE_ROWS := 0;
--  begin
--    if rising_edge(r_CLK_TB) then
--      for ii in 0 to (g_IMAGE_COLS-1) loop
--        productTemp := A(ii) * S(ii);
--        sumTemp := sumTemp + productTemp;
--        report ("COL = "  & natural'image(ii) & " A(ii)="& natural'image(A(ii)) & " S(ii)="& natural'image(S(ii)) &
--                " SUM = " & natural'image(sumTemp) & " PRODUCT = " & natural'image(productTemp)) severity note;
--      end loop;
--      sum <= sumTemp;
--    end if;
--  end process;
    rowMultiplier: rowMul
    generic map(
    	g_DEBUG => g_DEBUG,
    	g_IMAGE_ROWS => g_IMAGE_ROWS,
		g_IMAGE_COLS => g_IMAGE_COLS,
		g_Bits => g_Bits
    )
    port map(
        clk => r_CLK_TB,
        A => A,
        S => S,
--        col => g_IMAGE_COLS,
--        bits => g_Bits,
        result => sum
    );
 
  -- Prints debug statements if g_DEBUG is set to 1. (not synthesizable)
--  p_DEBUG : process (r_CLK_TB)
--  begin
--    if rising_edge(r_CLK_TB) then
--      if g_DEBUG = 1 then
--        report ("COL = "  & natural'image(r_COL) &
--                " SUM = " & natural'image(sum) & " PRODUCT = " & natural'image(product)) severity note;
--      end if;
--    end if;
--  end process;
   
end behave;