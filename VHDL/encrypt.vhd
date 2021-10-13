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

entity encrypt is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           sampleA : in myVector;
           sampleB : in array_t;
           q : in unsigned;
           M : in STD_LOGIC;
           encryptedM : out encryptedMsg;
           done : out STD_LOGIC
           );
end encrypt;

architecture Behavioral of encrypt is
    component modulus_combinational is
       generic ( mul_bits : natural := mul_bits;
	             n_bits : natural := n_bits);
	   Port(
			Dividend                : IN		UNSIGNED(mul_bits - 1 DOWNTO 0);
			Divisor		            : IN		UNSIGNED(n_bits - 1 DOWNTO 0);
			Modulo               : OUT       UNSIGNED(n_bits - 1 DOWNTO 0));
    end component;
    
  signal sample_sum_a : array_mul_t(0 to a_width-1) := (others => TO_UNSIGNED(0,mul_bits));
  signal sample_sum_b : unsigned(mul_bits - 1 downto 0) := TO_UNSIGNED(0,mul_bits);
  signal sample_mod_b : unsigned(n_bits - 1 downto 0) := TO_UNSIGNED(0,n_bits);
  signal dividends : array_mul_t(0 to 3);
  signal dividend_b : unsigned(mul_bits-1 downto 0):= TO_UNSIGNED(0,mul_bits);
  signal remainders : array_t(0 to 3);
  signal row_a : array_mul_t(0 to a_width-1) := (others => TO_UNSIGNED(0,mul_bits));
  signal element_b : unsigned(n_bits - 1 downto 0) := TO_UNSIGNED(0,n_bits);
  signal sumation_done : std_logic := '0';
  
begin
 
rowAdder : process(row_a)
    variable sum_a_temp : array_mul_t(0 to a_width-1) := (others => TO_UNSIGNED(0,mul_bits));
  begin
    
    if sumation_done = '0' and start='1' then
--      sample_sum_a <= sum_a_temp;
--      sample_sum_b <= element_b + sample_sum_b;

      for ii in 0 to a_width-1 loop
        sum_a_temp(ii) := TO_UNSIGNED(TO_INTEGER(row_a(ii)) + TO_INTEGER(sum_a_temp(ii)),mul_bits);
      end loop;
      sample_sum_a <= sum_a_temp;
      sample_sum_b <= element_b + sample_sum_b;
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
variable count : integer := 0;
variable index : integer := 0;
variable start_index : integer := 0;
variable mod_done : std_logic := '0';
begin
  if sumation_done = '0' then
      if count = sample_size then
            sumation_done <= '1';
      else 
        element_b <= sampleB(count);
        row_a <= sampleA(count);
        count := count + 1;
    end if;
  else
    
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
  end if;
end process;
end Behavioral;
