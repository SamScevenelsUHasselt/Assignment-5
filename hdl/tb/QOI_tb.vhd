----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2025 05:45:58 PM
-- Design Name: 
-- Module Name: QOI_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity QOI_tb is
--  Port ( );
end QOI_tb;

architecture Behavioral of QOI_tb is
    signal clock : STD_LOGIC;
    signal reset : STD_LOGIC;
    signal iface_di : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal iface_a : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal iface_we : STD_LOGIC;
    signal iface_do : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    
    constant clock_period : time := 10 ns;
begin
    -------------------------------------------------------------------------------
    -- DUT
    -------------------------------------------------------------------------------
    DUT: component QOI_Wrapper port map(
        clock => clock,
        reset => reset,
        iface_di => iface_di,
        iface_a => iface_a,
        iface_we => iface_we,
        iface_do => iface_do
    );
  
        -------------------------------------------------------------------------------
    -- CLOCK
    -------------------------------------------------------------------------------
    PCLK: process
    begin
        clock <= '1';
        wait for clock_period/2;
        clock <= '0';
        wait for clock_period/2;
    end process PCLK;


    -------------------------------------------------------------------------------
    -- RESET and test
    -------------------------------------------------------------------------------
    PRST: process
    begin
        reset <= '1';
        wait for clock_period*9;
        wait for clock_period/2;
        reset <= '0';
        wait for clock_period/2;
        wait for clock_period;
        for i in 0 to 3 loop
            for i in 0 to 3 loop
                iface_a <= X"85000000";
                iface_di <= X"FF0000FF";
                wait for clock_period;
                iface_we <= '1';
                wait for clock_period/2;
                iface_we <= '0';
                wait for clock_period/2;
            end loop;
            
            for i in 0 to 3 loop
                iface_a <= X"85000000";
                iface_di <= X"00FF00FF";
                wait for clock_period;
                iface_we <= '1';
                wait for clock_period/2;
                iface_we <= '0';
                wait for clock_period/2;
            end loop;
        end loop;
        
        for i in 0 to 3 loop
            for i in 0 to 3 loop
                iface_a <= X"85000000";
                iface_di <= X"0000FFFF";
                wait for clock_period;
                iface_we <= '1';
                wait for clock_period/2;
                iface_we <= '0';
                wait for clock_period/2;
            end loop;
            
            for i in 0 to 3 loop
                iface_a <= X"85000000";
                iface_di <= X"7F7F7FFF";
                wait for clock_period;
                iface_we <= '1';
                wait for clock_period/2;
                iface_we <= '0';
                wait for clock_period/2;
            end loop;
        end loop;
        iface_a <= X"85000004";
        iface_di <= X"00000001";
        wait for clock_period;
        iface_we <= '1';
        wait for clock_period/2;
        iface_we <= '0';
        wait for clock_period/2;

        iface_a <= X"85000004";
        iface_di <= X"00000001";
        wait for clock_period;
        iface_we <= '1';
        wait for clock_period/2;
        iface_we <= '0';
        wait for clock_period/2;

        wait;
    end process PRST;

end Behavioral;
