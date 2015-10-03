-- Written by: Brandon Healy
-- Last revised:  9/14/2015
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity lab1_top is
Port (
	slider_switches : in std_logic_vector( 7 downto 0 );
	push_buttons : in std_logic_vector( 1 downto 0 );
	seg7 : out std_logic_vector( 6 downto 0 );
	anodes : out std_logic_vector( 3 downto 0 );
	leds : out std_logic_vector( 7 downto 0 ) );
end lab1_top;

architecture Structure of lab1_top is
	-- Intermediate signal used to store the value of the digit to be sent to 
	-- the seven segment decoder.  This is not just slider_switches( 3 downto 0)
	-- because the digit could be zero if both pushbuttons are pressed.
	signal seg7_digit : std_logic_vector( 3 downto 0 );
begin

	-- Map active leds to the position of the corresponding slider switches
	leds <= slider_switches;

	-- Anodes are active low and control which of the seven segement displays 
	-- are turned on, want the following behavior mapped to push button
	-- switches:
	--		Push buttons not pressed -> only the rightmost seven segment 
	--			display lit with value of switches 0 to 3
	--		Rightmost push button pressed -> only the seven segment display second
	--			from the right lit with value of switches 0 to 3
	--		Second from right pushbutton pressed -> rightmost and second from the 
	--			right seven segment display lit with value of switches 0 to 3
	-- 		Rightmost and second from right pushbutton pressed -> all seven 
	--			segment displays lit with "0"
	with push_buttons select
		anodes <= 	"1110" when "00",
						"1101" when "01",
						"1100" when "10",
						"0000" when others;

	-- The value passed into the seven segment decoder module should be zero 
	-- when both push buttons are pressed and the value of switches 0 to 3 when
	-- when any other combination of pushbuttons are pressed.  Use the 
	-- intermediate signal seg7_digit to store the value passed into the seven 
	-- segment decoder.
	with push_buttons select
		seg7_digit <=	"0000" when "11",
							slider_switches( 3 downto 0) when others;

	-- Instantiate the seven segment decoder
	seg7_dec : entity seg7_hex port map (
		digit => seg7_digit,
		seg7 => seg7);

end Structure;
