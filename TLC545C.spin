{{
***************************************************************
  TLC545C Driver
  8-Bit Resolution, 19 Analog Inputs, Serial Communication
  by Dan Ray
  According to the datasheet, the TLC545C appears to be capable
  of operating twice as fast if the previous output of the
  previous address is read while clocking in the new address.
  This would require the calling software to always retcieve the
  previous for each new address.  I felt that would make this driver
  confusing to use so I implemented it at 50% efficiency.
  See TLC545C_Driver_Test.spin for pin assignment and test code.
***************************************************************
includes code adapted from:
 ADC0831_Driver.spin    
   Copyright (c) 2009 Austin Bowen
   *See end of file for terms of use*
***************************************************************


}}                      
CON
  wait_time = 400'in clock cycles'390 or greater works
    
VAR
  LONG CLK, IO_CLOCK, ADDRESS, DATA, CS

PRI Set_Initial_Pin_States
  OUTA[CLK]~
  OUTA[IO_CLOCK]~
  OUTA[ADDRESS]~
  OUTA[CS]~~ 

PUB Start(_CLK, _IO_CLOCK, _ADDRESS, _DATA, _CS)
{{ Set the pin variables }}
  LONGMOVE(@CLK, @_CLK, 5)
  
  'set pin directions
  DIRA[CLK]~~         'out
  DIRA[IO_CLOCK]~~   'out
  DIRA[ADDRESS]~~    'out
  DIRA[DATA]~         'in
  DIRA[CS]~~          'out

  Set_Initial_Pin_States

PUB Read(Analog_In_Line)|Index, bit_to_compare
{{ Reads the output and returns the value }}  

  Set_Initial_Pin_States
  WAITCNT(wait_time+CNT)
  
  OUTA[CS]~ 'set CS low, this begins the operating sequence
  WAITCNT(wait_time+CNT)
  repeat 6'3 cycles allows the chip-select setup time
    !OUTA[CLK]
    WAITCNT(wait_time+CNT)

  'send the address of Analog_In_Line
  repeat Index from 4 to 0

    bit_to_compare := |< Index
    'send address bit, Index
    if((bit_to_compare & Analog_In_Line)==bit_to_compare)
      OUTA[ADDRESS]~~
    else
      OUTA[ADDRESS]~                     

    'clocks high
    OUTA[IO_CLOCK]~~
    OUTA[CLK]~~
    '
    WAITCNT(wait_time+CNT)
    'clocks low
    OUTA[IO_CLOCK]~
    OUTA[CLK]~
    WAITCNT(wait_time+CNT)

  repeat 6 '3 more IO clock cycles
    !OUTA[IO_CLOCK]
    !OUTA[CLK]
    WAITCNT(wait_time+CNT)  

  OUTA[CS]~~ 'set CS high, this begins the conversion cycle
  WAITCNT(wait_time+CNT)
  repeat 72'36 cycles allows the analog reading
    !OUTA[CLK]
    WAITCNT(wait_time+CNT)


  '***************************************
  OUTA[CS]~
  WAITCNT(wait_time+CNT)
  repeat 6'3 cycles allows the chip-select setup time
    !OUTA[CLK]
    WAITCNT(wait_time+CNT)
  
  'Read the data**************************
  REPEAT 8                                
    RESULT := INA[DATA] + (RESULT << 1)
    OUTA[IO_CLOCK]~~
    OUTA[CLK]~~
    WAITCNT(wait_time+CNT)
    OUTA[IO_CLOCK]~
    OUTA[CLK]~
    
  OUTA[CS]~~
  RESULT := RESULT << 24 >> 24
  '***************************************
  'RESULT := 30'for testing the result value
  

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