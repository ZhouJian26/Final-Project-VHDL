LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY project_reti_logiche IS
    PORT (
        i_clk : IN std_logic;
        i_start : IN std_logic;
        i_rst : IN std_logic;
        i_data : IN std_logic_vector(7 DOWNTO 0);
        o_address : OUT std_logic_vector(15 DOWNTO 0);
        o_done : OUT std_logic;
        o_en : OUT std_logic;
        o_we : OUT std_logic;
        o_data : OUT std_logic_vector(7 DOWNTO 0)
    );
END project_reti_logiche;

-- Processo che valuta
-- Processo che scrive

ARCHITECTURE Behavioral OF project_reti_logiche IS

    TYPE state_type IS (WAITING_FOR_START, STATE_START, STATE_LOAD, STATE_WRITE, STATE_DONE);
    SIGNAL current_state, next_state : state_type := WAITING_FOR_START;

    TYPE ram IS ARRAY(0 TO 7) OF INTEGER RANGE 0 TO 255;
    SIGNAL ram_0, next_ram_0 : ram := (OTHERS => 0);

    SIGNAL is_data_loaded, next_is_data_loaded : std_logic := '0';
    SIGNAL curr_address_ram, next_address_ram : INTEGER := 0;
    SIGNAL reset, start, next_en, next_we, curr_we, curr_en, next_done, curr_done : std_logic := '0';
    SIGNAL data, target_addr, next_target_addr, next_data, next_output : std_logic_vector(7 DOWNTO 0) := "00000000";

BEGIN
    PROCESS (i_clk)
    BEGIN
        IF (i_clk'event AND i_clk = '0') THEN
            reset <= i_rst;
            start <= i_start;
            is_data_loaded <= next_is_data_loaded;
            curr_en <= next_en;
            data <= i_data;
            curr_address_ram <= next_address_ram;
            curr_done <= next_done;
            current_state <= next_state;
            ram_0(0) <= next_ram_0(0);
            ram_0(1) <= next_ram_0(1);
            ram_0(2) <= next_ram_0(2);
            ram_0(3) <= next_ram_0(3);
            ram_0(4) <= next_ram_0(4);
            ram_0(5) <= next_ram_0(5);
            ram_0(6) <= next_ram_0(6);
            ram_0(7) <= next_ram_0(7);
        END IF;

    END PROCESS;
    --PROCESS (i_clk)
    --BEGIN
    --IF (i_clk'event AND i_clk = '1') THEN
    --ram_0(0) <= next_ram_0(0);
    --ram_0(1) <= next_ram_0(1);
    --ram_0(2) <= next_ram_0(2);
    --ram_0(3) <= next_ram_0(3);
    --ram_0(4) <= next_ram_0(4);
    --ram_0(5) <= next_ram_0(5);
    --ram_0(6) <= next_ram_0(6);
    --ram_0(7) <= next_ram_0(7);
    --END IF;
    --END PROCESS;

    PROCESS (reset, is_data_loaded, start, curr_address_ram, data, curr_done, curr_en, current_state, ram_0)
        VARIABLE target : INTEGER := 0;
    BEGIN
        o_en <= curr_en;
        o_done <= curr_done;
        next_done <= curr_done;
        next_en <= curr_en;
        next_state <= current_state;
        o_we <= '0';
        o_address <= std_logic_vector(to_unsigned(curr_address_ram, 16));
        o_data <= "00000000";
        next_address_ram <= curr_address_ram;

        target := conv_integer(data);
        next_is_data_loaded <= is_data_loaded;

        next_ram_0(0) <= ram_0(0);
        next_ram_0(1) <= ram_0(1);
        next_ram_0(2) <= ram_0(2);
        next_ram_0(3) <= ram_0(3);
        next_ram_0(4) <= ram_0(4);
        next_ram_0(5) <= ram_0(5);
        next_ram_0(6) <= ram_0(6);
        next_ram_0(7) <= ram_0(7);
        -- RESET STATE --

        IF (reset = '1') THEN
            next_state <= STATE_START;
            next_is_data_loaded <= '0';
            next_en <= '0';
            --IF (start = '1') THEN--forse meglio togliere
            -- next_state <= STATE_LOAD;
            -- o_en <= '1';
            -- next_en <= '1';
            -- next_address_ram <= 0;
            -- o_address <= "0000000000000000";
            --END IF;
        END IF;

        -- START --
        CASE current_state IS
            WHEN WAITING_FOR_START =>
            WHEN STATE_START =>
                IF (reset = '0') THEN
                    IF (start = '1') THEN
                        o_en <= '1';
                        next_en <= '1';
                        IF (is_data_loaded = '0') THEN
                            next_state <= STATE_LOAD;
                            next_address_ram <= 0;
                            o_address <= "0000000000000000";
                        ELSE
                            next_state <= STATE_WRITE;
                            o_address <= "0000000000001000";
                        END IF;
                    END IF;
                END IF;

            WHEN STATE_LOAD =>
                IF (reset = '0') THEN
                    next_state <= STATE_LOAD;
                    next_address_ram <= curr_address_ram + 1;
                    o_address <= std_logic_vector(to_unsigned(curr_address_ram + 1, 16));
                    next_ram_0(curr_address_ram) <= target;

                    IF (curr_address_ram = 7) THEN
                        next_is_data_loaded <= '1';
                        next_state <= STATE_WRITE;
                    END IF;
                END IF;

            WHEN STATE_WRITE =>
                IF (reset = '0') THEN
                    next_state <= STATE_DONE;
                    o_address <= "0000000000001001";
                    next_address_ram <= 0;
                    o_we <= '1';
                    -- o_done <= '1';
                    next_done <= '1';
                    next_en <= '0';
                    o_data <= "01111111" AND data;
                    IF (ram_0(0) <= target AND (target - ram_0(0) < 4)) THEN
                        CASE target - ram_0(0) IS
                            WHEN 0 => o_data <= "10000001";
                            WHEN 1 => o_data <= "10000010";
                            WHEN 2 => o_data <= "10000100";
                            WHEN 3 => o_data <= "10001000";
                            WHEN OTHERS => NULL;
                        END CASE;

                    ELSIF (ram_0(1) <= target AND (target - ram_0(1) < 4)) THEN
                        CASE target - ram_0(1) IS
                            WHEN 0 => o_data <= "10010001";
                            WHEN 1 => o_data <= "10010010";
                            WHEN 2 => o_data <= "10010100";
                            WHEN 3 => o_data <= "10011000";
                            WHEN OTHERS => NULL;
                        END CASE;

                    ELSIF (ram_0(2) <= target AND (target - ram_0(2) < 4)) THEN
                        CASE target - ram_0(2) IS
                            WHEN 0 => o_data <= "10100001";
                            WHEN 1 => o_data <= "10100010";
                            WHEN 2 => o_data <= "10100100";
                            WHEN 3 => o_data <= "10101000";
                            WHEN OTHERS => NULL;
                        END CASE;

                    ELSIF (ram_0(3) <= target AND (target - ram_0(3) < 4)) THEN
                        CASE target - ram_0(3) IS
                            WHEN 0 => o_data <= "10110001";
                            WHEN 1 => o_data <= "10110010";
                            WHEN 2 => o_data <= "10110100";
                            WHEN 3 => o_data <= "10111000";
                            WHEN OTHERS => NULL;
                        END CASE;

                    ELSIF (ram_0(4) <= target AND (target - ram_0(4) < 4)) THEN
                        CASE target - ram_0(4) IS
                            WHEN 0 => o_data <= "11000001";
                            WHEN 1 => o_data <= "11000010";
                            WHEN 2 => o_data <= "11000100";
                            WHEN 3 => o_data <= "11001000";
                            WHEN OTHERS => NULL;
                        END CASE;

                    ELSIF (ram_0(5) <= target AND (target - ram_0(5) < 4)) THEN
                        CASE target - ram_0(5) IS
                            WHEN 0 => o_data <= "11010001";
                            WHEN 1 => o_data <= "11010010";
                            WHEN 2 => o_data <= "11010100";
                            WHEN 3 => o_data <= "11011000";
                            WHEN OTHERS => NULL;
                        END CASE;

                    ELSIF (ram_0(6) <= target AND (target - ram_0(6) < 4)) THEN
                        CASE target - ram_0(6) IS
                            WHEN 0 => o_data <= "11100001";
                            WHEN 1 => o_data <= "11100010";
                            WHEN 2 => o_data <= "11100100";
                            WHEN 3 => o_data <= "11101000";
                            WHEN OTHERS => NULL;
                        END CASE;

                    ELSIF (ram_0(7) <= target AND (target - ram_0(7) < 4)) THEN
                        CASE target - ram_0(7) IS
                            WHEN 0 => o_data <= "11110001";
                            WHEN 1 => o_data <= "11110010";
                            WHEN 2 => o_data <= "11110100";
                            WHEN 3 => o_data <= "11111000";
                            WHEN OTHERS => NULL;
                        END CASE;
                    END IF;
                END IF;

            WHEN STATE_DONE =>
                IF (start = '0') THEN
                    o_done <= '0';
                    next_done <= '0';
                    next_en <= '0';
                    next_state <= STATE_START;
                END IF;

        END CASE;
    END PROCESS;
END behavioral;