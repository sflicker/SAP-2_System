library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity system_top is
    port(
        i_clk : STD_LOGIC;
        i_reset : STD_LOGIC;
--        S1_addr_in : in STD_LOGIC_VECTOR(15 downto 0);       -- address setting - S1 in ref
        S2_prog_run_switch : in STD_LOGIC;       -- prog / run switch (prog=0, run=1)
--        S3_data_in : in STD_LOGIC_VECTOR(7 downto 0);       -- data setting      S3 in ref
        S4_read_write_switch : in STD_LOGIC;       -- read/write toggle   -- 1 to write values to ram. 0 to read. needs to be 0 for run mode
        S5_clear_start : in STD_LOGIC;       -- start/clear (reset)  -- 
        S6_step_toggle : in STD_LOGIC;       -- single step -- 1 for a single step
        S7_manual_auto_switch : in STD_LOGIC;       -- manual/auto mode - 0 for manual, 1 for auto. 
     --   memory_access_clk : in STD_LOGIC;  -- toogle memory write. if in program, write and manual mode. this is the ram clock for prog mode. execution mode should use the system clock.
        i_rx_serial : in STD_LOGIC;    -- input to receive serial.
        o_tx_serial : out STD_LOGIC;    -- output to send serial.
        o_seven_segment_anodes : out STD_LOGIC_VECTOR(3 downto 0);      -- maps to seven segment display
        o_seven_segment_cathodes : out STD_LOGIC_VECTOR(6 downto 0)     -- maps to seven segment display

    );
end system_top;

architecture rtl of system_top is
    signal r_system_clock_100mhz : STD_LOGIC;
    signal w_clk_display_refresh_1kHZ : STD_LOGIC;
    signal w_system_clock_1MHZ : STD_LOGIC;
    signal w_gated_cpu_clock_1MHZ : STD_LOGIC;
    signal w_display_data : STD_LOGIC_VECTOR(15 downto 0);
    signal w_input_data : STD_LOGIC_VECTOR(15 downto 0);
    signal w_hltbar : STD_LOGIC;
    signal w_ram_addr : STD_LOGIC_VECTOR(15 downto 0);
    signal w_ram_data : STD_LOGIC_VECTOR(7 downto 0);
    signal w_ram_write_enable : STD_LOGIC;
    signal w_ram_data_out : STD_LOGIC_VECTOR(7 downto 0);
    signal w_mdr_tm_data : STD_LOGIC_VECTOR(7 downto 0);
    signal w_mar_addr : STD_LOGIC_VECTOR(15 downto 0);
    signal w_ram_write_enable_from_proc : STD_LOGIC;
    signal w_tx_byte : STD_LOGIC_VECTOR(7 downto 0);
    signal w_mem_data_from_loader : STD_LOGIC_VECTOR(7 downto 0);
    signal w_mem_addr_from_loader : STD_LOGIC_VECTOR(15 downto 0);
    signal w_mem_we_from_loader : STD_LOGIC;
    signal w_rx_byte : STD_LOGIC_VECTOR(7 downto 0);
    signal w_rx_rv : STD_LOGIC;
    signal w_tx_active : STD_LOGIC;
    signal w_tx_done : STD_LOGIC;
    signal w_rx_dv : STD_LOGIC;
    signal w_tx_serial : STD_LOGIC;

begin

    r_system_clock_100mhz <= i_clk;


    display_clock_divider_1KHZ : entity work.clock_divider
        generic map(g_DIV_FACTOR => 100000)
        port map(
            i_clk => i_clk,
            i_reset => i_reset,
            o_clk => w_clk_display_refresh_1kHZ
        );

    processor_clock_divider_1MHZ : entity work.clock_divider
        generic map(g_DIV_FACTOR => 100)
        port map(
            i_clk => i_clk,
            i_reset => i_reset,
            o_clk => w_system_clock_1MHZ
        );  

    processor_clock_controller : entity work.clock_controller
        port map (
            i_clk => w_system_clock_1MHZ,
            i_prog_run_switch => S2_prog_run_switch,
            i_step_toggle => S6_step_toggle,
            i_manual_auto_switch => S7_manual_auto_switch,
            i_hltbar => w_hltbar,
            i_clrbar => not i_reset,
            o_clk => w_gated_cpu_clock_1MHZ
        );

        soft_core : entity work.proc_top
        port map (
            i_clk => w_gated_cpu_clock_1MHZ,
            i_reset => i_reset,
            i_data => w_ram_data_out,
            o_data => w_mdr_tm_data, 
            o_address => w_mar_addr,
            o_ram_we => w_ram_write_enable_from_proc,
            in_port_1 => w_input_data(7 downto 0),
            in_port_2 => w_input_data(15 downto 8),
            out_port_3 => w_display_data(7 downto 0),
            out_port_4 => w_display_data(15 downto 8),
            o_hltbar => w_hltbar
        );
    


    system_mem : entity work.ram_bank
        port map (
            i_clk => w_system_clock_1MHZ,
            i_addr => w_ram_addr,
            i_data => w_ram_data, 
            i_we => w_ram_write_enable,
            o_data => w_ram_data_out
        );

    ram_bank_input : entity work.memory_input_multiplexer            
        port map(
                i_prog_run_select => S2_prog_run_switch,
                
                i_prog_data => w_mem_data_from_loader,
                i_prog_addr => w_mem_addr_from_loader,
                i_prog_write_enable => w_mem_we_from_loader,

                i_run_data => w_mdr_tm_data,
                i_run_addr => w_mar_addr,
                i_run_write_enable => w_ram_write_enable_from_proc,
                
                o_data => w_ram_data,
                o_addr => w_ram_addr,
--                select_clk_in => ram_clk_in_sig,
                o_write_enable => w_ram_write_enable
        );


    mem_loader : entity work.memory_loader
        port map(
            i_clk => r_system_clock_100mhz,
            i_reset => i_reset, 
            i_prog_run_mode => S2_prog_run_switch,
            i_rx_data => w_rx_byte,
            i_rx_data_dv => w_rx_rv,
            i_tx_response_active =>w_tx_active,
            i_tx_response_done =>w_tx_done,
            o_tx_response_data =>w_tx_byte,
            o_tx_response_dv => w_rx_dv,
            o_wrt_mem_addr => w_mem_addr_from_loader,
            o_wrt_mem_data => w_mem_data_from_loader,
            o_wrt_mem_we => w_mem_we_from_loader
        );
    

--    GENERATING_FPGA_OUTPUT : if SIMULATION_MODE = false
--    generate  
        display_controller : entity work.display_controller
        port map(
            i_clk => w_clk_display_refresh_1kHZ,
            i_rst => i_reset,
            i_data => w_display_data,
            o_anodes => o_seven_segment_anodes,
            o_cathodes => o_seven_segment_cathodes
        );
  --  end generate;          
        
    UART_RX_INST: entity work.UART_RX
    generic map (
        ID => "ST-UART-RX",
        g_CLKS_PER_BIT => 868
    )
    port map(
--        i_clk => w_system_clock_1MHZ,
        i_clk => r_system_clock_100mhz,
        i_rx_serial => i_rx_serial,
        o_rx_dv => w_rx_rv,
        o_rx_byte => w_rx_byte
    );

    UART_TX_INST : entity work.UART_TX
    generic map (
        ID => "ST-UART-TX",
        g_CLKS_PER_BIT => 868
    )
    port map(
--        i_clk => w_system_clock_1MHZ,
        i_clk => r_system_clock_100mhz,
        i_tx_dv => w_rx_dv,
        i_tx_byte => w_tx_byte,
        o_tx_active => w_tx_active,
        o_tx_serial => o_tx_serial,
        o_tx_done => w_tx_done
    );


end rtl;