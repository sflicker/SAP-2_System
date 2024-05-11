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
        memory_access_clk : in STD_LOGIC;  -- toogle memory write. if in program, write and manual mode. this is the ram clock for prog mode. execution mode should use the system clock.
        i_rx_serial;    -- input to receive serial.
        i_tx_serial;    -- output to send serial.
        o_seven_segment_anodes : out STD_LOGIC_VECTOR(3 downto 0);      -- maps to seven segment display
        o_seven_segment_cathodes : out STD_LOGIC_VECTOR(6 downto 0);     -- maps to seven segment display

    );
end system_top;

architecture rtl of system_top is
    signal w_clk_display_refresh_1kHZ : STD_LOGIC;
    signal w_processor_clock_1MHZ : STD_LOGIC;
    signal r_reset : STD_LOGIC := '1';

begin
    display_clock_divider_1KHZ : entity work.clock_divider
        generic map(g_DIV_FACTOR => 100000)
        port map(
            i_clk => i_clk,
            i_reset => i_reset,
            o_clk => w_clk_display_refresh_1kHZ;
        );

    processor_clock_divider_1MHZ : entity work.clock_divider
        generic map(g_DIV_FACTOR => 100)
        port map(
            i_clk => i_clk,
            i_reset => i_reset,
            o_clk => w_processor_clock_1MHZ;
        );  

    processor_clock_controller : entity work.clock_controller
        port map (
            clk_in => w_cpu_clock_1MHZ,
            prog_run_switch => S2_prog_run_switch,
            step_toggle => S6_step_toggle,
            manual_auto_switch => S7_manual_auto_switch,
            hltbar => hltbar_sig,
            clrbar => clrbar_sig,
            clk_out => w_cpu_gated_clock_1MHZ,
            clkbar_out => clkbar_sys_sig
        );

    system_mem : entity work.ram_bank
        port map (
            i_clk => w_processor_clock_1MHZ,
            i_addr => w_ram_addr,
            i_data => w_ram_data_in, 
            i_write_enable => w_ram_write_enable
            o_data => w_ram_data_out
        );

    ram_bank_input : entity work.memory_input_multiplexer            
        port map(i_prog_run_select => S2_prog_run_switch,
                i_prog_data => S3_data_in,
                i_run_data => mdr_tm_data_out_sig,
                
                i_prog_addr => S1_addr_in,
                i_run_addr => mar_addr_sig,
--                prog_clk_in => memory_access_clk,
--                run_clk_in => clk_sys_sig,
                i_prog_write_enable => S4_read_write_switch,
                i_run_write_enable => ram_write_enable_sig,
                
                o_data => w_ram_data,
                o_addr => w_ram_addr,
--                select_clk_in => ram_clk_in_sig,
                o_write_enable => w_ram_write_enable
        );


    mem_loader : entity work.memory_loader
        port map(
            i_clk => w_processor_clock_1MHZ,
            i_reset => r_reset, 
            i_prog_run_mode => S2_prog_run_switch
        )


    GENERATING_FPGA_OUTPUT : if SIMULATION_MODE = false
    generate  
        display_controller : entity work.display_controller
        port map(
            clk => clk_disp_refresh_1KHZ_sig,
            rst => clr_sig,
            data_in => display_data,
            anodes_out => s7_anodes_out,
            cathodes_out => s7_cathodes_out
        );
    end generate;          
        
    UART_RX_INST: entity work.UART_RX
    port map(
        i_clk => 
        i_rx_serial => i_rx_serial,
        o_rx_dv => w_rx_rv,
        o_rx_byte => o_rx_byte
    );

    UART_TX_INST : entity work.UART_TX
    port map(
        i_clk => i_clk,
        i_tx_dv => w_rx_dv,
        i_tx_byte => r_tx_byte,
        o_tx_active => w_tx_active,
        o_tx_serial => w_tx_serial,
        o_tx_done => w_tx_done
    );

    loader : entity work.memory_loader
    port map (
        i_clk => w_clk,
        i_reset => r_reset,
        i_prog_run_mode => '0',
        i_rx_data => w_to_loader_rx_byte,
        i_rx_data_dv => w_to_loader_rx_dv,
        i_tx_response_active => w_loader_tx_active,
        i_tx_response_done => w_tx_response_done,
        o_tx_response_data => w_response_data,
        o_tx_response_dv => w_response_dv,
        o_wrt_mem_addr => w_wrt_mem_addr,
        o_wrt_mem_data => w_wrt_mem_data,
        o_wrt_mem_we => w_wrt_mem_we
    );


    soft_core : entity work.proc_top
        port map (
            i_clk => w_cpu_gated_clock_1MHZ,
            i_reset => r_reset,
            i_data =>
            o_data =>
            o_address =>
        );
    

    startup : process(i_clk, i_reset)
    begin
        if rising_edge(i_clk) then
            if i_reset = '1' then
                r_reset <= '1';
            else 
                r_reset <= '0';
            end if;
        end if;
    end;


end rtl;