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

entity QOI_Wrapper is
    Port (
        clock : in STD_LOGIC;
        reset : in STD_LOGIC;
        iface_di : in STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
        iface_a : in STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
        iface_we : in STD_LOGIC;
        iface_do : out STD_LOGIC_VECTOR(C_WIDTH-1 downto 0)
    );
end QOI_Wrapper;

architecture Behavioral of QOI_Wrapper is
    -- (DE-)LOCALISING IN/OUTPUTS
    signal clock_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal iface_di_i : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal iface_a_i : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal iface_we_i : STD_LOGIC;
    signal iface_do_o : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    
    signal pixelreg : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal controlreg : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal outreg : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal inforeg : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    
    signal new_pixel_flag : STD_LOGIC;
    
    signal address_within_range : STD_LOGIC;
    signal targeted_register : STD_LOGIC_VECTOR(17 downto 0);
begin
    
    qoi_solver: component QOI port map(
        clock => clock_i,
        reset => reset_i,
        pixel => pixelreg,
        new_pixel => new_pixel_flag,
        flush_rle => controlreg(0),
        result => outreg,
        result_info => inforeg(10 downto 0)
    );
    
    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    clock_i <= clock;
    reset_i <= reset;
    iface_di_i <= iface_di;
    iface_a_i <= iface_a;
    iface_we_i <= iface_we;
    iface_do <= iface_do_o;

    address_within_range <= '1' when iface_a_i(C_WIDTH-1 downto C_PERIPHERAL_MASK_LOWINDEX) = C_QOI_BASE_ADDRESS_MASK else '0';
    targeted_register <= iface_a_i(19 downto 2);    
    

    -------------------------------------------------------------------------------
    -- WRITE
    -------------------------------------------------------------------------------
    PREG: process(clock_i,reset_i,address_within_range,iface_we_i,targeted_register)
    begin
        if rising_edge(clock_i) then
            if reset_i = '1' then 
                pixelreg <= (others => '0');
                inforeg(C_WIDTH-1 downto 11) <= (others => '0');
                controlreg <= (others => '0');
                new_pixel_flag <= '0';
            else
                new_pixel_flag <= '0';
                controlreg <= (others => '0');
                if address_within_range = '1' then 
                    if iface_we_i = '1' then 
                        if targeted_register = "000000000000000000" then 
                            pixelreg <= iface_di_i;
                            new_pixel_flag <= '1';
                        elsif targeted_register = "000000000000000001" then
                            controlreg <= iface_di_i;
                            new_pixel_flag <= '1';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
        
    -------------------------------------------------------------------------------
    -- READ
    -------------------------------------------------------------------------------
    PMUX: process(address_within_range, iface_we_i, targeted_register, pixelreg, outreg)
    begin
        iface_do_o <= C_GND;
        if address_within_range = '1' and iface_we_i = '0' then 
            case targeted_register is
                when "000000000000000000" => iface_do_o <= pixelreg;
                when "000000000000000001" => iface_do_o <= controlreg;
                when "000000000000000010" => iface_do_o <= outreg;
                when "000000000000000011" => iface_do_o <= inforeg;
                when others  => iface_do_o <= C_GND;
            end case;
        end if;
    end process;
end Behavioral;