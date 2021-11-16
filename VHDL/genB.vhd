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
    Port(   Clock, Reset, Start : in std_logic;
            A, S : in array_t (0 to a_width-1);
            seed : in unsigned(63 downto 0);
            seed_valid : in std_logic;
            Q : in unsigned (n_bits - 1 DOWNTO 0);
            B : out unsigned(n_bits - 1 DOWNTO 0);
            Done : out std_logic);
end genB;

architecture Behavioral of genB is

    component row_mul_combinational is
	   generic (
		  mul_bits : natural := mul_bits
		);
	   Port ( A : in array_mul_t;
            S : in array_mul_t;
            result : out unsigned);
    end component;

    component error_generator is
        Port ( max_cap : in integer;
            clk,reset,start_signal   :in std_logic;
            seed : in unsigned(63 downto 0);
            seed_valid : in std_logic;
            done     : out std_logic;
            error    : out integer);
    end component;

    component modulus_combinational is
	   Port(
			Dividend                : IN		SIGNED(mul_bits - 1 DOWNTO 0);
			Divisor		            : IN		UNSIGNED(n_bits - 1 DOWNTO 0);
			Modulo               : OUT       UNSIGNED(n_bits - 1 DOWNTO 0));
    end component;

    type state_type is (S1, S2, S3);
    signal state : state_type;
    signal errorGen_done : std_logic;
    signal modulus_input: unsigned(mul_bits - 1 DOWNTO 0);
    signal rowMul_result : unsigned(mul_bits - 1 DOWNTO 0);
    signal errorGen_result : integer;
    signal modulue_start: std_logic;

    -- Temporary signals for conversion
    signal a_temp : array_mul_t(0 to a_width - 1);
	signal s_temp : array_mul_t(0 to a_width - 1);

    signal temp : integer;

begin
    temp <= error_range;


    -- Conversion from array_t to array_mul_t using resize()
    array_conversion : for i in 0 to a_width - 1 generate
    	a_temp(i) <= resize(A(i), mul_bits);
    	s_temp(i) <= resize(S(i), mul_bits);
    end generate;

    FSM_transitions: process (Reset, Clock)
    begin
        if Reset = '1'then
            state <= S1;
        elsif rising_edge(Clock) then
            case state is
                when S1 =>
                    if Start = '0' then state <= S1; else state <= S2; end if;
                when S2 =>
                    if errorGen_done = '1' then state <= S3; else state <= S2; end if;
                when S3 =>
                    -- if Start = '1' then state <= S3; else state <= S1; end if;
                    state <= S1;
            end case;
        end if;
    end process;

    do: process (state)
    begin
        -- Default
        modulue_start <= '0';
        Done <= '0';

        case state is
            when S1 =>
            -- Signals should be in their defaults

            when S2 =>
                modulue_start <= '1';

            when S3 =>
                Done <= '1';

        end case;
    end process;

    row_mul: row_mul_combinational port map (
        A => a_temp,
        S => s_temp,
        result => rowMul_result);

    err_gen: error_generator port map (
        max_cap => temp,
        clk => Clock,
        reset => Reset,
        seed => seed,
        seed_valid => seed_valid,
        start_signal => modulue_start,
        done => errorGen_done,
        error => errorGen_result
    );

    -- errorGen_result <= 0;

    modu: modulus_combinational port map(
            Dividend => signed(modulus_input),
            Divisor => Q,
            Modulo => B);

    modulus_input <= rowMul_result + errorGen_result;

end Behavioral;
