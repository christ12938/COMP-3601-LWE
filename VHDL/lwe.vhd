-- TODO
-- add header description

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;

entity lwe is port (
	resetN : in std_logic;

	-- Byte to encrypt
	byteIn :  in std_logic_vector(7 downto 0)

	uOut : out a_t(0 to g_IMAGE_COLS - 1)
	vOut : signed
);
end entity;

architecture behavioural of lwe is

begin


end behavioural;
