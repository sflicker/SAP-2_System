library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

entity system_top_filebased_tb is
    Generic (
        file_name : String := "asm_test_files/test_program_1.asm"
    );
end system_top_filebased_tb;

architecture test of system_top_filebased_tb is
    signal w_clk_100mhz : std_logic;
    signal r_reset : std_logic := '0';
    signal r_prog_run_switch : std_logic := '0';
--    signal r_read_write_switch : STD_LOGIC := '0';
    signal r_clear_start : std_logic := '0';
    signal r_step_toggle : std_logic := '0';
    signal r_manual_auto_switch : std_logic := '0';
    signal w_tb_tx_to_system_top_rx : std_logic := '1';
    signal w_tb_rx_from_system_top_tx : std_logic;
    signal w_seven_segment_anodes : STD_LOGIC_VECTOR(3 downto 0);
    signal w_seven_segment_cathodes : STD_LOGIC_VECTOR(6 downto 0);

    type t_byte_array is array (natural range <>) of std_logic_vector(7 downto 0);

    constant c_load_str : t_byte_array := (x"4C", x"4F", x"41", x"4D");
    constant c_ready_str : t_byte_array := (x"52", x"45", x"41", x"44", x"59");
    signal program_bytes : t_byte_array(0 to 4096);
    signal program_size : unsigned(15 downto 0);
    signal total_size : unsigned(15 downto 0);
    signal program_size_bytes : t_byte_array(0 to 1);
    signal program_addr : t_byte_array(0 to 1);
    signal r_checksum : unsigned(7 downto 0) := (others => '0');
    signal r_checksum_bytes : t_byte_array(0 to 0);
    signal r_tb_tx_byte : std_logic_vector(7 downto 0);
    signal r_tb_tx_dv : std_logic;
    signal w_tb_tx_active : std_logic;
    signal w_tb_tx_serial : std_logic;
    signal w_tb_tx_done : std_logic;
    signal w_to_tb_rx_dv : std_logic;
    signal w_to_tb_rx_byte : std_logic_vector(7 downto 0);
    signal w_clk_1MHZ : std_logic;

    procedure wait_cycles(signal clk : in std_logic; cycles : in natural) is
    begin
        for i in 1 to cycles loop
            wait until rising_edge(clk);
        end loop;
    end procedure wait_cycles;

    procedure load_program_bytes(constant c_file_name : String;
            signal data_size : out unsigned(15 downto 0);
            signal data_bytes : out t_byte_array
        ) is
        File f : TEXT OPEN READ_MODE is c_file_name;
        variable l : LINE;
        variable data_in : std_logic_vector(7 downto 0);
        variable pos : integer := 0;
        variable data : std_logic_vector(7 downto 0);
    begin 
        Report "Loading Program for Memory Loader Test";
        while not endfile(f) loop
            readline(f, l);
            bread(l, data_in);
            data_bytes(pos) <= data_in;
            pos := pos + 1;
        end loop;
        data_size <= unsigned(to_unsigned(pos, 16));
        wait for 0 ns;
        Report "Finished Loading Program For Memory Loader Test";
    end; 

    procedure send_bytes_to_loader (
        signal clk : in std_logic;
        constant data_size : in integer;
        constant data : in t_byte_array; 
        signal tx_data : out std_logic_vector(7 downto 0);
        signal tx_data_dv : out std_logic;
        signal tx_active : in STD_LOGIC) is
    begin
        for i in 0 to data_size -1 loop
            Report "Sending byte: " & to_string(data(i));
            tx_data <= data(i);
            tx_data_dv <= '1';
            wait until tx_active = '1';
            Report "Transmitter is reporting Active";
  --          wait_cycles(clk, 1);
  --          tx_data_dv <= '0';
            wait until tx_active = '0';
            Report "Transmitter is report not Active";
            tx_data_dv <= '0';
            wait_cycles(clk, 1);
--            wait_cycles(clk, 16);
        end loop;
    end;

    procedure receive_and_validate_bytes (
        signal clk : in std_logic;
        constant valid_data_size : in integer;
        constant valid_data : in t_byte_array; 
        signal response_data : in std_logic_vector(7 downto 0);
        signal response_dv : in std_logic
    ) is
    begin
        Report "Receiving and Validating " & to_string(valid_data_size) & " bytes.";
        for i in 0 to valid_data_size - 1 loop
            wait until response_dv = '1';
            Report "Receiving Bytes - response_dv: " & to_string(response_dv) & 
                ", " & to_string(response_data) & 
                ", i: " & to_string(i) & ", valid_data(i): " & to_string(valid_data(i));
            Assert response_data = valid_data(i) report "Incorrect Value" severity error;
            wait until response_dv = '0';
        end loop;
        Report "Finished matching reply bytes.";
    end;

    procedure checksum_bytes(
        constant data_size : in integer;
        constant data : in t_byte_array; 
        signal checksum : inout unsigned(7 downto 0)
    ) is
    begin
        Report "Checksum=" & to_string(checksum);
        for i in 0 to data_size - 1 loop
            Report "i=" & to_string(i) & ", Applying " & to_string(unsigned(data(i))) & " to checksum";
            checksum <= checksum xor unsigned(data(i));
            wait for 0 ns;
            Report "Checksum=" & to_string(checksum);
        end loop;
        Report "Checksum=" & to_string(checksum);
    end;


begin


    clock : entity work.clock
    generic map(g_CLK_PERIOD => 10 ns)
    port map(
        o_clk => w_clk_100mhz
    );
    
    processor_clock_divider_1MHZ : entity work.clock_divider
        generic map(g_DIV_FACTOR => 100)
        port map(
            i_clk => w_clk_100mhz,
            i_reset => r_reset,
            o_clk => w_clk_1MHZ
        );  


    system_top : entity work.system_top
    port map (
        i_clk => w_clk_100mhz,
        i_reset => r_reset,
        s2_prog_run_switch => r_prog_run_switch,
--        S4_read_write_switch => r_read_write_switch,
--        S5_clear_start => r_clear_start,
        S6_step_toggle => r_step_toggle,
        S7_manual_auto_switch => r_manual_auto_switch,
        i_rx_serial => w_tb_tx_to_system_top_rx,
        o_tx_serial => w_tb_rx_from_system_top_tx,
        o_seven_segment_anodes => w_seven_segment_anodes,
        o_seven_segment_cathodes => w_seven_segment_cathodes
    );

    tb_uart_tx : entity work.UART_TX
    generic map (
        ID => "TB-UART-TX",
        g_CLKS_PER_BIT => 9
    )
    port map(
        i_clk => w_clk_1MHZ,
        i_tx_dv => r_tb_tx_dv,
        i_tx_byte => r_tb_tx_byte,
        o_tx_active => w_tb_tx_active,
        o_tx_serial => w_tb_tx_to_system_top_rx,
        o_tx_done => w_tb_tx_done
    );

    tb_uart_rx : entity work.UART_RX
    generic map (
        ID => "TB-UART-RX",
        g_CLKS_PER_BIT => 9
    )
    port map (
        i_clk => w_clk_1MHZ,
        i_rx_serial => w_tb_rx_from_system_top_tx,
        o_rx_dv => w_to_tb_rx_dv,
        o_rx_byte => w_to_tb_rx_byte
    );            


    uut: process
    begin
        Report "Starting System Top - Memory Loader Test";
        load_program_bytes(file_name, program_size, program_bytes);
        wait for 50 ns;

        Report "Program Size: " & to_string(program_size);

--        r_prog_run_switch <= '0';
--        r_manual_auto_switch <= '0';
        wait for 50 ns;

        Report "Sending Load Command";
        send_bytes_to_loader(w_clk_100mhz, c_load_str'length, c_load_str, r_tb_tx_byte, r_tb_tx_dv, w_tb_tx_active);
        receive_and_validate_bytes(w_clk_100mhz, c_ready_str'length, c_ready_str, w_to_tb_rx_byte, w_to_tb_rx_dv);

        total_size <= program_size + 4;
        wait for 50 ns;
        Report "Total Size: " & to_string(total_size);
        program_size_bytes(0) <= std_logic_vector(total_size(7 downto 0));
        program_size_bytes(1) <= std_logic_vector(total_size(15 downto 8));
        wait for 50 ns;
    
        program_addr(0) <= (others => '0');
        program_addr(1) <= (others => '0');

        wait for 50 ns;
        -- send total size as byte array to loader
        send_bytes_to_loader(w_clk_100mhz, 2, program_size_bytes, r_tb_tx_byte, r_tb_tx_dv, w_tb_tx_active);
        checksum_bytes(2, program_size_bytes, r_checksum);

        wait for 50 ns;
        -- send address to as byte array to loader
        send_bytes_to_loader(w_clk_100mhz, 2, program_addr, r_tb_tx_byte, r_tb_tx_dv, w_tb_tx_active);
        checksum_bytes(2, program_addr, r_checksum);

        wait for 50 ns;

        -- send program as byte array to loader
        send_bytes_to_loader(w_clk_100mhz, to_integer(program_size), program_bytes, r_tb_tx_byte, r_tb_tx_dv, w_tb_tx_active);
        checksum_bytes(to_integer(program_size), program_bytes, r_checksum);
        -- receive checksum
        wait for 50 ns;
        Report "Checksum calculated by Test Bench=" & to_string(r_checksum);

        r_checksum_bytes(0) <= std_logic_vector(r_checksum);
        wait for 50 ns;
        receive_and_validate_bytes(w_clk_100mhz, r_checksum_bytes'length, r_checksum_bytes, w_to_tb_rx_byte, w_to_tb_rx_dv);

        wait for 50 ns;

        Report "Finished Loading Test Program into Memory";

        Report "Resetting System";

        r_prog_run_switch <= '1' ;
        wait for 50 ns;

        r_reset <= '1';
        wait for 50 ns;

        r_reset <= '0';
        wait for 50 ns;

--        r_clear_start <= '1';
--        wait for 50 ns;

--        r_clear_start <= '0';
--        wait for 50 ns;

        r_manual_auto_switch <= '1';

        wait;



    end process;



end test;