/*
	Learning with error encryptor and decryptor
	COMP3601 21T3
	Team Grey:
		Chris
		Dong
		Farnaz
		Tirth
*/

library ieee;
use ieee.math_real.log2;
use ieee.math_real.ceil;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package data_types is

	/* -------------------------------------------------------------------------- */
	/*                            Master Configuration                            */
	/* -------------------------------------------------------------------------- */
	-- CONFIG can be 1, 2, or 3
	-- Corresponds to the configurations in the project spec
	constant CONFIG : natural := 3;

	/* -------------------------------------------------------------------------- */
	/*                              Useful Constants                              */
	/* -------------------------------------------------------------------------- */
	-- Depending on CONFIG, these functions/constants will return the correct sizes
	function a_width return natural;	-- Width of matrix A
	function a_height return natural;	-- Height of matrix A
	constant s_height : natural := a_width;	-- Height of vector s
	constant u_height : natural := a_width;	-- Height of vector u
	function min_q return natural;	-- Minimum q
	function max_q return natural;	-- Maximum q
	function n_bits return natural;	-- Max bitwidth of q (which determines the bit width of must other signals in the circuit)
	function a_bram_data_width return natural;	-- Width of the matrix A block RAM's data
	function a_bram_address_width return natural;	-- Width of the matrix A block RAM's address

	/* -------------------------------------------------------------------------- */
	/*                              Array Data Types                              */
	/* -------------------------------------------------------------------------- */
	-- This must be compiled with the VHDL 2008 standard
	-- Example: to make a 4 high vector with 16 bit unsigned numbers, do
	-- signal my_vector : array_unsigned(0 to 3)(15 downto 0);
	type array_unsigned is array(positive range <>) of unsigned;
	type array_signed is array(positive range <>) of signed;


	constant g_IMAGE_ROWS : natural := 8;
	constant g_IMAGE_COLS : natural := 4;
	constant g_Bits : natural := 32;
	type a_t is array(natural range <>) of unsigned(0 to g_Bits-1);
	type myMatrix is array(natural range <>, natural range <>) of integer;

	type myVector is array(natural range <>) of a_t(0 to g_IMAGE_COLS-1);

end package data_types;

package body data_types is

	function a_width return natural is
	begin
		case CONFIG is
		when 1 => return 4;
		when 2 => return 8;
		when 3 => return 16;
		end case;
	end;

	function a_height return natural is
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

	function a_bram_data_width return natural is
	begin
		case CONFIG is
		when 1 => return 0;	-- FIXME
		when 2 => return 0;	-- FIXME
		when 3 => return 255;
		end case;
	end;

	function a_bram_address_width return natural is
	begin
		case CONFIG is
		when 1 => return 0;	-- FIXME
		when 2 => return 0;	-- FIXME
		when 3 => return 14;
		end case;
	end;

end package body data_types;
