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

    type state_type is (STATE_START, STATE_LOAD, STATE_WRITE);
    signal current_state, next_state : state_type;
    
    type ram is array(0 to 7) of integer range 0 to 255;
    signal ram_0 : ram;
    
    SIGNAL is_data_loaded, next_is_data_loaded : std_logic := '0';
    SIGNAL curr_address_ram, next_address_ram : std_logic_vector(15 DOWNTO 0) := "0000000000000000";
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
            current_state<=next_state;
        END IF;

    END PROCESS;
    
    
   
    
    
    
    PROCESS (reset, is_data_loaded, start, curr_address_ram, data, curr_done, curr_en,current_state)
    BEGIN
        next_state<= STATE_START;
        o_en <= curr_en;
        o_done <= curr_done;
        next_done <= curr_done;
        next_en <= curr_en;
        o_we <= '0';
        o_address <= curr_address_ram;
        o_data <= "00000000";
        next_address_ram <= curr_address_ram;

     
        next_is_data_loaded <= is_data_loaded;
        
        -- RESET STATE --
        

        -- START --
       case current_state is
            when STATE_START =>
            
                IF (reset = '1') THEN
                    next_state<= STATE_START;
                    next_is_data_loaded <= '0';
                        IF (start = '1') THEN
                            next_state<= STATE_LOAD;
                            
                            next_address_ram <= "0000000000000000";
                            o_address <= "0000000000000000";
                            
                        END IF;
                ELSIF (start = '1' AND curr_done = '0' ) THEN
                o_en <= '1';
                next_en <= '1';
                
                     IF (is_data_loaded = '0') THEN
                        next_state<= STATE_LOAD;
                       
                        next_address_ram <= "0000000000000000";
                        o_address <= "0000000000000000";
                    ELSE
                        next_state<= STATE_WRITE;
                        
                        o_address <= "0000000000001000";
                    END IF;
                ELSIF (start = '0' AND curr_done = '1') THEN
                    o_done <= '0';
                    next_done <= '0';
                END IF;
                
            when STATE_LOAD =>
                 IF ( reset = '0') THEN
                    next_state<=STATE_LOAD;
                    next_address_ram <= std_logic_vector(to_unsigned(conv_integer(curr_address_ram) + 1, 16));
                    o_address <= std_logic_vector(to_unsigned(conv_integer(curr_address_ram) + 1, 16));
                    ram_0(conv_integer(curr_address_ram))<=conv_integer(data);
                    
                    if(conv_integer(curr_address_ram)=7) then
                            next_is_data_loaded <= '1';
                            next_state<=STATE_WRITE;
                    end if;
                END IF;
                
            when STATE_WRITE =>
                   IF ( reset = '0') THEN
                        next_state<=STATE_START;
                        o_address <= "0000000000001001";
                        next_address_ram <= "0000000000000000";
                        o_we <= '1';
                        -- o_done <= '1';
                        next_done <= '1';
                        next_en <= '0';
                        o_data <= "01111111" AND data;
                        IF (ram_0(0) <= conv_integer(data) AND (conv_integer(data) -ram_0(0) < 4)) THEN
                            CASE conv_integer(data) - ram_0(0) IS
                                WHEN 0 => o_data <= "10000001";
                                WHEN 1 => o_data <= "10000010";
                                WHEN 2 => o_data <= "10000100";
                                WHEN 3 => o_data <= "10001000";
                                WHEN OTHERS => NULL;
                            END CASE;
                        END IF;
            
                        IF (ram_0(1) <= conv_integer(data) AND (conv_integer(data) -ram_0(1) < 4)) THEN
                            CASE conv_integer(data) - ram_0(1) IS
                                WHEN 0 => o_data <= "10010001";
                                WHEN 1 => o_data <= "10010010";
                                WHEN 2 => o_data <= "10010100";
                                WHEN 3 => o_data <= "10011000";
                                WHEN OTHERS => NULL;
                            END CASE;
                        END IF;
                        IF (ram_0(2) <= conv_integer(data) AND (conv_integer(data) -ram_0(2) < 4)) THEN
                            CASE conv_integer(data) - ram_0(2) IS
                                WHEN 0 => o_data <= "10100001";
                                WHEN 1 => o_data <= "10100010";
                                WHEN 2 => o_data <= "10100100";
                                WHEN 3 => o_data <= "10101000";
                                WHEN OTHERS => NULL;
                            END CASE;
                        END IF;
                        IF (ram_0(3) <= conv_integer(data) AND (conv_integer(data) -ram_0(3) < 4)) THEN
                            CASE conv_integer(data) - ram_0(3) IS
                                WHEN 0 => o_data <= "10110001";
                                WHEN 1 => o_data <= "10110010";
                                WHEN 2 => o_data <= "10110100";
                                WHEN 3 => o_data <= "10111000";
                                 WHEN OTHERS => NULL;
                            END CASE;
                        END IF;
                        IF (ram_0(4) <= conv_integer(data) AND (conv_integer(data) -ram_0(4) < 4)) THEN
                            CASE conv_integer(data) - ram_0(4) IS
                                WHEN 0 => o_data <= "11000001";
                                WHEN 1 => o_data <= "11000010";
                                WHEN 2 => o_data <= "11000100";
                                WHEN 3 => o_data <= "11001000";
                                WHEN OTHERS => NULL;
                            END CASE;
                        END IF;
                        IF (ram_0(5) <= conv_integer(data) AND (conv_integer(data) -ram_0(5) < 4)) THEN
                            CASE conv_integer(data) - ram_0(5) IS
                                WHEN 0 => o_data <= "11010001";
                                WHEN 1 => o_data <= "11010010";
                                WHEN 2 => o_data <= "11010100";
                                WHEN 3 => o_data <= "11011000";
                                WHEN OTHERS => NULL;
                            END CASE;
                        END IF;
                        IF (ram_0(6) <= conv_integer(data) AND (conv_integer(data) -ram_0(6) < 4)) THEN
                            CASE conv_integer(data) - ram_0(6) IS
                                WHEN 0 => o_data <= "11100001";
                                WHEN 1 => o_data <= "11100010";
                                WHEN 2 => o_data <= "11100100";
                                WHEN 3 => o_data <= "11101000";
                                WHEN OTHERS => NULL;
                            END CASE;
                        END IF;
                        IF (ram_0(7) <= conv_integer(data) AND (conv_integer(data) -ram_0(7) < 4)) THEN
                            CASE conv_integer(data) - ram_0(7) IS
                                WHEN 0 => o_data <= "11110001";
                                WHEN 1 => o_data <= "11110010";
                                WHEN 2 => o_data <= "11110100";
                                WHEN 3 => o_data <= "11111000";
                                WHEN OTHERS => NULL;
                            END CASE;
                        END IF;
                    END IF;
        end case;
    END PROCESS;
END behavioral;