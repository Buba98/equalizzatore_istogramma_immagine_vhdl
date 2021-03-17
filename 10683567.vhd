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
-- Revision 1.00 - 128 x 128 image size constraint added
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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

type state_type is (RST, SAVE_ROW, SAVE_COLUMN, SAVE_PIXEL, LOOP_SAVE, CALC_SHIFT, EQUALIZE_PIXEL, SAVE_PIXEL_EQUALIZED, LOOP_SAVE_EQUALIZED, DONE);
signal PS, NS : state_type;
signal row, row_next, column, column_next, row_copy, row_copy_next, column_copy, column_copy_next, min, max, min_next, max_next, delta, delta_next, cacca : std_logic_vector (7 downto 0);
signal count, count_next, idx, idx_next, shifted, shifted_next : std_logic_vector (15 downto 0);
signal shift, shift_next : std_logic_vector (3 downto 0);

begin

state : process(i_clk, i_rst, i_data, i_start)
    begin
        if i_rst = '1' then
            PS <= RST;
        elsif rising_edge(i_clk) then
            row <= row_next;
            shifted <= shifted_next;
            row_copy <= row_copy_next;
            shift <= shift_next;
            column <= column_next;
            column_copy <= column_copy_next;
            count<=count_next;
            max <= max_next;
            min <= min_next;
            idx<=idx_next;
            delta <= delta_next;
            PS <= NS;
        end if;
    end process;

delta_lambda : process (PS, i_start, i_rst, i_data, row, row_next, column, column_next, row_copy, row_copy_next, column_copy, column_copy_next, min, max, min_next, max_next, delta, delta_next, count, count_next, idx, idx_next, shifted, shifted_next, shift, shift_next)
    begin
        row_next <= row;
        shifted_next <= shifted;
        row_copy_next <= row_copy;
        shift_next <= shift;
        column_next <= column;
        column_copy_next <= column_copy;
        count_next <= count;
        idx_next <= idx;
        min_next <= min;
        max_next <= max;
        delta_next <= delta;
        NS <= PS;
        case PS is
            when RST =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                o_address <= "0000000000000000";
                o_data <= "00000000";
                min_next <= "11111111";
                max_next <= "00000000";
                count_next <= "0000000000000010";
                idx_next <= "0000000000000010";
                if i_start = '1' and i_rst = '0' then          
                    NS <= SAVE_COLUMN;
                else
                    NS <= RST;                    
                end if;
             when SAVE_COLUMN =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                o_data <= "00000000";
                o_address <= "0000000000000001";
                if i_data <= "10000000" then
                    column_next <= i_data;
                    column_copy_next <= i_data;
                else
                    column_next <= "10000000";
                    column_copy_next <= "10000000";
                end if;
                if(i_data = "00000000") then
                    NS <= DONE;
                else
                    NS <= SAVE_ROW;
                end if;
             when SAVE_ROW =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                o_data <= "00000000";
                o_address <= idx;
                if i_data <= "10000000" then
                    row_next <= i_data;
                    row_copy_next <= i_data;
                else
                    row_next <= "10000000";
                    row_copy_next <= "10000000";
                end if;
                if i_data = "00000000" then
                    NS <= DONE;
                else
                    NS <= SAVE_PIXEL;
                end if;
             when SAVE_PIXEL =>
                o_en <= '0';
                o_we <= '0';
                o_done <= '0';
                o_data <= "00000000";
                o_address <= idx;
                if(i_data < min) then
                    min_next <= i_data;
                end if;
                if(i_data > max) then
                    max_next <= i_data;
                end if;
                idx_next <= idx + "1";
                NS <= LOOP_SAVE;
             when LOOP_SAVE =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                o_data <= "00000000";
                o_address <= idx;
                if row_copy = "1" then
                    if column_copy = "1" then
                        row_copy_next <= row;
                        column_copy_next <= column;
                        delta_next <= max - min;
                        NS <= CALC_SHIFT;
                    else
                        row_copy_next <= row;
                        column_copy_next <= column_copy - '1';
                        NS <= SAVE_PIXEL;
                    end if;
                else
                    row_copy_next <= row_copy - '1';
                    NS <= SAVE_PIXEL;
                end if;
             when CALC_SHIFT =>
                o_en <= '1';
                o_we <= '0';
                o_done <= '0';
                o_data <= "00000000";
                o_address <= count;
                if    delta <= "00000000" then
                    shift_next <= "1000";
                elsif delta <= "00000010" then
                    shift_next <= "0111";
                elsif delta <= "00000110" then
                    shift_next <= "0110";
                elsif delta <= "00001110" then
                    shift_next <= "0101";
                elsif delta <= "00011110" then
                    shift_next <= "0100";
                elsif delta <= "00111110" then
                    shift_next <= "0011";
                elsif delta <= "01111110" then
                    shift_next <= "0010";
                elsif delta <= "11111110" then
                    shift_next <= "0001";
                elsif delta <= "11111111" then
                    shift_next <= "0000";
                end if;
                NS <= EQUALIZE_PIXEL;
             when EQUALIZE_PIXEL =>
                o_en <= '0';
                o_we <= '0';
                o_done <= '0';
                o_address <= idx;
                o_data <= "00000000";
                count_next <= count + "1";
                case shift is
                    when "1000" => shifted_next <= (i_data - min) & "00000000";
                    when "0111" => shifted_next <= "0" & (i_data - min) & "0000000";
                    when "0110" => shifted_next <= "00" & (i_data - min) & "000000";
                    when "0101" => shifted_next <= "000" & (i_data - min) & "00000";
                    when "0100" => shifted_next <= "0000" & (i_data - min) & "0000";
                    when "0011" => shifted_next <= "00000" & (i_data - min) & "000";
                    when "0010" => shifted_next <= "000000" & (i_data - min) & "00";
                    when "0001" => shifted_next <= "0000000" & (i_data - min) & "0";
                    when others => shifted_next <= "00000000" & (i_data - min);
                end case;
                NS <= SAVE_PIXEL_EQUALIZED;
             when SAVE_PIXEL_EQUALIZED =>
                o_en <= '1';
                o_we <= '1';
                o_address <= idx;
                o_done <= '0';
                if shifted <= "0000000011111111" then
                    o_data <= shifted (7 downto 0);
                else
                    o_data <= "11111111";
                end if;
                NS <= LOOP_SAVE_EQUALIZED;
             when LOOP_SAVE_EQUALIZED =>
                o_en <= '1';
                o_we <= '0';
                o_data <= "00000000";
                o_done <= '0';
                o_address <= count;
                idx_next <= idx + "1";
                if row_copy = "1" then
                    if column_copy = "1" then
                        NS <= DONE;
                    else
                        row_copy_next <= row;
                        column_copy_next <= column_copy - '1';
                        NS <= EQUALIZE_PIXEL;
                    end if;
                else
                    row_copy_next <= row_copy - '1';
                    NS <= EQUALIZE_PIXEL;
                end if;   
              when DONE =>
                o_en <= '0';
                o_data <= "00000000";
                o_we <= '0';
                o_done <= '1';
                o_address <= "0000000000000000";
                if i_start = '0' then 
                    NS <= RST;
                else
                    NS <= DONE;
                end if; 
        end case;
    end process;   
end Behavioral;
