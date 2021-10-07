--	Learning with error encryptor and decryptor
--	COMP3601 21T3
--	Team Grey:
--		Chris
--		Dong
--		Farnaz
--		Tirth

library ieee;
use ieee.math_real.log2;
use ieee.math_real.ceil;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package data_types is

	-- CONFIG can be 1, 2, or 3
	-- Corresponds to the configurations in the project spec
	constant CONFIG : natural := 1;

	-- Seed for the random number generator
	-- Always width 16 because the random number generator's widths are constant
	constant RNG_BIT_WIDTH : natural := 16;
	constant SEED : unsigned(RNG_BIT_WIDTH * 2 - 1 downto 0) := to_unsigned(123, RNG_BIT_WIDTH * 2);

	-- Depending on CONFIG, these functions/constants will return the correct sizes
	function a_width return natural;	-- Width of matrix A
	function a_height return natural;	-- Height of matrix A
	constant b_height : natural := a_height;	-- Heighed of vector B
	constant s_height : natural := a_width;	-- Height of vector s
	constant u_height : natural := a_width;	-- Height of vector u
	function min_q return natural;	-- Minimum q
	function max_q return natural;	-- Maximum q
	function n_bits return natural;	-- Bit width based on q (not exactly the bit width of q), most signals should have this bit width
	function mul_bits return natural; -- Bit width used by the multiplier, because the multiplier needs larger numbers
	function a_bram_data_width return natural;	-- Width of the matrix A block RAM's data
	function a_bram_address_width return natural;	-- Width of the matrix A block RAM's address

	-- constant g_IMAGE_ROWS : natural := 8;
	-- constant g_IMAGE_COLS : natural := 4;
	-- constant g_Bits : natural := 32;
	-- An array of mul_bits bit numbers, used in multiplier, because multiplier needs larger numbers
	type array_mul_t is array(natural range <>) of unsigned(mul_bits - 1 downto 0);
	-- An array of n_bits bit numbers, used in most places
	type array_t is array(natural range <>) of unsigned(n_bits - 1 downto 0);

	-- myVector is a matrix
	type myVector is array(natural range <>) of array_mul_t(0 to a_width - 1);
	-- type myMatrix is array(natural range <>, natural range <>) of integer;

end package data_types;

package body data_types is

	function a_width return natural is
	begin
		case CONFIG is
		when 1 => return 4;
		when 2 => return 8;
		when 3 => return 16;
		when others => return 16;
		end case;
	end;

	function a_height return natural is
	begin
		case CONFIG is
		when 1 => return 256;
		when 2 => return 8192;
		when 3 => return 32768;
		when others => return 32768;

		end case;
	end;

	function min_q return natural is
	begin
		case CONFIG is
		when 1 => return 1;
		when 2 => return 2048;
		when 3 => return 16384;
		when others => return 16384;
		end case;
	end;

	function max_q return natural is
	begin
		case CONFIG is
		when 1 => return 128;
		when 2 => return 8192;
		when 3 => return 65535;
		when others => return 65535;
		end case;
	end;

	function n_bits return natural is
	begin
		case CONFIG is
		when 1 => return 8;
		when 2 => return 16;
		when 3 => return 16;
		when others => return 16;
		end case;
	end;

	function mul_bits return natural is
	begin
		case CONFIG is
		when 1 => return 17;
		when 2 => return 30;
		when 3 => return 36;
		when others => return 36;
		end case;
	end;

	function a_bram_data_width return natural is
	begin
		case CONFIG is
		when 1 => return 0;	-- FIXME
		when 2 => return 0;	-- FIXME
		when 3 => return 256;
		when others => return 256;
		end case;
	end;

	function a_bram_address_width return natural is
	begin
		case CONFIG is
		when 1 => return 0;	-- FIXME
		when 2 => return 0;	-- FIXME
		when 3 => return 15;
		when others => return 15;
		end case;
	end;

end package body data_types;
