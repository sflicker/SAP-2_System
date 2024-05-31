library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use std.textio.all;
  
-- CONTROL WORD
-- BITS 0-3     W BUS Selector  - these are for components whose outputs are bus connected
                -- 0000 0H  All Zeros
                -- 0001 1H  PC
                -- 0010 2H  IR Operand
                -- 0011 3H  ALU Out
                -- 0100 4H  MDR FM Out
                -- 0101 5H  ACC Out
                -- 0110 6H  B Out
                -- 0111 7H  C Out
                -- 1000 8H  Tmp Out
                -- 1001 9H  Input 1
                -- 1010 AH  Input 2
                -- 1011 BH  PC Low
                -- 1100 CH  PC High
                -- 1101 DH  SP
                -- WE Selector
--  BITS 4-7    ALU Operation
                -- 0000 OH   ALU NOP
                -- 0001 1H   ADD
                -- 0010 2H   SUB
                -- 0011 3H   INCREMENT
                -- 0100 4H   DECREMENT
                -- 0101 5H   AND
                -- 0110 6H   OR
                -- 0111 7H   XOR
                -- 1000 8H   Complement
                -- 1001 9H   RAL
                -- 1010 AH   RAR
--  BIT 8       PC Increment
--  BIT 9       IR Clear
--  BIT A       ACCUMULATOR Write Enable         -- next 12 bits are WE for components whose inputs are bus connected
--  BIT B       B Write Enable
--  BIT C       C Write Enable
--  BIT D       TMP Write Enable
--  BIT E       MAR Write Enable
--  BIT F       PC Write Enable
--  BIT 10      MDR-TM Write Enable
--  BITS 11-12  IR component WE
                -- 00   nothing selected
                -- 01   opcode WE selected
                -- 10   operand low WE selected
                -- 11   operand high WE selected
--  BIT 13      OUT Port 1 Write Enable
--  BIT 14      OUT Port 2 Write Enable
--  BIT 15      PC LOW WE
--  BIT 16      PC HIGH WE
--  BIT 17      MDR-FM WE                       -- WE for components not connected to 
--  BIT 18      RAM WE
--  BIT 19      Update Status Flags
--  BIT 1A      Check M. Abort if Not M
--  BIT 1B      Check Z. Abort if not Z
--  BIT 1C      Check Not Z. Abort if Z
--  BIT 1D      WAIT        -- use this if an another controller is running
--  BIT 1E      SP INC
--  BIT 1F      SP DEC

-- SAP-2 Opcodes
-- ADD B        80      ; Accum <= Accum + B ; includes flag updates
-- ADD C        81      ; Accum <= Accum + C ; includes flag updates
-- ANA B        A0      ; Accum <= Accum AND B ; includes flag updates
-- ANA C        A1      ; Accum <= Accum AND C ; includes flag updates
-- ANI byte     E6      ; Accum <= Accum AND byte ; includes flag updatesm
-- CALL address CD      ; PC <= address
-- CMA          2F      ; Accum <= NOT Accum
-- DCR A        3D      ; Accum <= Accum - 1 ; includes flag updates
-- DCR B        05      ; B <= B - 1 ; includes flag updates
-- DCR C        0D      ; C <= C - 1 ; includes flag updates
-- HLT          76      ; Stops processing
-- IN byte      DB      ; Acc <= INPUT PORT #byte
-- INR A        3C      ; Accum <= Accum + 1 ; flags updates
-- INR B        04      ; B <= B + 1 ; flags updates
-- INR C        0C      ; C <= C + 1 ; flags updates
-- JM address   FA      ; PC <= Address if Minus Flags set
-- JMP address  C3      ; PC <= Address
-- JNZ address  C2      ; PC <= Address if zero flag not set
-- JZ address   CA      ; PC <= Address if zero flag set
-- LDA address  3A      ; Acc <= RAM[address]
-- MOV A,B      78      ; Acc <= B
-- MOV A,C      79      ; Acc <= C
-- MOV B,A      47      ; B <= Acc
-- MOV B,C      41      ; B <= C
-- MOV C,A      4F      ; C <= Acc
-- MOV C,B      48      ; C <= B
-- MVI A, byte  3E      ; A <= byte
-- MVI B, byte  06      ; B <= byte
-- MVI C, byte  OE      ; C <= byte
-- NOP          00      ; do nothing. all counters should be set to default (low) positions
-- ORA B        B0      ; Acc <= Acc OR B   ; flags also set
-- ORA C        B1      ; Acc <= Acc OR C   ; flags also set
-- ORI Byte     F6      ; Acc <= Acc OR byte    ; flags also set
-- OUT byte     D3      ; OUTPUT PORT #byte <= Acc
-- RAL          17      ; shift accumulator bits left
-- RAR          1F      ; shift accumulator bits right
-- RET          C9      ; return from subroutine
-- STA address  32      ; RAM[address] <= Acc
-- SUB B        90      ; ACC <= Acc - B        ; flags also set
-- SUB C        91      ; ACC <= ACC - C        ; flags also set
-- XRA B        A8      ; ACC <= ACC XOR B      ; flags also set
-- XRA C        A9      ; ACC <= ACC XOR C      ; flags also set
-- XRI byte     EE      ; ACC <= ACC xor byte   ; flags also set

entity proc_controller is
  Port (
    -- inputs
    i_clk : in STD_LOGIC;
    i_rst : in STD_LOGIC;
    i_opcode : in STD_LOGIC_VECTOR(7 downto 0);          -- 8 bit opcodes
    i_minus_flag : in STD_LOGIC;
    i_equal_flag : in STD_LOGIC;

    -- outputs
    o_wbus_sel : out STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    o_alu_op : out STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    o_wbus_control_word: out STD_LOGIC_VECTOR(0 to 12) := (others => '0');
    o_pc_inc : out STD_LOGIC := '0';
    o_mdr_fm_we : out STD_LOGIC := '0';
    o_ram_we : out STD_LOGIC := '0';
    o_ir_clr : out STD_LOGIC := '0';
    o_update_status_flags : out STD_LOGIC := '0';
    o_controller_wait : out STD_LOGIC := '0';
    o_sp_inc : out STD_LOGIC := '0';
    o_sp_dec : out STD_LOGIC := '0';
    
    o_HLTBar : out STD_LOGIC := '1';
    o_stage : out integer := 0;
    o_first_stage: out STD_LOGIC := '0';
    o_last_stage: out STD_LOGIC := '0'
    );
end proc_controller;

architecture rtl of proc_controller is
    signal stage_sig : integer := 1;

    signal control_word_index_signal : std_logic_vector(9 downto 0);
    signal control_word_signal : std_logic_vector(0 to 31);

--    phase_out <= std_logic_vector(shift_left(unsigned'("000001"), stage_counter_sig - 1));

--    stage_counter : out integer


    type t_address_rom is array(0 to 255) of std_logic_vector(9 downto 0);
    type t_control_rom is array(0 to 1023) of STD_LOGIC_VECTOR(0 to 31);

    impure function init_address_rom return t_address_rom is
        file text_file : text open read_mode is "instruction_index.txt";
        variable text_line : line;
        variable rom_content : t_address_rom;
    begin
        Report "Loading Instruction Index";
        for i in 0 to 255 loop 
            readline(text_file, text_line);
            bread(text_line, rom_content(i));
        end loop;

        return rom_content;
    end function;

    impure function init_control_rom return t_control_rom is
        file text_file : text open read_mode is "control_rom.txt";
        variable text_line : line;
        variable rom_content : t_control_rom;
    begin
        Report "Loading Control Rom";
        for i in 0 to 1023 loop 
            readline(text_file, text_line);
            bread(text_line, rom_content(i));
        end loop;

        return rom_content;
    end function;

    constant ADDRESS_ROM_CONTENTS : t_address_rom := init_address_rom;

    constant NOP : STD_LOGIC_VECTOR(0 to 31) := "00000000000000000000000000000000";

    constant CONTROL_ROM : t_control_rom := init_control_rom;

    procedure output_control_word(
        variable stage_var : integer := 1;
        variable control_word : std_logic_vector(0 to 31)) is
    begin
        Report "Stage: " & to_string(stage_var) 
            & ", o_wbus_sel: " & to_string(control_word(0 to 3))
            & ", o_alu_op: " & to_string(control_word(4 to 7))
            & ", o_pc_inc: " & to_string(control_word(8))
            & ", o_ir_clr: " & to_string(control_word(9))
            & ", acc_write_enable: " & to_string(control_word(10))
            & ", b_write_enable: " & to_string(control_word(11))
            & ", c_write_enable: " & to_string(control_word(12))
            & ", tmp_write_enable: " & to_string(control_word(13))
            & ", mar_write_enable: " & to_string(control_word(14))
            & ", pc_write_enable: " & to_string(control_word(15))
            & ", mdr_tm_write_enable: " & to_string(control_word(16))
            & ", ir_write_enable: " & to_string(control_word(17 to 18))
            & ", out_1_write_enable: " & to_string(control_word(19))
            & ", out_2_write_enable: " & to_string(control_word(20))
            & ", pc_low_write_enable: " & to_string(control_word(21))
            & ", pc_high_write_enable: " & to_string(control_word(23))
            & ", o_mdr_fm_we: " & to_string(control_word(23))
            & ", o_ram_we: " & to_string(control_word(24))
            & ", o_update_status_flags: " & to_string(control_word(25))
            & ", abort_if_not_m: " & to_string(control_word(26))
            & ", abort_if_not_z: " & to_string(control_word(27))
            & ", abort_if_z: " & to_string(control_word(28))
            & ", o_controller_wait: " & to_string(control_word(29))
            & ", sp_inc: " & to_string(control_word(30))
            & ", sp_dec: " & to_string(control_word(31));

    end procedure;

begin
    o_HLTBar <= '0' when i_opcode = x"76" else
        '1';
    o_stage <= stage_sig;

    run_mode_process:
        process(i_clk, i_rst, i_opcode)
            variable stage_var : integer := 1;
            variable control_word_index : std_logic_vector(9 downto 0);
            variable control_word : std_logic_vector(0 to 31);
        begin

            if i_rst = '1' then
                stage_var := 1;
                stage_sig <= stage_var;
                o_alu_op <= (others => '0');
                o_controller_wait <= '0';
                o_first_stage <= '0';
                o_ir_clr <= '0';
                o_mdr_fm_we <= '0';
                o_pc_inc <= '0';
                o_last_stage <= '0';
                o_sp_dec <= '0';
                o_sp_inc <= '0';
                o_update_status_flags <= '0';
                o_wbus_control_word <= (others => '0');
                o_wbus_sel <= (others => '0');
                o_ram_we <= '0';
                control_word_index := (others => '0');
                
            elsif rising_edge(i_clk) then
                if stage_var = 1 then       -- reset for fetch
                    control_word_index := "0000000000";
                    o_first_stage <= '1';
                elsif stage_var = 5 then    -- start the control for the opcode
                    control_word_index := ADDRESS_ROM_CONTENTS(to_integer(unsigned(i_opcode)));
                    o_first_stage <= '0';
                else                        -- increment the index for the next control word
                    control_word_index := std_logic_vector(unsigned(control_word_index) + 1);
                    o_first_stage <= '0';
                end if;

                Report "Control Word Index: " & to_string(control_word_index);
                control_word := CONTROL_ROM(to_integer(unsigned(control_word_index)));

                Report "Stage: " & to_string(stage_var) 
                    & ", control_word_index: " & to_string(control_word_index) 
                    & ", control_word: " & to_string(control_word) 
                    & ", opcode: " & to_hex_string(i_opcode)
                    & ", minus_flag: " & to_string(i_minus_flag)
                    & ", equal_flag: " & to_string(i_equal_flag)
                    & ", AbortIfNotMinusFlag: " & to_string(control_word(26))
                    & ", AbortIfNotZeroFlag: " & to_string(control_word(27))
                    & ", AbortIfZeroFlag: " & to_string(control_word(28));

                -- exit OP control program if NOP reached and reset stage to 1.
                if control_word = NOP then        -- if the control word is NOP then abort the op and go to next fext
                    Report "NOP detected moving to next instruction";
                    stage_var := 1;
                    stage_sig <= stage_var;
                    o_last_stage <= '1';
--                    stage_counter <= stage;
                elsif control_word(26) = '1' and i_minus_flag = '0' then   -- also abort op for conditional jumps
                    Report "Abort If Not Minus detected. moving to next instruction";
                    stage_var := 1;
                    stage_sig <= stage_var;
                    o_last_stage <= '1';
                elsif control_word(27) = '1' and i_equal_flag = '0' then 
                    Report "Abort If Not Zero detected. moving to next instruction";
                    stage_var := 1;
                    stage_sig <= stage_var;
                    o_last_stage <= '1';
                elsif control_word(28) = '1' and i_equal_flag = '1' then
                    Report "Abort If Zero detected. moving to next instruction";
                    stage_var := 1;
                    stage_sig <= stage_var;
                    o_last_stage <= '1';
                else
                    -- if not finished with control program..
                    -- translate control word to output control signals 
                    o_last_stage <= '0';
                    output_control_word(stage_var, control_word);
                    control_word_signal <= control_word;
                    control_word_index_signal <= control_word_index;

                    o_wbus_sel <= control_word(0 to 3);
                    o_alu_op <= control_word(4 to 7);
                    o_pc_inc <= control_word(8);
                    o_ir_clr <= control_word(9);
                    o_wbus_control_word <= control_word(10 to 22);
                    o_mdr_fm_we <= control_word(23);
                    o_ram_we <= control_word(24);

                    o_update_status_flags <= control_word(25);

                    o_controller_wait <= control_word(29);
                    o_sp_inc <= control_word(30);
                    o_sp_dec <= control_word(31);
--                    stage_counter <= stage;
        
                    if stage_var >= 30 then     -- all op controls should end in a NOP so should never be true.
                        REPORT "WARNING stage maximum reached!!!!";
                        stage_var := 1;
                        stage_sig <= stage_var;
                    else
                        -- increment stage
                        stage_var := stage_var + 1; 
                        stage_sig <= stage_var;
                    end if;
                end if;
            end if;
--        phase_out <= std_logic_vector(shift_left(unsigned'("000001"), stage - 1));
        end process;

end rtl;
