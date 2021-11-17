----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 10/06/2021 01:20:01 PM
-- Design Name:
-- Module Name: genB - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.data_types.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity genB is
    Port(   --Clock, Reset, Start: in std_logic;
            A, S : in array_t (0 to a_width-1);
            -- seed : in unsigned(63 downto 0);
            -- seed_valid : in std_logic;
            Q : in unsigned (n_bits - 1 DOWNTO 0);
            B : out unsigned(n_bits - 1 DOWNTO 0));
           -- Done : out std_logic);
end genB;

architecture Behavioral of genB is

    component row_mul_combinational is
	   Port ( A : in array_t;
            S : in array_t;
            result : out unsigned);
    end component;

    component modulus_combinational is
	   Port(
			Dividend                : IN		SIGNED(mul_bits - 1 DOWNTO 0);
			Divisor		            : IN		UNSIGNED(n_bits - 1 DOWNTO 0);
			Modulo               : OUT       UNSIGNED(n_bits - 1 DOWNTO 0));
    end component;

--    type state_type is (S1, S2, S3);
    signal modulus_input: unsigned(mul_bits - 1 DOWNTO 0);
    signal rowMul_result : unsigned(mul_bits - 1 DOWNTO 0);

    -- Temporary signals for conversion
--    signal a_temp : array_mul_t(0 to a_width - 1);
--	signal s_temp : array_mul_t(0 to a_width - 1);

    signal temp : integer;

begin
    temp <= error_range;


    -- Conversion from array_t to array_mul_t using resize()
--array_conversion : for i in 0 to a_width - 1 generate
--    a_temp(i) <= resize(A(i), mul_bits);
--    s_temp(i) <= resize(S(i), mul_bits);
--end generate;



row_mul: row_mul_combinational port map (
        A => A,
        S => S,
        result => modulus_input);


modu: modulus_combinational port map(
        Dividend => signed(modulus_input),
        Divisor => Q,
        Modulo => B);


end Behavioral;
