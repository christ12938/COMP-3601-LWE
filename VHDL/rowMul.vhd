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
	generic (
		mul_bits : natural := mul_bits
		);
	Port ( A : in array_mul_t;
           S : in array_mul_t;
           reset, start : in std_logic;
           result : out unsigned);
end rowMul;

architecture Behavioral of rowMul is

begin
 p_IMAGE : process(reset, start, A, S)
    variable productTemp : unsigned( mul_bits - 1 downto 0);
    variable sumTemp : unsigned ( mul_bits - 1 downto 0);
--    variable productTemp : integer := 0;
--    variable sumTemp : integer := 0;
  begin
    if reset = '1' or start = '0' then
        productTemp := TO_UNSIGNED(0, mul_bits);
        sumTemp := TO_UNSIGNED(0, mul_bits);
    elsif start = '1' then
      productTemp := TO_UNSIGNED(0, mul_bits);
      sumTemp := TO_UNSIGNED(0, mul_bits);
      for ii in 0 to (a_width - 1) loop
        productTemp := TO_UNSIGNED(TO_INTEGER(A(ii)) * TO_INTEGER(S(ii)), mul_bits);
--        productTemp := A(ii)*S(ii);
        sumTemp := sumTemp + productTemp;
        report ("COL = "  & natural'image(ii) & " A(ii)="& integer'image(TO_INTEGER(A(ii))) & " S(ii)="& integer'image(TO_INTEGER(S(ii))) &
                " SUM = " & integer'image(TO_INTEGER(sumTemp)) & " PRODUCT = " & integer'image(TO_INTEGER(productTemp))) severity note;
      end loop;
      result <= sumTemp;
    end if;
 end process;

end Behavioral;
