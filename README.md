# Thermostat

This repo contains the VHDL implementation of a thermostat system, including the main code and a testbench for simulation.

## Overview

This project simulates a thermostat controller with heating and cooling functionalities, including : 

- **Temperature Display:** Shows either the current temperature or the desired temperature based on the `display_select` signal.
- **Heating and Cooling Control:** Turns on/off heating and cooling systems based on the difference between current and desired temperatures.
- **Fan Control:** Manages the fan operation in various states of the thermostat.


## Inputs and Outputs

### Inputs
- `clk`: Clock signal
- `reset`: Reset signal
- `current_temp`: Current temperature input (7-bit vector)
- `desired_temp`: Desired temperature input (7-bit vector)
- `display_select`: Selects which temperature to display (`0` for desired, `1` for current)
- `COOL`: Cooling system activation signal
- `HEAT`: Heating system activation signal
- `FURNACE_HOT`: Furnace status signal
- `AC_READY`: AC readiness signal

### Outputs
- `temp_display`: Temperature display output (7-bit vector)
- `A_C_ON`: Air conditioning system on signal
- `FURNACE_ON`: Furnace on signal
- `FAN_ON`: Fan on signal
`
## Processes

### RegisterInputs Process
This process handles the registration of inputs and the state transitions:
 Registers the input values and updates the current state based on the next state.

### DisplaySetting Process
 Updates the temperature display based on the `display_select` signal (`1` for current temperature, `0` for desired temperature).

### StateMachine Process
This process defines the state transitions and the conditions under which they occur:
- **IDLE:** Checks if heating or cooling is required based on the current and desired temperatures.
- **HEATON:** Activates the heating system and transitions to `FURNACENOWHOT` once the furnace is hot.
- **FURNACENOWHOT:** Keeps the furnace on until the desired temperature is reached, then transitions to `FURNACECOOL`.
- **FURNACECOOL:** Cools down the furnace and transitions to `IDLE` once the AC is ready or countdown reaches zero.
- **COOLON:** Activates the cooling system and transitions to `ACNOWREADY` once the AC is ready.
- **ACNOWREADY:** Keeps the AC on until the desired temperature is reached, then transitions to `ACDONE`.
- **ACDONE:** Finalizes the cooling process and transitions to `IDLE` once the AC is not ready or countdown reaches zero.

### OutputAssignment Process
This process assigns values to the output signals based on the current state:
- **FURNACE_ON:** Active during `HEATON` and `FURNACENOWHOT` states.
- **A_C_ON:** Active during `COOLON` and `ACNOWREADY` states.
- **FAN_ON:** Active during `FURNACENOWHOT`, `ACNOWREADY`, `FURNACECOOL`, and `ACDONE` states.

### Countdown Process
This process manages a countdown timer for the cooling and heating transitions; initializes or decrements the countdown timer based on the current state.

## Testbench simulation Process
The main simulation process performs the following steps:

**Initialization**: Resets the system and waits for stabilization.

**Test Cases:**
- Temperature Display Switching: Tests switching between current and desired temperature display based on display_select.
- Heating Process: Simulates the heating process, checks if the furnace and fan turn on/off correctly based on the temperature and HEAT signal.
- Cooling Process: Simulates the cooling process, checks if the AC and fan turn on/off correctly based on the temperature and COOL signal.
- Assertions: Uses assertions to verify that the outputs match the expected values at various points in the simulation.
- 
## Acknowledgements

Xilinx Vivado Design Suite
Scott Dickson on Udemy for code idea.
