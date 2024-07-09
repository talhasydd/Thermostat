library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


entity thermostat is 
 
	port ( 	clk 			: in std_logic;
			reset 			: in std_logic;
			current_temp 	: in std_logic_vector(6 downto 0);
			desired_temp 	: in std_logic_vector(6 downto 0);
			display_select 	: in std_logic;
			COOL 			: in std_logic;
			HEAT 			: in std_logic;
			FURNACE_HOT 	: in std_logic;
			AC_READY 		: in std_logic;
			
			temp_display 	: out std_logic_vector(6 downto 0);
			A_C_ON 			: out std_logic;
			FURNACE_ON 		: out std_logic;
			FAN_ON 			: out std_logic
		);
			
end thermostat;
	
	
architecture RTL of thermostat is

type STATES is (IDLE, HEATON, FURNACENOWHOT, FURNACECOOL, COOLON, ACNOWREADY, ACDONE );


signal current_temp_reg, desired_temp_reg 		: std_logic_vector(6 downto 0);
signal display_select_reg, COOL_reg, HEAT_reg 	: std_logic;
signal FURNACE_HOT_reg, AC_READY_reg 			: std_logic;
signal CURRENT_STATE, NEXT_STATE 				: STATES;
signal COUNTDOWN 								: integer;


begin
	
RegisterInputs : process(clk, reset)
	begin
		if reset = '1' then
		
			current_temp_reg 	<= (others => '0');
			desired_temp_reg 	<= (others => '0');
			display_select_reg 	<= '0';
			COOL_reg 			<= '0';
			HEAT_reg 			<= '0';
			
			CURRENT_STATE <= IDLE;

			
		elsif clk'event and clk = '1' then
		
			current_temp_reg 	<= current_temp;
			desired_temp_reg 	<= desired_temp;
			display_select_reg 	<= display_select;
			COOL_reg 			<= COOL;
			HEAT_reg 			<= HEAT;
			FURNACE_HOT_reg 	<= FURNACE_HOT;
			AC_READY_reg 		<= AC_READY;
			
			CURRENT_STATE 		<= NEXT_STATE;
			
		end if;
	end process;	


DisplaySetting: process(clk, reset)								-- process to decide which temperature to display
begin

	if reset = '1' then

		temp_display <= (others => '0');
 

	elsif clk'event and clk = '1' then 

		if display_select_reg = '1' then
	
			temp_display <= current_temp_reg;
		else
			temp_display <= desired_temp_reg;
		end if;
		
	end if;
end process;


StateMachine : process (COOL_reg, HEAT_reg, current_temp_reg, desired_temp_reg, CURRENT_STATE, FURNACE_HOT_reg, AC_READY_reg, COUNTDOWN)
begin 
	case NEXT_STATE is
    when IDLE =>
      if (DESIRED_TEMP_REG > CURRENT_TEMP_REG) and HEAT_REG = '1' then
	  
        NEXT_STATE <= HEATON;
		
      elsif (DESIRED_TEMP_REG < CURRENT_TEMP_REG) and COOL_REG = '1' then
        NEXT_STATE <= COOLON;
      else
        NEXT_STATE <= IDLE;
      end if;
	  
    when HEATON =>
      if FURNACE_HOT_REG = '1' then
         NEXT_STATE <= FURNACENOWHOT;
      else
         NEXT_STATE <= HEATON;
      end if;
    when FURNACENOWHOT =>
      if not((DESIRED_TEMP_REG > CURRENT_TEMP_REG) and HEAT_REG = '1') then
         NEXT_STATE <= FURNACECOOL;
      else
         NEXT_STATE <= FURNACENOWHOT;
		 
      end if;
    when FURNACECOOL =>
      if AC_READY_REG = '0' and COUNTDOWN = 0 then
        NEXT_STATE <= IDLE;
      else
        NEXT_STATE <= FURNACECOOL;
      end if;
    when COOLON =>
      if AC_READY_REG = '1' then
        NEXT_STATE <= ACNOWREADY;
      else
        NEXT_STATE <= COOLON;
      end if;
     when ACNOWREADY =>
      if not((DESIRED_TEMP_REG < CURRENT_TEMP_REG) and COOL_REG = '1') then
        NEXT_STATE <= ACDONE;
      else
        NEXT_STATE <= ACNOWREADY;
      end if;
     when ACDONE =>
       if AC_READY_REG = '0' and COUNTDOWN = 0 then
         NEXT_STATE <= IDLE;
       else
         NEXT_STATE <= ACDONE;
       end if;
     when others => 
       NEXT_STATE <= IDLE;
   end case;
end process;	
		
process(clk)																-- process to assign outputs
begin
  if clk'event and clk= '1' then
    if NEXT_STATE = HEATON or NEXT_STATE = FURNACENOWHOT then
      FURNACE_ON <= '1';
    else
      FURNACE_ON <= '0';
    end if;
    if NEXT_STATE = COOLON or NEXT_STATE = ACNOWREADY then
      A_C_ON <= '1';
    else
      A_C_ON <= '0';
    end if;
    if NEXT_STATE = FURNACENOWHOT or NEXT_STATE = ACNOWREADY or 
       NEXT_STATE = FURNACECOOL   or NEXT_STATE = ACDONE then
         FAN_ON <= '1';
     else
         FAN_ON <= '0';
    end if;
	
  end if;
  
end process;


process (clk, reset)
begin

	if reset = '1' then
	
		COUNTDOWN <= 0;
		
	elsif clk'event and clk = '1' then
	
		if NEXT_STATE = FURNACENOWHOT then
		COUNTDOWN <= 10;
	
		elsif NEXT_STATE = ACNOWREADY then
		COUNTDOWN <= 20;
		
		elsif 	NEXT_STATE = FURNACECOOL or
				NEXT_STATE = ACDONE then
		
		COUNTDOWN <= COUNTDOWN - 1;
		
		end if;
	end if;	
		
	
end process;

end RTL; 