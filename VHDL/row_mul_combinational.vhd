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

entity row_mul_combinational is
	generic (
		mul_bits : natural := mul_bits
		);
	Port ( A : in array_mul_t(0 to a_width - 1);
           S : in array_mul_t(0 to a_width - 1);
          --  reset, start : in std_logic;
           result : out unsigned(mul_bits - 1 downto 0));
end row_mul_combinational;

architecture Behavioral of row_mul_combinational is
begin
  p_IMAGE : process(A, S)
    variable productTemp : unsigned(2 * mul_bits - 1 downto 0);
    variable sumTemp : unsigned(mul_bits - 1 downto 0);
--    variable productTemp : integer := 0;
--    variable sumTemp : integer := 0;
  begin
    -- if reset = '1' or start = '0' then
    --     productTemp := TO_UNSIGNED(0, mul_bits);
    --     sumTemp := TO_UNSIGNED(0, mul_bits);

    -- elsif start = '1' then
    productTemp := TO_UNSIGNED(0, productTemp'length);
    sumTemp := TO_UNSIGNED(0, sumTemp'length);
    for ii in 0 to (a_width - 1) loop
      productTemp := A(ii) * S(ii);
--        productTemp := A(ii)*S(ii);
      sumTemp := sumTemp + resize(productTemp, sumTemp'length);
      -- report ("COL = "  & natural'image(ii) & " A(ii)="& integer'image(TO_INTEGER(A(ii))) & " S(ii)="& integer'image(TO_INTEGER(S(ii))) &
              -- " SUM = " & integer'image(TO_INTEGER(sumTemp)) & " PRODUCT = " & integer'image(TO_INTEGER(productTemp))) severity note;
    end loop;
    -- end if;
    result <= sumTemp;
  end process;

end Behavioral;
