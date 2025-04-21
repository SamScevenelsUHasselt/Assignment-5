--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC - Emerging technologies, Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     wrapped_sensor - Behavioural
-- Project Name:    sensor
-- Description:     
--
-- Revision     Date       Author     Comments
-- v0.1         20250324   VlJo       Initial version
--
--------------------------------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
--    use IEEE.NUMERIC_STD.ALL;

library work;
    use work.PKG_hwswcd.ALL;

entity wrapped_sensor is
    generic(
        G_PIXELS : natural := 3750
    );
    port(
        clock : in STD_LOGIC;
        reset : in STD_LOGIC;
        iface_di : in STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
        iface_a : in STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
        iface_we : in STD_LOGIC;
        iface_do : out STD_LOGIC_VECTOR(C_WIDTH-1 downto 0)
    );
end entity wrapped_sensor;


architecture Behavioural of wrapped_sensor is

    -- (DE-)LOCALISING IN/OUTPUTS
    signal clock_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal iface_di_i : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal iface_a_i : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal iface_we_i : STD_LOGIC;
    signal iface_do_o : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);

    signal reg0, reg1, reg2: STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);

    signal address_within_range : STD_LOGIC;
    signal targeted_register : STD_LOGIC_VECTOR(17 downto 0);


    signal sensor_re : STD_LOGIC;
    signal sensor_pixeldata : STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
    signal sensor_first : STD_LOGIC;

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    clock_i <= clock;
    reset_i <= reset;
    iface_di_i <= iface_di;
    iface_a_i <= iface_a;
    iface_we_i <= iface_we;
    iface_do <= iface_do_o;
    

    -------------------------------------------------------------------------------
    -- PARSING
    -------------------------------------------------------------------------------
    address_within_range <= '1' when iface_a_i(C_WIDTH-1 downto C_PERIPHERAL_MASK_LOWINDEX) = C_SENSOR_BASE_ADDRESS_MASK else '0';
    targeted_register <= iface_a_i(19 downto 2);

    sensor_re <= reg0(0);
    reg1 <= sensor_pixeldata;
    -- reg2 <= (0 => sensor_first, others => '0');
    -- reg2 <= x"00" & x"08" & x"08" & "0000000" & sensor_first;
    reg2 <= x"00" & x"4B" & x"32" & "0000000" & sensor_first;


    -------------------------------------------------------------------------------
    -- WRITE
    -------------------------------------------------------------------------------
    PREG: process(clock_i)
    begin
        if rising_edge(clock_i) then
            if reset_i = '1' then 
                reg0 <= (others => '0');
            else
                if address_within_range = '1' then 
                    if iface_we_i = '1' then 
                        if targeted_register = "000000000000000000" then 
                            reg0 <= iface_di_i;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;


    -------------------------------------------------------------------------------
    -- READ
    -------------------------------------------------------------------------------
    PMUX: process(address_within_range, iface_we_i, targeted_register, reg0, reg1, reg2)
    begin
        iface_do_o <= C_GND;
        if address_within_range = '1' and iface_we_i = '0' then 
            case targeted_register is
                when "000000000000000000" => iface_do_o <= reg0;
                when "000000000000000001" => iface_do_o <= reg1;
                when "000000000000000010" => iface_do_o <= reg2;
                when others  => iface_do_o <= C_GND;
            end case;
        end if;
    end process;


    -------------------------------------------------------------------------------
    -- CORE
    -------------------------------------------------------------------------------
    sensor_inst00: component sensor generic map(G_PIXELS => G_PIXELS) port map(
        clock => clock_i,
        reset => reset_i,
        pixel_data_out_re => sensor_re,
        pixel_data_out => sensor_pixeldata,
        first => sensor_first
    );

end Behavioural;
