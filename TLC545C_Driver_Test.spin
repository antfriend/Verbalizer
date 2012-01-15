{{
  TLC545C Driver Test App - runs on the propeller demo board
  
}}

CON
  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000

  Analog_In_Line = 0 'address of the TLC545C analog in pin we are testing
  
  CLK_PIN = 0
  IO_CLOCK = 1
  ADDRESS = 2
  DATA_PIN = 3
  CS_PIN = 4
  
VAR
    LONG the_results
    
OBJ
    adc   :     "TLC545C"

PRI Initialize
  adc.Start(CLK_PIN, IO_CLOCK, ADDRESS, DATA_PIN, CS_PIN)
  'initialize LEDs on Demo board
  DIRA[16..23]~~
  OUTA[16..23]~

  repeat 3
    wait_this_fraction_of_a_second(10)
    OUTA[16..23]~~
    wait_this_fraction_of_a_second(10)
    LEDs_Off
  
PUB MAIN
            
  Initialize

  repeat
    the_results := adc.READ(Analog_In_Line)
    wait_this_fraction_of_a_second(10)
    LEDs_Off
    wait_this_fraction_of_a_second(10)
    case the_results
      0..10 : OUTA[16]~~
      10..19 : OUTA[17]~~
      20..29 : OUTA[18]~~
      30..39 : OUTA[19]~~
      40..49 : OUTA[20]~~
      50..59 : OUTA[21]~~
      60..69 : OUTA[22]~~
      70..79 : OUTA[23]~~
      
      other : OUTA[16..23]~~

PRI LEDs_Off
  OUTA[16..23]~
  
PRI wait_this_fraction_of_a_second(the_decimal)'1/the_decimal, e.g. 1/2, 1/4th, 1/10

  waitcnt(clkfreq / the_decimal + cnt)'if the_decimal=4, then we wait 1/4 sec
    