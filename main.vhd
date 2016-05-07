----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:08:05 05/07/2016 
-- Design Name: 
-- Module Name:    main - Behavioral 
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

entity main is
    Port ( 
			  clk    : in  std_logic;
			  lcd_e  : out std_logic;
			  lcd_rs : out std_logic; 
			  lcd_rw : out std_logic;
			  lcd_db : out std_logic_vector(7 downto 4);
			  trig : out  STD_LOGIC;
           echo : in  STD_LOGIC;
           reset : in  STD_LOGIC);
end main;

architecture Behavioral of main is

 -- lcd 
  signal line1 : std_logic_vector(127 downto 0);
  signal line2 : std_logic_vector(127 downto 0);
  -- component generics
  constant CLK_PERIOD_NS : positive := 20;  -- 50 Mhz
  -- component ports
  signal rst          : std_logic;
-- my
type main_state is (init, start_measurment, wait_on_busy, set_display); -- state machine
signal state: main_state;
signal next_state: main_state;

	COMPONENT dist_sensor
	PORT(
		echo : IN std_logic;
		start : IN std_logic;
		clk : IN std_logic;
		reset : IN std_logic;          
		trig : OUT std_logic;
		busy : OUT std_logic;
		dist_cm : OUT std_logic_vector(3 downto 0);
		dist_dm : OUT std_logic_vector(3 downto 0);
		dist_m : OUT std_logic_vector(2 downto 0)
		);
	END COMPONENT;
	
signal start_dist: std_logic;
signal busy_dist: std_logic;
signal dist_cm : std_logic_vector(3 downto 0);
signal dist_dm : std_logic_vector(3 downto 0);
signal dist_m : std_logic_vector(2 downto 0);

signal dist_cm_to_disp : std_logic_vector(3 downto 0);
signal dist_dm_to_disp : std_logic_vector(3 downto 0);
signal dist_m_to_disp : std_logic_vector(2 downto 0);

begin
	  -- component instantiation
  DUT : entity work.lcd16x2_ctrl
    generic map (
      CLK_PERIOD_NS => CLK_PERIOD_NS)
    port map (
      clk          => clk,
      rst          => rst,
      lcd_e        => lcd_e,
      lcd_rs       => lcd_rs,
      lcd_rw       => lcd_rw,
      lcd_db       => lcd_db,
      line1_buffer => line1,
      line2_buffer => line2);
	
	Inst_dist_sensor: dist_sensor PORT MAP(
		trig => trig,
		echo => echo,
		start => start_dist,
		busy => busy_dist,
		dist_cm => dist_cm,
		dist_dm => dist_dm,
		dist_m => dist_m,
		clk => clk,
		reset => reset
	);
	
  line1(127 downto 120) <= X"20"; 
  line1(119 downto 112) <= "00110000" or "00000"&dist_m_to_disp;  -- 0
  line1(111 downto 104) <= "00110000" or "0000"&dist_dm_to_disp;  -- 0
  line1(103 downto 96)  <= "00110000" or "0000"&dist_cm_to_disp;  -- 0
  line1(95 downto 88)   <= x"63";  -- c
  line1(87 downto 80)   <= X"6d";  -- m
  line1(79 downto 72)   <= X"20";  -- 
  line1(71 downto 64)   <= X"20";  -- 
  line1(63 downto 56)   <= X"20";  --
  line1(55 downto 48)   <= X"20";  --
  line1(47 downto 40)   <= X"20";  
  line1(39 downto 32)   <= x"50";  -- P
  line1(31 downto 24)   <= x"55";  -- U 
  line1(23 downto 16)   <= x"4C";  -- L
  line1(15 downto 8)    <= X"20";
  line1(7 downto 0)     <= X"20";

  line2(127 downto 120) <= X"20";  --  
  line2(119 downto 112) <= X"20";  -- 
  line2(111 downto 104) <= X"20";  -- 
  line2(103 downto 96)  <= X"20";  -- 
  line2(95 downto 88)   <= X"20";  -- 
  line2(87 downto 80)   <= X"20";  -- 
  line2(79 downto 72)   <= X"20";  -- 
  line2(71 downto 64)   <= X"20";  -- 
  line2(63 downto 56)   <= X"20";  -- 
  line2(55 downto 48)   <= X"20";  -- 
  line2(47 downto 40)   <= X"20";  -- 
  line2(39 downto 32)   <= X"20";  -- 
  line2(31 downto 24)   <= X"20";  -- 
  line2(23 downto 16)   <= X"20";  -- 
  line2(15 downto 8)    <= X"20";  -- 
  line2(7 downto 0)     <= X"20";  -- 
	
	-- state machine initilaizer
	autom_sync: process( clk, reset)
	begin 
		if(reset = '0') then
			state <= init;
		elsif(clk'event AND clk ='1') then
			state <= next_state; 
		end if;
	end process autom_sync;
	
		-- state machine
	autom: process(state, busy_dist) 
	begin
		next_state <= state;
		case state is 
			when init => -- wait for lcd to initialize
				dist_cm_to_disp <= (others=>'0');
				dist_dm_to_disp <= (others=>'0');
				dist_m_to_disp <= (others=>'0');
				next_state <= start_measurment;
			when start_measurment =>
				start_dist <= '1';
				if(busy_dist = '1') then
					next_state <= wait_on_busy;
				end if;
			when wait_on_busy =>
				if(busy_dist = '0') then -- measurment completed 
					start_dist <= '0';
					next_state <= set_display;
				end if;
			when set_display => -- show value
				dist_cm_to_disp <= dist_cm;
				dist_dm_to_disp <= dist_dm;
				dist_m_to_disp <= dist_m;
				next_state <= start_measurment;
		end case;
	end process autom;

	rst <= not reset;

end Behavioral;

