library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;


entity simple_mul_tb is
end simple_mul_tb;

architecture behavioural of simple_mul_tb is
	constant BIT_WIDTH : positive := 32;
	signal a, b, c : signed(BIT_WIDTH - 1 downto 0);
begin

  stimulus : process begin
		a <= to_signed(-9, BIT_WIDTH);
		b <= to_signed(5, BIT_WIDTH);
		wait;
	end process;

	-- f <= d - e;
	c <= a rem b;
end;
