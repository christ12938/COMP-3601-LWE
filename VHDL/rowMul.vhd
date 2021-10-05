----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 24.09.2021 19:59:02
-- Design Name:
-- Module Name: rowMul - Behavioral
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
use work.data_types.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rowMul is
--	generic (
--		g_IMAGE_ROWS : natural := 2;
--		g_IMAGE_COLS : natural := 2;
--		g_Bits : natural := 32
--		);
	Port ( clk : in STD_LOGIC;
           A : in a_t;
           S : in a_t;
           multiply : in std_logic;
           result : out unsigned);
end rowMul;

architecture Behavioral of rowMul is

begin
 p_IMAGE : process(clk)
    variable productTemp : unsigned(31 downto 0) := TO_UNSIGNED(0,g_Bits);
    variable sumTemp : unsigned (31 downto 0)  := TO_UNSIGNED(0,g_Bits);
--    variable productTemp : integer := 0;
--    variable sumTemp : integer := 0;
  begin
    if rising_edge(clk) and multiply = '0' then
      productTemp := TO_UNSIGNED(0,g_Bits);
      sumTemp := TO_UNSIGNED(0,g_Bits);
      for ii in 0 to (g_IMAGE_COLS - 1) loop
        productTemp := TO_UNSIGNED(TO_INTEGER(A(ii)) * TO_INTEGER(S(ii)),g_Bits);
--        productTemp := A(ii)*S(ii);
        sumTemp := sumTemp + productTemp;
        report ("COL = "  & natural'image(ii) & " A(ii)="& integer'image(TO_INTEGER(A(ii))) & " S(ii)="& integer'image(TO_INTEGER(S(ii))) &
                " SUM = " & integer'image(TO_INTEGER(sumTemp)) & " PRODUCT = " & integer'image(TO_INTEGER(productTemp))) severity note;
      end loop;
      result <= sumTemp;
    end if;
 end process;

end Behavioral;
