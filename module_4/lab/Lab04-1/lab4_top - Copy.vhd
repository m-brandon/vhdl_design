library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.all;

entity lab4_top is Port (
	clk50 				: in std_logic;
	rst_button 			: in std_logic;
	load_button 		: in std_logic;
	no_ad_button 		: in std_logic;
	slider_switches 	: in std_logic_vector (7 downto 0);
	seg7 					: out std_logic_vector( 6 downto 0 );
	anodes 				: out std_logic_vector( 3 downto 0 );

	reset_writes_enable_debug 	: out std_logic;
	write_cycle_counter_debug : out std_logic_vector ( 2 downto 0 );
	
	RAM_oe				: out std_logic;
	RAM_we				: out std_logic;
	RAM_ce 				: out std_logic;
	RAM_adv				: out std_logic;
	RAM_clk				: out std_logic;
	RAM_cre				: out std_logic;
	RAM_lb				: out std_logic;
	RAM_ub				: out std_logic;
	RAM_addr 			: out std_logic_vector ( 23 downto 1 );
	RAM_data 			: inout std_logic_vector ( 15 downto 0 ) );
end lab4_top;

architecture Behavioral of lab4_top is
	signal reset_writes_enable 	: std_logic;
	signal reset_read_enable 		: std_logic;
	signal reset_write_counter 	: unsigned ( 7 downto 0 );
	signal write_cycle_counter 	: unsigned ( 2 downto 0 );
	signal read_cycle_counter 		: unsigned ( 2 downto 0 );
	signal current_read_data 		: std_logic_vector ( 15 downto 0 );
	signal temp_anodes 				: std_logic_vector ( 3 downto 0 );
begin

	RAM_clk <= '0';
	RAM_adv <= '0';
	RAM_cre <= '0';

	reset_writes_enable_debug <= reset_writes_enable;
	write_cycle_counter_debug <= std_logic_vector(write_cycle_counter);

	write_cycle : process ( clk50, rst_button )
	begin
		if ( rst_button = '1' ) then
			-- set the reset write enable to '1' to indicate that the memory addresses should start being written
			reset_writes_enable <= '1';
			reset_read_enable <= '0';
			-- set the reset write counter that counts how many total write cycles have occurred to zero
			reset_write_counter <= ( others => '0' );
			-- reset the cycle counter to zero to start the cycle from the beginning
			write_cycle_counter <= "000";
			-- reset the current character value to all zeros, but immediately after a write cycle, a read cycle 
			-- will be kicked off
			current_read_data <= ( others => '0' );
			-- tri-state the data lines just to be sure
			RAM_data <= ( others => 'Z' );
		elsif  ( rising_edge(clk50) ) then
			if ( reset_writes_enable = '1' ) then
				if ( write_cycle_counter = "000" ) then
					RAM_ce <= '1';
					RAM_we <= '1';
					RAM_ub <= '1';
					RAM_lb <= '1';
					RAM_addr <= ( others => '0' );
					RAM_data <= ( others => 'Z' );
				elsif ( write_cycle_counter = "001" ) then
					RAM_ce <= '0';
					RAM_we <= '0';
					RAM_ub <= '0';
					RAM_lb <= '0';
					RAM_addr( 23 downto 9 ) <= ( others => '0' );
					RAM_addr( 8 downto 1 ) <= std_logic_vector(reset_write_counter);
				elsif ( write_cycle_counter = "100" ) then
					RAM_data( 15 downto 8 ) <= x"AD";
					RAM_data( 7 downto 0 ) <= std_logic_vector(reset_write_counter);
				elsif ( write_cycle_counter = "101" ) then
					RAM_ce <= '1';
					RAM_we <= '1';
					RAM_ub <= '1';
					RAM_lb <= '1';
					write_cycle_counter <= ( others => '0' );
					if ( reset_write_counter < x"FF" ) then
						reset_write_counter <= reset_write_counter + 1;
					else
						-- stop the write process from doing any more writes by lowering the reset_writes_enable line
						reset_writes_enable <= '0';
						-- immediately kick off a read cycle so that the current value of the switches will be shown
						-- on the seven segment displays
						read_cycle_counter <= ( others => '0' );
						reset_read_enable <= '1';
					end if;
				end if;
				write_cycle_counter <= write_cycle_counter + 1;
			end if;
		end if; 
	end process write_cycle;

	read_cycle : process ( clk50, load_button )
	begin
		if ( load_button = '1' ) then
			read_cycle_counter <= ( others => '0' );
			reset_read_enable <= '1';
		elsif ( rising_edge(clk50) ) then
			if ( reset_writes_enable = '0' ) then 
				-- tri-state the data lines to stop them from being driven whenever the reset_writes enable is low
				RAM_data <= ( others => 'Z' );
				if ( reset_read_enable = '1' ) then
					if ( read_cycle_counter = "000" ) then
						RAM_ce <= '1';
						RAM_we <= '1';
						RAM_oe <= '1';
						RAM_ub <= '1';
						RAM_lb <= '1';
						RAM_addr <= ( others => '0' );
						RAM_data <= ( others => 'Z' );
					elsif ( read_cycle_counter = "001" ) then
						RAM_ce <= '0';
						RAM_oe <= '0';
						RAM_ub <= '0';
						RAM_lb <= '0';
						RAM_addr( 23 downto 9 ) <= ( others => '0' );
						RAM_addr( 8 downto 1 ) <= std_logic_vector(reset_write_counter);
					elsif ( read_cycle_counter = "101" ) then
						RAM_ce <= '1';
						RAM_we <= '1';
						RAM_ub <= '1';
						RAM_lb <= '1';
						current_read_data <= RAM_data;
						read_cycle_counter <= ( others => '0' );
						reset_read_enable <= '0';
					end if;
					read_cycle_counter <= read_cycle_counter + 1;
				end if;
			end if;
		end if;
	end process read_cycle;

	seg7_output_gen : entity seg7_driver port map (
		clk50 => clk50,
		reset => rst_button,
		char0 => current_read_data( 3 downto 0 ),
		char1 => current_read_data( 7 downto 4 ),
		char2 => current_read_data( 11 downto 8 ),
		char3 => current_read_data( 15 downto 12 ),
		anodes => temp_anodes,
		encoded_char => seg7 );

	with no_ad_button select
		anodes <= 	( '1', '1', temp_anodes(1), temp_anodes(0) ) when '1',
					temp_anodes when others;

end Behavioral;
