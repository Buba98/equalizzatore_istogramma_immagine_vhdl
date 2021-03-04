----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Vincenzo Greco
-- 
-- Create Date: 03/01/2021 10:42:23 AM
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
port (
i_clk : in std_logic;
i_rst : in std_logic;
i_start : in std_logic;
i_data : in std_logic_vector(7 downto 0);
o_address : out std_logic_vector(15 downto 0);
o_done : out std_logic;
o_en : out std_logic;
o_we : out std_logic;
o_data : out std_logic_vector (7 downto 0)
);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

type STATUS is (RST, ASK_ROW, SAVE_ROW, ASK_COLUMN, SAVE_COLUMN, CALC_DIM_MATRIX, ASK_PIXEL, SAVE_PIXEL, COMP_MAX_MIN, CALC_SHIFT, ASK_PIXEL_SHIFT, SAVE_PIXEL_SHIFT, SAVE_PIXEL_MEM);
signal PS, NS : STATUS;
signal row, row_next, column, column_next, pixel, pixel_next, min, max, min_next, max_next : std_logic_vector (7 downto 0);
signal count, count_next, idx, idx_next : std_logic_vector (15 downto 0);
signal shift, shift_next : std_logic_vector (3 downto 0);

begin

delta_lambda : process (i_clk)
    begin
        row_next <= row;
        shift_next <= shift;
        column_next <= column;
        idx_next <= idx;
        min_next <= min;
        max_next <= max;
        pixel_next <= pixel;
        NS <= PS;    
        case PS is
            when RST =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                min_next <= "11111111";
                max_next <= "00000000";
                o_address <= "0000000000000000";
                idx_next <= "0000000000000010";
                if (i_start = '1' and i_rst = '0') then                    
                    NS <= ASK_COLUMN;                    
                 else
                    NS <= RST;
                 end if;
             when ASK_COLUMN =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                o_address <= "0000000000000000";
                NS <= SAVE_COLUMN;
             when SAVE_COLUMN =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                o_address <= "0000000000000000";  
                column_next <= i_data;
                NS <= ASK_ROW;
             when ASK_ROW =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                o_address <= "0000000000000001";
                NS <= SAVE_ROW;
             when SAVE_ROW =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                o_address <= "0000000000000001";  
                row_next <= i_data;
                NS <= CALC_DIM_MATRIX;
             when CALC_DIM_MATRIX =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                o_address <= "0000000000000001";
--                count_next <= std_logic_vector (unsigned(row_next) * unsigned(column_next));
                count_next <= row_next * column_next;
                NS <= ASK_PIXEL;
             when ASK_PIXEL =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                o_address <= idx_next;
                NS <= SAVE_PIXEL;
             when SAVE_PIXEL =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                idx_next <= idx_next + "0000000000000001";
                pixel_next <= i_data;
                NS <= COMP_MAX_MIN;
             when COMP_MAX_MIN =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                if(pixel_next < min_next) then
                    min_next <= pixel_next;
                end if;
                if(pixel_next > max_next) then
                    max_next <= pixel_next;
                end if;
                if(count_next > idx_next) then
                    NS <= ASK_PIXEL;
                else
                    NS <= CALC_SHIFT;
                end if;
             when CALC_SHIFT =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                max_next <= max_next - min_next + "00000001";
                case TO_INTEGER(unsigned(max_next)) is
                    when 0 to 1 => shift_next <= "1000";
                    when 2 to 3 => shift_next <= "0111";
                    when 4 to 7 => shift_next <= "0101";
                    when 8 to 15 => shift_next <= "0100";
                    when 16 to 31 => shift_next <= "0011";
                    when 32 to 63 => shift_next <= "0010";
                    when 64 to 127 => shift_next <= "0001";
                    when 128 to 256 => shift_next <= "0000";
                end case;
                idx_next <= "0000000000000010";
                NS <= ASK_PIXEL_SHIFT;
             when ASK_PIXEL_SHIFT =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                o_address <= idx_next;
                NS <= SAVE_PIXEL_SHIFT;
             when SAVE_PIXEL_SHIFT =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                case shift_next is
                    when "0000" => pixel_next <=  i_data;
                    when "0001" => 
                        if(i_data > "01000000") then
                            pixel_next <= "11111111";
                        else
                            pixel_next <=  i_data & "0";
                        end if;
                    when "0010" =>
                        if(i_data > "00100000") then
                            pixel_next <= "11111111";
                        else
                            pixel_next <=  i_data & "00";
                        end if;
                    when "0011" =>
                        if(i_data > "00010000") then
                            pixel_next <= "11111111";
                        else 
                            pixel_next <=  i_data & "000";
                        end if;
                    when "0100" =>
                        if(i_data > "00001000") then
                            pixel_next <= "11111111";
                        else 
                            pixel_next <=  i_data & "0000";
                        end if;
                    when "0101" =>
                        if(i_data > "00000100") then
                            pixel_next <= "11111111";
                        else 
                            pixel_next <=  i_data & "00000";
                        end if;
                    when "0110" =>
                        if(i_data > "00000010") then
                            pixel_next <= "11111111";
                        else 
                            pixel_next <=  i_data & "000000";
                        end if;
                    when "0111" => 
                        if(i_data > "00000001") then
                            pixel_next <= "11111111";
                        else
                            pixel_next <=  i_data & "0000000";
                        end if;
                    when "1000" => 
                        pixel_next <=  i_data & "11111111";
                end case;
                NS <= SAVE_PIXEL_MEM;
             when SAVE_PIXEL_MEM =>
                o_en <= '1';
                o_we <= '1';
                o_done <= '0';
                o_address <= idx_next + count;
                idx_next <= idx_next + "0000000000000001";
                o_data <= pixel_next;
                if(count_next > idx_next) then
                    NS <= ASK_PIXEL_SHIFT;
                else
                    NS <= RST;
                end if;          
        end case;
    end process;

state : process(i_clk, i_start, i_rst)
    begin
        if (i_rst = '1') then
            PS <= RST;
        elsif rising_edge(i_clk) then
            PS <= NS;
            row <= row_next;
            shift <= shift_next;
            column <= column_next;
            count<=count_next;
            pixel <= pixel_next;
            max <= max_next;
            min <= min_next;
            idx<=idx_next;
        end if;
    end process;
    
end Behavioral;
