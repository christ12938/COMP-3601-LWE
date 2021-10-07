library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.data_types.ALL;

entity decrypt is
    Port(   U, S : in array_mul_t (0 to a_width-1);
            V, Q : in unsigned (n_bits - 1 DOWNTO 0);
            M    : out std_logic);
end decrypt;

architecture Behavioral of decrypt is 

    component rowMul is
	   generic (
		  mul_bits : natural := mul_bits
		);
	   Port ( A : in array_mul_t;
            S : in array_mul_t;
            reset, start : in std_logic;
            result : out unsigned);
    end component;
    
    component modulus is
       generic ( mul_bits : natural := mul_bits;
	             n_bits : natural := n_bits);
	   Port(	Start, Reset       : IN 		STD_LOGIC;
			Dividend                : IN		UNSIGNED(mul_bits - 1 DOWNTO 0);
			Divisor		            : IN		UNSIGNED(n_bits - 1 DOWNTO 0);
			Modulo               : OUT       UNSIGNED(n_bits - 1 DOWNTO 0));
    end component;
    
    signal rowMul_result : unsigned(mul_bits - 1 DOWNTO 0);
    signal product_result : unsigned(mul_bits - 1 DOWNTO 0);
    signal dec: unsigned(n_bits - 1 DOWNTO 0);
    signal condition : unsigned(n_bits - 1 DOWNTO 0);
begin
    
    row_mul: rowMul port map (
            A => U,
            S => S,
            reset => '0',
            start => '1',
            result => rowMul_result);
    
    modu: modulus port map(
            Start => '1',
            Reset => '0',
            Dividend => product_result,
            Divisor => Q,
            Modulo => dec);
    
     product_result <= to_unsigned((to_integer(V) - to_integer(rowMul_result)), mul_bits);
     condition <= "00" & Q (n_bits - 1 DOWNTO 2);
     M <= '0' when dec < condition else
          '1';
    
end Behavioral;