--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC - Emerging technologies, Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     riscv_microcontroller_tb - Behavioural
-- Project Name:    Testbench for RISC-V microcontroller
-- Description:     
--
-- Revision     Date       Author     Comments
-- v0.1         20241128   VlJo       Initial version
--
--------------------------------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

library work;
    use work.PKG_hwswcd.ALL;

entity riscv_microcontroller_tb is
    generic (
        G_DATA_WIDTH : integer := 32;
        G_DEPTH_LOG2 : integer := 11;

        FNAME_OUT_FILE :       string := "C:/Users/SamSc/OneDrive/Desktop/HWSWCD/Assignment-5/firmware/simulation_output.txt"
    );  
end entity riscv_microcontroller_tb;

architecture Behavioural of riscv_microcontroller_tb is

    -- clock and reset
    signal clock_i : STD_LOGIC;
    signal reset_i : STD_LOGIC;
    signal leds_i : STD_LOGIC_VECTOR(3 downto 0);
    
    signal dmem_ad : STD_LOGIC_VECTOR(31 downto 0);
    signal dmem_we : STD_LOGIC;
    signal dmem_di : STD_LOGIC_VECTOR(31 downto 0);
    
    signal sclock : STD_LOGIC;
    signal ce : STD_LOGIC;
    
    
    
    -- constants
    constant C_ZEROES: STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0) := (others => '0');
    constant clock_period : time := 10 ns;

begin

    -------------------------------------------------------------------------------
    -- DUT
    -------------------------------------------------------------------------------
    DUT: component riscv_microcontroller port map(
        sys_clock => clock_i,
        sys_reset => reset_i,
        
        gpio_leds => leds_i,
        
        di => dmem_di,
        we => dmem_we,
        a => dmem_ad,
        
        sclock => sclock,
        ce_out => ce,
        
        external_irq => '0'
    );

    -------------------------------------------------------------------------------
    -- Basic IO
    -------------------------------------------------------------------------------
    basicIO_model_inst00: component basicIO_model generic map(
        G_DATA_WIDTH => G_DATA_WIDTH,
        FNAME_OUT_FILE => FNAME_OUT_FILE
    ) port map(
        clock => sclock,
        reset => reset_i,
        ce => ce,
        di => dmem_di,
        ad => dmem_ad,
        we => dmem_we,
        do => open
    );

    -------------------------------------------------------------------------------
    -- CLOCK
    -------------------------------------------------------------------------------
    PCLK: process
    begin
        clock_i <= '1';
        wait for clock_period/2;
        clock_i <= '0';
        wait for clock_period/2;
    end process PCLK;


    -------------------------------------------------------------------------------
    -- RESET
    -------------------------------------------------------------------------------
    PRST: process
    begin
        reset_i <= '1';
        wait for clock_period*9;
        wait for clock_period/2;
        reset_i <= '0';
        wait;
    end process PRST;

end Behavioural;