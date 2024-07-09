library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity testbench is

end testbench;

architecture TB of testbench is

component thermostat 
 
	port ( 	current_temp 	: in std_logic_vector(6 downto 0);
			desired_temp 	: in std_logic_vector(6 downto 0);
			display_select 	: in std_logic;
			COOL 			: in std_logic;
			HEAT 			: in std_logic;
			clk 			: in std_logic;
			reset 			: in std_logic;
			FURNACE_HOT 	: in std_logic;
			AC_READY 		: in std_logic;
			
			temp_display 	: out std_logic_vector(6 downto 0);
			A_C_ON 			: out std_logic;
			FURNACE_ON 		: out std_logic;
			FAN_ON 			: out std_logic
		);
			
end component;

signal current_temp, desired_temp 				: std_logic_vector(6 downto 0);
signal temp_display 							: std_logic_vector(6 downto 0);
signal display_select 							: std_logic;
signal COOL, HEAT, A_C_ON, FURNACE_ON, FAN_ON 	: std_logic;
signal clk  									: std_logic := '0';
signal reset									: std_logic;
signal FURNACE_HOT, AC_READY 					: std_logic;

begin

UUT : thermostat port map (current_temp 	=> current_temp,
							desired_temp 	=> desired_temp,
							display_select 	=> display_select,
							temp_display 	=> temp_display, 
							COOL 			=> COOL,
							HEAT 			=> HEAT,
							clk 			=> clk,
							reset 			=> reset,
							AC_READY 		=> AC_READY,
							FAN_ON 			=> FAN_ON,
							A_C_ON 			=> A_C_ON,
							FURNACE_ON 		=> FURNACE_ON,
							FURNACE_HOT 	=> FURNACE_HOT
							);





clk <= not clk after 5ns;

process
begin

report "starting the thermostat simulation";

	reset <= '1';
    wait for 20 ns;
    reset <= '0';
    wait for 20 ns;
		
		
	--Test 
		
	current_temp <= "0000000";
	desired_temp <= "1111111";
	FURNACE_HOT <= '0';
	AC_READY <= '0';
	HEAT <= '0';
	COOL <= '0';
	display_select <= '0';
	wait for 50 ns;
	assert temp_display = desired_temp report "temp_display should have been desired_temp" severity error;

	display_select <= '1';
	wait for 50 ns;
	assert temp_display = current_temp report "temp_display should have been current_temp" severity error;

	HEAT <= '1';
	wait until FURNACE_ON = '1';
	FURNACE_HOT <= '1';
	wait until FAN_ON = '1';
	HEAT  <= '0';
	wait until FURNACE_ON = '0';
	FURNACE_HOT <= '0';
	wait for 50 ns;
	HEAT <= '0';
	wait for 150 ns;
	current_temp <= "1000000";
	desired_temp <= "0100000";
	wait for 50 ns;
	COOL <= '1';
	wait until A_C_ON = '1';
	AC_READY <= '1';
	wait until FAN_ON = '1';
	COOL <= '0';
	AC_READY <= '0';
	wait for 50 ns;
	COOL <= '0';
	wait for 50 ns;
	wait;
end process;
end TB;