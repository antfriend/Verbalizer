'************************************************************************************************************
'************************************************************************************************************
'************************************************************************************************************
'******************************************                                 *********************************
'******************************************          the verbalizer         *********************************
'******************************************                                 *********************************
'************************************************************************************************************
'************************************************************************************************************
'************************************************************************************************************


CON
     _CLKMODE = XTAL1 + PLL16X
     _XINFREQ = 5_000_000
    
  'Pins                    
  COM_RX   = 2       ' Say-It Module RX Pin             
  COM_TX   = 1       ' Say-It Module TX Pin             
  VRLED    = 0       ' Say-It Module LED Pin

'********************************************************************  
    SAY_BAUD  = 9600
'********************************************************************
  LCD_Line = 12
  bottom_Pot_Line = 13
  top_left_Pot_Line = 14
  top_right_Pot_Line = 15

  button_Line = 16
   
  left_Pot_Line = 21
  right_Pot_Line = 22
  on_Pot_Line = 23

  'f1_string = char("f1=0")

 
VAR
        Byte the_LED_test
        
        LONG listener_cog_ID 
        LONG listener_stack[150]
        LONG SayItMessageAddress
                
        LONG mode_cog_ID
        LONG mode_cog_stack[500]
        
        LONG pot_position[6] 'the array of all the values
        BYTE pot_formant[4] ' the array of which pot has what
        LONG formant_values[14] 'the array of pot-scale values for all formants - base 1
        LONG left_pot_number
        LONG right_pot_number
        LONG on_pot_number
        LONG top_left_pot_number
        LONG top_right_pot_number
        LONG bottom_pot_number

        byte aa,ga,gp,vp,vr        
        
        LONG f1
        LONG f2
        LONG f3
        LONG f4
        LONG na
        LONG nf
        LONG fa
        LONG ff

                           
OBJ
     'listen     :               "SayItDriver_free"   'this is the listening module                
     sounds     :               "Sounds"             '
     talk       :               "Talk"               'synthesized speech
     blah       :               "Play_Blah"
     'LCD        :               "Serial_Lcd"
     pst        :               "Parallax Serial Terminal"                   ' Serial communication object


PUB MAIN | the_listener, index, value, what_do_you_think_I_said, new_pot, the_mode, uhm_what_did_you_say, an_iterator, button_state  

  '************************************************
    '************* Initialization *******************
      '************************************************
      
  initialize_LEDs
  'if LCD.init(LCD_Line, 9600, 2)
    'initialize_LEDs  
  talk.start
  'talk.volume(100)
  'set variable default values
  'setformants(170, 1100, 2600, 3200)
  'nf := 2900 * 100 /1953
  f1 := 170  '40-781
  f2 := 1100 '56-1094
  f3 := 2600 '128-2500
  f4 := 1000 '179-3496
  nf := 2900 * 100 /1953 '102-1992
  talk.set_f1_freq_mod_pointer(@f1)
  talk.set_f2_freq_mod_pointer(@f2)
  talk.set_f3_freq_mod_pointer(@f3)
  talk.set_f4_freq_mod_pointer(@f4)
  talk.set_nasal_freq_mod_pointer(@nf)
  cycle_LEDs
  pst.Start(115200) '115200
  sounds.positive_result

  repeat
    value := get_string_from_processing_app 'get the value    
    pst.Dec(value)'send the value back      'send it back
    flush_serial

    
PRI initialize_LEDs | the_iterator
  repeat the_iterator from 16 to 23
    dira[the_iterator]~~
  all_LEDs_off
  
  
PRI all_LEDs_off | the_iterator
  repeat the_iterator from 16 to 23
    outa[the_iterator]~


PRI all_LEDs_on | the_iterator
  repeat the_iterator from 16 to 23
    outa[the_iterator]~~


PRI blink
    outa[23]~~
    waitcnt(clkfreq / 4 + cnt)'(1/8 second)
    outa[23]~

  
PRI cycle_LEDs | the_iterator
  'the_iterator := 6
  repeat the_iterator from 64 to 16 step 4
    outa[23]~~
    waitcnt(clkfreq / the_iterator + cnt)'(1/8 second)
    outa[23]~
    waitcnt(clkfreq / (the_iterator/2) + cnt)'(1/8 second)
    
  waitcnt(clkfreq / 4 + cnt)'(1/4 second)


PRI flush_serial
  pst.RxFlush


PRI get_string_from_processing_app : value

  all_LEDs_off
  'if pst.RxCheck => 0 
    'value := pst.DecIn
    value := pst.BinIn
    if value > 1000
       '
        case value
          1001 : 'aa=
             outa[18]~~
           
          1002 .. 999_000_000 : 'ga=
             outa[19]~~
             
          1_000_000_000 .. 2_000_000_000 :
             outa[20]~~
                                             
          other :
             outa[21]~~
          
                     
        if value < 10_000
             outa[17]~~
             
        else
           outa[22]~~
                                                 
    else
       case value
         1 : outa[16]~~
         2 : outa[17]~~
         3 : outa[18]~~
         4 : outa[19]~~
         50 .. 55 : outa[20]~~
         55 .. 69 : outa[21]~~
         70 .. 999 : outa[22]~~  
         other : outa[23]~~
       
  'waitcnt(clkfreq / 8 + cnt)'(1/4 second)
       
  'pst.StrIn(@the_in_string)
  'if
   ' blink
  'else
    'cycle_LEDs
  return value      









   