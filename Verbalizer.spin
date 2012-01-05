'************************************************************************************************************
'************************************************************************************************************
'******************************************                                 *********************************
'******************************************          the verbalizer         *********************************
'******************************************                                 *********************************
'************************************************************************************************************
'************************************************************************************************************

CON
'********************************************************************
     _CLKMODE = XTAL1 + PLL16X
     _XINFREQ = 5_000_000
'********************************************************************
     LCD_Line = 12
'********************************************************************
     Muh_VERSION = 4
'********************************************************************
'*** Key States ***
     'greater than 3 is the count within the debounce range 
     DEBOUNCE= 100_000
     TRIGGER = 3
     SUSTAIN = 2
     RELEASE = 1
     SILENCE = 0
'********************************************************************
     QUEUEMAX = 4

VAR
     LONG Key_State[40]'each of 37 keys' Key States(TRIGGER, SUSTAIN, RELEASE, or SILENCE), but for iterating cols x rows I use 40
     LONG CogQueue[QUEUEMAX],KeyQueue[QUEUEMAX]'to contain "Keys" and ", Cog IDs"
     LONG QueueCount
     BYTE LCD_Display_Mode
     LONG LCD_Stack[500]
      
OBJ
        LCD        :               "Serial_Lcd"
        blah       :               "VerbalizeIt"
   
PRI Update_this_Keys_State(the_key, is_pressed) | the_count_now

  if (is_pressed == TRUE)
    if (Key_State[the_key] <> SUSTAIN)
       Key_State[the_key] := TRIGGER
  else
    if (Key_State[the_key] == SUSTAIN)
       Key_State[the_key] := RELEASE
    else
       Key_State[the_key] := SILENCE 

PRI wait_this_fraction_of_a_second(the_decimal)'1/the_decimal, e.g. 1/2, 1/4th, 1/10

  waitcnt(clkfreq / the_decimal + cnt)'if the_decimal=4, then we wait 1/4 sec

PRI initialize_pins 
           
      'Keyboard Input ~ Keyboard_Key_Index
      outa[0..7]~ 'read pins set to low 
      dira[0..7]~ 'read pins set to input
      
      'Keyboard Output ~ Keyboard_Quadrant_Index
      dira[14..16]~~ 'set to output     
      outa[14..16]~  'set low
      dira[21..22]~~ 'set to output     
      outa[21..22]~  'set low

PUB MAIN | Keyboard_Quadrant_Index, Keyboard_Key_Index, the_key

      LCD_Display_Mode := 0
      initialize_pins
      blah.start
      cognew(LCD_Display_Loop, @LCD_Stack)
      'Run_LCD
      
      repeat the_key from 0 to 38
        Key_State[the_key] := SILENCE
                                                                                
'*****MAIN LOOP*************************************************************************************************************
      repeat 'main loop
        
        'wait_this_fraction_of_a_second(128)
        repeat Keyboard_Quadrant_Index from 1 to 33 step 8'iterate through the Keyboard_Quadrant_Index

          'All go low
          outa[14..16]~  'set low
          outa[21..22]~  'set low

          case Keyboard_Quadrant_Index
            1 : outa[15]~~  'set high
            9 : outa[14]~~  'set high
            17 : outa[16]~~  'set high
            25 : outa[21]~~  'set high
            33 : outa[22]~~  'set high
            other : 'this can't be happening!
           
          repeat Keyboard_Key_Index from 0 to 7 'read Keyboard_Key_Index
            the_key := Keyboard_Quadrant_Index + Keyboard_Key_Index
            if (the_key < 38)'limited by number of keys

              if(ina[Keyboard_Key_Index] == 1)
                Update_this_Keys_State(the_key, TRUE)
                
              else
                Update_this_Keys_State(the_key, FALSE)

        repeat the_key from 1 to 37         
             if (Key_State[the_key] == RELEASE)'caught a release
                 if blah.stop_if_available(the_key)'if this one is stopping, then advance to SILENCE  
                     Key_State[the_key] := SILENCE  'advance to silence

        repeat the_key from 1 to 37
             if (Key_State[the_key] == SUSTAIN)
                blah.go_sustain(the_key)
                
        repeat the_key from 1 to 37       
             if (Key_State[the_key] == TRIGGER)'caught a trigger                 
                 if blah.go_if_available(the_key)'if this one starts a voice, then advance to SUSTAIN
                     Key_State[the_key] := SUSTAIN  'advance to sustain
                     


'*****END MAIN LOOP*************************************************************************************************************         
     
   
PRI Run_LCD
    
  if LCD.init(LCD_Line, 9600, 2)
    wait_this_fraction_of_a_second(4) '250 milliseconds (1/4 second)
    clear_lcd

  clear_lcd
  wait_this_fraction_of_a_second(4) '250 milliseconds (1/4 second)
  'display_the_display


PRI clear_lcd
  send("?")
  send("f")

PRI display_the_display | the_iterator

   clear_lcd
  LCD.str(string("Dan Ray presents"))

  waitcnt(clkfreq / 4 + cnt)'1/4 sec
  LCD.str(string("the "))

  waitcnt(clkfreq / 64 + cnt)'1/4 sec
  send("V")
  waitcnt(clkfreq / 64 + cnt)'1/4 sec
  send("E")
  waitcnt(clkfreq / 32 + cnt)'1/4 sec
  send("R")
  waitcnt(clkfreq / 32 + cnt)'1/4 sec
  send("B")
  waitcnt(clkfreq / 32 + cnt)'1/4 sec
  send("A")
  waitcnt(clkfreq / 16 + cnt)'1/4 sec
  send("L")
  waitcnt(clkfreq / 16 + cnt)'1/4 sec
  send("I")
  waitcnt(clkfreq / 16 + cnt)'1/4 sec
  send("Z")
  waitcnt(clkfreq / 8 + cnt)'1/4 sec
  send("E")
  waitcnt(clkfreq / 8 + cnt)'1/4 sec
  send("R")

  'waitcnt(90_000_000 + cnt)
  wait_this_fraction_of_a_second(4)
    
  LCD_home_then_here(0)
  LCD.str(string("v="))
  send(char_from_number(Muh_VERSION))
  repeat the_iterator from 72 to 4 step 2 '32 segments 
    send("*")
    wait_this_fraction_of_a_second(the_iterator)
                
PRI send(this_character) 
    LCD.str(@this_character)
    
PRI LCD_home_then_here(the_cursor_position)
      send("?")'go to 
      send("a")'home position
      'go to cursor position
      hop_cursor(the_cursor_position)
      

PRI hop_cursor(the_number_to_hop)
    repeat the_number_to_hop
      LCD.str(string("?i"))
      'send("?")
      'send("i")
        
PRI char_from_number(number_value) : char_val
    
    case number_value
      -100..0 :  char_val := "0"
      1 :  char_val := "1"
      2 :  char_val := "2"
      3 :  char_val := "3"
      4 :  char_val := "4"
      5 :  char_val := "5"
      6 :  char_val := "6"
      7 :  char_val := "7"
      8 :  char_val := "8"
      9 :  char_val := "9"
      10 : char_val := "A"
      11 : char_val := "B"
      12 : char_val := "C"
      13 : char_val := "D"
      14 : char_val := "E"
      15 : char_val := "F"
      16 : char_val := "G"
      17 : char_val := "H"
      18 : char_val := "I"
      19 : char_val := "J"
      20 : char_val := "K"
      21 : char_val := "L"
      22 : char_val := "M"
      23 : char_val := "N"
      24 : char_val := "O"
      25 : char_val := "P"
      26 : char_val := "Q"
      27 : char_val := "R"
      28 : char_val := "S"
      29 : char_val := "T"
      30 : char_val := "U"
      31 : char_val := "V"
      32..100 : char_val := "W"  
    return char_val

PRI LCD_Display_Loop

  Run_LCD
  
  repeat
    case LCD_Display_Mode
      0 :  display_the_display
      1 :  display_the_display
      other :  display_the_display

    wait_this_fraction_of_a_second(1)
    

{********************************************************************************************
           FREQOUTMULTI
********************************************************************************************}
{
PRI Play_Tone(tone_one, tone_two, for_duration) | cog_id1, cog_id2'duration of 1 = 1/10 second
  
  cog_id1 := freq.start(10, 11, -1, -1, -1, -1, 218, 438, 0, 0, 0, 0)
  cog_id2 := freq.start(10, 11, -1, -1, -1, -1, tone_one, tone_two, 0, 0, 0, 0)
  for_duration := 2000000 *  for_duration
  waitcnt(for_duration+cnt)
  freq.stop(cog_id1)
  freq.stop(cog_id2) 

PRI positive_result
    Play_Tone(880, 440, 3)
    Play_Tone(2200, 2200, 4)
    Play_Tone(8800, 4400, 5)

PRI negative_result
    Play_Tone(200, 400, 9)
    waitcnt(10000000+cnt)
    Play_Tone(200, 400, 9)

PRI Play_One(a_tone) | cog_id1

  cog_id1 := freq.start(10, 11, -1, -1, -1, -1, a_tone, 0, 0, 0, 0, 0)
  
  RETURN cog_id1
  

PRI Stop_One(cog_id1)
  freq.stop(cog_id1)


PRI Say_One(a_tone) | cog_id1

  'cog_id1 := freq.start(10, 11, -1, -1, -1, -1, a_tone, 0, 0, 0, 0, 0)
  cog_id1 := blah.start'(a_tone)
  'blah.go
  RETURN cog_id1
  

PRI Stop_Saying_This_One(cog_id1)
  'freq.stop(cog_id1)
  'blah.done
  if cog_id1 > -1
    cogstop(cog_id1)
 
  }              