--	Learning with error encryptor and decryptor
--	COMP3601 21T3
--	Team Grey:
--		Chris
--		Dong
--		Farnaz
--		Tirth

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
		u_out : out array_t(0 to u_height - 1);
		v_out : out unsigned(n_bits - 1 downto 0);

		-- Decryption
		u_in : in array_t(0 to u_height - 1);
		v_in : in unsigned(n_bits - 1 downto 0);
		byte_out : out std_logic_vector(7 downto 0)
	);

end entity;

architecture behavioural of lwe is
	-- Block RAM for storing matrix A in configuration 3
	component a_bram_config_3 is
		port (
			bram_porta_0_addr : in std_logic_vector(14 downto 0);
			bram_porta_0_clk : in std_logic;
			bram_porta_0_din : in std_logic_vector(255 downto 0);
			bram_porta_0_dout : out std_logic_vector(255 downto 0);
			bram_porta_0_we : in std_logic_vector(0 to 0)
		);
	end component;

	-- n bit register
	component regne is
		generic (n : positive := n_bits);
		port (
			-- Data in
			d : in std_logic_vector(n - 1 downto 0);
			-- Enable
			e : in std_logic;
			-- Reset not
			resetn : in std_logic;
			-- Clock
			clock : in std_logic;
			-- Data out
			q : out std_logic_vector(n - 1 downto 0)
		);
	end component;

	signal q_in : unsigned(n_bits - 1 downto 0);
	signal q_out : unsigned(n_bits - 1 downto 0);
	signal q_enable : std_logic;

	signal s_in : array_t(0 to s_height - 1);
	signal s_out : array_t(0 to s_height - 1);
	signal s_enable : std_logic;

	signal a_bram_data_in : unsigned(a_bram_data_width - 1 downto 0);
	signal a_bram_data_out : unsigned(a_bram_data_width - 1 downto 0);
	signal a_bram_address : unsigned(a_bram_address_width - 1 downto 0);
	signal a_bram_write_enable : std_logic;

begin
	-- Register storing Q
	q_reg : regne
	generic map (n => n_bits)
	port map (
		d => std_logic_vector(q_in),
		e => q_enable,
		resetn => reset_n,
		clock => clock,
		unsigned(q) => q_out
	);

	-- Registers storing S
	gen_s_regs : for i in 0 to s_height - 1 generate
		s_reg : regne
		generic map (n => n_bits)
		port map (
			d => std_logic_vector(s_in(i)),
			e => s_enable,
			resetn => reset_n,
			clock => clock,
			unsigned(q) => s_out(i)
		);
	end generate;

	-- This section uses an if generate because the block RAM was generated via the Vivado UI, so the block RAM VHDL implementation isn't available
	-- Block RAM for matrix A in configuration 1
	a_bram_config_1_generate : if (CONFIG = 1) generate
		-- TODO add block RAM for configuration 1
	end generate;
	a_bram_config_2_generate : if (CONFIG = 2) generate
		-- TODO add block RAM for configuration 2
	end generate;
	a_bram_config_3_generate : if (CONFIG = 3) generate
		a_bram : a_bram_config_3
		port map (
			bram_porta_0_addr => std_logic_vector(a_bram_address),
			bram_porta_0_clk => clock,
			bram_porta_0_din => std_logic_vector(a_bram_data_in),
			unsigned(bram_porta_0_dout) => a_bram_data_out,
			bram_porta_0_we(0) => a_bram_write_enable
		);
	end generate;
end behavioural;



-- port (
-- 	INPUTS
-- 	clock (bit)
-- 	resetn? (bit)
-- 	data_in_a (array_t) from block ram
-- 	start (bit)
-- 	data_in_b (array_t)

-- 	message (bit)

-- 	OUTPUTS
-- 	u (array_t) v (unsigned) (both in a record)
-- 	done (bit)

-- 	bram_address (unsigned)
-- )
