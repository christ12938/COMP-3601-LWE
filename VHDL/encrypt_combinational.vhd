----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 06.10.2021 23:40:58
-- Design Name:
-- Module Name: encrypt - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values

use work.data_types.all;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity encrypt_combinational is
    Port ( clk : in STD_LOGIC;
           start : in std_logic;
           start_mod : in STD_LOGIC;
           reset : in STD_LOGIC;
           A_row : in array_t(0 to a_width-1);
           B_element : in unsigned(n_bits - 1 downto 0);
           q : in unsigned(n_bits - 1 downto 0);
           M : in STD_LOGIC;
           encryptedM : out encryptedMsg;
           done : out STD_LOGIC
           );
end encrypt_combinational;

architecture Behavioral of encrypt_combinational is
    component modulus_combinational is
       generic ( dividend_width : natural := mul_bits;
	             divisor_width : natural := n_bits);
	   Port(
			Dividend                : IN		UNSIGNED(mul_bits - 1 DOWNTO 0);
			Divisor		            : IN		UNSIGNED(n_bits - 1 DOWNTO 0);
			Modulo               : OUT       UNSIGNED(n_bits - 1 DOWNTO 0));
    end component;

  signal sample_sum_a : array_mul_t(0 to a_width-1);
  signal sample_sum_b : unsigned(mul_bits - 1 downto 0);
  signal sample_mod_b : unsigned(n_bits - 1 downto 0);
  signal dividends : array_mul_t(0 to 3);
  signal dividend_b : unsigned(mul_bits-1 downto 0);
  signal remainders : array_t(0 to 3);

begin

rowAdder : process(A_row,B_element,reset)
    variable sum_a_temp : array_mul_t(0 to a_width-1) := (others => TO_UNSIGNED(0,mul_bits));
  begin
    if reset='1' then
        sample_sum_a <= (others => TO_UNSIGNED(0,mul_bits));
        sample_sum_b <= TO_UNSIGNED(0,mul_bits);

        sum_a_temp := (others => TO_UNSIGNED(0,mul_bits));
    elsif start = '1' then
        for ii in 0 to a_width-1 loop
            sum_a_temp(ii) := A_row(ii) + sample_sum_a(ii);
        end loop;

        sample_sum_a <= sum_a_temp;
        sample_sum_b <= B_element + sample_sum_b;
    end if;

 end process;

modu0: modulus_combinational port map(
            Dividend => dividends(0),
            Divisor => q,
            Modulo => remainders(0));
modu1: modulus_combinational port map(
            Dividend => dividends(1),
            Divisor => q,
            Modulo => remainders(1));
modu2: modulus_combinational port map(
            Dividend => dividends(2),
            Divisor => q,
            Modulo => remainders(2));
modu3: modulus_combinational port map(
            Dividend => dividends(3),
            Divisor => q,
            Modulo => remainders(3));
modu4: modulus_combinational port map(
            Dividend => dividend_b,
            Divisor => q,
            Modulo => sample_mod_b);

controller : process(clk)
variable index : integer := 0;
variable start_index : integer := 0;
variable mod_done : std_logic := '0';
begin
  if start_mod = '1' then
    if falling_edge(clk)and mod_done ='0' and index > 0 then
        start_index := index-3;
        encryptedM.u(start_index) <= remainders(0);
        start_index := start_index + 1;
        encryptedM.u(start_index) <= remainders(1);
        start_index := start_index + 1;
        encryptedM.u(start_index) <= remainders(2);
        start_index := start_index + 1;
        encryptedM.u(start_index) <= remainders(3);
        index := index + 1;
    end if;

    if rising_edge(clk) and mod_done = '0' then
        if index = a_width then
            encryptedM.v <= sample_mod_b;
            mod_done := '1';
            done <= '1';
        else
            done <= '0';
--            sample_sum_b <= sample_sum_b;
            if M ='1' then
                dividend_b <= sample_sum_b + resize(shift_right(q, 1),mul_bits);
            else
                dividend_b <= sample_sum_b;
            end if;
            dividends(0) <= sample_sum_a(index);
            index := index + 1;
            dividends(1) <= sample_sum_a(index);
            index := index + 1;
            dividends(2) <= sample_sum_a(index);
            index := index + 1;
            dividends(3) <= sample_sum_a(index);
        end if;
    end if;
  else
    done <= '0';
    index := 0;
    mod_done := '0';
    start_index := 0;
  end if;
end process;
end Behavioral;
