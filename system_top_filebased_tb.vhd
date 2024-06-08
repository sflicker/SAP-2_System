library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_textio.all;
use std.textio.all;

entity system_top_filebased_tb is
    Generic (
        file_name : String := "asm_test_files/test_program_1.asm"
    );
end system_top_filebased_tb;

architecture test of system_top_filebased_tb is
    signal w_clk_100mhz : std_logic;
    signal r_rst : std_logic := '0';
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
    type t_opcode_count_array is array(0 to 255) of integer range 0 to integer'high;

    constant c_load_str : t_byte_array := (x"4C", x"4F", x"41", x"44", x"0D", x"0A"); -- "LOAD"
    constant c_ready_str : t_byte_array := (x"52", x"45", x"41", x"44", x"59", x"0D", x"0A"); --"READY";
    constant c_reset_str : t_byte_array :=  (x"52", x"45", x"53", x"45", x"54", x"0D", x"0A");   --   "RESET"
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
    signal r_opcode_code_counts : t_opcode_count_array := (others => 0);



    procedure wait_cycles(signal clk : in std_logic; cycles : in natural) is
    begin
        for i in 1 to cycles loop
            wait until rising_edge(clk);
        end loop;
    end procedure wait_cycles;

    -- format consists of multiple lines for line
    -- (4 hex digits) (:) [(whsp) (2 hex digits)]* (whsp) (-)
    -- the rest of the line following - will be ignored. 
    -- the first four digits form the current address of the bytes.
    -- each of the 2 hex digits form a program byte. these are added
    -- to add array of bytes.
    -- the Address must be immediately followed by a colon.
    -- each byte must be preceeded and followed by a whitespace character.
    
    procedure load_program_bytes(
        constant c_file_name : String;
        signal data_size : out unsigned(15 downto 0);
        signal data_bytes : out t_byte_array;
        signal opcode_count : inout t_opcode_count_array
    ) is
        File f : TEXT OPEN READ_MODE is c_file_name;
        variable l : LINE;
        variable pos : integer := 0;
        variable line_byte_count : integer := 0;
        variable data : std_logic_vector(7 downto 0);
        variable hex_str : String(1 to 2);
        variable line_str : String(1 to 256);
        variable address_str: String(1 to 5);
        variable hex_byte : std_logic_vector(7 downto 0);
        variable address_bytes : std_logic_vector(15 downto 0);
        variable line_len : integer;
        variable i : integer;
        variable current_char : character;
        variable end_of_line : boolean;
        variable read_result : boolean;
        variable digit_count : integer;
        variable line_count : integer := 1;

        type t_parsing_state is (s_address, s_colon, s_whitespace, s_byte);
        variable parsing_state : t_parsing_state := s_address;

        function is_whitespace(c : character) return Boolean is
        begin
            case c is 
                when ' ' | HT => 
                    return True;
                when others => 
                    return False;
            end case;
        end function;
        
        function is_hex_digit(c : character) return boolean is
        begin
            case c is
                when '0' to '9' | 'A' to 'F' | 'a' to 'a' =>
                    return True;
                when others =>
                    return False;
            end case;
        end function;

        subtype nibble is std_logic_vector(3 downto 0);

        function conv_hex_digit_to_nibble(c : character) return nibble
        is
        begin
            case c is
                when '0' => return "0000";
                when '1' => return "0001";
                when '2' => return "0010";
                when '3' => return "0011";
                when '4' => return "0100";
                when '5' => return "0101";
                when '6' => return "0110";
                when '7' => return "0111";
                when '8' => return "1000";
                when '9' => return "1001";
                when 'a' | 'A' => return "1010";
                when 'b' | 'B' => return "1011";
                when 'c' | 'C' => return "1100";
                when 'd' | 'D' => return "1101";
                when 'e' | 'E' => return "1110";
                when 'f' | 'F' => return "1111";
                when others => 
                    assert false report "bad hex digit" severity failure;
            end case;
        end function;

    begin
        report "Loading program file";
        report "file_name: " & c_file_name;

        line_loop: while not endfile(f) loop
            Report "Reading Line - " & to_string(line_count);
            readline(f, l);
            Report "line length: " & to_string(l'length);
            line_count := line_count + 1;
            parsing_state := s_address;
            -- skip the address and colon
            i := 1;
            line_byte_count := 0;
            line_len := l'length;
            digit_count := 0;
            address_bytes := (others => '0');
            hex_byte := (others => '0');

            character_loop : while i <= line_len loop
                read(l, current_char, read_result);
                if current_char = ':' then
                    Report "Found colon";
                    parsing_state := s_colon;
                elsif current_char = '-' then 
                    Report "Found comment - skipping rest of line";
                    -- goto next line
                    exit character_loop;
                elsif is_whitespace(current_char) then
                    Report "Found Whitespace";
                    if parsing_state = s_byte then
                        data_bytes(pos) <= hex_byte;
                        pos := pos + 1;
                        if line_byte_count = 0 then
                            opcode_count(to_integer(unsigned(hex_byte))) 
                                <= opcode_count(to_integer(unsigned(hex_byte))) + 1;
                        end if;
                        line_byte_count := line_byte_count + 1;
                    end if;
                    parsing_state := s_whitespace;
                    digit_count := 0;

                    hex_byte := (others => '0');
                elsif is_hex_digit(current_char) then
                    Report "Found Hex Digit";
                    if parsing_state = s_address then
                        address_bytes((4-digit_count)*4-1 downto (3-digit_count)*4) 
                            := conv_hex_digit_to_nibble(current_char); 
                        report "address_bytes: " & to_string(address_bytes);
                    elsif parsing_state = s_whitespace then
                        hex_byte(7 downto 4) := conv_hex_digit_to_nibble(current_char);
                        parsing_state := s_byte;
                    elsif parsing_state = s_byte then 
                        hex_byte(3 downto 0) := conv_hex_digit_to_nibble(current_char); 
                        report "hex_byte: " & to_string(hex_byte);
                    end if;
                    digit_count := digit_count + 1;

                end if;
                report "i: " & to_string(i) & ", current_char: " & to_string(current_char) & ", read_result: " & to_string(read_result); 
                i := i + 1;
            end loop character_loop;
            Report "Finished character loop";

        end loop line_loop;

        -- file_open(report_file, "opcode_report.txt", WRITE_MODE);
        -- for j in 0 to 255 loop
        --     if opcode_count(j) > 0 then
        --         write(l, string'("Opcode " & to_hstring(std_logic_vector(to_unsigned(j, 8))) & " : " & integer'image(opcode_count(j))));
        --         writeline(report_file, l);
        --     end if;
        -- end loop;
    
        -- file_close(report_file);


        data_size <= to_unsigned(pos, 16);
        wait for 0 ns;
        report "Finished Loading Program for Memory Loader Test";
    end procedure;

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

            wait until tx_active = '0';
            Report "Transmitter is report not Active";
            tx_data_dv <= '0';
            wait_cycles(clk, 1);

        end loop;
    end;

    procedure receive_results_bytes (
        signal clk : in std_logic;
        constant data_size : in integer;
        signal response_data : in std_logic_vector(7 downto 0);
        signal response_dv : in std_logic
    ) is
    begin
        Report "Receiving Results " & to_string(data_size) & " bytes.";
        for i in 0 to data_size - 1 loop
            wait until response_dv = '1';
            Report "Receiving Results Bytes - response_dv: " & to_string(response_dv) & 
                ", " & to_hex_string(response_data); 
            wait until response_dv = '0';
        end loop;
        Report "Finished receiving bytes.";
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
            i_rst => r_rst,
            o_clk => w_clk_1MHZ
        );  


    system_top : entity work.system_top
    port map (
        i_clk => w_clk_100mhz,
        i_rst => r_rst,
        s2_prog_run_switch => r_prog_run_switch,

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
        i_rst => r_rst,
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
        i_rst => r_rst,
        i_rx_serial => w_tb_rx_from_system_top_tx,
        o_rx_dv => w_to_tb_rx_dv,
        o_rx_byte => w_to_tb_rx_byte
    );            


    uut: process
        variable l : LINE;
        File report_file : TEXT;

    begin
        Report "Starting System Top - Memory Loader Test";

        r_rst <= '1';
        wait for 50 ns;

        r_rst <= '0';
        wait for 50 ns;

        load_program_bytes(file_name, program_size, program_bytes, r_opcode_code_counts);
        for i in 0 to to_integer(program_size) - 1 loop
            report "Byte " & integer'image(i) & ": " & to_hex_string(program_bytes(i));
        end loop;

        
        file_open(report_file, "opcode_report.txt", WRITE_MODE);
        for j in 0 to 255 loop
            if r_opcode_code_counts(j) > 0 then
                report "Opcode " & to_hstring(std_logic_vector(to_unsigned(j, 8))) & " : " & integer'image(r_opcode_code_counts(j));
                write(l, string'("Opcode " & to_hstring(std_logic_vector(to_unsigned(j, 8))) & " : " & integer'image(r_opcode_code_counts(j))));
                writeline(report_file, l);
            end if;
        end loop;
        
        file_close(report_file);

        wait for 50 ns;

        Report "Program Size: " & to_string(program_size);

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

        Report "Sending Reset Command";
        send_bytes_to_loader(w_clk_100mhz, c_reset_str'length, c_reset_str, r_tb_tx_byte, r_tb_tx_dv, w_tb_tx_active);
        receive_results_bytes(w_clk_100mhz, 2, w_to_tb_rx_byte, w_to_tb_rx_dv);
        receive_and_validate_bytes(w_clk_100mhz, c_ready_str'length, c_ready_str, w_to_tb_rx_byte, w_to_tb_rx_dv);

        wait;

    end process;

end test;