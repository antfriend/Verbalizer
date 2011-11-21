{{
****************************************
*  Multiple Frequency Output v1.0      *
*  Author: Brandon Nimon               *
*  Copyright (c) 2008 Parallax, Inc.   *
*  See end of file for terms of use.   *
*******************************************************************
* This program grants the ability to output up to six frequencies *
* at once using the resources of only a single cog. The program   *
* could be easily modified to support more outputs if necessary.  *
* With a clock speed of 5MHz, single outputs can stably reach as  *
* high as 52KHz. The use of higher clock speeds can increase the  *
* maximum output. If more than one output is used (the main       *
* purpose of this program), the maximum frequencies depend on the *
* amount and combination of frequencies.                          *
* Changing the ratio variable allows programmers to alter the     *
* high to low ratio of the frequencies being outputted. The value *
* is divided by 10 to determine the length of high/low wait.      *
* If a output is not needed, just enter -1 for the pin or 0 for   *
* the frequency.                                                  *
*******************************************************************
}}

CON

OBJ

VAR

PUB start (pin1, pin2, pin3, pin4, pin5, pin6, freq1, freq2, freq3, freq4, freq5, freq6) | ratio, cog_id
            
  ratio := 5                                                                    ' divided by 10 to determine high-to-low length ratio

  pinmask~ 

  If (pin1 => 0 AND pin1 < 32 AND freq1 > 0)                                    ' if disabled, skip
    pin1mask := |< pin1                                                         ' set pin mask
    pinmask |= pin1mask                                                         ' set combined mask
    pin1per := clkfreq / freq1                                                  ' determine period length for frequency
    pin1high := clkfreq / freq1 * ratio / 10                                    ' determine high length
    pin1low := pin1per - pin1high                                               ' determine low length

  If (pin2 => 0 AND pin2 < 32 AND freq2 > 0)
    pin2mask := |< pin2
    pinmask |= pin2mask      
    pin2per := clkfreq / freq2
    pin2high := clkfreq / freq2 * ratio / 10
    pin2low := pin2per - pin2high

  If (pin3 => 0 AND pin3 < 32 AND freq3 > 0)
    pin3mask := |< pin3
    pinmask |= pin3mask      
    pin3per := clkfreq / freq3
    pin3high := clkfreq / freq3 * ratio / 10
    pin3low := pin3per - pin3high

  If (pin4 => 0 AND pin4 < 32 AND freq4 > 0)
    pin4mask := |< pin4
    pinmask |= pin4mask      
    pin4per := clkfreq / freq4
    pin4high := clkfreq / freq4 * ratio / 10
    pin4low := pin4per - pin4high

  If (pin5 => 0 AND pin5 < 32 AND freq5 > 0)
    pin5mask := |< pin5
    pinmask |= pin5mask      
    pin5per := clkfreq / freq5
    pin5high := clkfreq / freq5 * ratio / 10
    pin5low := pin5per - pin5high

  If (pin6 => 0 AND pin6 < 32 AND freq6 > 0)
    pin6mask := |< pin6
    pinmask |= pin6mask      
    pin6per := clkfreq / freq6
    pin6high := clkfreq / freq6 * ratio / 10
    pin6low := pin6per - pin6high

  cog_id := cognew(@freqout, 0)
  return cog_id

PUB stop(cog_id)
  cogstop(cog_id)
  
DAT
                        ORG 0

freqout
                        MOV     OUTA, #0                                        ' set to low
                        MOV     DIRA, pinmask                                   ' set output pins


                        MOV     time1l, cnt                                     ' set start time
                        ADD     time1l, pin1per                                 ' set next low time
                        MOV     time1h, time1l
                        ADD     time1h, pin1low                                 ' set high time

                        MOV     time2l, cnt
                        ADD     time2l, pin2per
                        MOV     time2h, time2l
                        ADD     time2h, pin2low 

                        MOV     time3l, cnt
                        ADD     time3l, pin3per
                        MOV     time3h, time3l
                        ADD     time3h, pin3low

                        MOV     time4l, cnt
                        ADD     time4l, pin4per
                        MOV     time4h, time4l
                        ADD     time4h, pin4low

                        MOV     time5l, cnt
                        ADD     time5l, pin5per
                        MOV     time5h, time5l
                        ADD     time5h, pin5low

                        MOV     time6l, cnt
                        ADD     time6l, pin6per
                        MOV     time6h, time6l
                        ADD     time6h, pin6low
                        

out1                    TJZ     pin1mask, #out2                                 ' if disabled, skip
                        MOV     timet, time1h                                   ' test high time against now
                        SUB     timet, cnt                                      ' test high time against now
                        CMP     timet, pin1per  WZ, WC                          ' test high time against now
              IF_Z_OR_C OR      OUTA, pin1mask                                  ' set high
              IF_Z_OR_C ADD     time1h, pin1per                                 ' set next high time

                        MOV     timet, time1l                                   ' test low time against now
                        SUB     timet, cnt                                      ' test low time against now
                        CMP     timet, pin1per  WZ, WC                          ' test low time against now
              IF_Z_OR_C ANDN    OUTA, pin1mask                                  ' set low
              IF_Z_OR_C ADD     time1l, pin1per                                 ' set next low time


out2                    TJZ     pin2mask, #out3
                        MOV     timet, time2h  
                        SUB     timet, cnt
                        CMP     timet, pin2per  WZ, WC   
              IF_Z_OR_C OR      OUTA, pin2mask  
              IF_Z_OR_C ADD     time2h, pin2per

                        MOV     timet, time2l  
                        SUB     timet, cnt
                        CMP     timet, pin2per  WZ, WC   
              IF_Z_OR_C ANDN    OUTA, pin2mask
              IF_Z_OR_C ADD     time2l, pin2per                                                


out3                    TJZ     pin3mask, #out4
                        MOV     timet, time3h  
                        SUB     timet, cnt
                        CMP     timet, pin3per  WZ, WC   
              IF_Z_OR_C OR      OUTA, pin3mask  
              IF_Z_OR_C ADD     time3h, pin3per

                        MOV     timet, time3l  
                        SUB     timet, cnt
                        CMP     timet, pin3per  WZ, WC   
              IF_Z_OR_C ANDN    OUTA, pin3mask
              IF_Z_OR_C ADD     time3l, pin3per


out4                    TJZ     pin4mask, #out5
                        MOV     timet, time4h  
                        SUB     timet, cnt
                        CMP     timet, pin4per  WZ, WC   
              IF_Z_OR_C OR      OUTA, pin4mask  
              IF_Z_OR_C ADD     time4h, pin4per

                        MOV     timet, time4l  
                        SUB     timet, cnt
                        CMP     timet, pin4per  WZ, WC   
              IF_Z_OR_C ANDN    OUTA, pin4mask
              IF_Z_OR_C ADD     time4l, pin4per


out5                    TJZ     pin5mask, #out6
                        MOV     timet, time5h  
                        SUB     timet, cnt
                        CMP     timet, pin5per  WZ, WC   
              IF_Z_OR_C OR      OUTA, pin5mask  
              IF_Z_OR_C ADD     time5h, pin5per

                        MOV     timet, time5l  
                        SUB     timet, cnt
                        CMP     timet, pin5per  WZ, WC   
              IF_Z_OR_C ANDN    OUTA, pin5mask
              IF_Z_OR_C ADD     time5l, pin5per


out6                    TJZ     pin6mask, #out1
                        MOV     timet, time6h  
                        SUB     timet, cnt
                        CMP     timet, pin6per  WZ, WC   
              IF_Z_OR_C OR      OUTA, pin6mask  
              IF_Z_OR_C ADD     time6h, pin6per

                        MOV     timet, time6l  
                        SUB     timet, cnt
                        CMP     timet, pin6per  WZ, WC   
              IF_Z_OR_C ANDN    OUTA, pin6mask
              IF_Z_OR_C ADD     time6l, pin6per

                        JMP     #out1


pinmask                 LONG    0                                               ' all enabled pins should be set to 1
timet                   LONG    0                                               ' temperary time storage

pin1mask                LONG    0                                               ' pin's bit set to 1 
pin1per                 LONG    0                                               ' period of frequency in cycles
pin1high                LONG    0                                               ' high length
pin1low                 LONG    0                                               ' low length

time1l                  LONG    0                                               ' next low time
time1h                  LONG    0                                               ' next high time


pin2mask                LONG    0 
pin2per                 LONG    0
pin2high                LONG    0
pin2low                 LONG    0

time2l                  LONG    0
time2h                  LONG    0


pin3mask                LONG    0 
pin3per                 LONG    0
pin3high                LONG    0
pin3low                 LONG    0

time3l                  LONG    0
time3h                  LONG    0


pin4mask                LONG    0
pin4per                 LONG    0
pin4high                LONG    0
pin4low                 LONG    0

time4l                  LONG    0
time4h                  LONG    0


pin5mask                LONG    0 
pin5per                 LONG    0
pin5high                LONG    0
pin5low                 LONG    0

time5l                  LONG    0
time5h                  LONG    0


pin6mask                LONG    0 
pin6per                 LONG    0
pin6high                LONG    0
pin6low                 LONG    0

time6l                  LONG    0
time6h                  LONG    0

                        FIT 496

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