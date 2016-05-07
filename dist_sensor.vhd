----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:41:57 04/23/2016 
-- Design Name: 
-- Module Name:    dist_sensor - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dist_sensor is
    Port ( trig : out  STD_LOGIC;
           echo : in  STD_LOGIC;
           start : in  STD_LOGIC;
           busy : out  STD_LOGIC;
           dist_cm : out  STD_LOGIC_VECTOR (3 downto 0);
           dist_dm : out  STD_LOGIC_VECTOR (3 downto 0);
           dist_m : out  STD_LOGIC_VECTOR (2 downto 0);
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC);
end dist_sensor;

architecture Behavioral of dist_sensor is

signal counter: std_logic_vector(11 downto 0); -- counter to measure distance
signal counter_trig: std_logic_vector(8 downto 0);  -- counter to measure trigger length
signal counter_cycle: std_logic_vector(23 downto 0);  -- counter to measure cycle 
signal cnt_cm, cnt_dm: std_logic_vector(3 downto 0);  -- distance
signal cnt_m: std_logic_vector(2 downto 0);  -- distance
signal trigger_send: std_logic;  -- boolean is trigger send ?
signal timeout: std_logic; -- no obstacle in range ?
signal cycle_completed: std_logic;  -- boolean is full cycle of measurment completed

type sensor_state is (idle, send_trigger, wait_for_echo, meas_distance); -- state machine
signal state: sensor_state;
signal next_state: sensor_state;

constant COUNTER_1CM : integer := 5-1;--2900-1; 
constant COUNTER_TRIGGER : integer :=  2;--500-1;
--measurment cycle should be over 60ms
constant COUNTER_MEAS_CYCLE : integer := 80-1;--3000000-1; 

begin
	-- state machine initilaizer
	autom_sync: process( clk, reset)
	begin 
		if(reset = '0') then
			state <= idle;
		elsif(clk'event AND clk ='1') then
			state <= next_state; 
		end if;
	end process autom_sync;
	
	-- state machine
	autom: process(state, start, trigger_send, cycle_completed, echo, timeout) 
	begin
		next_state <= state;
		case state is 
			when idle => -- waiting for start command
				if(start = '1') then -- start measurment
					next_state <= send_trigger;
					busy <= '1'; -- set busy flag
				else 
					busy <= '0';
				end if;
			when send_trigger =>
				if(trigger_send = '1') then
					next_state <= wait_for_echo;
				end if;
			when wait_for_echo => -- wait for echo to arrive on hc
				if(echo = '1') then 
					next_state <= meas_distance;
				end if;
			when meas_distance =>
				if(timeout = '1' and cycle_completed = '1') then -- measurment completed 
					busy <= '0'; -- release busy flag
					next_state <= idle; -- go to idle state
				else 
					busy <= '1';
				end if;
		end case;
	end process autom;
	
	--send trigger counter
	send_trig: process(clk, reset, state) 
	begin
		if(reset = '0' OR state /= send_trigger) then -- if reset or not our state clear
			counter_trig <= (others => '0');
			trigger_send <= '0';
		elsif(clk'event and clk = '1') then
			counter_trig <= counter_trig +"01";
			if(counter_trig >= COUNTER_TRIGGER) then  -- 10uS passed, set trigger
				trigger_send <= '1';
			end if;
		end if;
	end process send_trig;
	
	--send trigger counter
	cycle_timer: process(clk, reset, state) 
	begin
		if(reset = '0' OR state = idle) then -- if reset or not our state clear
			counter_cycle <= (others => '0');
			cycle_completed <= '0';
		elsif(clk'event and clk = '1') then
			if(counter_cycle >= COUNTER_MEAS_CYCLE) then  -- 10uS passed, set trigger
				cycle_completed <= '1';
			else
				counter_cycle <= counter_cycle +"01";
			end if;
		end if;
	end process cycle_timer;
	
	--measure distance counter
	meas_dist: process(clk, reset, state)
	begin 
		if(reset = '0' OR state = send_trigger) then -- if reset or not our state clear
			counter <= (others => '0');
			cnt_cm <= (others => '0');
			cnt_dm <= (others => '0');
			cnt_m <= (others => '0');
			timeout <= '0';
		elsif(clk'event and clk = '1') then
			if(state = meas_distance) then
				if(echo = '1') then -- if echo still exists 
					counter <= counter + "01";
				end if;
				if(counter >= COUNTER_1CM) then -- 1cm measured
					cnt_cm <= cnt_cm + "01";
					counter <= (others => '0');
					
					if(cnt_cm >= 9) then -- 1dm measured
						cnt_dm <= cnt_dm + "01";
						cnt_cm <= (others => '0');
					end if;
					
					if(cnt_cm >= 9 and cnt_dm >= 9) then -- 1m mesured
						cnt_m <= cnt_m + "01";
						cnt_dm <= (others => '0');
					end if;
					
				end if;
				
				
				if(cnt_m > 2 OR echo = '0') then -- out of range or echo ended 
					timeout <='1';
				end if;
				
			end if;
		end if;
	end process meas_dist;

	trig <= '1' when state = send_trigger else '0';
	dist_cm <= cnt_cm;
	dist_dm <= cnt_dm;
	dist_m <= cnt_m;


end Behavioral;

