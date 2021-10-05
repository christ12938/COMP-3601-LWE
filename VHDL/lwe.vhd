-- TODO
-- add header description

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;

entity lwe is

	port (
		reset_n : in std_logic;
		clock : in std_logic;

		-- Encryption
		byte_in : in std_logic_vector(7 downto 0);
		u_out : out a_t(0 to a_columns - 1);
		v_out : out signed(n_bits - 1 downto 0);

		-- Decryption
		u_in : in
	);
end entity;

architecture behavioural of lwe is

begin


end behavioural;
