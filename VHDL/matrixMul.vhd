----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 02.10.2021 12:28:56
-- Design Name:
-- Module Name: matrixMul - Behavioral
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

entity matrixMul is
    Port ( clk : in STD_LOGIC;
            A : in myVector;
            S : in array_mul_t;
           result : out array_mul_t;
           done : out STD_LOGIC);
end matrixMul;

architecture Behavioral of matrixMul is
component rowMul is
    port( clk : in STD_LOGIC;
           A : in array_mul_t;
           S : in array_mul_t;
           multiply : in std_logic;
           result : out unsigned);
  end component;
  --signal count : integer := 0;
  signal tempProduct : unsigned(mul_bits - 1 downto 0) := TO_UNSIGNED(0, mul_bits);
  --signal tempProduct : integer := 0;
  signal row : array_mul_t(0 to a_width - 1);
  signal multiply : std_logic := '0';
begin
rowMultiplier: rowMul
    port map(
        clk => clk,
        A => row,
        S => S,
        multiply => multiply,
        result => tempProduct
    );
calculation : process(clk)
variable count : integer := 0;
begin
    if count < a_height then
        row <= A(count);
    end if;
    if rising_edge(clk) then
        if count = a_height then
            result(count-1) <= tempProduct;
            done <= '1';
            multiply <= '1';
            --result <= internalResult;
--        elsif count = 0 then
--             done <= '0';
----             result(0) <= TO_INTEGER(tempProduct);
--             count := count + 1;
--             result(0) <= TO_INTEGER(tempProduct);
--             --row <= A(count);
        elsif count = 0 then
            done <= '0';
            count := count + 1;
        else
            result(count-1) <= tempProduct;
            count := count + 1;
            --row <= A(count);
        end if;
    end if;
end process;



end Behavioral;
