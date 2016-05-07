--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:22:26 05/07/2016
-- Design Name:   
-- Module Name:   F:/dane/vlsi/pul_projekt/main_tb.vhd
-- Project Name:  pul_projekt
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: main
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
 
ENTITY main_tb IS
END main_tb;
 
ARCHITECTURE behavior OF main_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT main
    PORT(
         clk : IN  std_logic;
         lcd_e : OUT  std_logic;
         lcd_rs : OUT  std_logic;
         lcd_rw : OUT  std_logic;
         lcd_db : OUT  std_logic_vector(7 downto 4);
         trig : OUT  std_logic;
         echo : IN  std_logic;
         reset : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal echo : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal lcd_e : std_logic;
   signal lcd_rs : std_logic;
   signal lcd_rw : std_logic;
   signal lcd_db : std_logic_vector(7 downto 4);
   signal trig : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	constant COUNTER_1CM : integer := 5 - 1;
	constant SIM_DISTANCE_CM: integer := 8;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: main PORT MAP (
          clk => clk,
          lcd_e => lcd_e,
          lcd_rs => lcd_rs,
          lcd_rw => lcd_rw,
          lcd_db => lcd_db,
          trig => trig,
          echo => echo,
          reset => reset
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset <= '0';
      wait for 100 ns;	
		reset <= '1';
		--wait for trigger
		wait on trig;
		--hc-sr04 response with echo
		wait for clk_period*10;
		echo <= '1';
		
		--wait time aprox corresponding 3cm (while 1cm = 5 clocks ticks -- for simulation only)
		wait for clk_period*SIM_DISTANCE_CM*(COUNTER_1CM+1);
		echo <= '0';
		
		--wait for trigger
		wait on trig;
		--hc-sr04 response with echo
		wait for clk_period*10;
		echo <= '1';
		
		--wait time aprox corresponding 3cm (while 1cm = 5 clocks ticks -- for simulation only)
		wait for clk_period*SIM_DISTANCE_CM*(COUNTER_1CM+1);
		echo <= '0';
		--wait for trigger and end
		wait on trig;
		
		
		
      -- insert stimulus here 

      assert false severity failure;
   end process;

END;
