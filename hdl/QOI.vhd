----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2025 06:41:48 PM
-- Design Name: 
-- Module Name: QOI - Behavioral
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

library work;
    use work.PKG_hwswcd.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use ieee.numeric_std.all;


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity QOI is
    Port (
        clock : in STD_LOGIC;
        reset : in STD_LOGIC;
        pixel : in STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
        new_pixel : in STD_LOGIC;
        flush_rle : in STD_LOGIC;
        result : out STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
        result_info: out STD_LOGIC_VECTOR(17 downto 0)
    );
end QOI;


--result_info-- bit 17 downto 12 --> index
--result_info-- bit 11 --> RLE happened

--result_info-- bit 10
-- 0 -> Nothing in result_re
-- 1 -> Somethin in result_re (due to rle being reset)
--result_info--bits 9 downto 8
-- 00 -> No chunck in result (due to rle increase)
-- 01 -> 1 bit chunck in result
-- 10 -> 2 bit chunck in result
-- 11 -> 4 bit chunck in result
--result info--bits 7 downto 0 --> Running array result
---------------
architecture Behavioral of QOI is
    -- (DE-)LOCALISING IN/OUTPUTS
    signal clock_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal pixel_i : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal new_pixel_i : STD_LOGIC;
    signal flush_rle_i : STD_LOGIC;
    signal result_o : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal result_info_o : STD_LOGIC_VECTOR(17 downto 0);
    signal new_pixel_i_prev : STD_LOGIC;
    
    alias r : STD_LOGIC_VECTOR(7 downto 0) is pixel_i(31 downto 24);
    alias g : STD_LOGIC_VECTOR(7 downto 0) is pixel_i(23 downto 16);
    alias b : STD_LOGIC_VECTOR(7 downto 0) is pixel_i(15 downto 8);
    
    signal r_prev, g_prev, b_prev : STD_LOGIC_VECTOR(7 downto 0);
    signal rle : integer range -1 to 62;
    
    signal index : natural range 0 to 63;
    
--    type T_running_array is array (0 to 63) of STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
--    signal ra : T_running_array;
--    signal ra_value : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    
begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    clock_i <= clock;
    reset_i <= reset;
    pixel_i <= pixel;
    new_pixel_i <= new_pixel;
    flush_rle_i <= flush_rle;
    result <= result_o;
    result_info <= result_info_o;
    -------------------------------------------------------------------------------
    -- QOI
    -------------------------------------------------------------------------------
    PREG: process(new_pixel_i,flush_rle_i)
        variable base_sum : natural range 0 to 3825; -- max r*3 + g*5 + b*7
        variable result : natural range 0 to 63;
    
        variable rle_v : STD_LOGIC_VECTOR(5 downto 0);
        variable index_v : STD_LOGIC_VECTOR(5 downto 0);
        
        variable r_diff : signed(7 downto 0);
        variable g_diff : signed(7 downto 0);
        variable b_diff : signed(7 downto 0);
        
        variable r_diff_g : signed(7 downto 0);
        variable b_diff_g : signed(7 downto 0);
        
        variable r_diff_9 : signed(8 downto 0);
        variable g_diff_9 : signed(8 downto 0);
        variable b_diff_9 : signed(8 downto 0);
        
        variable r_diff_v : STD_LOGIC_VECTOR(7 downto 0);
        variable g_diff_v : STD_LOGIC_VECTOR(7 downto 0);
        variable b_diff_v : STD_LOGIC_VECTOR(7 downto 0);

        variable r_luma_v : STD_LOGIC_VECTOR(7 downto 0);
        variable g_luma_v : STD_LOGIC_VECTOR(7 downto 0);
        variable b_luma_v : STD_LOGIC_VECTOR(7 downto 0);
    begin
        if reset_i = '1' then 
            rle <= -1;
            
--            for i in ra'range loop
--                ra(i) <= (others => '0');
--            end loop;
            
            index <= 0;
--            ra_value <= (others => '0');
            result_o <= (others => '0');
            result_info_o <= (others => '0');
        else
            if new_pixel_i = '1' then
                
                base_sum := to_integer(unsigned(r)) * 3 +
                        to_integer(unsigned(g)) * 5 +
                        to_integer(unsigned(b)) * 7;
    
                result := (base_sum + 53) mod 64;
                
                index <= result;
                result_info_o(17 downto 12) <= STD_LOGIC_VECTOR(TO_UNSIGNED(index,6));
                
                
                
                result_info_o(11 downto 0) <= "000000000000";
                if flush_rle_i = '1' then
                    if rle = -1 then
                        result_info_o(11 downto 0) <= "000000000000";
                    else
                        rle_v := std_logic_vector(TO_UNSIGNED(rle,6));
                        result_info_o(7 downto 0) <= "11" & rle_v;
                        result_info_o(10) <= '1';
                        rle <= -1;
                    end if;
                else
                    --STEP 1 ------ check if equal to previous pixel_i ---------------------------------------------------------------------------------------------------------------------
                    if r = r_prev and g = g_prev and b = b_prev then 
                        rle <= rle + 1;
                        result_info_o(11) <= '1';
                        if rle > 61 then --Ensure that rle does not exceed 62 as this is illegal and store the current QOI_OP_RUN chunk
                            rle_v := std_logic_vector(TO_UNSIGNED(rle,6));
                            result_o <= X"000000" & "11" & rle_v;
                            result_info_o(9 downto 8) <= "01";
                            rle <= -1;
                        end if;
                    else
                        if rle > -1 then --if rle != -1 then store QOI_OP_RUN chunk
                            rle_v := std_logic_vector(TO_UNSIGNED(rle,6));
                            result_info_o(7 downto 0) <= "11" & rle_v;
                            result_info_o(10) <= '1';
                            rle <= -1;
                        end if;
                        --STEP 2 ------ check if in the running array --------------------------------------------------------------------------------------------------------------------
--                        if ra_value = pixel_i then --The pixel_i is in the running array
--                            index_v := std_logic_vector(TO_UNSIGNED(index,6));
--                            result_o <= X"000000" & "00" & index_v;
--                            result_info_o(9 downto 8) <= "01";
--                        else --if not store it anyway and continue
--                            ra(index) <= pixel_i;
                           --STEP 3 ------ check difference with previous pixel_is --------------------------------------------------------------------------------------------------------
                            r_diff_9 := signed('0' & r) - signed('0' & r_prev);
                            r_diff := r_diff_9(7 downto 0);
                            g_diff_9 := signed('0' & g) - signed('0' & g_prev);
                            g_diff := g_diff_9(7 downto 0);
                            b_diff_9 := signed('0' & b) - signed('0' & b_prev);
                            b_diff := b_diff_9(7 downto 0);
                            if (-2 <= r_diff and r_diff <= 1) and (-2 <= g_diff and g_diff <= 1) and (-2 <= b_diff and b_diff <= 1) then
                                r_diff_v := std_logic_vector(r_diff+2);
                                g_diff_v := std_logic_vector(g_diff+2);
                                b_diff_v := std_logic_vector(b_diff+2);
                                result_o <= X"000000" & "01" & r_diff_v(1 downto 0) & g_diff_v(1 downto 0) & b_diff_v(1 downto 0);
                                result_info_o(9 downto 8) <= "01";
                            elsif (-32 <= g_diff and g_diff <= 31) then 
                                r_diff_g := r_diff - g_diff;
                                b_diff_g := b_diff - g_diff;
                                if (-8 <= r_diff_g and r_diff_g <= 7) and (-8 <= b_diff_g and b_diff_g <= 7) then
                                    r_luma_v := std_logic_vector(r_diff_g + 8);
                                    g_luma_v := std_logic_vector(g_diff + 32);
                                    b_luma_v := std_logic_vector(b_diff_g + 8);
                                    result_o <= X"0000" & "10" & g_luma_v(5 downto 0) & r_luma_v(3 downto 0) & b_luma_v(3 downto 0);
                                    result_info_o(9 downto 8) <= "10";
                                else
                                    result_o <= "11111110" & r & g & b;
                                    result_info_o(9 downto 8) <= "11";
                                end if;
                            else
                                result_o <= "11111110" & r & g & b;
                                result_info_o(9 downto 8) <= "11";
                            end if;
--                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    pixel_iflag: process(clock_i)
    begin
        if reset_i = '1' then
            r_prev <= (others => '0');
            g_prev <= (others => '0');
            b_prev <= (others => '0');
            new_pixel_i_prev <= '0';
        else
            if falling_edge(clock_i) then
                if new_pixel_i = '0' and new_pixel_i_prev = '1' then
                    r_prev <= r;
                    g_prev <= g;
                    b_prev <= b;
                end if;
                new_pixel_i_prev <= new_pixel_i;
            end if;
        end if;
    end process;
end Behavioral;
