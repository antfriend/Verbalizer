{{
  TLC545C Driver Test App - runs on the propeller demo board
  
}}

CON
  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000

  CS_PIN = 0
  CLK_PIN = 1
  DATA_PIN = 2
  
VAR
    long  x, y     

OBJ
    adc   :     "TLC545C"


PUB MAIN

  adc.Start(CS_PIN, CLK_PIN, DATA_PIN)
