----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 11/16/2021 04:58:20 PM
-- Design Name:
-- Module Name: log_deltas - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.DATA_TYPES.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity log_deltas is
    Port (frac : in unsigned(mL - 1 downto 0);
          delta : out unsigned(k_trunc-1 downto 0));
end log_deltas;

architecture Behavioral of log_deltas is
begin

    config_1_gen : if CONFIG = 1 generate
        process (frac)
        begin
            case frac is
                when "0000000" => delta <= "000000000000000";
                when "0000001" => delta <= "000000001101111";
                when "0000010" => delta <= "000000011011100";
                when "0000011" => delta <= "000000101000111";
                when "0000100" => delta <= "000000110101110";
                when "0000101" => delta <= "000001000010011";
                when "0000110" => delta <= "000001001110101";
                when "0000111" => delta <= "000001011010101";
                when "0001000" => delta <= "000001100110001";
                when "0001001" => delta <= "000001110001100";
                when "0001010" => delta <= "000001111100100";
                when "0001011" => delta <= "000010000111001";
                when "0001100" => delta <= "000010010001100";
                when "0001101" => delta <= "000010011011100";
                when "0001110" => delta <= "000010100101010";
                when "0001111" => delta <= "000010101110110";
                when "0010000" => delta <= "000010111000000";
                when "0010001" => delta <= "000011000000111";
                when "0010010" => delta <= "000011001001100";
                when "0010011" => delta <= "000011010001110";
                when "0010100" => delta <= "000011011001111";
                when "0010101" => delta <= "000011100001101";
                when "0010110" => delta <= "000011101001001";
                when "0010111" => delta <= "000011110000100";
                when "0011000" => delta <= "000011110111100";
                when "0011001" => delta <= "000011111110010";
                when "0011010" => delta <= "000100000100110";
                when "0011011" => delta <= "000100001011000";
                when "0011100" => delta <= "000100010001000";
                when "0011101" => delta <= "000100010110110";
                when "0011110" => delta <= "000100011100010";
                when "0011111" => delta <= "000100100001100";
                when "0100000" => delta <= "000100100110100";
                when "0100001" => delta <= "000100101011011";
                when "0100010" => delta <= "000100110000000";
                when "0100011" => delta <= "000100110100011";
                when "0100100" => delta <= "000100111000100";
                when "0100101" => delta <= "000100111100011";
                when "0100110" => delta <= "000101000000001";
                when "0100111" => delta <= "000101000011101";
                when "0101000" => delta <= "000101000110111";
                when "0101001" => delta <= "000101001010000";
                when "0101010" => delta <= "000101001100110";
                when "0101011" => delta <= "000101001111100";
                when "0101100" => delta <= "000101010001111";
                when "0101101" => delta <= "000101010100001";
                when "0101110" => delta <= "000101010110010";
                when "0101111" => delta <= "000101011000001";
                when "0110000" => delta <= "000101011001110";
                when "0110001" => delta <= "000101011011010";
                when "0110010" => delta <= "000101011100100";
                when "0110011" => delta <= "000101011101101";
                when "0110100" => delta <= "000101011110101";
                when "0110101" => delta <= "000101011111010";
                when "0110110" => delta <= "000101011111111";
                when "0110111" => delta <= "000101100000010";
                when "0111000" => delta <= "000101100000100";
                when "0111001" => delta <= "000101100000100";
                when "0111010" => delta <= "000101100000011";
                when "0111011" => delta <= "000101100000000";
                when "0111100" => delta <= "000101011111100";
                when "0111101" => delta <= "000101011110111";
                when "0111110" => delta <= "000101011110001";
                when "0111111" => delta <= "000101011101001";
                when "1000000" => delta <= "000101011100000";
                when "1000001" => delta <= "000101011010101";
                when "1000010" => delta <= "000101011001001";
                when "1000011" => delta <= "000101010111100";
                when "1000100" => delta <= "000101010101110";
                when "1000101" => delta <= "000101010011111";
                when "1000110" => delta <= "000101010001110";
                when "1000111" => delta <= "000101001111100";
                when "1001000" => delta <= "000101001101001";
                when "1001001" => delta <= "000101001010101";
                when "1001010" => delta <= "000101001000000";
                when "1001011" => delta <= "000101000101001";
                when "1001100" => delta <= "000101000010010";
                when "1001101" => delta <= "000100111111001";
                when "1001110" => delta <= "000100111011111";
                when "1001111" => delta <= "000100111000100";
                when "1010000" => delta <= "000100110101000";
                when "1010001" => delta <= "000100110001010";
                when "1010010" => delta <= "000100101101100";
                when "1010011" => delta <= "000100101001100";
                when "1010100" => delta <= "000100100101100";
                when "1010101" => delta <= "000100100001010";
                when "1010110" => delta <= "000100011101000";
                when "1010111" => delta <= "000100011000100";
                when "1011000" => delta <= "000100010100000";
                when "1011001" => delta <= "000100001111010";
                when "1011010" => delta <= "000100001010011";
                when "1011011" => delta <= "000100000101100";
                when "1011100" => delta <= "000100000000011";
                when "1011101" => delta <= "000011111011001";
                when "1011110" => delta <= "000011110101111";
                when "1011111" => delta <= "000011110000011";
                when "1100000" => delta <= "000011101010111";
                when "1100001" => delta <= "000011100101001";
                when "1100010" => delta <= "000011011111011";
                when "1100011" => delta <= "000011011001100";
                when "1100100" => delta <= "000011010011100";
                when "1100101" => delta <= "000011001101011";
                when "1100110" => delta <= "000011000111001";
                when "1100111" => delta <= "000011000000110";
                when "1101000" => delta <= "000010111010010";
                when "1101001" => delta <= "000010110011101";
                when "1101010" => delta <= "000010101101000";
                when "1101011" => delta <= "000010100110001";
                when "1101100" => delta <= "000010011111010";
                when "1101101" => delta <= "000010011000010";
                when "1101110" => delta <= "000010010001001";
                when "1101111" => delta <= "000010001001111";
                when "1110000" => delta <= "000010000010100";
                when "1110001" => delta <= "000001111011001";
                when "1110010" => delta <= "000001110011101";
                when "1110011" => delta <= "000001101100000";
                when "1110100" => delta <= "000001100100010";
                when "1110101" => delta <= "000001011100011";
                when "1110110" => delta <= "000001010100100";
                when "1110111" => delta <= "000001001100100";
                when "1111000" => delta <= "000001000100011";
                when "1111001" => delta <= "000000111100001";
                when "1111010" => delta <= "000000110011110";
                when "1111011" => delta <= "000000101011011";
                when "1111100" => delta <= "000000100010111";
                when "1111101" => delta <= "000000011010010";
                when "1111110" => delta <= "000000010001101";
                when "1111111" => delta <= "000000001000110";

                when others => delta <= "000000000000000";
            end case;
        end process;
    end generate;


end Behavioral;
