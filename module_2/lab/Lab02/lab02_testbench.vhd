--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:23:03 09/13/2015
-- Design Name:   
-- Module Name:   C:/Users/brandon/Dropbox/vhdl_design/module_2/lab/Lab02/lab02_testbench.vhd
-- Project Name:  Lab02
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: lab02_top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY lab02_testbench IS
END lab02_testbench;
 
ARCHITECTURE behavior OF lab02_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT lab02_top
    PORT(
         slider_switches : IN  std_logic_vector(7 downto 0);
         push_buttons : IN  std_logic_vector(1 downto 0);
         seg7 : OUT  std_logic_vector(6 downto 0);
         anodes : OUT  std_logic_vector(3 downto 0);
         leds : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal slider_switches : std_logic_vector(7 downto 0) := (others => '0');
   signal push_buttons : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal seg7 : std_logic_vector(6 downto 0);
   signal anodes : std_logic_vector(3 downto 0);
   signal leds : std_logic_vector(7 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant PERIOD : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: lab02_top PORT MAP (
          slider_switches => slider_switches,
          push_buttons => push_buttons,
          seg7 => seg7,
          anodes => anodes,
          leds => leds
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for PERIOD;
		push_buttons <= "00";
		slider_switches <= "00000000";
		
		wait for 2*PERIOD;
		slider_switches <= "00000001";
		
		wait for 3*PERIOD;
		slider_switches <= "00000010";
		
      wait for 4*PERIOD;
   end process;

END;
