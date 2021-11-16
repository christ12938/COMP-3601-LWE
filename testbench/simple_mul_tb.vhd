library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;


entity simple_mul_tb is
end simple_mul_tb;

architecture behavioural of simple_mul_tb is
	constant BIT_WIDTH : positive := 64;
	signal a, b, c : signed(BIT_WIDTH - 1 downto 0);
--	signal a, b, c : integer;
begin

   stimulus : process begin
		a <= to_signed(-9, a'length);
		b <= to_signed(5, b'length);
--		wait for 10 ns;
--		a <= x"0000000100000001";
--		b <= -a;

--		wait for 10 ns;
--		b <= to_signed(13, b'length);
--		c <= a mod b;

--		c <= -a;

		 wait;
	 end process;

	-- f <= d - e;
	c <= a mod b;
end;
