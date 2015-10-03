library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.all;

entity lab4_top is Port (
	clk50 				: in std_logic;
	-- Asychronous reset switch
	rst_button 			: in std_logic;
	-- Button to load values from slider switches and use those to define the memory address to load and display on the 
	-- seven segment displays
	load_button 		: in std_logic;
	-- Button to turn off the leading "ad" in the data retrieved from memory when displaying on seven segments
	no_ad_button 		: in std_logic;
	-- Used to define the address for a memory access
	slider_switches 	: in std_logic_vector (7 downto 0);
	seg7 					: out std_logic_vector( 6 downto 0 );
	anodes 				: out std_logic_vector( 3 downto 0 );
	-- Define the RAM lines to interface with memory
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
	-- Flag to indicate that a memory write is happening after a reset
	signal reset_writes_enable 	: std_logic;
	-- Flag to indicate that a memory write is ocurring
	signal read_enable 				: std_logic;
	-- Counter for how many of the 256 values have been written to memory after a reset
	signal reset_write_counter 	: unsigned ( 7 downto 0 );
	-- Cycle counter to keep track of where in a read or write cycle is currently being executed
	signal cycle_counter 			: unsigned ( 2 downto 0 );
	-- Signal for the data read in from a read operation
	signal current_read_data 		: std_logic_vector ( 15 downto 0 );
	signal temp_anodes 				: std_logic_vector ( 3 downto 0 );
begin

	-- These three RAM signals should remain low throughout any asynchronous read / write operation
	RAM_clk <= '0';
	RAM_adv <= '0';
	RAM_cre <= '0';

	mem_process : process ( clk50, rst_button )
	begin
		if ( rst_button = '1' ) then
			-- reset the cycle counter to all zeros
			cycle_counter <= "000";
			-- Pull the chip enable line high to deactivate the chip and pull the associated lines into what should 
			-- their initialization states
			RAM_ce <= '1';
			RAM_we <= '1';
			RAM_oe <= '1';
			RAM_ub <= '1';
			RAM_lb <= '1';
			RAM_addr <= ( others => '0' );
			-- Set the RAM data lines to high impedence in case the memory is driving them
			RAM_data <= ( others => 'Z' );
			-- Initiate a memory write cycle after coming out of reset
			reset_writes_enable <= '1';
			read_enable <= '0';
			reset_write_counter <= ( others => '0' );
			current_read_data <= ( others => '0' );
		elsif ( rising_edge(clk50) ) then
			-- Begin a write block operation
			if ( reset_writes_enable = '1' ) then 
				cycle_counter <= cycle_counter + 1;
				-- on the first clock cycle of a write operation, set the initial states to make sure they are held
				-- long enough per the spec and assert the memory address before really initiating the write operation
				if ( cycle_counter = "000" ) then
					RAM_ce <= '1';
					RAM_we <= '1';
					RAM_ub <= '1';
					RAM_lb <= '1';
					RAM_addr( 23 downto 9 ) <= ( others => '0' );
					RAM_addr( 8 downto 1 ) <= std_logic_vector(reset_write_counter);
					RAM_data <= ( others => 'Z' );
				-- on the second clock cycle set the lines that indicate a write operation is going to take place
				elsif ( cycle_counter = "001" ) then
					RAM_ce <= '0';
					RAM_we <= '0';
					RAM_ub <= '0';
					RAM_lb <= '0';
				-- after waiting long enough, per the spec, set the data lines to write before the next clock cycle where 
				-- they will be latched into memory
				elsif ( cycle_counter = "100" ) then
					RAM_data( 15 downto 8 ) <= x"AD";
					RAM_data( 7 downto 0 ) <= std_logic_vector(reset_write_counter);
				-- on the sixth clock cycle pull the lines back high to latch the data into memory, check the write 
				-- operation counter to see if all 256 values have been written.  If not finished reset the cycle counter
				-- and begin a new write operation, if finished go back into the initialized state and wait for a read
				-- operation or a reset
				elsif ( cycle_counter = "101" ) then
					RAM_ce <= '1';
					RAM_we <= '1';
					RAM_ub <= '1';
					RAM_lb <= '1';
					cycle_counter <= ( others => '0' );
					reset_write_counter <= reset_write_counter + 1;
					if ( reset_write_counter = x"FF" ) then
						reset_writes_enable <= '0';
					end if;	
				-- Things have gone awry with the cycle count, reset the cycle counter to all zeros
				elsif ( cycle_counter > "101" ) then 
					cycle_counter <= ( others => '0' );					
				end if;
			-- If the load button has been pressed, set the read operation flag high to begin a read operation once 
			-- the load button is released
			elsif ( load_button = '1' ) then
				read_enable <= '1';
				cycle_counter <= ( others => '0' );					
			elsif ( read_enable = '1' ) then
				cycle_counter <= cycle_counter + 1;
				-- on the first clock cycle of a read operation assert the initialization state long enough to ensure the 
				-- spec is adhered to and load the address in preparation for the read operation
				if ( cycle_counter = "000" ) then
					RAM_ce <= '1';
					RAM_we <= '1';
					RAM_oe <= '1';
					RAM_ub <= '1';
					RAM_lb <= '1';
					RAM_addr( 23 downto 9 ) <= ( others => '0' );
					RAM_addr( 8 downto 1 ) <= slider_switches;
					RAM_data <= ( others => 'Z' );
				-- indicate that a read operation should begin
				elsif ( cycle_counter = "001" ) then
					RAM_ce <= '0';
					RAM_oe <= '0';
					RAM_ub <= '0';
					RAM_lb <= '0';
				-- after the necessary amount of time, per the spec, has passed pull the relevant lines high to end the 
				-- read operation, read the data lines and disable the read operation until the load button is pressed 
				-- again
				elsif ( cycle_counter = "101" ) then
					RAM_ce <= '1';
					RAM_we <= '1';
					RAM_oe <= '1';
					RAM_ub <= '1';
					RAM_lb <= '1';
					current_read_data <= RAM_data;
					cycle_counter <= ( others => '0' );
					read_enable <= '0';
				-- Things have gone awry, reset the cycle counter to all zeros
				elsif ( cycle_counter > "101" ) then 
					RAM_ce <= '1';
					RAM_we <= '1';
					RAM_oe <= '1';
					RAM_ub <= '1';
					RAM_lb <= '1';
					current_read_data <= ( others => '0' );
					cycle_counter <= ( others => '0' );
					read_enable <= '0';
				end if;
			end if;
		end if;
	end process mem_process;
	
	-- Hook up the seven segment output display driver
	seg7_output_gen : entity seg7_driver port map (
		clk50 => clk50,
		reset => rst_button,
		char0 => current_read_data( 3 downto 0 ),
		char1 => current_read_data( 7 downto 4 ),
		char2 => current_read_data( 11 downto 8 ),
		char3 => current_read_data( 15 downto 12 ),
		anodes => temp_anodes,
		encoded_char => seg7 );

	-- determine which seven segment displays to display based on whether the "no ad" button is pressed
	with no_ad_button select
		anodes <= 	( '1', '1', temp_anodes(1), temp_anodes(0) ) when '1',
					temp_anodes when others;

end Behavioral;
