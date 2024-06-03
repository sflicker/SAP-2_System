library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity command_processor is 
    port (
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_prog_run_mode : in STD_LOGIC;
        i_rx_data : in STD_LOGIC_VECTOR(7 downto 0);
        i_rx_data_dv : in STD_LOGIC;

        i_tx_response_active : in STD_LOGIC;
        i_tx_response_done : in STD_LOGIC;
        o_tx_response_data : out STD_LOGIC_VECTOR(7 downto 0);
        o_tx_response_dv : out STD_LOGIC;

        o_active : out STD_LOGIC := '0';
        o_idle : out STD_LOGIC := '0'
    );
end command_processor;

architecture rtl of command_processor is

    function string_std_std_logic_vector(s : in string) return std_logic_vector is
        variable result : std_logic_vector(s'length*8-1 downto 0);
    begin
        for i in s'range loop
            result((i-s'low)*8 + 7 downto (i-s'low)*8) :=
                std_logic_vector(to_unsigned(character'pos(s(i)), 8));
        end loop;
        return result;
    end function;



--    type t_byte_array is array (natural range <>) of std_logic_vector(7 downto 0);
    type t_state is (s_init, s_idle, s_receiving, s_processing, s_wait_for_completion);
    signal r_command_buffer : std_logic_vector(255 downto 0) := (others => '0');
    signal r_command_buffer_index : integer range 0 to 31 := 0;
    signal r_state : t_state := s_init;

    constant CMD_LOAD : std_logic_vector(255 downto 0) :=
        string_std_std_logic_vector("LOAD" & string'(others => character'val(0)));
    constant CMD_RESET : std_logic_vector(255 downto 0) :=
        string_std_std_logic_vector("RESET" & string'(others => character'val(0)));
    constant CMD_EXEC : std_logic_vector(255 downto 0) :=
        string_std_std_logic_vector("EXEC" & string'(others => character'val(0)));
    constant CMD_EXAM : std_logic_vector(255 downto 0) :=
        string_std_std_logic_vector("EXAM" & string'(others => character'val(0)));



begin

    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            r_state <= s_init;
            r_command_buffer_index := 0;

        elsif rising_edge(i_clk) then
            case r_state is 
                when s_init =>
                    r_state <= s_init;
                    r_command_buffer_index := 0;
                when s_idle =>
                    if i_rx_data_dv = '1' then
                        r_state <= s_receiving;
                    end if;
                when s_receiving =>
                    if i_rx_data_dv = '1' then
                        if i_rx_data = x"0D" then -- CARRIAGE RETURN
                            r_state <= s_processing;
                        elsif r_command_buffer_index < 32 then
                            r_command_buffer(r_command_buffer_index) <= i_rx_data;
                            r_command_buffer_index <= r_command_buffer_index + 1;
                        end if;
                    end if;
                when s_processing =>
                    if command_buffer(255 downto 224) = CMD_LOAD(255 downto 224) then
                        load_prog_enable <= '1';
                    elsif command_buffer(255 downto 225) = CMD_EXEC(255 downto 224) then
                        exec_command_enable <= '1';
                    elsif command_buffer(255 downto 225) = CMD_RESET(255 downto 224) then
                        reset_command_enable <= '1';
                    elsif command_buffer(255 downto 225) = CMD_EXAM(255 downto 224) then
                        examine_command_enable <= '1';
                    end if;
                    r_state <= s_wait_for_completion;
                when s_wait_for_completion =>
                    if load_program_done = '1' or exec_command_done = '1' or reset_command_done = '1' or examine_command_done = '1' then
                        load_prog_enable <= '0';
                        exec_command_enable <= '0';
                        reset_command_enable <= '0';
                        examine_command_enable <= '0';
                        r_state <= s_idle;
                        command_buffer <= (others => '0');
                    end if;
            end case;
        end if;
    end process;
    
    
    
end architecture rtl;