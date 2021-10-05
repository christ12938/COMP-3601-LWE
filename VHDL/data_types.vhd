library ieee;
use ieee.math_real.log2;
use ieee.math_real.ceil;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package data_types is
	-- CONFIG can be 1, 2, or 3
	-- Corresponds to the configurations in the project spec
	-- Set CONFIG to use the following 5 functions
	constant CONFIG : natural := 3;

	function a_rows return natural;
	function a_columns return natural;
	function min_q return natural;
	function max_q return natural;
	function n_bits return natural;


	constant g_IMAGE_ROWS : natural := 8;
	constant g_IMAGE_COLS : natural := 4;
	constant g_Bits : natural := 32;
	type a_t is array(natural range <>) of unsigned(0 to g_Bits-1);
	type myMatrix is array(natural range <>, natural range <>) of integer;

	type myVector is array(natural range <>) of a_t(0 to g_IMAGE_COLS-1);

end package data_types;

package body data_types is

	function a_rows return natural is
	begin
		case CONFIG is
		when 1 => return 4;
		when 2 => return 8;
		when 3 => return 16;
		end case;
	end;

	function a_columns return natural is
	begin
		case CONFIG is
		when 1 => return 256;
		when 2 => return 8192;
		when 3 => return 32768;
		end case;
	end;

	function min_q return natural is
	begin
		case CONFIG is
		when 1 => return 1;
		when 2 => return 2048;
		when 3 => return 16384;
		end case;
	end;

	function max_q return natural is
	begin
		case CONFIG is
		when 1 => return 128;
		when 2 => return 8192;
		when 3 => return 65535;
		end case;
	end;

	function n_bits return natural is
	begin
		return natural(ceil(log2(real(max_q))));
	end;

end package body data_types;
