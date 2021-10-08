LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.DATA_TYPES.ALL;

ENTITY modulus IS
	GENERIC (  mul_bits : NATURAL := mul_bits;
	           n_bits : NATURAL := n_bits);
	PORT(	Start, Reset            : IN 		STD_LOGIC;
			Dividend                : IN		UNSIGNED(mul_bits - 1 DOWNTO 0);
			Divisor		            : IN		UNSIGNED(n_bits - 1 DOWNTO 0);
			Modulo                  : OUT       UNSIGNED(n_bits - 1 DOWNTO 0));
END modulus;

ARCHITECTURE Behavior OF modulus IS

BEGIN
    PROCESS (Start, Reset, Dividend, Divisor)
    
         VARIABLE remainder_positive: UNSIGNED(mul_bits - 1 DOWNTO 0); 
         VARIABLE result: integer; 
         VARIABLE quotient: UNSIGNED(mul_bits - 1 DOWNTO 0);
         VARIABLE isNeg: STD_LOGIC;
         VARIABLE Dividend_temp: UNSIGNED(mul_bits - 1 DOWNTO 0);
    BEGIN
        IF Reset = '1' OR Start = '0' THEN
            remainder_positive := (others => '0');
            quotient := (others => '0');
        ELSIF Start = '1' THEN
             remainder_positive := (others => '0');
             quotient := (others => '0');
             
             if Dividend(mul_bits - 1) = '1' then
                Dividend_temp := UNSIGNED(ABS(SIGNED(Dividend)));
                isNeg := '1';
             else
                Dividend_temp := Dividend;
                isNeg := '0';
             end if;
             
             FOR i IN mul_bits - 1 DOWNTO 0 LOOP
               remainder_positive := remainder_positive (mul_bits - 2 DOWNTO 0) & '0';
               remainder_positive(0) := Dividend_temp(i);
               IF remainder_positive >= Divisor THEN
                    remainder_positive := remainder_positive - Divisor;
                    quotient(i) := '1';
               END IF;
             END LOOP;
             if isNeg = '1' then
                quotient := NOT(quotient) + 1;
                result := to_integer(SIGNED(Dividend)) - to_integer(SIGNED(quotient)) * to_integer(UNSIGNED(Divisor));
                if result < 0 then
                    result := result + to_integer(UNSIGNED(Divisor));
                end if;
                Modulo <= to_unsigned(result, n_bits);
             else
                Modulo <= UNSIGNED(remainder_positive(n_bits - 1 DOWNTO 0));
             end if;
         END IF;
    END PROCESS;
    
END Behavior;