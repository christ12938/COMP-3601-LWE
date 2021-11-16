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

-- import approximate multiplier and replace the multiplier with approximate multiplier
-- the current approximate multiplier will work for 8 bit integers
entity row_mul_combinational is
	generic (
		mul_bits : natural := mul_bits
		);
	Port ( A : in array_mul_t;
           S : in array_mul_t;
          --  reset, start : in std_logic;
           result : out unsigned);
end row_mul_combinational;

architecture Behavioral of row_mul_combinational is


component  dgn_mitchellmul8bit is  generic (
		  sz : natural := 16
		);
		 Port ( X : in std_logic_vector(sz-1 downto 0);
            Y : in std_logic_vector(sz-1 downto 0);
            M : out  std_logic_vector(2*sz-1 downto 0));
    end component;

signal appr_mul_res : std_logic_vector(31 downto 0);
signal mul1 : std_logic_vector(15 downto 0);
signal mul2 : std_logic_vector (15 downto 0) ;
begin

  approximate_multiplier: dgn_mitchellmul8bit 
        generic map (sz => 16)
        port map ( 
            X => mul1,
            Y => mul2, 
            M => appr_mul_res);
            
  p_IMAGE : process(A, S)
    variable productTemp : unsigned( mul_bits - 1 downto 0);
    variable sumTemp : unsigned ( mul_bits - 1 downto 0);
--    variable productTemp : integer := 0;
--    variable sumTemp : integer := 0;
  begin
   

    productTemp := TO_UNSIGNED(0, mul_bits);
    sumTemp := TO_UNSIGNED(0, mul_bits);
    for ii in 0 to a_width - 1 loop
    
       mul1 <= std_logic_vector(A(ii));
       mul2 <= std_logic_vector(S(ii));
        
      productTemp := TO_UNSIGNED(TO_INTEGER(A(ii)) * TO_INTEGER(S(ii)), mul_bits);
--        productTemp := A(ii)*S(ii);
      sumTemp := sumTemp + To_Integer(UNSIGNED(appr_mul_res));
--      sumTemp + productTemp;
      -- report ("COL = "  & natural'image(ii) & " A(ii)="& integer'image(TO_INTEGER(A(ii))) & " S(ii)="& integer'image(TO_INTEGER(S(ii))) &
              -- " SUM = " & integer'image(TO_INTEGER(sumTemp)) & " PRODUCT = " & integer'image(TO_INTEGER(productTemp))) severity note;
    end loop;
    -- end if;
    result <= sumTemp;
  end process;

end Behavioral;
