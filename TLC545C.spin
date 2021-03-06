{{
***************************************************************
  TLC545C Driver
  8-Bit Resolution, 19 Analog Inputs, Serial Communication
  by Dan Ray
  According to the datasheet, the TLC545C appears to be capable
  of operating twice as fast if the previous output of the
  previous address is read while clocking in the new address.
  This would require the calling software to always recieve the
  previous for each new address.  I felt that would make this driver
  confusing to use so I implemented it at 50% efficiency.
  See TLC545C_Driver_Test.spin for pin assignment and test code.
***************************************************************
}}
          
CON
  wait_time = 400'in clock cycles'390 or greater works
    
VAR
  Long CLK, IO_CLOCK, ADDRESS, DATA, CS

PRI Set_Initial_Pin_States
  outa[CLK]~        
  outa[IO_CLOCK]~   
  outa[ADDRESS]~    
  outa[CS]~~           

PUB Start(_CLK, _IO_CLOCK, _ADDRESS, _DATA, _CS)
{{ Set the pin variables }}
  longmove(@CLK, @_CLK, 5)
  
  'set pin directions
  dira[CLK]~~         'out
  dira[IO_CLOCK]~~    'out
  dira[ADDRESS]~~     'out
  dira[DATA]~         'in *** should have a 1K resistor on this pin to lower the 5v out from the TLC545C
  dira[CS]~~          'out

  Set_Initial_Pin_States

PUB Read(Analog_In_Line)|Index, bit_to_compare
{{ Reads the output and returns the value }}  

  Set_Initial_Pin_States
  waitcnt(wait_time+CNT)
  
  outa[CS]~ 'set CS low, this begins the operating sequence
  waitcnt(wait_time+CNT)
  repeat 6'3 cycles allows the chip-select setup time
    !outa[CLK]
    waitcnt(wait_time+CNT)

  'send the address of Analog_In_Line
  repeat Index from 4 to 0

    bit_to_compare := |< Index
    'send address bit, Index
    if((bit_to_compare & Analog_In_Line)==bit_to_compare)
      outa[ADDRESS]~~
    else
      outa[ADDRESS]~                     

    'clocks high
    outa[IO_CLOCK]~~
    outa[CLK]~~
    '
    waitcnt(wait_time+CNT)
    'clocks low
    outa[IO_CLOCK]~
    outa[CLK]~
    waitcnt(wait_time+CNT)

  repeat 6 '3 more IO clock cycles
    !outa[IO_CLOCK]
    !outa[CLK]
    waitcnt(wait_time+CNT)  

  outa[CS]~~ 'set CS high, this begins the conversion cycle
  waitcnt(wait_time+CNT)
  repeat 72'36 cycles allows the analog reading
    !outa[CLK]
    waitcnt(wait_time+CNT)


  '***************************************
  outa[CS]~
  waitcnt(wait_time+CNT)
  repeat 6'3 cycles allows the chip-select setup time
    !outa[CLK]
    waitcnt(wait_time+CNT)
  
  'Read the data**************************
  repeat 8                                
    RESULT := ina[DATA] + (result << 1)
    outa[IO_CLOCK]~~
    outa[CLK]~~
    waitcnt(wait_time+CNT)
    outa[IO_CLOCK]~
    outa[CLK]~
    
  outa[CS]~~
  result := result << 24 >> 24
  '***************************************

{{

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}