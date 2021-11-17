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
use IEEE.NUMERIC_STD.ALL;

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

component approx_multiplier_combinational is
    Port (
           input_a : in unsigned(n_bits-1 downto 0) ;
           input_b : in unsigned(n_bits -1 downto 0);
           output   : out unsigned (mul_bits - 1 downto 0));
end component;

signal input_a: unsigned(n_bits-1 downto 0);
signal input_b: unsigned(n_bits-1 downto 0);
signal res: unsigned (mul_bits - 1 downto 0);

begin

  approx_multiply: approx_multiplier_combinational port map (
    input_a => input_a,
    input_b => input_b,
    output => res
  );
  
  p_IMAGE : process(A, S)
    variable productTemp : unsigned(2 * mul_bits - 1 downto 0);
    variable sumTemp : unsigned(mul_bits - 1 downto 0);
--    variable productTemp : integer := 0;
--    variable sumTemp : integer := 0;
  begin
    productTemp := TO_UNSIGNED(0, productTemp'length);
    sumTemp := TO_UNSIGNED(0, sumTemp'length);
    for ii in 0 to (a_width - 1) loop
      input_a <= A(ii);
      input_b <= S(ii);
      productTemp := res;
--      A(ii) * S(ii);
--        productTemp := A(ii)*S(ii);
      sumTemp := sumTemp + resize(productTemp, sumTemp'length);
      -- report ("COL = "  & natural'image(ii) & " A(ii)="& integer'image(TO_INTEGER(A(ii))) & " S(ii)="& integer'image(TO_INTEGER(S(ii))) &
              -- " SUM = " & integer'image(TO_INTEGER(sumTemp)) & " PRODUCT = " & integer'image(TO_INTEGER(productTemp))) severity note;
    end loop;
    -- end if;
    result <= sumTemp;
  end process;

end Behavioral;
