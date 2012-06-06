{{
'*********************************************************************************************************************
'*********************************************************************************************************************
'******************************************                                 ******************************************
'******************************************          the verbalizer         ******************************************
'******************************************           by Dan Ray            ******************************************
'*********************************************************************************************************************
'*********************************************************************************************************************
    ***** aka the "mouth organ" *****                                         ***** aka the "mouth organ" *****
      ******************************                                              ******************************
            *****************                                                           *****************
}}

CON
'********************************************************************
     _CLKMODE = XTAL1 + PLL16X
     _XINFREQ = 5_000_000
'********************************************************************
        
'********************************************************************
     Muh_VERSION = 5
'********************************************************************

'*** Key States ***
     'greater than 3 is the count within the debounce range 
        'DEBOUNCE= 100_000
        TRIGGER = 3
        SUSTAIN = 2
        RELEASE = 1
        SILENCE = 0
        
'***PINS********************************************************        
'*** adc *******************************************************
        CLK_PIN = 13
        IO_CLOCK = 23
        ADDRESS = 24
        DATA_PIN = 25
        CS_PIN = 26
        POTS_MAX = 18
'*** mode *****************************************************
        DO_NOTHING = 0
        PLAY_PHONEMES = 1 
        RECORD_PHONEMES = 2
        PLAY_ALLOPHONES = 3
        RECORD_ALLOPHONES = 4
        PLAY_WORDS = 5
        RECORD_WORDS = 6
        MODE_S1 = 27
        MODE_S2 = 28
        
VAR
     LONG Key_State[40]'each of 37 keys' Key States(TRIGGER, SUSTAIN, RELEASE, or SILENCE), but for iterating cols x rows I use 40
     BYTE The_Mode
     LONG ADC_Stack[20]'stack space allotment
     LONG Settings_Stack[20]'stack space allotment   
     BYTE Pot[19]
     BYTE serial_progress
     LONG serial_started
      
OBJ
        serial           :   "Parallax Serial Terminal"
        Verbalizations   :   "VerbalizeIt"
        adc              :   "TLC545C"
        settings         :   "settings"
        'Stk              :   "Stack Length"
        
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
      'mode pins
      dira[MODE_S1]~
      dira[MODE_S2]~
      outa[MODE_S1]~
      outa[MODE_S2]~
     
      'Keyboard ~ Keyboard_Key_Index
      outa[0..7]~~  'key pins set                       'PU~PU~PU~PU~ 
      dira[0..7]~~ 'key pins set                       'PU~PU~PU~PU~
      
      'Keyboard ~ Keyboard_Quadrant_Index
      dira[14..16]~ 'quadrant set                     'PU~PU~PU~PU~
      outa[14..16]~~  'quadrant set                     'PU~PU~PU~PU~
      dira[21..22]~ 'quadrant set                     'PU~PU~PU~PU~
      outa[21..22]~~  'quadrant set                     'PU~PU~PU~PU~
      
PRI Get_this_Setting(the_setting_name)

  the_setting_name := "i"+("d"<<8)
  
  if (settings.findKey(the_setting_name))
      return settings.getByte(the_setting_name)
  else
    return 0
     
PUB MAIN | Quadrant_Pin, Keyboard_Quadrant_Index, Keyboard_Key_Index, the_key, serial_count 'starts cog 1 of 8

initialize_pins
      'Stk.Init(@ADC_Stack, 32)'stack
      cognew(Analog_to_Digital_Conversion, @ADC_Stack)'start cog 2 of 8
      wait_this_fraction_of_a_second(5)
      'waitcnt(clkfreq * 2 + cnt)
      'Stk.GetLength(30, 250000)
      
      if(The_Mode == PLAY_PHONEMES)'if the switch is down, serial will run
         serial_started := TRUE
      else
         serial_started := FALSE
        
      'settings.start       
      Verbalizations.start(@Pot)        

      if(serial_started == TRUE)
        serial.start(250_000)
    
      repeat the_key from 0 to 38
        Key_State[the_key] := SILENCE
                                                                                
'*****MAIN LOOP*************************************************************************************************************
      repeat 'main loop

        if(serial_started == TRUE)
          serial_count++
          if(serial_count > 75)
            serial_count := 0
            Serial_Loop
          else
            wait_this_fraction_of_a_second(500)'to avoid keybounce
        else
           wait_this_fraction_of_a_second(500)'to avoid keybounce
           
        '******************************************************************    
        {repeat Keyboard_Quadrant_Index from 1 to 33 step 8 'iterate through the Keyboard_Quadrant_Index
          'All go low
          'outa[14..16]~~  'set ### 'PU~PU~PU~PU~PU~PU~PU~PU~PU~PU~PU~PU~PU~PU~PU~Pull~Up~or~Pull~Down
          'outa[21..22]~~  'set ### 'PU~PU~PU~PU~PU~PU~PU~PU~PU~PU~PU~PU~PU~PU~PU~Pull~Up~or~Pull~Down
           
          case Keyboard_Quadrant_Index '###########  'PU~PU~PU~PU~PU~PU~PU~PU~PU~Pull~Up~or~Pull~Down
            1 : Quadrant_Pin := 15 'outa[15]~   'set high  ############  'PU~PU~PU~PU~PU~PU~PU~PU~PU~Pull~Up~or~Pull~Down
            9 : Quadrant_Pin := 14 'outa[14]~   'set high  ############  'PU~PU~PU~PU~PU~PU~PU~PU~PU~Pull~Up~or~Pull~Down
            17 : Quadrant_Pin := 16 'outa[16]~   'set high  ###########  'PU~PU~PU~PU~PU~PU~PU~PU~PU~Pull~Up~or~Pull~Down
            25 : Quadrant_Pin := 21 'outa[21]~   'set high  ###########  'PU~PU~PU~PU~PU~PU~PU~PU~PU~Pull~Up~or~Pull~Down
            33 : Quadrant_Pin := 22 'outa[22]~   'set high  ###########  'PU~PU~PU~PU~PU~PU~PU~PU~PU~Pull~Up~or~Pull~Down
            other : 'this can't be happening! #####  'PU~PU~PU~PU~PU~PU~PU~PU~PU~Pull~Up~or~Pull~Down
        }
           
        repeat Keyboard_Key_Index from 0 to 7 'read Keyboard_Key_Index ****
          'All go low
          outa[0..7]~~
          outa[Keyboard_Key_Index]~
       
          repeat Keyboard_Quadrant_Index from 1 to 33 step 8
            case Keyboard_Quadrant_Index
                                1 : Quadrant_Pin := 15 'outa[15]~   'set high  ############  'PU~PU~PU~PU~PU~PU~PU~PU~PU~Pull~Up~or~Pull~Down
                                9 : Quadrant_Pin := 14 'outa[14]~   'set high  ############  'PU~PU~PU~PU~PU~PU~PU~PU~PU~Pull~Up~or~Pull~Down
                                17 : Quadrant_Pin := 16 'outa[16]~   'set high  ###########  'PU~PU~PU~PU~PU~PU~PU~PU~PU~Pull~Up~or~Pull~Down
                                25 : Quadrant_Pin := 21 'outa[21]~   'set high  ###########  'PU~PU~PU~PU~PU~PU~PU~PU~PU~Pull~Up~or~Pull~Down
                                33 : Quadrant_Pin := 22 'outa[22]~   'set high  ###########  'PU~PU~PU~PU~PU~PU~PU~PU~PU~Pull~Up~or~Pull~Down
                                                 
            the_key := Keyboard_Quadrant_Index + Keyboard_Key_Index
            if (the_key < 38)'limited by number of keys
         
              if(ina[Quadrant_Pin] == 0) 
                Update_this_Keys_State(the_key, TRUE)'PU~PU~PU~PU~PU~PU~PU~PU~PU~PullUp~or~Pull~Down 
                
              else
                Update_this_Keys_State(the_key, FALSE)'PU~PU~PU~PU~PU~PU~PU~PU~PU~Pull~Up~or~Pull~Down 
        '******************************************************************
        
        case The_Mode
                                                
          PLAY_PHONEMES :
                                 repeat the_key from 1 to 37         
                                     if (Key_State[the_key] == RELEASE)'caught a release
                                         if Verbalizations.release_test(the_key)'if this one is stopping, then advance to SILENCE  
                                             Key_State[the_key] := SILENCE  'advance to silence
                                                      
                                 repeat the_key from 1 to 37                      
                                     if ((Key_State[the_key] == TRIGGER) OR (Key_State[the_key] == SUSTAIN))'caught a trigger
                                         if Verbalizations.go_test(the_key)
                                                        Key_State[the_key] := SUSTAIN
                                                   
          
          PLAY_ALLOPHONES : 'PLAY_ALLOPHONES = 3                      
                                repeat the_key from 1 to 37         
                                     if (Key_State[the_key] == RELEASE)'caught a release
                                         if Verbalizations.stop_if_available(the_key)'if this one is stopping, then advance to SILENCE  
                                             Key_State[the_key] := SILENCE  'advance to silence
                                 
                                repeat the_key from 1 to 37
                                     if (Key_State[the_key] == SUSTAIN)
                                        Verbalizations.go_sustain(the_key)
                                        
                                repeat the_key from 1 to 37       
                                     if (Key_State[the_key] == TRIGGER)'caught a trigger                 
                                         if Verbalizations.go_if_available(the_key)'if this one starts a voice, then advance to SUSTAIN
                                             Key_State[the_key] := SUSTAIN  'advance to sustain

          PLAY_WORDS : 'PLAY_WORDS
                                repeat the_key from 1 to 37         
                                     if (Key_State[the_key] == RELEASE)'caught a release
                                         if Verbalizations.release_word(the_key)'if this one is stopping, then advance to SILENCE  
                                             Key_State[the_key] := SILENCE  'advance to silence
                                 
                                repeat the_key from 1 to 37
                                     if (Key_State[the_key] == SUSTAIN)
                                        Verbalizations.sustain_word(the_key)
                                        
                                repeat the_key from 1 to 37       
                                     if (Key_State[the_key] == TRIGGER)'caught a trigger                 
                                         if Verbalizations.trigger_word(the_key)'if this one starts a voice, then advance to SUSTAIN
                                             Key_State[the_key] := SUSTAIN  'advance to sustain

                                             
          RECORD_WORDS : 'RECORD_WORDS = 4
                                 repeat the_key from 1 to 37                      
                                     if (Key_State[the_key] == TRIGGER)'caught a trigger
                                         Verbalizations.go_test(the_key)
          OTHER :
             'do nothing
             Verbalizations.release_test(1)
                                             
'*****END MAIN LOOP*************************************************************************************************************         
     
PRI Serial_Loop | index

  'serial.start(250_000)
    'waitcnt(clkfreq + cnt)  
     
    'repeat
      'value := serial.DecIn
      serial.Str(String(serial#CS))
      serial.Str(String(serial#NL, serial#NL, "~~~Dan Ray presents The Verbalizer~~~", serial#NL))
      serial_progress++
      if(serial_progress > 16)
        serial_progress := 1
      serial.Str(String(serial#NL))
      repeat serial_progress
        serial.Str(String("*"))
         
      repeat index from 0 to POTS_MAX
        serial.Str(String(serial#NL, "knob"))
        serial.Dec(index)
        serial.Str(String(" = "))
        serial.Dec(Pot[index])  
        serial.Str(String(", "))
        serial.Dec(Thirtyfifth_value_of_pot(Pot[index]))
 
      'wait_this_fraction_of_a_second(2)
  'else
    'end this cog?
    'cogstop
            
PRI char_from_number(number_value) : char_val
    
    case number_value
      0 :  char_val := "0"
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
      32 : char_val := "W"
      33 : char_val := "X"
      34 : char_val := "Y"
      other : char_val := "Z"  
    return char_val

PRI Thirtyfifth_value_of_pot(pot_value) : the_decimal_value

  return pot_value/7
  
{  
           case pot_value
                0..3   :   the_decimal_value := 1 'necesary first threshhold
                4..15   :   the_decimal_value := 2
                16..35   :   the_decimal_value := 3
                36..70   :   the_decimal_value := 4
                71..125   :   the_decimal_value := 5
                126..205   :   the_decimal_value := 6
                206..310   :   the_decimal_value := 7
                311..460   :   the_decimal_value := 8
                461..630   :   the_decimal_value := 9
                other   :   the_decimal_value := 10
                
    return the_decimal_value        
}
PRI Analog_to_Digital_Conversion | index 'and Mode switch

  repeat index from 0 to POTS_MAX
    Pot[index] := 0
    
  adc.Start(CLK_PIN, IO_CLOCK, ADDRESS, DATA_PIN, CS_PIN)
  wait_this_fraction_of_a_second(10)
  
  repeat
    'read the mode switch
    
    if(ina[MODE_S1] == 0)
      The_Mode := PLAY_PHONEMES
    else
      The_Mode := PLAY_ALLOPHONES
   
    if(ina[MODE_S2] == 0)
      The_Mode := PLAY_WORDS
    
    'read the adc
    repeat index from 0 to POTS_MAX
      Pot[index] := adc.Read(index)
    'wait_this_fraction_of_a_second(1000)

PRI map(da_value, da_minimum, da_maximum)

  return ((da_value*(da_maximum-da_minimum))/255)+da_minimum

             