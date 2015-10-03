-- Written by: Brandon Healy
-- Last revised:  9/20/2015
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity seg7_driver is Port (
	clk50 : in std_logic; -- system clock, 50 MHz on the dev board
	reset : in std_logic;
	char0 : in std_logic_vector ( 3 downto 0 );
	char1 : in std_logic_vector ( 3 downto 0 );
	char2 : in std_logic_vector ( 3 downto 0 );
	char3 : in std_logic_vector ( 3 downto 0 );
	anodes : out std_logic_vector ( 3 downto 0 );
	encoded_char : out std_logic_vector ( 6 downto 0 ) );
end seg7_driver;

architecture Behavorial of seg7_driver is
	constant refresh_pulse_cnt_val : integer := 50000; -- clock rate of the system clock divided by 1000
--	constant refresh_pulse_cnt_val : integer := 5; -- lower value for testbench generation
	
	signal curr_anode : std_logic_vector ( 3 downto 0 );
	signal curr_char : std_logic_vector ( 3 downto 0 );
	signal refresh_pulse : std_logic;
	signal refresh_pulse_cnt : unsigned ( 15 downto 0 );
begin

	-- generate the digit refresh clock signal at a rate of 1 kHz by counting clock cycles and setting the counter's 
	-- rollover to a value equal to the clock rate divided by 1000 so that the rollover (and the pulse) occur 
	-- 1000 times a second
	refresh_pulse_gen : process ( clk50, reset )
	begin
		-- if there's a reset force the pulse line low and reset the counter
		if ( reset = '1' ) then
			refresh_pulse <= '0';
			refresh_pulse_cnt <= ( others => '0' );
		elsif ( rising_edge(clk50) ) then
			refresh_pulse_cnt <= refresh_pulse_cnt + 1;
			-- when rollover is reached force the pulse line high for one clock cycle and reset the counter
			if ( refresh_pulse_cnt = refresh_pulse_cnt_val ) then
				refresh_pulse <= '1';
				refresh_pulse_cnt <= ( others => '0' );
			else
				refresh_pulse <= '0';
			end if;
		end if;
	end process refresh_pulse_gen;

	-- every time a refresh pulse is generated, change the seven segment display that is being used
	calc_anode : process ( clk50, reset )
	begin
		-- when reset is pushed, force the display to the first seven segment digit
		if (reset = '1') then
			curr_anode <= "1110";
		elsif ( rising_edge(clk50) ) then
			if ( refresh_pulse = '1' ) then
				case curr_anode is
					when "1110" =>
						curr_anode <= "1101";
					when "1101" =>
						curr_anode <= "1011";
					when "1011" =>
						curr_anode <= "0111";
					when others =>
						curr_anode <= "1110";
				end case;
			end if; 
		end if;
	end process calc_anode;
	anodes <= curr_anode;

	-- decide which digit to display based on which seven segment digit is currently being displayed
	char_multiplex : process ( curr_anode, char0, char1, char2, char3 )
	begin
		case curr_anode is
			when "1110" =>
				curr_char <= char0;
			when "1101" =>
				curr_char <= char1;
			when "1011" =>
				curr_char <= char2;
			when others =>
				curr_char <= char3;
		end case;
	end process char_multiplex;

	seg7_dec : entity seg7_hex port map (
		digit => curr_char,
		seg7 => encoded_char );

end Behavorial;
