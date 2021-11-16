library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.data_types.ALL;

entity decrypt is
    Port(   U, S : in array_t (0 to a_width-1);
            V, Q : in unsigned (n_bits - 1 DOWNTO 0);
            M    : out std_logic);
end decrypt;

architecture Behavioral of decrypt is

    component row_mul_combinational is
       generic (
          mul_bits : natural := mul_bits
        );
       Port ( A : in array_mul_t;
            S : in array_mul_t;
--            reset, start : in std_logic;
            result : out unsigned);
    end component;

    component modulus_combinational is
       generic ( dividend_width : natural := mul_bits;
                 divisor_width : natural := n_bits);
       Port(
            Dividend                : IN		SIGNED(mul_bits - 1 DOWNTO 0);
            Divisor		            : IN		UNSIGNED(n_bits - 1 DOWNTO 0);
            Modulo               : OUT       UNSIGNED(n_bits - 1 DOWNTO 0));
    end component;

    signal u_dot_s : unsigned(mul_bits - 1 DOWNTO 0);
    signal v_sub_u_dot_s : signed(mul_bits - 1 DOWNTO 0);
    signal dec: unsigned(n_bits - 1 DOWNTO 0);
    signal condition : unsigned(n_bits - 1 DOWNTO 0);
    signal temp_u, temp_s : array_mul_t(0 to a_width - 1);
begin
    conversion : for i in 0 to a_width - 1 generate
        temp_u(i) <= resize(U(i), mul_bits);
        temp_s(i) <= resize(S(i), mul_bits);
    end generate;

    row_mul: row_mul_combinational port map (
            A => temp_u,
            S => temp_s,
--            reset => '0',
--            start => '1',
            result => u_dot_s);

    modu: modulus_combinational port map (
--            Start => '1',
--            Reset => '0',
            Dividend => v_sub_u_dot_s,
            Divisor => Q,
            Modulo => dec);

    v_sub_u_dot_s <= signed(resize(V, u_dot_s'length)) - signed(u_dot_s);
    -- condition <= "00" & Q (n_bits - 1 DOWNTO 2);
    -- condition <= Q / 4;
    -- M <= '0' when dec < condition else
        --  '1';
--	condition_generation_config_3 : if CONFIG = 3 generate
--    	M <= '1' when ((q / 4) <= dec and dec <= (3 * q / 4)) else '0';
--    end generate;
    -- If else generate is only supported in VHDL 2008 so I have to do this
--    condition_generation_config_others : if CONFIG = 2 or CONFIG = 1 generate
    condition_config_1 : if CONFIG = 1 generate
        M <= '1' when ((q / 4) <= dec and dec <= (3 * q / 4)) else '0';
    end generate;

    condition_config_2 : if CONFIG = 2 generate
        M <= '0' when ((q / 4) <= dec and dec <= (3 * q / 4)) else '1';
    end generate;

    condition_config_3 : if CONFIG = 2 generate
        M <= '1' when ((q / 4) <= dec and dec <= (3 * q / 4)) else '0';
    end generate;


    -- M <= '1' when ((q / 4) <= dec and dec <= (3 * (q / 4))) else '0';

    -- M <= '0' when dec <= (q / 4) else '1';
--	end generate;
end Behavioral;
