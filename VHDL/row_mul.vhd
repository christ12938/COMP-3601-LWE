----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 24.09.2021 19:59:02
-- Design Name:
-- Module Name: rowMul - behavioural
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
use work.data_types.all;
use IEEE.NUMERIC_STD.ALL;

entity row_mul is
	Port (
		A, S : in array_t(0 to a_width - 1);
		reset, start, clock : in std_logic;
		done : out std_logic;
		result : out unsigned(mul_bits - 1 downto 0)
	);
end row_mul;

architecture behavioural of row_mul is

	component approx_multiplier_combinational is
			Port (
						clock : in std_logic;
						input_a : in unsigned(n_bits - 1 downto 0) ;
						input_b : in unsigned(n_bits - 1 downto 0);
						output   : out unsigned (mul_bits - 1 downto 0));
	end component;

	component register_sync_reset is
		generic (n : positive := 8);
		port (
			d : in std_logic_vector(n - 1 downto 0);
			e : in std_logic;
			reset : in std_logic;
			clock : in std_logic;
			q : out std_logic_vector(n - 1 downto 0)
		);
	end component;

	-- signal res : unsigned(mul_bits - 1 downto 0);
	signal approx_mul_out : unsigned(mul_bits - 1 downto 0);
	signal debug_actual : unsigned(mul_bits - 1 downto 0);
	signal debug_diff : signed(mul_bits - 1 downto 0);

	signal input_a, input_b : unsigned(n_bits - 1 downto 0);


	-- Counter to count to width
	signal counter_a_enable : std_logic := '0';
	signal counter_a : integer range 0 to a_height := 0;
	signal counter_a_reset_synchronous : std_logic := '0';

	-- FSM
	type fsm_state is (S_IDLE, S_MUL_WAIT, S_MUL_WORK);
	signal current_state, next_state : fsm_state := S_IDLE;
	-- signal cumulative_sum : unsigned(mul_bits - 1 downto 0);

	-- Sum registers
	signal sum_in, sum_out : unsigned(mul_bits - 1 downto 0);
	signal sum_write_enable : std_logic := '0';
	signal sum_reset : std_logic := '0';

	-- Done bit
	signal done_reset : std_logic := '0';
	signal done_enable : std_logic := '0';

	signal index : integer range 0 to a_width;

begin

	-- Counter
	count_a : process(clock, reset)
		variable counter_a_variable : integer range 0 to a_height := 0;
	begin
		if reset = '1' then
			counter_a_variable := 0;
		elsif rising_edge(clock) then
			if counter_a_reset_synchronous = '1' then
				counter_a_variable := 0;
			elsif counter_a_enable = '1' then
				counter_a_variable := counter_a_variable + 1;
			end if;
		end if;
		counter_a <= counter_a_variable;
	end process;

	-- Sum
	sum : register_sync_reset
		generic map (n => mul_bits)
		port map (
			d => std_logic_vector(sum_in),
			e => counter_a_enable,
			reset => sum_reset or reset,
			clock => clock,
			unsigned(q) => sum_out
		);
	sum_in <= sum_out + approx_mul_out;
	result <= sum_out;

	-- Done bit
	done_bit : register_sync_reset
		generic map (n => 1)
		port map (
			d(0) => '1',
			e => done_enable,
			reset => done_reset or reset,
			clock => clock,
			q(0) => done
		);

	-- State transition
	state_transition : process(clock, reset) begin
		if reset = '1' then
			current_state <= S_IDLE;
		elsif rising_edge(clock) then
			current_state <= next_state;
		end if;
	end process;

	-- FSM Logic
	fsm : process(start, counter_a, current_state)
	begin
		-- Default behaviours
		next_state <= current_state;
		counter_a_enable <= '0';
		counter_a_reset_synchronous <= '0';
		sum_reset <= '0';
		sum_write_enable <= '0';
		done_reset <= '0';
		done_enable <= '0';

		case current_state is
		when S_IDLE =>
			-- Done bit reset
			done_reset <= '1';
			sum_reset <= '1';
			-- Reset sum
			-- cumulative_sum <= to_unsigned(0, mul_bits);
			-- Reset counter
			counter_a_reset_synchronous <= '1';

			if start = '1' then
				next_state <= S_MUL_WAIT;
			end if;

		when S_MUL_WAIT =>
			next_state <= S_MUL_WORK;
			-- counter_a_enable <= '1';

		when S_MUL_WORK =>
			counter_a_enable <= '1';
			sum_write_enable <= '1';

			if counter_a = a_width - 1 then
				-- Whole row finished
				done_enable <= '1';
				next_state <= S_IDLE;
				counter_a_reset_synchronous <= '1';
			end if;


		-- when S_ALL_DONE =>
		-- 	next_state <= S_IDLE;

		when others =>
			report "Row multiplier in an invalid state" severity error;
		end case;
	end process;

	index <=
		counter_a when counter_a <= 7 else
		0;

	input_a <= A(index);
	input_b <= S(index);

	approx_multiply: approx_multiplier_combinational port map (
		clock => clock,
		input_a => input_a,
		input_b => input_b,
		output => approx_mul_out
	);
	debug_actual <= resize(input_a * input_b, debug_actual'length);
	debug_diff <= signed(debug_actual) - signed(approx_mul_out);


-- 	p_IMAGE : process(A, S, res)
-- 		-- variable productTemp : unsigned(mul_bits - 1 downto 0);
-- 		variable sumTemp : unsigned(mul_bits - 1 downto 0);
-- --    variable productTemp : integer := 0;
-- --    variable sumTemp : integer := 0;
-- 	begin
-- 		-- productTemp := TO_UNSIGNED(0, productTemp'length);
-- 		sumTemp := TO_UNSIGNED(0, sumTemp'length);
-- 		for ii in 0 to (NUM_MULS - 1) loop
-- 			sumTemp := sumTemp + res(ii);
-- 			-- input_a <= A(ii);
-- 			-- input_b <= S(ii);
-- 			-- productTemp := res;
-- --      A(ii) * S(ii);
-- --        productTemp := A(ii)*S(ii);
-- 			-- sumTemp := sumTemp + productTemp;
-- 			-- report ("COL = "  & natural'image(ii) & " A(ii)="& integer'image(TO_INTEGER(A(ii))) & " S(ii)="& integer'image(TO_INTEGER(S(ii))) &
-- 							-- " SUM = " & integer'image(TO_INTEGER(sumTemp)) & " PRODUCT = " & integer'image(TO_INTEGER(productTemp))) severity note;
-- 		end loop;
-- 		result <= sumTemp;
-- 		-- end if;
-- 	end process;

end behavioural;
