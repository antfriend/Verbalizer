{{
  TLC545C Driver Test App - runs on the propeller demo board
  
}}

CON
  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000

  Analog_In_Line = 18 '[1-18] is the address of the TLC545C analog in pin we are testing
  
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
    wait_this_fraction_of_a_second(1000)
    OUTA[16..23]~~
    wait_this_fraction_of_a_second(10)
    LEDs_Off
  
PUB Main
            
  Initialize

  repeat
    the_results := adc.READ(Analog_In_Line)
    wait_this_fraction_of_a_second(100)
    LEDs_Off
    wait_this_fraction_of_a_second(100)
    case the_results
       0, 8,16..44,240,248 : OUTA[16]~~
       1, 9,45..72,241,249 : OUTA[17]~~
       2,10,73..100,242,250 : OUTA[18]~~
       3,11,101..129,243,251 : OUTA[19]~~
       4,12,130..158,244,252 : OUTA[20]~~
       5,13,159..186,245,253 : OUTA[21]~~
       6,14,187..214,246,254 : OUTA[22]~~
       7,15,215..239,247,255 : OUTA[23]~~ 
       other : OUTA[16..23]~~

PRI LEDs_Off
  OUTA[16..23]~
  
PRI wait_this_fraction_of_a_second(the_decimal)'1/the_decimal, e.g. 1/2, 1/4th, 1/10

  waitcnt(clkfreq / the_decimal + cnt)'if the_decimal=4, then we wait 1/4 sec
    