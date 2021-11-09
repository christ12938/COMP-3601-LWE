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
	constant CONFIG : natural := 2;

	-- Depending on CONFIG, these functions/constants will return the correct sizes
	function a_width return natural;	-- Width of matrix A
	function a_height return natural;	-- Height of matrix A

	function a_height_bits return natural;	-- Number of bits of Height of matrix A

	constant b_height : natural := a_height;	-- Heighed of vector B
	constant s_height : natural := a_width;	-- Height of vector s
	constant u_height : natural := a_width;	-- Height of vector u

	function min_q return natural;	-- Minimum q
	function max_q return natural;	-- Maximum q
	function n_bits return natural;	-- Bit width based on q (not exactly the bit width of q), most signals should have this bit width
	function mul_bits return natural;	-- Bit width used by the multiplier, because the multiplier needs larger numbers
	function a_bram_data_width return natural;	-- Width of the matrix A block RAM's data
	function a_bram_address_width return natural;	-- Width of the matrix A block RAM's address
	function primes_bram_address_width return natural;	-- Width of the primes block ROM's address
	function num_primes return natural;	-- Number of total primes for each configuration
	function encryption_sum_bits return natural;	-- The modulus's divident width inside the encryption module
	-- Block RAM data width for the primes is n_bits
	constant b_bram_data_width : natural := a_bram_data_width;
	constant b_bram_address_width : natural := a_bram_address_width;

	-- ----------------------------------------------------------------------------
	--                                  Seeding
	-- ----------------------------------------------------------------------------
	-- Master seed for the seed generator, always 32 bits
	-- FIXME currently set to 64 bits for experimentation
	-- constant MASTER_SEED : unsigned(63 downto 0) := b"1101100111111001100100110001110011110010001000100010000010000100";

	-- Seed for the random number generator
	-- Number will just be truncated when n_bits is smaller
	-- FIXME deprecated
--	constant SEED : unsigned(63 downto 0) := x"0000000000000000";

	-- We don't need 20 seeds but just in case
	constant NUM_SEEDS : positive := 20;
	type seed_array_t is array(natural range 0 to NUM_SEEDS - 1) of unsigned(63 downto 0);
	-- Indices 0 to 15 are reserved for rng_bank
	-- Index 16 is reserved for gen_q
	-- Index 17 is reserved for gen_b
	-- Index 18 is reserved for encryptor
	constant SEEDS : seed_array_t := (
		-- Reserved for rng_bank
		x"93716937efeba65e",
		x"08efa0dd8e94d2bf",
		x"5d1a59e195ea7040",
		x"5eee7a5e2e09b8f8",
		x"fc02afd93f7a2f27",
		x"10bd85ba8655757b",
		x"860b9fd23e435a05",
		x"cefb65e866be0134",
		x"b17daf7b14789b7b",
		x"35783c0925e3311c",
		x"4a59c752b5d47f6f",
		x"ef55da3d82ee505e",
		x"4a76ce137a4cd553",
		x"3edffcdc258255c0",
		x"2bb40c42af7d1474",
		x"a6f80b881de37a1c",
		-- Reserved for gen_q
		x"79600dfbd716292a",
		-- Reserved for gen_b
		x"7990e60be863c92c",
		-- Reserved for encryptor
		x"2ca662617cf9e4bc",
		-- Unreserved
		x"abf14d44f40fe0f7"
	);



	constant sample_size : natural := a_height / 4;
    type array_index is array(natural range 0 to sample_size - 1) of unsigned(a_height_bits - 1 downto 0);

	-- An array of mul_bits bit numbers, used in multiplier, because multiplier needs larger numbers
	type array_mul_t is array(natural range <>) of unsigned(mul_bits - 1 downto 0);
	-- An array of n_bits bit numbers, used in most places
	type array_t is array(natural range <>) of unsigned(n_bits - 1 downto 0);

	-- myVector is a matrix
	type myVector is array(natural range <>) of array_t(0 to a_width - 1);

	-- type myMatrix is array(natural range <>, natural range <>) of integer;
	-- Record for storing encrypted message (u,v) : output of encryotion and input for decryption
	type encryptedMsg is record
		u : array_t(0 to a_width-1);
		v : unsigned(n_bits - 1 downto 0);
	end record encryptedMsg;

end package data_types;

package body data_types is

	function a_width return natural is
	begin
		case CONFIG is
		-- when 1 => return 8; -- for encryption testing
		when 1 => return 4;
		when 2 => return 8;
		when 3 => return 16;
		when others => return 16;
		end case;
	end;

	function a_height return natural is
	begin
		case CONFIG is
		-- when 1 => return 8; -- for encryption testing
		when 1 => return 256;
		when 2 => return 8192;
		when 3 => return 32768;
		when others => return 32768;

		end case;
	end;

    function a_height_bits return natural is
	begin
		case CONFIG is
		when 1 => return 8;
		when 2 => return 13;
		when 3 => return 15;
		when others => return 15;
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
		when 1 => return 18;
		when 2 => return 31;
		when 3 => return 37;
		when others => return 36;
		end case;
	end;

	function a_bram_data_width return natural is
	begin
		case CONFIG is
		when 1 => return n_bits * 4;
		when 2 => return n_bits * 8;
		when 3 => return n_bits * 16;
		when others => return n_bits * 16;
		end case;
	end;

	function a_bram_address_width return natural is
	begin
		case CONFIG is
		when 1 => return 8;
		when 2 => return 13;
		when 3 => return 15;
		when others => return 15;
		end case;
	end;

	function primes_bram_address_width return natural is
	begin
		case CONFIG is
		when 1 => return 5;
		when 2 => return 10;
		when 3 => return 13;
		when others => return 13;
		end case;
	end;

	function num_primes return natural is
	begin
		case CONFIG is
		when 1 => return 31;
		when 2 => return 719;
		when 3 => return 4642;
		when others => return 4642;
		end case;
	end;

	function encryption_sum_bits return natural is
  begin
		case CONFIG is
		when 1 => return 14;
		when 2 => return 25;
		when 3 => return 30;
		when others => return n_bits;
		end case;
	end;

	function mL return natural is
  begin
		case CONFIG is
		when 1 => return 6;
		when 2 => return 12;
		when 3 => return 18;
		when others => return n_bits;
		end case;
	end;
	
	function mE return natural is
  begin
		case CONFIG is
		when 1 => return 7;
		when 2 => return 15;
		when 3 => return 23;
		when others => return n_bits;
		end case;
	end;
	
	function k_trunc return natural is
  begin
		case CONFIG is
		when 1 => return 15;
		when 2 => return 27;
		when 3 => return 33;
		when others => return n_bits;
		end case;
	end;


end package body data_types;
