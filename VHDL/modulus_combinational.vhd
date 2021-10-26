LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.DATA_TYPES.ALL;

ENTITY modulus_combinational IS
	GENERIC (
		dividend_width : NATURAL := mul_bits;
		divisor_width : NATURAL := n_bits
	);
	PORT(
		Dividend                : IN		UNSIGNED(dividend_width - 1 DOWNTO 0);
		Divisor		            : IN		UNSIGNED(divisor_width - 1 DOWNTO 0);
		Modulo                  : OUT       UNSIGNED(divisor_width - 1 DOWNTO 0)
	);
END modulus_combinational;

ARCHITECTURE Behavior OF modulus_combinational IS

BEGIN
	PROCESS (Dividend, Divisor)

		VARIABLE remainder_positive: UNSIGNED(dividend_width - 1 DOWNTO 0);
		VARIABLE result: integer;
		VARIABLE quotient: UNSIGNED(dividend_width - 1 DOWNTO 0);
		VARIABLE isNeg: STD_LOGIC;
		VARIABLE Dividend_temp: UNSIGNED(dividend_width - 1 DOWNTO 0);

	BEGIN
		remainder_positive := (others => '0');
		quotient := (others => '0');
		remainder_positive := (others => '0');
		quotient := (others => '0');

		if Dividend(dividend_width - 1) = '1' then
			Dividend_temp := UNSIGNED(ABS(SIGNED(Dividend)));
			isNeg := '1';
		else
			Dividend_temp := Dividend;
			isNeg := '0';
		end if;

		FOR i IN dividend_width - 1 DOWNTO 0 LOOP
			remainder_positive := remainder_positive (dividend_width - 2 DOWNTO 0) & '0';
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
			Modulo <= to_unsigned(result, divisor_width);
		else
			Modulo <= UNSIGNED(remainder_positive(divisor_width - 1 DOWNTO 0));
		end if;
	END PROCESS;

END Behavior;
