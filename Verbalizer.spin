{{
'*********************************************************************************************************************
'*********************************************************************************************************************
'******************************************                                 ******************************************
'******************************************          the verbalizer         ******************************************
'******************************************                                 ******************************************
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
        LCD_Line = 12
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
        
'*** adc *******************************************************
        CLK_PIN = 13
        IO_CLOCK = 23
        ADDRESS = 24
        DATA_PIN = 25
        CS_PIN = 26

'*** mode *****************************************************
        DO_NOTHING = 0
        PLAY_PHONEMES = 3 
        RECORD_PHONEMES = 2
        PLAY_ALLOPHONES = 1
        RECORD_ALLOPHONES = 4
        PLAY_WORDS = 5
        RECORD_WORDS = 6
        MODE_POT = 12
        MODE_S1 = 27
        MODE_S2 = 28
        
VAR
     LONG Key_State[40]'each of 37 keys' Key States(TRIGGER, SUSTAIN, RELEASE, or SILENCE), but for iterating cols x rows I use 40
     LONG QueueCount
     BYTE LCD_Display_Mode
     BYTE The_Mode
     LONG LCD_Stack[500]'stack space allotment
     LONG ADC_Stack[500]'stack space allotment
     LONG Settings_Stack[500]'stack space allotment   
     BYTE Pot[19]
     'BYTE verb_scope 'PHONEMES, ALLOPHONES, or WORDS
      
OBJ
        LCD              :   "Serial_Lcd"
        Verbalizations   :   "VerbalizeIt"
        adc              :   "TLC545C"
        settings         :   "settings"
        
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
      outa[MODE_S1]~
      outa[MODE_S2]~
      dira[MODE_S1]~
      dira[MODE_S2]~     

      
      'Keyboard Input ~ Keyboard_Key_Index
      outa[0..7]~ 'read pins set to low 
      dira[0..7]~ 'read pins set to input
      
      'Keyboard Output ~ Keyboard_Quadrant_Index
      dira[14..16]~~ 'set to output     
      outa[14..16]~  'set low
      dira[21..22]~~ 'set to output     
      outa[21..22]~  'set low
      
PRI Get_this_Setting(the_setting_name)
{
CON
  NET_MAC_ADDR       = "E"+("A"<<8)
  +++++++++++++++++++++++++++++++++++++++
 settings.setData(settings#NET_MAC_ADDR,string(02,01,01,01,01,01),6)
 +++++++++++++++++++++++++++++++++++++++++++
  if settings.getData(settings#NET_MAC_ADDR,@stack,6)
    term.str(string("MAC: "))
    repeat i from 0 to 5
      if i
        term.out("-")
      term.hex(byte[@stack][i],2)
    term.out(13)  

}
  the_setting_name := "i"+("d"<<8)
  
  if (settings.findKey(the_setting_name))
      return settings.getByte(the_setting_name)
  else
    return 0
      
PUB MAIN | Keyboard_Quadrant_Index, Keyboard_Key_Index, the_key 'starts cog 1 of 8
      settings.start 
      LCD_Display_Mode := 0
      initialize_pins
      Verbalizations.start(@Pot)    
      cognew(Analog_to_Digital_Conversion, @ADC_Stack)'start cog 2 of 8
      cognew(LCD_Display_Loop, @LCD_Stack)'start cog 3 of 8 
      
      repeat the_key from 0 to 38
        Key_State[the_key] := SILENCE
                                                                                
'*****MAIN LOOP*************************************************************************************************************
      repeat 'main loop
        wait_this_fraction_of_a_second(1000)'no need to go much faster than super human speed
         
        repeat Keyboard_Quadrant_Index from 1 to 33 step 8 'iterate through the Keyboard_Quadrant_Index
          'All go low
          outa[14..16]~  'set low
          outa[21..22]~  'set low
           
          case Keyboard_Quadrant_Index '###########
            1 : outa[15]~~  'set high  ############
            9 : outa[14]~~  'set high  ############
            17 : outa[16]~~  'set high  ###########
            25 : outa[21]~~  'set high  ###########
            33 : outa[22]~~  'set high  ###########
            other : 'this can't be happening! #####
           
          repeat Keyboard_Key_Index from 0 to 7 'read Keyboard_Key_Index ****
            the_key := Keyboard_Quadrant_Index + Keyboard_Key_Index
            if (the_key < 38)'limited by number of keys

              if(ina[Keyboard_Key_Index] == 1)
                Update_this_Keys_State(the_key, TRUE)
                
              else
                Update_this_Keys_State(the_key, FALSE)
          '******************************************************************
        
        case The_Mode 'Thirtyfifth_value_of_pot(Pot[MODE_POT])
          {
          DO_NOTHING = 0
          PLAY_PHONEMES = 1 
          RECORD_PHONEMES = 2
          PLAY_ALLOPHONES = 3
          RECORD_ALLOPHONES = 4
          PLAY_WORDS = 5
          RECORD_WORDS = 6
           }
          DO_NOTHING :
                                Verbalizations.release_test(1)

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
                                             
          RECORD_WORDS : 'RECORD_WORDS = 4
                                 repeat the_key from 1 to 37                      
                                     if (Key_State[the_key] == TRIGGER)'caught a trigger
                                         Verbalizations.go_test(the_key)
         OTHER :
             'do nothing
             Verbalizations.release_test(1)
                                             
'*****END MAIN LOOP*************************************************************************************************************         
     
   
PRI Run_LCD
    
  if LCD.init(LCD_Line, 9600, 2)
    wait_this_fraction_of_a_second(2) '250 milliseconds (1/4 second)
    'clear_lcd
    'see LCD commands at:
    'http://cdn.shopify.com/s/files/1/0038/9582/files/LCD117_Board_Command_Summary.pdf?1260768875
    'source:
    'http://shop.moderndevice.com/products/16-x-2-gray-lcd-and-lcd117-kit

    'LCD datasheet: http://cdn.shopify.com/s/files/1/0038/9582/files/MD_Blue16x2LCD_1602A.pdf?1260730783
    
    'LCD.str(string("?G216")) 'configure driver for 2 x 16 LCD
    'LCD.str(string("?>3"))'enter big number mode
    'LCD.str(string("?<"))'exit big number mode
    'LCD.str(string("?Bff"))'Backlight Intensity 
     'LCD.str(string("?L4"))'Low output on auxiliary digital pins 4[4,5,6]
     'LCD.str(string("?L5"))'Low output on auxiliary digital pins 5[4,5,6]
     'LCD.str(string("?L6"))'Low output on auxiliary digital pins 6[4,5,6]
     'LCD.str(string("?c0"))'Set Cursor Style: 0= none 2= blinking 3=underline
     'LCD.str(string("?!01"))'Send direct command to LCD of "01"
     'wait_this_fraction_of_a_second(2)

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

PRI LCD_Display_Loop

  Run_LCD
  'display_the_pots
  display_the_display
  display_the_display

  repeat
    display_the_pots

  
PRI display_the_pots | index
    LCD_home_then_here(0)
    'LCD.str(string(" p1="))
    repeat index from 0 to 15
    'LCD.str(string(" p0="))
      send(char_from_number(Thirtyfifth_value_of_pot(Pot[index])))
   
    wait_this_fraction_of_a_second(10)

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
PRI Analog_to_Digital_Conversion | index

  repeat index from 0 to 18
    Pot[index] := 0
    
  adc.Start(CLK_PIN, IO_CLOCK, ADDRESS, DATA_PIN, CS_PIN)
  wait_this_fraction_of_a_second(10)
  
  repeat
    'read the mode switch
    
    if(ina[MODE_S1] == 1)
      The_Mode := PLAY_PHONEMES
    else
      The_Mode := PLAY_ALLOPHONES
   
   {   
    if(ina[MODE_S2] == 1)
      The_Mode := PLAY_ALLOPHONES
    else
      The_Mode := PLAY_PHONEMES
    }
    
    'read the adc
    repeat index from 0 to 18
      Pot[index] := adc.Read(index)
    'wait_this_fraction_of_a_second(1000)

PRI map(da_value, da_minimum, da_maximum)

  return ((da_value*(da_maximum-da_minimum))/255)+da_minimum

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
  cog_id1 := Verbalizations.start'(a_tone)
  'Verbalizations.go
  RETURN cog_id1
  

PRI Stop_Saying_This_One(cog_id1)
  'freq.stop(cog_id1)
  'Verbalizations.done
  if cog_id1 > -1
    cogstop(cog_id1)
 
  }              