library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity seg7_hex is Port (
 digit : in STD_LOGIC_VECTOR (3 downto 0);
 seg7 : out STD_LOGIC_VECTOR (6 downto 0) );
end seg7_hex;

architecture Behavioral of seg7_hex is
begin
	-- Map the input digit to the correct configuration of segments in the 
	-- seven segment LED.  LED segments are active low.
	sev_seg_decode : process ( digit )
	begin
		if ( digit = x"0" ) then
			seg7 <= "1000000";
		elsif ( digit = x"1" ) then
			seg7 <= "1111001";
		elsif ( digit = x"2" ) then
			seg7 <= "0100100";
		elsif ( digit = x"3" ) then
			seg7 <= "0110000";
		elsif ( digit = x"4" ) then
			seg7 <= "0011001";
		elsif ( digit = x"5" ) then
			seg7 <= "0010010";
		elsif ( digit = x"6" ) then
			seg7 <= "0000010";
		elsif ( digit = x"7" ) then
			seg7 <= "1111000";
		elsif ( digit = x"8" ) then
			seg7 <= "0000000";
		elsif ( digit = x"9" ) then
			seg7 <= "0010000";
		elsif ( digit = x"A" ) then
			seg7 <= "0001000";
		elsif ( digit = x"B" ) then
			seg7 <= "0000011";
		elsif ( digit = x"C" ) then
			seg7 <= "1000110";
		elsif ( digit = x"D" ) then
			seg7 <= "0100001";
		elsif ( digit = x"E" ) then
			seg7 <= "0000110";
		else 
			seg7 <= "0001110";
		end if;
	end process sev_seg_decode;
end Behavioral;
