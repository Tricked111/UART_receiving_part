library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity testbench is
end testbench;

---------------------------------------------------------------
architecture TB of testbench is

    constant baudrate : natural := 9600;
    constant clkrate : natural := baudrate*16;
    constant clk_period : time := 1 sec / clkrate;
    constant baud_period : time := clk_period*16;

    signal clk:         std_logic;
    signal rst: 	    std_logic;
    signal din: 	    std_logic;
    signal dout: 	    std_logic_vector(7 downto 0);
    signal dout_vld: 	std_logic;

    -- Auxilary procedure for byte sending
    procedure send_byte(constant byte_in  : in  std_logic_vector(7 downto 0);
                        signal din  : out std_logic) is
        begin
            din <= '0';
            wait for baud_period;
            for i in 0 to 7 loop
                din <= byte_in(i);
                wait for baud_period;
            end loop;
            din <= '1';
            wait for baud_period;
    end send_byte;

begin
    -- Design under test
    DUT: entity work.UART_RX(behavioral)
    port map (
        CLK 	    => clk,
        RST 	    => rst,
        DIN 	    => din,
        DOUT 	    => dout,
        DOUT_VLD 	=> dout_vld
    );

    -- Clock generator
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Main testbench process
    test: process							
    begin								
		rst <= '1';
        din <= '1';
        wait for clk_period*5;
        rst <= '0';
        wait for clk_period*5;
        
        send_byte("01000111", din);
        wait for baud_period*3;
        send_byte("01010101", din);

        wait;
    end process;

end TB;
-----------------------------------------------------------------