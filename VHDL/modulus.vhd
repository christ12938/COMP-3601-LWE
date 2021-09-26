LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY modulus IS
	GENERIC ( N : INTEGER := 36;
              M : INTEGER := 16);
	PORT(	Clock, Resetn, Start    : IN 		STD_LOGIC;
			Divident                : IN		STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			Divisor		            : IN		STD_LOGIC_VECTOR(M - 1 DOWNTO 0);
			Remainder               : OUT       STD_LOGIC_VECTOR(M - 1 DOWNTO 0);
            Done                    : OUT       STD_LOGIC);
END modulus;

ARCHITECTURE Behavior OF modulus IS
	TYPE State_type IS (S1, S2, S3, S4);
    SIGNAL State: State_type;
    SIGNAL A: UNSIGNED(N - 1 DOWNTO 0);
    SIGNAL Q: UNSIGNED(N - 1 DOWNTO 0);
    SIGNAL S: UNSIGNED(N - 1 DOWNTO 0);
    SIGNAL z: STD_LOGIC;
BEGIN
    State_Transition: PROCESS (Resetn, Clock)
    BEGIN
        IF Resetn = '0' THEN State <= S1;
        ELSIF (Clock'EVENT AND Clock = '1') THEN
            CASE State IS
                WHEN S1 => 
                    IF Start = '1' THEN State <= S2; ELSE State <= S1; END IF;
                WHEN S2 => 
                    IF z = '1' THEN State <= S3; ELSE State <= S4; END IF;
                WHEN S3 =>
                    IF Start = '1' THEN State <= S3; ELSE State <= S1; END IF;
                WHEN S4 =>
                    State <= S2;
            END CASE;
        END IF ;
    END PROCESS;

    Calculate: PROCESS (A, Q, State, Start)
        VARIABLE temp:STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    BEGIN
        CASE State IS
            WHEN S1 =>
                A <= UNSIGNED(Divident);
                Q <= RESIZE(UNSIGNED(Divisor), N);
                Remainder <= "0000000000000000";
                Done <= '0';
                z <= '0';
            WHEN S2 =>
                IF A < Q THEN
                    z <= '1';
                ELSE
                    S <= A - Q;
                END IF;
            WHEN S3 =>
                temp := STD_LOGIC_VECTOR(A);
                Remainder <= temp(M - 1 DOWNTO 0);
                Done <= '1';
            WHEN S4 =>
                A <= S;
        END CASE;
    END PROCESS;
END Behavior;