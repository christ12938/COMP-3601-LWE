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
use work.my_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rowMul is
	generic (
		g_DEBUG      : natural := 0;        -- 0 = no debug, 1 = print debug
		g_IMAGE_ROWS : natural := 65535;
		g_IMAGE_COLS : natural := 5;
		g_Bits : natural := 32
		);
	Port ( clk : in STD_LOGIC;
           A : in a_t;
           S : in a_t;
--           col : in integer;
--           bits : in natural;
           result : out unsigned);
end rowMul;

architecture Behavioral of rowMul is

begin
 p_IMAGE : process (clk)
    variable productTemp : unsigned(31 downto 0) := ( others => '0');
    variable sumTemp : unsigned (31 downto 0)  := ( others => '0');
  begin
    if rising_edge(clk) then
      for ii in 0 to (g_IMAGE_COLS - 1) loop
        productTemp := TO_UNSIGNED(A(ii) * S(ii),g_Bits);
        sumTemp := sumTemp + productTemp;
        report ("COL = "  & natural'image(ii) & " A(ii)="& natural'image(A(ii)) & " S(ii)="& natural'image(S(ii)) &
                " SUM = " & integer'image(TO_INTEGER(sumTemp)) & " PRODUCT = " & integer'image(TO_INTEGER(productTemp))) severity note;
      end loop;
      result <= sumTemp;
    end if;
 end process;

end Behavioral;
