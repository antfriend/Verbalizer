{{
***************************************************************
  TLC545C Driver
  8-Bit Resolution, 19 Analog Inputs, Serial Communication

***************************************************************
includes code from:
 ADC0831_Driver.spin    
   Copyright (c) 2009 Austin Bowen
   *See end of file for terms of use*
***************************************************************


   +5V
      TLC545C              Propeller I/O PINS
   │  ┌──────────┐   1kΩ(all) 
   ┣──┤Vcc     CS├────── CS
   ┣──┤REF+   CLK├────── CLK
   │  │      DATA├──────── DATA
   │  │   ADDRESS├────── ADDRESS
   │  │        IO├────── IO_CLOCK
   ─┤INA0      │
   │  │.         │
   │  │.         │
   ─┤INA18     │
   │  │          │
   ┣──┤REF-      │
   ┣──┤GND       │
   │  └──────────┘
      


}}                      

VAR
  LONG CS, CLK, DATA', ADDRESS, IO_CLOCK

PUB START (_CS, _CLK, _DATA)'add _ADDRESS, _IO_CLOCK
{{ Set the pin variables }}
  LONGMOVE(@CS, @_CS, 3)

  

PUB READ(Analog_In_Line)
{{ Reads the output and returns the value }}  
  DIRA[CS]~~
  DIRA[CLK]~~
  DIRA[DATA]~

  OUTA[CS]~                        
  OUTA[CLK]~

  'Analog_In_Line*************************
  
  '***************************************
  
  'Read the data**************************
  REPEAT 9
    !OUTA[CLK]
    !OUTA[CLK]                                
    RESULT := INA[DATA] + (RESULT << 1)
    WAITCNT(400+CNT)
  OUTA[CS]~~
  RESULT := RESULT << 24 >> 24
  '***************************************

PUB CONVERT (VALUE, VMIN, VMAX)
{{ Give it the value of your reading, minimum voltage value,
   and maximum voltage value, and it returns the voltage of your reading

   HINT: Since this isn't floating point, you can get a higher voltage resolution
     by multiplying the VMIN and VMAX values by factors of 10, but remember where
     the decimal is supposed to be
}}
  RETURN ((VALUE*(VMAX-VMIN))/255)+VMIN


{{Permission is hereby granted, free of charge, to any person obtaining a copy of this software
  and associated documentation files (the "Software"), to deal in the Software without restriction,
  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
  subject to the following conditions: 
   
  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 
   
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}} 