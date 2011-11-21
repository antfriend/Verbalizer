

CON
'********************************************************************
     _CLKMODE = XTAL1 + PLL16X
     _XINFREQ = 5_000_000
'********************************************************************
     LCD_Line = 12

OBJ
        LCD        :               "Serial_Lcd"
   
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
             

PUB MAIN | Keyboard_Quadrant_Index, Keyboard_Key_Index, key_state
      initialize_pins
      Run_LCD
        
     ' wait_this_fraction_of_a_second(1)'1/the_decimal, e.g. 1/2, 1/4th, 1/10

      repeat 'main loop
        
        
        repeat Keyboard_Quadrant_Index from 1 to 5'iterate through the Keyboard_Quadrant_Index
         'All go low
          outa[14..16]~  'set low
          outa[21..22]~  'set low
          case Keyboard_Quadrant_Index
            1 : outa[14]~~  'set high
            2 : outa[15]~~  'set high
            3 : outa[16]~~  'set high
            4 : outa[21]~~  'set high
            5 : outa[22]~~  'set high
            other : 'this can't be happening!
           
          repeat Keyboard_Key_Index from 0 to 7 'read Keyboard_Key_Index
            key_state := 0                    
            key_state := ina[Keyboard_Key_Index]~
            if(key_state == 0)
              This_Key_Pressed(0, 0)
            else
              This_Key_Pressed(Keyboard_Quadrant_Index, Keyboard_Key_Index)
           
PRI This_Key_Pressed(Quadrant, Key)
  'print to LCD
  send(char_from_number(Quadrant))
  send(",")
  send(char_from_number(Key))
  send(" ")
   
PRI Run_LCD
    
  if LCD.init(LCD_Line, 9600, 2)
    waitcnt(clkfreq / 4 + cnt)'250 milliseconds (1/4 second)
    clear_lcd
    'display_the_display
    'send("h")
    'send("o")
  clear_lcd
  waitcnt(clkfreq / 4 + cnt)
  display_the_display


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
  repeat the_iterator from 72 to 4 step 2 
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
      12..100 : char_val := "C"  
    return char_val

               