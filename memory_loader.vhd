library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_loader is
    port(
        i_clk : in STD_LOGIC;                               -- system clock
        i_rst : in STD_LOGIC;                             -- reset loader
        i_prog_run_mode : in STD_LOGIC;                     -- system prog(low)/run(high) selecter. loader is active in prog mode only. 
        i_rx_data : in STD_LOGIC_VECTOR(7 downto 0);        -- receive a byte of data 
        i_rx_data_dv : in STD_LOGIC;                        -- byte of data is available to receive.
        i_tx_response_active : in STD_LOGIC;                -- response transmitter is active
        i_tx_response_done : in STD_LOGIC; 
        i_ram_data : in STD_LOGIC_VECTOR(7 downto 0);
        o_tx_response_data : out STD_LOGIC_VECTOR(7 downto 0) := (others => '0');   -- response byte to transmit
        o_tx_response_dv : out STD_LOGIC := '0';                   -- response byte is ready to transmit
        o_wrt_mem_addr : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); -- address of mem to write
        o_wrt_mem_data : out STD_LOGIC_VECTOR(7 downto 0) := (others => '0');  -- byte of data to write to mem
        o_wrt_mem_we : out STD_LOGIC := '0';
        o_active : out STD_LOGIC := '0';                        -- ram we enable. must be high for one clock cycle to write a byte.
        o_idle : out STD_LOGIC := '0'
    );
end memory_loader;

architecture rtl of memory_loader is
    type t_byte_array is array (natural range <>) of std_logic_vector(7 downto 0);
    type t_state is (s_init, s_idle, s_rx_start, s_tx_start_resp, s_rx_total,
        s_rx_start_addr, s_rx_data, s_wrt_data, s_verify_data, s_tx_checksum, s_tx_checksum_finish, s_cleanup);
    
    constant c_load_str : t_byte_array := (x"4C", x"4F", x"41", x"44", x"0D", x"0A");   --   "LOAD"
    constant c_ready_str : t_byte_array := (x"52", x"45", x"41", x"44", x"59", x"0D", x"0A");   -- "READY"

    signal r_state : t_state := s_init;
--    signal r_total : STD_LOGIC_VECTOR(15 downto 0);
    signal r_counter : unsigned(15 downto 0) := (others => '0');
    signal r_addr : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal r_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal r_rx_total : std_logic_vector(15 downto 0) := (others => '0');
    signal r_rx_start_addr : std_logic_vector(15 downto 0) := (others => '0');
    signal r_index : integer := 0;
    --signal r_checksum : unsigned(7 downto 0) := (others => '0');
    signal r_state_pos : integer := 0;
    signal r_data_verify : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal r_rx_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal r_loading : STD_LOGIC := '0';
    signal r_idle : STD_LOGIC := '0';
begin

    o_active <= r_loading and not i_prog_run_mode;
    r_state_pos <= t_state'POS(r_state);
    r_rx_data <= i_rx_data when i_rx_data_dv;
    o_idle <= r_idle and not i_prog_run_mode;

    p_memory_loader : process(i_clk, i_rst, i_prog_run_mode)
        variable start_addr : std_logic_vector(15 downto 0) := (others => '0');
        variable checksum : std_logic_vector(7 downto 0) := (others => '0');
    begin
        if i_rst = '1' then
            r_state <= s_init;
            o_tx_response_data <= (others => '0');
            o_tx_response_dv <= '0';
            o_wrt_mem_addr <= (others => '0');
            o_wrt_mem_data <= (others => '0');
            o_wrt_mem_we <= '0';

            r_addr <= (others => '0');
            r_counter <= (others => '0');
            r_idle <= '0';
            r_index <= 0;
            checksum := (others => '0');
            start_addr := (others => '0');
            r_loading <= '0';
            start_addr := (others => '0');
            r_rx_total <= (others => '0');
        elsif rising_edge(i_clk) and i_prog_run_mode = '0' then
            case r_state is 
                when s_init => 
                    Report "Memory Loader - s_init -> s_idle";
                    r_index <= 0;
                    r_counter <= (others => '0');
                    start_addr := (others => '0');
                    r_addr <=  (others => '0');
                    r_data <= (others => '0');
                    r_rx_start_addr <= (others => '0');
                    r_rx_total <= (others => '0');
                    checksum := (others => '0');
                    r_state <= s_idle;
                    o_tx_response_data <= (others => '0');
                    o_tx_response_dv <= '0';
                    o_wrt_mem_addr <= (others => '0');
                    o_wrt_mem_data <= (others => '0');
                    o_wrt_mem_we <= '0';
                    r_loading <= '0';
                    r_idle <= '0';
                when s_idle =>
                    r_loading <= '0';
                    r_idle <= '1';
                    if i_rx_data_dv = '1' then     -- only receive if data valid 
                        if i_rx_data = c_load_str(r_index) then
                            r_index <= r_index + 1;
                            r_state <= s_rx_start;
                            Report "Memory Loader - s_idle -> s_rx_start";
                        else 
                            Report "Memory Loader - Incorrect byte received resetting index and remaining in Idle state";
                            r_state <= s_idle;
                            r_index <= 0;
                        end if;
                    end if;

                when s_rx_start =>
                    if i_rx_data_dv = '1' then
                        if i_rx_data = c_load_str(r_index) then
                            r_data <= i_rx_data;
                            r_idle <= '0';
                            r_loading <= '1';
                            if r_index = c_load_str'length-1 then
                                r_index <= 0;
                                r_state <= s_tx_start_resp;
                                Report "Memory Loader - s_rx_start -> s_tx_start_resp";
                            else
                                r_index <= r_index + 1;
                                r_state <= s_rx_start;
                            end if;
                        else
                            r_index <= 0;
                            r_state <= s_init;
                        end if;
                    end if;
                
                when s_tx_start_resp =>
                    r_loading <= '1';
                    r_idle <= '0';
                    if i_tx_response_done = '1' then
                        if r_index = c_ready_str'length-1 then
                            r_index <= 0;
                            r_state <= s_rx_total;
                            Report "Memory Loader - s_tx_start_resp -> s_rx_total";
                        else
                            r_index <= r_index + 1;
                            r_state <= s_tx_start_resp;
                        end if;
                    elsif i_tx_response_active = '0' then   -- only transmit is upstream is not active
                        Report "Sending Start Response Byte " & to_string(r_index) & ", " & to_string(c_ready_str(r_index));
                        o_tx_response_data <= c_ready_str(r_index);
                        o_tx_response_dv <= '1';
                        r_state <= s_tx_start_resp;

                    else
                        o_tx_response_dv <= '0';
                        r_state <= s_tx_start_resp;
                    end if;

                when s_rx_total =>
                    if i_rx_data_dv = '1' then
                        if r_index = 0 then
                            r_rx_total(7 downto 0) <= i_rx_data;
                            checksum := checksum xor i_rx_data;
                            r_index <= r_index + 1;
                            r_state <= s_rx_total;
                            r_counter <= r_counter + 1;
                        elsif r_index = 1 then
                            r_rx_total(15 downto 8) <= i_rx_data;
                            checksum := checksum xor i_rx_data;
                            r_index <= 0;
                            r_state <= s_rx_start_addr;
                            r_counter <= r_counter + 1;
                        end if;
                    else
                        r_state <= s_rx_total;
                    end if;

                when s_rx_start_addr =>
                    if i_rx_data_dv = '1' then
                        if r_index = 0 then
                            start_addr(7 downto 0) := i_rx_data;
                            checksum := checksum xor i_rx_data;
                            r_index <= r_index + 1;
                            r_state <= s_rx_start_addr;
                            r_counter <= r_counter + 1;
                        elsif r_index = 1 then
                            start_addr(15 downto 8) := i_rx_data;
                            r_rx_start_addr <= start_addr;
                            r_addr <= start_addr;
                            checksum := checksum xor i_rx_data;
                            r_index <= 0;
                            r_state <= s_rx_data;
                            r_counter <= r_counter + 1;
                        end if;
                    else
                        r_state <= s_rx_start_addr;
                    end if;

                when s_rx_data =>
                    if i_rx_data_dv = '1' then
                        r_data <= i_rx_data;
                        checksum := checksum xor i_rx_data;
                    --    r_counter <= r_counter + 1;
                        r_state <= s_wrt_data;
                        o_wrt_mem_addr <= r_addr;
                        o_wrt_mem_data <= i_rx_data;
                        o_wrt_mem_we <= '1';
                        r_index <= 0;
                    else 
                        r_state <= s_rx_data;
                    end if;

                when s_wrt_data =>
                    -- this is really a to give mem write at least one clock
                    -- and do the counter increments.
                    -- may need to hold for several clock cycles but assuming not    
                    
                    if r_index = 2 then
                        o_wrt_mem_we <= '0';
                        r_state <= s_verify_data;
                        r_index <= 0;
                    else 
                        r_index <= r_index + 1;
                        r_state <= s_wrt_data;
                    end if;

                when s_verify_data =>
                    r_data_verify <= i_ram_data;
                    if r_index = 2 then
                        if r_data_verify = i_rx_data then
                            Report "Correct Byte ReadBack from Ram - " & to_string(r_data_verify);
                        else 
                            Report "Incorrect Byte ReadBack from Ram - " 
                            & to_string(r_data_verify) & ", should be " & to_string(i_rx_data) ;
                            -- TODO NEED SOME ERROR HANDLING HERE
                        end if;

                        r_index <= 0;
                        
                        if r_counter = unsigned(r_rx_total) -1 then
                            r_state <= s_tx_checksum;
                        else
                            r_counter <= r_counter + 1;
                            r_addr <= std_logic_vector(unsigned(r_addr) + 1);
                            r_state <= s_rx_data;
                        end if;
    
                    else
                        r_index <= r_index + 1;
                        r_state <= s_verify_data;
                    end if;

                when s_tx_checksum =>
                    if i_tx_response_done = '1' then
                        r_state <= s_cleanup;
                    elsif i_tx_response_active = '0' then
                        Report "Sending Checksum - " & to_string(checksum);
                        o_tx_response_data <= std_logic_vector(checksum);
                        o_tx_response_dv <= '1';
                        r_state <= s_tx_checksum;
                    else 
                        o_tx_response_dv <= '0';
                        r_state <= s_tx_checksum;
                    end if;




                    -- if i_tx_response_active = '0' then
                    --     Report "Sending Checksum - " & to_string(r_checksum);
                    --     o_tx_response_data <= std_logic_vector(r_checksum);
                    --     o_tx_response_dv <= '1';
                    --     r_state <= s_tx_checksum_finish;
                    -- else
                    --     o_tx_response_dv <= '0';
                    --     r_state <= s_tx_checksum;
                    -- end if;

                when s_tx_checksum_finish =>
                      o_tx_response_dv <= '0';
                      r_state <= s_cleanup;
                --     if i_tx_response_active = '0' then
                --         o_tx_response_dv <= '0';
                --         r_state <= s_cleanup;
                --     else 
                --         r_state <= s_tx_checksum_finish;
                --     end if;

                when s_cleanup =>
                    o_tx_response_data <= (others => '0');
                    o_tx_response_dv <= '0';
                    r_state <= s_init;
                    r_loading <= '0';
            end case;
        end if;
    end process;
end rtl;
    