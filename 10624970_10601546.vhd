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

    SIGNAL is_data_loaded, load_data : BOOLEAN := false;
    SIGNAL address_ram, next_address_ram := std_logic_vector(15 DOWNTO 0) := "0000000000000000";
    SIGNAL reset, start := std_logic := '0';
    SIGNAL data : std_logic_vector(7 DOWNTO 0) := "00000000";

BEGIN
    -- Resetta
    PROCESS (reset)
        IF (reset = '1') THEN
            is_data_loaded <= false; -- invalida i valori attuali
            address_ram <= "0000000000000000";
        END IF;
    END PROCESS;

    -- Campionatore
    PROCESS (i_clk)
        IF (i_clk'event AND i_clk = '1')
            reset <= i_rst;
            start <= i_start;
            data <= i_data;
            address_ram <= next_address_ram;
            o_address <= next_address_ram;
        END IF;
    END PROCESS;

    -- Starta
    PROCESS (i_start)
        IF (i_start = '1')
            IF (NOT(is_data_loaded))
                load_data <= true;
                o_en <= '1';
                o_we <= '0';
                next_address_ram <= address_ram;
                --altrimenti carica solo il target address
            END IF;
        END IF;
    END PROCESS;

    -- Processo che legge in serie da memoria
    PROCESS (data)
        --IF (i_clk'event AND i_clk = '1')
        IF (load_data)
            -- preparo prossima lettura
            next_address_ram <= address_ram + "0000000000000001";
            o_en <= '1';
            o_we <= '0';