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

    SIGNAL state, next_state : state_type;
    SIGNAL is_data_loaded, next_is_data_loaded, load_data, next_load_data, next_is_load_target, next_load_target : BOOLEAN := false;
    SIGNAL address_ram, next_address_ram := std_logic_vector(15 DOWNTO 0) := "1111111111111111";
    SIGNAL reset, start, next_en, next_we := std_logic := '0';
    SIGNAL data, next_target_addr, target_addr, wz_0, next_wz_0, wz_2, next_wz_2, wz_3, next_wz_3, wz_4, next_wz_4, wz_5, next_wz_5, wz_6, next_wz_6, wz_7, next_wz_7 : std_logic_vector(7 DOWNTO 0) := "00000000";

BEGIN

    -- Resetta | DONE
    PROCESS (reset)
        IF (reset = '1') THEN
            next_is_data_loaded <= false; -- invalida i valori attuali
        END IF;
    END PROCESS;

    -- Campionatore | IN PROGRESS
    PROCESS (i_clk)
        IF (i_clk'event AND i_clk = '1')
            -- OUTPUT
            o_done <= next_done;
            o_en <= next_en;
            o_we <= next_we;

            o_data <= next_data;

            o_output <= next_output;

            o_address <= next_address_ram;

            -- INPUT
            reset <= i_rst;
            start <= i_start;

            data <= i_data;

            -- STATE
            is_data_loaded <= next_is_data_loaded;
            is_load_target <= next_is_load_target;
            load_data <= next_load_data;
            load_target <= next_load_target;
            is_load_data <= next_is_load_data;
            address_ram <= next_address_ram;
            state <= next_state;
            curr_output <= next_output;
            is_done <= next_is_done;

            wz_0 <= next_wz_0;
            wz_1 <= next_wz_1;
            wz_2 <= next_wz_2;
            wz_3 <= next_wz_3;
            wz_4 <= next_wz_4;
            wz_5 <= next_wz_5;
            wz_6 <= next_wz_6;
            wz_7 <= next_wz_7;

            target_addr <= next_target_addr;
        END IF;
    END PROCESS;

    -- Starter | DONE
    PROCESS (start)
        IF (start = '1')
            next_is_load_target <= false;
            next_en <= '1';
            next_we <= '0';
            IF (NOT(is_data_loaded))
                next_load_data <= true;
                next_address_ram <= "0000000000000000";
            ELSE
                next_load_target <= true;
                next_address_ram <= "000000000001000";
                --altrimenti carica solo il target address
            END IF;
        ELSE
            next_is_done <= false;
        END IF;
    END PROCESS;

    -- Lettura Dati | DONE
    PROCESS (address_ram, load_data) -- gestire tempo
        IF (load_data)

            next_load_data <= load_data; -- se problema assegna in when case ******
            next_address_ram <= address_ram + "0000000000000001"; -- auto increment se problema assegna in when case ******
            next_en <= '1';
            next_we <= '0';

            CASE address_ram - "0000000000000001" IS
                WHEN "000000000000000" =>
                    next_wz_0 <= data;
                WHEN "000000000000001" =>
                    next_wz_1 <= data;
                WHEN "000000000000010" =>
                    next_wz_2 <= data;
                WHEN "000000000000011" =>
                    next_wz_3 <= data;
                WHEN "000000000000100" =>
                    next_wz_4 <= data;
                WHEN "000000000000101" =>
                    next_wz_5 <= data;
                WHEN "000000000000110" =>
                    next_wz_6 <= data;
                WHEN "000000000000111" =>
                    next_wz_7 <= data;
                WHEN "000000000001000" =>
                    -- fine lettura
                    next_target_addr <= data;
                    next_load_data <= false;
                    next_is_load_data <= true;
                    next_is_load_target <= true;
                WHEN OTHERS => NULL;

            END CASE;
        END IF;
    END PROCESS;

    -- Lettura solo target address | DONE
    PROCESS (address_ram, load_target)
        IF (load_target)

            next_load_target <= load_target; -- se problema assegna in when case ******
            next_address_ram <= address_ram + "0000000000000001"; -- auto increment se problema assegna in when case ******
            next_en <= '1';
            next_we <= '0';

            CASE address_ram IS
                WHEN "000000000001001" =>
                    -- fine lettura
                    next_target_addr <= data;
                    next_load_target <= false;
                    next_is_load_target <= true;
                WHEN OTHERS => NULL;

            END CASE;
        END IF;
    END PROCESS;

    -- Valutazione WZ0 | DONE
    PROCESS (is_load_target)
        next_en <= '0'; -- forse errore
        next_we <= '0';
        IF (is_load_target)

            next_is_done <= true;
            is_load_target <= false;
            next_en <= '1';
            next_we <= '1';
            next_address_ram = "000000000001001";

            IF (wz_0 <= target_addr)
                CASE target_addr - wz_0 IS
                    WHEN "0000000000000000" =>
                        next_output <= "10000001";
                    WHEN "0000000000000001" =>
                        next_output <= "10000010";
                    WHEN "0000000000000010" =>
                        next_output <= "10000100";
                    WHEN "0000000000000011" =>
                        next_output <= "10001000";
                    WHEN OTHERS => NULL;
                END CASE;
            ELSIF (wz_1 <= target_addr)
                CASE target_addr - wz_1 IS
                    WHEN "0000000000000000" =>
                        next_output <= "10010001";
                    WHEN "0000000000000001" =>
                        next_output <= "10010010";
                    WHEN "0000000000000010" =>
                        next_output <= "10010100";
                    WHEN "0000000000000011" =>
                        next_output <= "10011000";
                    WHEN OTHERS => NULL;
                END CASE;
            ELSIF (wz_2 <= target_addr)
                CASE target_addr - wz_2 IS
                    WHEN "0000000000000000" =>
                        next_output <= "10100001";
                    WHEN "0000000000000001" =>
                        next_output <= "10100010";
                    WHEN "0000000000000010" =>
                        next_output <= "10100100";
                    WHEN "0000000000000011" =>
                        next_output <= "10101000";
                    WHEN OTHERS => NULL;
                END CASE;
            ELSIF (wz_3 <= target_addr)
                CASE target_addr - wz_3 IS
                    WHEN "0000000000000000" =>
                        next_output <= "10110001";
                    WHEN "0000000000000001" =>
                        next_output <= "10110010";
                    WHEN "0000000000000010" =>
                        next_output <= "10110100";
                    WHEN "0000000000000011" =>
                        next_output <= "10111000";
                    WHEN OTHERS => NULL;
                END CASE;
            ELSIF (wz_4 <= target_addr)
                CASE target_addr - wz_4 IS
                    WHEN "0000000000000000" =>
                        next_output <= "11000001";
                    WHEN "0000000000000001" =>
                        next_output <= "11000010";
                    WHEN "0000000000000010" =>
                        next_output <= "11000100";
                    WHEN "0000000000000011" =>
                        next_output <= "11001000";
                    WHEN OTHERS => NULL;
                END CASE;
            ELSIF (wz_5 <= target_addr)
                CASE target_addr - wz_5 IS
                    WHEN "0000000000000000" =>
                        next_output <= "11010001";
                    WHEN "0000000000000001" =>
                        next_output <= "11010010";
                    WHEN "0000000000000010" =>
                        next_output <= "11010100";
                    WHEN "0000000000000011" =>
                        next_output <= "11011000";
                    WHEN OTHERS => NULL;
                END CASE;
            ELSIF (wz_6 <= target_addr)
                CASE target_addr - wz_6 IS
                    WHEN "0000000000000000" =>
                        next_output <= "11100001";
                    WHEN "0000000000000001" =>
                        next_output <= "11100010";
                    WHEN "0000000000000010" =>
                        next_output <= "11100100";
                    WHEN "0000000000000011" =>
                        next_output <= "11101000";
                    WHEN OTHERS => NULL;
                END CASE;
            ELSIF (wz_7 <= target_addr)
                CASE target_addr - wz_7 IS
                    WHEN "0000000000000000" =>
                        next_output <= "11110001";
                    WHEN "0000000000000001" =>
                        next_output <= "11110010";
                    WHEN "0000000000000010" =>
                        next_output <= "11110100";
                    WHEN "0000000000000011" =>
                        next_output <= "11111000";
                    WHEN OTHERS => NULL;
                END CASE;
            ELSE
                next_output <= 0 & target_addr;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;