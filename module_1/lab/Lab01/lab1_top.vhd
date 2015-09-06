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
	signal seg7_digit : std_logic_vector( 3 downto 0 );
begin

	leds <= slider_switches;

	with push_buttons select
		anodes <= 	"1110" when "00",
						"1101" when "01",
						"1100" when "10",
						"0000" when others;

	with push_buttons select
		seg7_digit <=	"0000" when "11",
							slider_switches( 3 downto 0) when others;

	seg7_dec : entity seg7_hex port map (
		digit => seg7_digit,
		seg7 => seg7);

end Structure;
