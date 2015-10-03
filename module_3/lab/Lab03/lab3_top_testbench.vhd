-- Written by: Brandon Healy
-- Last revised:  9/20/2015
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity lab3_top_tb is 
end lab3_top_tb;

architecture model of lab3_top_tb is
	signal clk50 : std_logic;
	signal rst_button : std_logic;
	signal slider_switches : std_logic_vector ( 3 downto 0 );
	signal seg7 : std_logic_vector ( 6 downto 0 );
	signal anodes : std_logic_vector ( 3 downto 0 );
begin

	gen_clk50 : process
	begin
		clk50 <= '1';
		wait for 10 ns;
		clk50 <= '0';
		wait for 10 ns;
	end process gen_clk50;

	gen_reset : process 
	begin
		rst_button <= '1';
		wait for 100 ns;
		rst_button <= '0';
		wait;
	end process gen_reset;

	lab3_inst : entity lab3_top port map (
		clk50 => clk50,
		rst_button =rst_button> , 
		slider_switches => slider_switches,
		seg7 => seg7,
		anodes => anodes );
end architecture model;
