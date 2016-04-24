--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:50:02 04/23/2016
-- Design Name:   
-- Module Name:   F:/dane/vlsi/pul_projekt/dist_sensor_tb.vhd
-- Project Name:  pul_projekt
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dist_sensor
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
 
ENTITY dist_sensor_tb IS
END dist_sensor_tb;
 
ARCHITECTURE behavior OF dist_sensor_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dist_sensor
    PORT(
         trig : OUT  std_logic;
         echo : IN  std_logic;
         start : IN  std_logic;
         busy : OUT  std_logic;
         dist_cm : OUT  std_logic_vector(3 downto 0);
         dist_dm : OUT  std_logic_vector(3 downto 0);
         dist_m : OUT  std_logic_vector(2 downto 0);
         clk : IN  std_logic;
         reset : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal echo : std_logic := '0';
   signal start : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal trig : std_logic;
   signal busy : std_logic;
   signal dist_cm : std_logic_vector(3 downto 0);
   signal dist_dm : std_logic_vector(3 downto 0);
   signal dist_m : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	constant COUNTER_1CM : integer := 5 - 1;
	constant SIM_DISTANCE_CM: integer := 307;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dist_sensor PORT MAP (
          trig => trig,
          echo => echo,
          start => start,
          busy => busy,
          dist_cm => dist_cm,
          dist_dm => dist_dm,
          dist_m => dist_m,
          clk => clk,
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
		--wait 5 cylces to start measurment
      wait for clk_period*5;
		start <= '1';
		wait for clk_period*10;
		--hc-sr04 response with echo
		echo <= '1';
		--disable start
		start <= '0';
		--wait time aprox corresponding 3cm (while 1cm = 5 clocks ticks -- for simulation only)
		wait for clk_period*SIM_DISTANCE_CM*(COUNTER_1CM+1);
		echo <= '0';
		
		wait for clk_period*5;
		
		
      -- insert stimulus here 

      assert false severity failure;
   end process;

END;
