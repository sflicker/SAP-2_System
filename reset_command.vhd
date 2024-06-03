library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reset_command is 
    port (
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_hltbar : in STD_LOGIC;
        i_prog_run_mode : in STD_LOGIC;
        i_rx_data : in STD_LOGIC_VECTOR(7 downto 0);        -- receive a byte of data 
        i_rx_data_dv : in STD_LOGIC;                        -- byte of data is available to receive.
        i_tx_response_active : in STD_LOGIC;                -- response transmitter is active
        i_tx_response_done : in STD_LOGIC;
        o_reset_command : out STD_LOGIC := '0';
        o_run_command : out STD_LOGIC := '0';
        o_prog_run_command : out STD_LOGIC := '0';
        i_display_data : in STD_LOGIC_VECTOR(15 downto 0);
        o_tx_response_data : out STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
        o_tx_response_dv : out STD_LOGIC := '0';
        o_active : out STD_LOGIC := '0'; 
        o_idle : out STD_LOGIC := '0'

    );
end reset_command;

architecture rtl of reset_command is
    type t_byte_array is array (natural range <>) of std_logic_vector(7 downto 0);
    type t_state is (s_init, s_idle, s_chk_cmd_str, s_do_reset, s_start_run, s_wait_for_run_finish, 
        s_send_results, s_resp, s_cleanup);
    constant c_reset_str : t_byte_array := (x"52", x"45", x"53", x"45", x"54", x"0D", x"0A");   --   "RESET"
    constant c_ready_str : t_byte_array := (x"52", x"45", x"41", x"44", x"59", x"0D", x"0A");   -- "READY"
    signal r_state : t_state := s_init;
    signal r_index : integer := 0;
    signal r_active : std_logic := '0';
    signal r_idle : std_logic := '0';
begin

    o_active <= r_active and not i_prog_run_mode;
    o_idle <= r_idle and not i_prog_run_mode;

    p_reset_command : process(i_clk, i_rst, i_prog_run_mode)
    begin
        if i_rst = '1' then
            r_state <= s_init;
            r_idle <= '0';
            r_active <= '0';
            o_run_command <= '0';
            o_reset_command <= '0';
            o_prog_run_command <= '0';
        elsif rising_edge(i_clk) and i_prog_run_mode = '0' then
            case r_state is
                when s_init =>
                    r_index <= 0;
                    r_state <= s_idle;
                    r_idle <= '0';
                    r_active <= '0';        
                when s_idle =>
                    r_idle <= '1';
                    r_active <= '0';
                    if i_rx_data_dv = '1' then
                        if i_rx_data = c_reset_str(r_index) then
                            r_index <= r_index + 1;
                            r_state <= s_chk_cmd_str;
                        else 
                            r_state <= s_idle;
                            r_index <= 0;
                        end if;
                    end if;
                when s_chk_cmd_str =>
                    if i_rx_data_dv = '1' then
                        if i_rx_data = c_reset_str(r_index) then
                            --r_data <= i_rx_data;
                            r_idle <= '0';
                            r_active <= '1';
        
                            if r_index = c_reset_str'length-1 then
                                r_index <= 0;
                                r_state <= s_do_reset;
                            else
                                r_index <= r_index + 1;
                                r_state <= s_chk_cmd_str;
                            end if;
                        else
                            r_index <= 0;
                            r_state <= s_init;
                        end if;
                    end if;
                when s_do_reset =>
                    r_active <= '1';
                    r_idle <= '0';
                    o_reset_command <= '1';
                    r_state <= s_start_run;

                when s_start_run =>
                    o_reset_command <= '0';
                    o_run_command <= '1';
                    o_prog_run_command <= '1';
                    r_state <= s_wait_for_run_finish;
                when s_wait_for_run_finish =>
                    if i_hltbar = '0' then 
                        r_state <= s_send_results;
                    else 
                        r_state <= s_wait_for_run_finish;
                    end if;
                when s_send_results =>
                    o_reset_command <= '0';
                    o_run_command <= '0';
                    o_prog_run_command <= '0';
                    r_active <= '1';
                    r_idle <= '0';
                    if i_tx_response_done = '1' then 
                        if r_index = 1 then
                            r_index <= 0;
                            r_state <= s_resp;
                        else 
                            r_index <= 1;
                            r_state <= s_send_results;
                        end if;
                    elsif i_tx_response_active = '0' then
                        if r_index = 0 then
                            -- send low byte of results (OUT 3)
                            o_tx_response_data <= i_display_data(7 downto 0);
                            o_tx_response_dv <= '1';
                            r_state <= s_send_results;
                        elsif r_index = 1 then
                            -- send high byte of results (OUT 4)
                            o_tx_response_data <= i_display_data(15 downto 8);
                            o_tx_response_dv <= '1';
                            r_state <= s_send_results;
                        end if;
                    else
                        o_tx_response_dv <= '0';
                        r_state <= s_send_results;
                    end if;
                when s_resp =>
                    o_reset_command <= '0';
                    o_run_command <= '0';
                    r_active <= '1';
                    r_idle <= '0';
                    if i_tx_response_done = '1' then
                        if r_index = c_ready_str'length-1 then
                            r_index <= 0;
                            r_state <= s_cleanup;
                        else 
                            r_index <= r_index + 1;
                            r_state <= s_resp;
                        end if;
                    elsif i_tx_response_active = '0' then
                        o_tx_response_data <= c_ready_str(r_index);
                        o_tx_response_dv <= '1';
                        r_state <= s_resp;
                    else 
                        o_tx_response_dv <= '0';
                        r_state <= s_resp;
                    end if;
                when s_cleanup =>
                    r_active <= '0';
                    r_idle <= '0';
                    o_reset_command <= '0';
                    r_state <= s_init;
                end case;
            end if;
        end process;
    end rtl;
