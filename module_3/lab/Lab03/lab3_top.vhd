-- Written by: Brandon Healy
-- Last revised:  9/20/2015
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

-- Entity for lab 3
entity lab3_top is Port (
	clk50 : in std_logic;
	rst_button : in std_logic; -- reset is pushbutton 0, all other buttons are unused in this lab
	slider_switches : in std_logic_vector( 3 downto 0 ); -- lower four slider switches, upper switches are unused in this lab
	seg7 : out std_logic_vector( 6 downto 0 );
	anodes : out std_logic_vector( 3 downto 0 ) );
end lab3_top;

architecture Behavorial of lab3_top is
	-- 1 Hz counter rollover is set to the number of clock cycles in one second so that the rollover occurs 
	-- once per second
	constant one_hz_cnt_val : integer := 50000000;

	-- for simplicity of coding, create an array of standard logic vectors so that the values for each of the seven
	-- segment digits can be stored in a single data type
	type char_val_array is array ( 3 downto 0 ) of std_logic_vector ( 3 downto 0 );

	-- create two arrays for the values of the seven segment digits, one that holds the current value of each seven
	-- segment digit, then a second copy so that as the actual values are being changed, there is a recorded value so 
	-- to allow each of the upper three digits to be loaded with the value of the digit just below it
	signal char_vals : char_val_array;
	signal char_prev_vals : char_val_array;
	signal latch_char_val_pulse : std_logic;
	signal latch_char_val_pulse_cnt : unsigned ( 25 downto 0 );
begin
	
	gen_1Hz_pulse : process ( clk50, rst_button )
	begin
		-- is the reset button is pressed, force the 1 Hz pulse line low and reset the counter for the 1 Hz pulse
		if ( rst_button = '1' ) then
			latch_char_val_pulse <= '0';
			latch_char_val_pulse_cnt <= ( others => '0' );
		-- count the clock cycles and when the number of clock cycles reaches the number of cycles in one second, 
		-- set the 1 Hz pulse line high and reset the counter
		elsif ( rising_edge(clk50) ) then
			latch_char_val_pulse_cnt <= latch_char_val_pulse_cnt + 1;
			if ( latch_char_val_pulse_cnt = one_hz_cnt_val ) then
				latch_char_val_pulse <= '1';
				latch_char_val_pulse_cnt <= ( others => '0' );
			-- anytime the counter has not reached the required value, force the 1 Hz pulse line low
			else
				latch_char_val_pulse <= '0';
			end if;
		end if;
	end process gen_1Hz_pulse;

	-- generate the values for each of the seven segment digits so that the seven segment driver can set each of the
	-- digits on the board appropriately
	gen_char_vals : process ( clk50, rst_button )
	begin
		-- when the reset is pressed, set all characters and the previous characters values to '0'
		if ( rst_button = '1' ) then 
			char_vals(0) <= ( others => '0' );
			char_vals(1) <= ( others => '0' );
			char_vals(2) <= ( others => '0' );
			char_vals(3) <= ( others => '0' );
			char_prev_vals(0) <= ( others => '0' );
			char_prev_vals(1) <= ( others => '0' );
			char_prev_vals(2) <= ( others => '0' );
			char_prev_vals(3) <= ( others => '0' );
		elsif ( rising_edge(clk50) ) then
			-- if the 1 Hz clock pulse is present, get the new value for the least significant digit from the 
			-- slider switches and transition the previous values from the lower digit into the current values for 
			-- each of the upper three digits 
			if ( latch_char_val_pulse = '1' ) then 	
				char_vals(0) <= slider_switches;
				char_vals(1) <= char_prev_vals(0);
				char_vals(2) <= char_prev_vals(1);
				char_vals(3) <= char_prev_vals(2);
			-- if the 1 Hz clock pulse is not present, store the current values in the previous value bins for 
			-- each digit
			else 									
				char_prev_vals(0) <= char_vals(0);
				char_prev_vals(1) <= char_vals(1);
				char_prev_vals(2) <= char_vals(2);
				char_prev_vals(3) <= char_vals(3);
			end if;
		end if;
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

end Behavorial;
