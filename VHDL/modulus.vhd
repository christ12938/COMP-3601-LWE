LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.DATA_TYPES.ALL;

ENTITY modulus IS
	GENERIC (  mul_bits : NATURAL := mul_bits;
	           n_bits : NATURAL := n_bits);
	PORT(	Start, Reset, Clock    : IN 		STD_LOGIC;
			Dividend                : IN		UNSIGNED(mul_bits - 1 DOWNTO 0);
			Divisor		            : IN		UNSIGNED(n_bits - 1 DOWNTO 0);
			Remainder               : OUT       UNSIGNED(n_bits - 1 DOWNTO 0);
			Done                    : OUT    STD_LOGIC);
END modulus;

ARCHITECTURE Behavior OF modulus IS
BEGIN
    PROCESS (Start, Reset)
         VARIABLE result: UNSIGNED(mul_bits - 1 DOWNTO 0);
    BEGIN
        IF Reset = '1' OR Start = '0' THEN
            Done <= '0';
        ELSIF Start = '1' THEN
             result := (others => '0');
             FOR i IN mul_bits - 1 DOWNTO 0 LOOP
               result := result (mul_bits - 2 DOWNTO 0) & '0';
               result(0) := Dividend(i);
               IF result >= Divisor THEN
                    result := result - Divisor;
               END IF;
             END LOOP;
             Remainder <= UNSIGNED(result(n_bits - 1 DOWNTO 0));
             Done <= '1';
         END IF;
    END PROCESS;
    
END Behavior;