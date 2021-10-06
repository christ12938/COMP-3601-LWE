LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY modulus IS
	GENERIC ( N : INTEGER := 36;
	          M : INTEGER := 16);
	PORT(	Start    : IN 		STD_LOGIC;
			Dividend                : IN		STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			Divisor		            : IN		STD_LOGIC_VECTOR(M - 1 DOWNTO 0);
			Remainder               : OUT       STD_LOGIC_VECTOR(M - 1 DOWNTO 0));
END modulus;

ARCHITECTURE Behavior OF modulus IS
BEGIN
    PROCESS (Start)
         VARIABLE result: UNSIGNED(N - 1 DOWNTO 0);
    BEGIN
        IF Start = '1' THEN
             result := (others => '0');
             FOR i IN N - 1 DOWNTO 0 LOOP
               result := result (N - 2 DOWNTO 0) & '0';
               result(0) := Dividend(i);
               IF result >= UNSIGNED(Divisor) THEN
                    result := result - UNSIGNED(Divisor);
               END IF;
             END LOOP;
                Remainder <= STD_LOGIC_VECTOR(result(M - 1 DOWNTO 0));
         END IF;
    END PROCESS;
    
END Behavior;