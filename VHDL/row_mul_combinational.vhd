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
	Port ( A : in array_t(0 to a_width - 1);
					 S : in array_t(0 to a_width - 1);
					--  reset, start : in std_logic;
					 result : out unsigned(mul_bits - 1 downto 0));
end row_mul_combinational;
architecture Behavioral of row_mul_combinational is

component approx_multiplier_combinational is
		Port (
					clock : in std_logic;
					input_a : in unsigned(n_bits - 1 downto 0) ;
					input_b : in unsigned(n_bits - 1 downto 0);
					output   : out unsigned (mul_bits - 1 downto 0));
end component;
	constant NUM_MULS : positive := a_width;
	-- signal input_a: unsigned(n_bits-1 downto 0);
	-- signal input_b: unsigned(n_bits-1 downto 0);
	signal res : array_mul_t(0 to NUM_MULS - 1);
	signal debug_actual : array_mul_t(0 to NUM_MULS - 1);

	type debug_array_mul_t is array(natural range <>) of signed(mul_bits - 1 downto 0);

	signal debug_diff : debug_array_mul_t(0 to NUM_MULS - 1);


begin
	-- config_1_muls : if CONFIG = 1 generate
		mul_gen : for i in 0 to NUM_MULS - 1 generate
			approx_multiply: approx_multiplier_combinational port map (
				input_a => A(i),
				input_b => S(i),
				output => res(i),
				clock => '0'
			);
			debug_actual(i) <= resize(A(i) * S(i), res(i)'length);
			debug_diff(i) <= signed(debug_actual(i)) - signed(res(i));
		end generate;
	-- end generate;

	p_IMAGE : process(A, S, res)
		-- variable productTemp : unsigned(mul_bits - 1 downto 0);
		variable sumTemp : unsigned(mul_bits - 1 downto 0);
--    variable productTemp : integer := 0;
--    variable sumTemp : integer := 0;
	begin
		-- productTemp := TO_UNSIGNED(0, productTemp'length);
		sumTemp := TO_UNSIGNED(0, sumTemp'length);
		for ii in 0 to (NUM_MULS - 1) loop
			sumTemp := sumTemp + res(ii);
			-- input_a <= A(ii);
			-- input_b <= S(ii);
			-- productTemp := res;
--      A(ii) * S(ii);
--        productTemp := A(ii)*S(ii);
			-- sumTemp := sumTemp + productTemp;
			-- report ("COL = "  & natural'image(ii) & " A(ii)="& integer'image(TO_INTEGER(A(ii))) & " S(ii)="& integer'image(TO_INTEGER(S(ii))) &
							-- " SUM = " & integer'image(TO_INTEGER(sumTemp)) & " PRODUCT = " & integer'image(TO_INTEGER(productTemp))) severity note;
		end loop;
		result <= sumTemp;
		-- end if;
	end process;

end Behavioral;
