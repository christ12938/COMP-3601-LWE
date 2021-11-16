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
		Dividend                : IN		signed(dividend_width - 1 DOWNTO 0);
		-- Divisor is assumed to be always positive
		Divisor		            : IN		UNSIGNED(divisor_width - 1 DOWNTO 0);
		Modulo                  : OUT       UNSIGNED(divisor_width - 1 DOWNTO 0)
	);
END modulus_combinational;

ARCHITECTURE Behavior OF modulus_combinational IS
	constant DEBUG_PRINT : boolean := false;
BEGIN
	-- We can use the built in MOD for config 1 and 2
	config_1_2_generate : if CONFIG = 1 or CONFIG = 2 generate
		modulo <= to_unsigned(to_integer(Dividend) mod to_integer(Divisor), modulo'length);
	end generate;

	-- We have to do mod manually for config 3 because integers overflow and SIGNED MOD doesn't work properly
	config_3_generate : if CONFIG = 3 generate
		PROCESS (Dividend, Divisor)
	
			VARIABLE remainder_positive: unsigned(dividend_width - 1 DOWNTO 0);
			VARIABLE result: signed(dividend_width - 1 downto 0);
			VARIABLE quotient: signed(dividend_width - 1 DOWNTO 0);
			variable quot_mul_divs : signed(2 * dividend_width - 1 downto 0);
	
		BEGIN
			if divisor = 0 then
				-- Default to 0 when dividing by 0
				modulo <= to_unsigned(0, modulo'length);
			else
				quotient := abs(dividend) / signed(resize(Divisor, quotient'length));
				remainder_positive := unsigned(abs(dividend)) rem resize(Divisor, remainder_positive'length);
	
				if DEBUG_PRINT then
					report "quotient " & integer'image(to_integer(quotient));
					report "rem_pos " & integer'image(to_integer(remainder_positive));
				end if;
	
				if dividend < 0 then
					if DEBUG_PRINT then
						report "DIVIDEND < 0";
					end if;
	
					-- 2s complement
					quotient := -quotient;
					quot_mul_divs := quotient * signed(resize(Divisor, quotient'length));
					result := Dividend - resize(signed(quot_mul_divs), Dividend'length);
	
					if DEBUG_PRINT then
						report "result " & integer'image(to_integer(result));
					end if;
					if result < 0 then
						result := result + signed(Divisor);
					end if;
					Modulo <= resize(unsigned(result), divisor_width);
				else
					if DEBUG_PRINT then
						report "DIVIDEND >= 0";
					end if;
	
					Modulo <= resize(remainder_positive, modulo'length);
				end if;
	
				if DEBUG_PRINT then
					report "DONE";
				end if;
			end if;
		END PROCESS;
	end generate;

END Behavior;
