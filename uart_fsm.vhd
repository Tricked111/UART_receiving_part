-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): xkniaz00
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY UART_FSM IS
	PORT (
		CLK        : IN std_logic;
		RST        : IN std_logic;
		DIN        : IN std_logic;
		D_CNT      : IN std_logic_vector(3 DOWNTO 0);
		M_CNT    : IN std_logic_vector(4 DOWNTO 0);
		READ_EN    : OUT std_logic;
		M_CNT_EN : OUT std_logic;
		DOUT_VLD      : OUT std_logic
	);
END ENTITY UART_FSM;
ARCHITECTURE behavioral OF UART_FSM IS
	TYPE state IS (WAIT_START_BIT, WAIT_ZERO_BIT, READ_DATA, WAIT_STOP_BIT, VLD);
	SIGNAL current_state : state := WAIT_START_BIT;
BEGIN
	READ_EN    <= '1' WHEN current_state = READ_DATA ELSE '0';
	
   DOUT_VLD      <= '1' WHEN current_state = VLD ELSE '0';
	
   M_CNT_EN <= '0' WHEN current_state = VLD OR current_state = WAIT_START_BIT ELSE '1';
	
   PROCESS (CLK) BEGIN
	
   
   IF rising_edge(CLK) THEN
		IF RST = '1' THEN
			current_state <= WAIT_START_BIT;
		ELSE
			CASE current_state IS
				WHEN WAIT_START_BIT => 
					IF DIN = '0' THEN
						current_state <= WAIT_ZERO_BIT;
					END IF;
				WHEN WAIT_ZERO_BIT => 
					IF M_CNT = "10110" THEN
						current_state <= READ_DATA;
					END IF;
				WHEN READ_DATA => 
					IF D_CNT = "1000" THEN
						current_state <= WAIT_STOP_BIT;
					END IF;
				WHEN WAIT_STOP_BIT => 
					IF M_CNT = "10000" THEN
						current_state <= VLD;
					END IF; 
				WHEN VLD => current_state <= WAIT_START_BIT;
			END CASE;
 
		END IF;
	END IF;
END PROCESS;
END behavioral;