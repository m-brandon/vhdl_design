library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.all;

entity lab04_tb is
end lab04_tb;

architecture Behavioral of lab04_tb is

	signal pushButtons	  	: std_logic_vector(3 downto 0) := "0000";
   signal clk_50         	: std_logic := '0';           
   signal sliderSwitches 	: std_logic_vector(7 downto 0);
   signal seg7           	: std_logic_vector(6 downto 0);
	signal an             	: std_logic_vector(3 downto 0);

	signal RAM_Adr 			: std_logic_vector (23 downto 1); 			-- Address
	signal RAM_OEb				: std_logic;								-- Output Enable
	signal RAM_WEb				: std_logic;								-- Write Enable
	signal RAMAdv   			: std_logic; 								-- Address Valid
	signal RAMClk   			: std_logic; 								-- RAM clock
	signal RAMCre   			: std_logic; 								-- 
	signal RAM_CEb				: std_logic; 								-- Chep Enable
	signal RAM_LB				: std_logic; 								-- Lower Byte
	signal RAM_UB				: std_logic; 								-- Upper Byte
	signal RAM_data			: std_logic_vector (15 downto 0);			-- Bidirectional data
	
begin 
    
	clk_50 <= not clk_50 after 10 ns;
   
	-- Asynchronous reset:
	process
	begin
	
		-- Reset
		pushButtons(3 downto 0) <= "0000"; wait for 0 ns;
		pushButtons(3 downto 0) <= "0001"; wait for 200 ns;
		pushButtons(3 downto 0) <= "0000";
		
		-- Make sure enough time has ellapsed to load data values into first 256 locations of SRAM
		wait for 240000 ns;
		sliderSwitches <= "00000000";
		
		-- read address 0x00
		sliderSwitches <= "00000000"; 
		pushButtons(3 downto 0) <= "0010"; wait for 504 ns;
		pushButtons(3 downto 0) <= "0000"; wait for 1000 ns;
	
		-- read address 0x01
		sliderSwitches <= "00000001";
		pushButtons(3 downto 0) <= "0010"; wait for 504 ns;
		pushButtons(3 downto 0) <= "0000"; wait for 1000 ns;
		
		-- read address 0x04
		sliderSwitches <= "00000100"; 
		pushButtons(3 downto 0) <= "0010"; wait for 504 ns;
		pushButtons(3 downto 0) <= "0000"; wait for 1000 ns;
		
		-- read address 0xFE
		sliderSwitches <= "11111110"; 
		pushButtons(3 downto 0) <= "0010"; wait for 504 ns;
		pushButtons(3 downto 0) <= "0000"; wait for 1000 ns;
		
		-- read address 0xFF
		sliderSwitches <= "11111111"; 
		pushButtons(3 downto 0) <= "0010"; wait for 504 ns;
		pushButtons(3 downto 0) <= "0000"; wait;

	end process;
	
	-- Instantiate the top level design
	lab4_top_0: entity lab4_top port map(
		clk50 => clk_50, 
		rst_button => pushButtons(0), 
		load_button => pushButtons(1),
		no_ad_button => pushButtons(2),  
		slider_switches => sliderSwitches, 
		seg7 => seg7, 
		anodes => an, 		
		RAM_addr => RAM_Adr,
		RAM_oe => RAM_OEb,
		RAM_we => RAM_WEb,
		RAM_adv => RAMAdv,
		RAM_clk => RAMClk,
		RAM_cre => RAMCre,
		RAM_ce => RAM_CEb,
		RAM_lb => RAM_LB,
		RAM_ub => RAM_UB,
		RAM_data => RAM_data);
	
	-- Instantiate the SRAM. For ModelSim simulation only. Do not synthesize
	sram_0: entity sram_d port map(
		RAM_CEb,
		RAM_OEb,
		RAM_WEb,
		RAM_Adr(8 downto 1),
		RAM_data,
		'1');

end architecture;
