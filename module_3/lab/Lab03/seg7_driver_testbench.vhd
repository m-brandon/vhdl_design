-- Written by: Brandon Healy
-- Last revised:  9/20/2015
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity seg7_driver_tb is 
end seg7_driver_tb;

architecture model of seg7_driver_tb is
	type char_val_array is array ( 3 downto 0 ) of std_logic_vector ( 3 downto 0 );

	signal clk50 : std_logic;
	signal rst_button : std_logic;
	signal char_vals : char_val_array;

	signal anodes : std_logic_vector ( 3 downto 0 );
	signal seg7 : std_logic_vector ( 6 downto 0 );
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

	gen_char_vals : process
	begin

		char_vals(0) <= "0001";
		char_vals(1) <= "0010";
		char_vals(2) <= "0011";
		char_vals(3) <= "0100";
		
		wait for 1000 ns;
		
		char_vals(0) <= "0101";
		char_vals(1) <= "0110";
		char_vals(2) <= "0111";
		char_vals(3) <= "1000";
		
		wait;
	
	end process gen_char_vals;

	seg7_output_gen : entity seg7_driver port map (
		clk50 => clk50,
		reset => rst_button,
		char0 => char_vals(0),
		char1 => char_vals(1),
		char2 => char_vals(2),
		char3 => char_vals(3),
		anodes => anodes,
		encoded_char => seg7 );



end architecture model;
