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
     LONG Key_PreviousState[40]'What was it last time we looked?
     LONG CogQueue[QUEUEMAX],KeyQueue[QUEUEMAX]'to contain "Keys" and ", Cog IDs"
     LONG QueueCount
      
OBJ
        LCD        :               "Serial_Lcd"
        'sounds     :               "Sounds"             '
        talk       :               "Talk"               'synthesized speech
        'blah       :               "Play_Blah"
        freq  :       "FREQOUTMULTI"
        
PRI Key_Status_Changed(the_key) | the_status, the_index, found_it

  found_it := FALSE

  repeat the_index from 1 to (QUEUEMAX)
    if(KeyQueue[the_index] == the_key)
      found_it := TRUE

  case Key_State[the_key]
    TRIGGER :
        KeyQueue[the_key] := the_key
        'CogQueue[the_key] := Play_One(the_key*20)
        Key_State[the_key] := SUSTAIN
        wait_this_fraction_of_a_second(4)
        
    SUSTAIN :
        'do nothing
        
    RELEASE :
        Key_State[the_key] := SILENCE
        if(CogQueue[the_key] > 0)'ensure this has a cog id
          'Stop_One(CogQueue[the_key])
           
    SILENCE :
       'do nothing

       
       {
      'is the key status down?
      if(Key_State[the_key] == TRIGGER)
        KeyQueue[the_key] := the_key
        'CogQueue[the_key] := Play_One(the_key*20)
        Key_State[the_key] := SUSTAIN
        wait_this_fraction_of_a_second(4)
      else 
        Key_State[the_key] := SILENCE
        if(CogQueue[the_key] > 0)'ensure this has a cog id
          'Stop_One(CogQueue[the_key])
     }
        
  {
  if(found_it == FALSE)
    'find a SILENT one
    repeat the_index from 0 to (QUEUEMAX-1)
      if(Key_State[KeyQueue[the_index]] == SILENCE)
        KeyQueue[the_index] := the_key
        CogQueue[the_index] := Play_One(the_key*20)  
  }    
        
      'if((Key_State[KeyQueue[the_index]] == SILENCE)|(Key_State[KeyQueue[the_index]] == RELEASE))'*** not sure yet which of these to use ***
          '1. silence the voice

          '2. stop the cog

          '3. zero out this array item
    

  {                
  if(QueueCount == 0)'no cogs in the queue, this must be the first trigger
    QueueCount := 1
    '**************************************
    'start a new cog
    'CogQueue[1] := newcog(  )'returns this cog id
    sounds.positive_result
    KeyQueue[1] := the_key
    '**************************************
  if(found_it == FALSE)
    'start a new cog in the first empty array item
      
    
  else 'this is either a new cog or a change to an existing cog
        'if we have it, find it with found_it
    found_it := FALSE
    repeat the_index from 1 to QueueCount
      if(KeyQueue[the_index] == the_key)
        found_it := TRUE
        'the status on this key has changed
        'going up or going down? is it past the debounce phase?
        
        'CAN I ASSUME IT IS A RELEASE?
         if(Key_State[KeyQueue[the_index]] == SILENCE)'then the_key has changed to SILENCE
          'silence it, stop the cog, and clean up the array
          '1. silence the voice

          '2. stop the cog

          '3. clean up the array  (?) unless I can manage the queue by 'slotting'
          
          
        
    if(found_it == FALSE)
      'this must be a new trigger
      
      if(QueueCount < QUEUEMAX)'if the queue is full, do nothing
                                'otherwise start a new one
        QueueCount := QueueCount + 1
        '**************************************
        'start a new cog
        'CogQueue[1] := newcog(  )'returns this cog id
        sounds.negative_result
        KeyQueue[1] := the_key
        '**************************************
   }            
      
  {
    if(QueueCount <= QUEUEMAX)

    else 'the 
   } 

  'get the_status from Key_State[the_key]
  'status only changes in one direction
   
'if QueueCount < QUEUEMAX
  'is it existing or new?
 
{ 
  if (Key_State[the_key] == TRIGGER)'caught a trigger
      Key_PreviousState[the_key] := Key_State[the_key]
      Key_State[the_key] := SUSTAIN  'advance to sustain              
      'wait_this_fraction_of_a_second(4)
  if (Key_State[the_key] == RELEASE)'caught a release
      Key_PreviousState[the_key] := Key_State[the_key]
      Key_State[the_key] := SILENCE  'advance to sustain  
      'wait_this_fraction_of_a_second(4)
 }
 
PRI Update_this_Keys_State(the_key, is_pressed) | the_count_now

  if (is_pressed == TRUE)
    if(Key_State[the_key] == SUSTAIN)
      'do nothing
    else
      Key_State[the_key] := TRIGGER
  else
    if(Key_State[the_key] == SUSTAIN)
      Key_State[the_key] := RELEASE
    else
      'do nothing
                                    
PRI display_state_of_this_key(the_key)'only affects keys 1-32, the LCD cursor positions
  if (the_key < 33)
    LCD_home_then_here(the_key-1)'lcd index is base 0
    'send(char_from_number(Key_State[the_key]))
    if(Key_State[the_key] == SILENCE)
      send("*")
    if (Key_State[the_key] == TRIGGER)
      send("T")
    if (Key_State[the_key] == SUSTAIN)
      send("S")
    if (Key_State[the_key] == RELEASE)
      send("R")
      
    wait_this_fraction_of_a_second(8)
  
PRI wait_this_fraction_of_a_second(the_decimal)'1/the_decimal, e.g. 1/2, 1/4th, 1/10   
  waitcnt(clkfreq / the_decimal + cnt)'if the_decimal=4, then we wait 1/4 sec

PRI initialize_VARs | the_index
  repeat the_index from 0 to (39)
    KeyQueue[the_index] := the_index
    Key_State[the_index] := SILENCE
    Key_PreviousState[the_index] := SILENCE
    
PRI initialize_pins 
           
      'Keyboard Input ~ Keyboard_Key_Index
      outa[0..7]~ 'read pins set to low 
      dira[0..7]~ 'read pins set to input
      
      'Keyboard Output ~ Keyboard_Quadrant_Index
      dira[14..16]~~ 'set to output     
      outa[14..16]~  'set low
      dira[21..22]~~ 'set to output     
      outa[21..22]~  'set low

PUB MAIN | Keyboard_Octave_Index, Keyboard_Key_Index, the_key, the_looper, the_limit, the_from
      initialize_pins
      initialize_VARs
      Run_LCD
       
     ' wait_this_fraction_of_a_second(1)'1/the_decimal, e.g. 1/2, 1/4th, 1/10

      repeat 'main loop
        
        
        repeat the_looper from 1 to 5 'iterate through the Keyboard_Quadrant_Index
          'All go low
          outa[14..16]~  'set low
          outa[21..22]~  'set low
          case the_looper
            1 :                 outa[15]~~  'set high
                                Keyboard_Octave_Index := 1
                                the_from := 0
                                the_limit := 6'5 is the top number to get read
            2 :                 outa[14]~~  'set high
                                Keyboard_Octave_Index := 9
                                the_from := 0
                                the_limit := 7            
            3 :                 'outa[16]~~  'set high
                                Keyboard_Octave_Index := 17
                                the_limit := 7              
            4 :                 'outa[21]~~  'set high
                                Keyboard_Octave_Index := 25
                                the_limit := 7                
            5 :                 'outa[22]~~  'set high
                                Keyboard_Octave_Index := 33
                                the_limit := 5
                                            
            other : 'this can't be happening!
              This_Key_Pressed(2,2)
              
          repeat Keyboard_Key_Index from 0 to the_limit 'read Keyboard_Key_Index
            the_key := Keyboard_Octave_Index + Keyboard_Key_Index
            if (the_key < 38)'limited by number of keys

              if(ina[Keyboard_Key_Index] == 1)
                Update_this_Keys_State(the_key, TRUE)
              else
                Update_this_Keys_State(the_key, FALSE)
              'Key_Status_Changed(the_key)              
              display_state_of_this_key(the_key)
              
           '{   
          'now compare against previous state values and update LCD
        repeat the_key from 1 to 37
          if (Key_State[the_key] == Key_PreviousState[the_key])
             'do nothing
          else             
             '***************************************    
             Key_Status_Changed(the_key)
             '***************************************
             Key_PreviousState[the_key] := Key_State[the_key]
             'display_state_of_this_key(the_key)
             
             ' }
              
PRI This_Key_Pressed(Quadrant, Key)
  'print to LCD
  LCD_home_then_here(Quadrant)
  'wait_this_fraction_of_a_second(32)
  'send(char_from_number(Quadrant))
  'send(",")
  send(char_from_number(Key))
  'send(" ")
  'wait_this_fraction_of_a_second(32)
   
PRI Run_LCD
    
  if LCD.init(LCD_Line, 9600, 2)
    waitcnt(clkfreq / 4 + cnt)'250 milliseconds (1/4 second)
    clear_lcd
    'display_the_display
    'send("h")
    'send("o")
  'clear_lcd
  'waitcnt(clkfreq / 4 + cnt)
  display_the_display


PRI clear_lcd
  send("?")
  send("f")


PRI display_the_display | the_iterator
{
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
}    
  LCD_home_then_here(0)
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

{********************************************************************************************
           FREQOUTMULTI
********************************************************************************************}
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
               