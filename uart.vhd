-- uart.vhd: UART controller - receiving part
-- Author(s): xkniaz00
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY UART_RX IS
	PORT (
		CLK      : IN std_logic;
		RST      : IN std_logic;
		DIN      : IN std_logic;
		DOUT     : OUT std_logic_vector(7 DOWNTO 0);
		DOUT_VLD : OUT std_logic := '0'
		);
	END UART_RX; 
	ARCHITECTURE behavioral OF UART_RX IS
		SIGNAL rd_en    : std_logic;
		SIGNAL m_cnt_en : std_logic;
		SIGNAL out_vld  : std_logic;
		SIGNAL m_cnt    : std_logic_vector(4 DOWNTO 0);
		SIGNAL d_cnt    : std_logic_vector(3 DOWNTO 0);
	BEGIN
		FSM : ENTITY work.UART_FSM(behavioral)
			PORT MAP(
				CLK        => CLK, 
				RST        => RST, 
				DIN        => DIN, 
				D_CNT      => d_cnt, 
				M_CNT    => m_cnt, 
				READ_EN    => rd_en, 
				M_CNT_EN => m_cnt_en, 
				DOUT_VLD      => out_vld
			);

				DOUT_VLD <= out_vld;
				PROCESS (CLK) BEGIN
				IF rising_edge(CLK) THEN
					IF RST = '1' THEN
						m_cnt <= "00000";
						d_cnt <= "0000";
					ELSE
						
						IF m_cnt_en = '1' THEN
							m_cnt <= m_cnt + 1;
						ELSE
							m_cnt <= "00000";
						END IF;
 
 
						IF rd_en = '1' THEN
							IF m_cnt(4) = '1' THEN
 
								CASE(d_cnt) IS
									WHEN "0000" => DOUT(0)  <= DIN;
									WHEN "0001" => DOUT(1)  <= DIN;
									WHEN "0010" => DOUT(2)  <= DIN;
									WHEN "0011" => DOUT(3)  <= DIN;
									WHEN "0100" => DOUT(4)  <= DIN;
									WHEN "0101" => DOUT(5)  <= DIN;
									WHEN "0110" => DOUT(6)  <= DIN;
									WHEN "0111" => DOUT(7) <= DIN;
									WHEN OTHERS => NULL;
								END CASE;

								d_cnt <= d_cnt + 1;
								m_cnt <= "00001";
							END IF;
						END IF;
 
 
 
						IF rd_en = '0' THEN
							d_cnt <= "0000";
						END IF;
					END IF;
				END IF;
	END PROCESS;
END behavioral;