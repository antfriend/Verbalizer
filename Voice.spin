{{'**************************************************
  One of up to Four VocalTract module Voices, Used in the VerbalizeIt module
}}'**************************************************

CON
  Longer = 300
  Shorter = 80
  
VAR       
        'vocal tract paramters
        byte aa,ga,gp,vp,vr,f1,f2,f3,f4,na,nf,fa,ff
        long the_pot_list_address
        
OBJ
        v       : "VocalTract"

PUB start(the_pot_pointer)

    v.start(@aa, -1, -1, -1) 'start tract, no pin outputs
    
    the_pot_list_address := the_pot_pointer
    set_gp_to_pitch(1)
    bEEt_to_silence
    v.go(1)
    return v.sample_ptr

PUB done
    return v.empty

PUB go_test(the_key) | the_pitch_adjust

    f1 := byte[the_pot_list_address][3] '* 100 / 1953 '19.53 Hz    1st resonator frequency: 40 -> 781 Hz
    f2 := byte[the_pot_list_address][4] '* 100 / 1953  '19.53 Hz   2nd resonator frequency: 56 -> 1094 Hz
    f3 := byte[the_pot_list_address][2] '* 100 / 1953  '19.53 Hz   3rd resonator frequency: 128 -> 2500 Hz
    f4 := byte[the_pot_list_address][1] '* 100 / 1953  '19.53 Hz   4th resonator frequency: 179 -> 3496 Hz

    aa := byte[the_pot_list_address][0]
     
     the_pitch_adjust := Convert_Pot_0_to_12(byte[the_pot_list_address][5])
     the_pitch_adjust := the_pitch_adjust - 6
    set_gp_to_pitch(the_key + the_pitch_adjust)
    'always set gp before calling ga_wrapper
    ga_wrapper(Convert_Pot_1_to_85(byte[the_pot_list_address][7]))
    
    vp := Convert_Pot_1_to_85(byte[the_pot_list_address][8])  '1 'rnd(4, 48)  
    vr := Convert_Pot_1_to_85(byte[the_pot_list_address][9]) '80 'rnd(4, 52)     

    na := byte[the_pot_list_address][14]
    nf := byte[the_pot_list_address][15] '* 100 / 1953 
    
    fa := byte[the_pot_list_address][10]
    ff := byte[the_pot_list_address][13] '* 100 / 3906 '0-255 works best? 39.06 Hz  2344 Hz ("Sh")
  
    v.go(byte[the_pot_list_address][6]*2)
    repeat 7
      v.go(1)
    
PUB go_trigger(the_key) 
{' ******************************
 ' *       key pressed          *
}' ******************************
    set_gp_to_pitch(the_key)
    'always set gp before calling ga_wrapper
    
    vp := Convert_Pot_1_to_85(byte[the_pot_list_address][3])  '1 'rnd(4, 48)  
    vr := Convert_Pot_1_to_85(byte[the_pot_list_address][4]) '80 'rnd(4, 52) 

    Select_Allophone(byte[the_pot_list_address][0], the_key)
    'always set gp before calling ga_wrapper
    ga_wrapper(Convert_Pot_1_to_85(byte[the_pot_list_address][2]))
    v.go(byte[the_pot_list_address][1]*2)
    
    repeat 6 'fill the buffer
      v.go(1)
    
PUB go_sustain(the_key) 
{' ******************************
 ' *        key held            *
}' ******************************
  'set_gp_to_pitch(the_key)
    
    vp := Convert_Pot_1_to_85(byte[the_pot_list_address][8])  '1 'rnd(4, 48)  
    vr := Convert_Pot_1_to_85(byte[the_pot_list_address][9]) '80 'rnd(4, 52) 

    Select_Allophone(byte[the_pot_list_address][5], the_key)
    'always set gp before calling ga_wrapper
    ga_wrapper(Convert_Pot_1_to_85(byte[the_pot_list_address][7]))
    v.go(byte[the_pot_list_address][6]*2)
    
  repeat 6 'fill the buffer
    v.go(1)

PUB go_release(the_key) 
{' ******************************
 ' *       key released         *
}' ******************************
    'the_key := 1
    
    vp := Convert_Pot_1_to_85(byte[the_pot_list_address][15])  '1 'rnd(4, 48)  
    vr := Convert_Pot_1_to_85(byte[the_pot_list_address][16]) '80 'rnd(4, 52) 
   
    Select_Allophone(byte[the_pot_list_address][10], the_key)
    'always set gp before calling ga_wrapper
    ga_wrapper(Convert_Pot_1_to_85(byte[the_pot_list_address][14]))
    v.go(byte[the_pot_list_address][11]*2)'50
    
    'now quickly go to silence
    bEEt_to_silence
    v.go(10)'50
     
    repeat 6
      v.go(1)

PUB trigger_word(the_key)
  'go_trigger_seven
  go_blah(the_key)
  go_null
  'repeat 2 'fill the buffer
    'v.go(1)'(rnd(200, 1000))
 
PUB go_null
  'sOAp
  
  Select_Allophone(byte[the_pot_list_address][11], 1)
    ga_wrapper(0)
    aa := 0
    fa := 0
    na := 0
    
  'bEEt_to_silence   
  v.go(30)
  
PRI Select_Allophone(the_pot_value, the_key)

    set_gp_to_pitch(the_key)

    the_pot_value := Thirtyfifth_value_of_pot(the_pot_value)
    case the_pot_value
       0 : bEEt_to_silence
       1 : bEEt_to_silence
       2 : bEEt_to_silence
       3 : sOAp
       4 : bEEt
       5 : hAt
       6 : hOt
       7 : boRRow
       8 : baLL
       9 : formants_ee
      10 : formants_i
      11 : formants_e
      12 : formants_a
      13 : formants_o
      14 : formants_oh 'oh   foot boot r    l    uh 
      15 : formants_foot
      16 : formants_boot
      17 : formants_r
      18 : formants_l
      19 : formants_uh
       
      34 : go_blah(the_key)
      35 : go_sustain_ah(the_key)

      other : play_the_key(the_key)
      
PRI play_the_key(the_key)
'************************************************
'** press a key to select a recorded allophone **
'************************************************
  setformants(400, 850, 2800, 3750)
  ff := 200
  fa := 40
  'na := 100
  'nf := 200
       
PRI go_blah(the_key) 
    'randomize some values ********************************

    setformants(400, 850, 2800, 3750)
    v.go(1)
    set_gp_to_pitch(the_key) 
    'always set gp before calling ga_wrapper
    
    'vp := 2 'rnd(4, 48)  
    'vr := 92 'rnd(4, 52)
  'v.go(100)
  setformants(100, 200, 2800, 3750)
  'v.go(rnd(100, 1000))
  v.go(50) ' 1.4 milliseconds
  
  setformants(400, 850, 2800, 3750)
  aa := 10
  ga_wrapper(20)
  v.go(40)

  v.go(byte[the_pot_list_address][1])

  setformants(730, 1050, 2500, 3480)
  aa := 20
  ga_wrapper((byte[the_pot_list_address][1]/3))
  na := 100       'added
  nf := 200      'added
  v.go(4*byte[the_pot_list_address][1])
  
  'repeat 2 'fill the buffer
    'v.go(1)'(rnd(200, 1000))

PRI go_ahh(the_key)

  set_gp_to_pitch(the_key)
    'always set gp before calling ga_wrapper
    
    'vp := 2 'rnd(4, 48)  
    'vr := 92 'rnd(4, 52)
  {
  setformants(100, 200, 2800, 3750)
  'v.go(rnd(100, 1000))
  v.go(2) ' 1.4 milliseconds
  
  setformants(400, 850, 2800, 3750)
  aa := 10
  ga_wrapper(20)
  v.go(40)

  v.go(80)
  }
  setformants(730, 1050, 2500, 3480)
  aa := 20
  ga_wrapper(30)
  na := 100       'added
  nf := 200      'added
  'v.go(4*byte[the_pot_list_address][1])
  'repeat 6
    'v.go(25)'(rnd(200, 1000))
  'gone
       
PRI go_sustain_ah(the_key)

    set_gp_to_pitch(the_key)
    'always set gp before calling ga_wrapper
  {
  setformants(100, 200, 2800, 3750)
  'v.go(rnd(100, 1000))
  v.go(2) ' 1.4 milliseconds
  
  setformants(400, 850, 2800, 3750)
  aa := 10
  ga_wrapper(20)
  v.go(40)

  v.go(80)
  }
  setformants(730, 1050, 2500, 3480)
  aa := 2
  ga_wrapper(30)
  na := 20       'added
  nf := 60      'added
         
PRI setformants(s1, s2, s3, s4)
  f1 := s1 * 100 / 1953        
  f2 := s2 * 100 / 1953
  f3 := s3 * 100 / 1953
  f4 := s4 * 100 / 1953
{
 other variants of this method

    f1 := (sf1 + jj/2) / jj  <# 255
    f2 := (sf2 + jj/2) / jj  <# 255
    f3 := (sf3 + jj/2) / jj  <# 255
    f4 := (sf4 + jj/2) / jj  <# 255


  repeat i from 0 to 3
    vt[tract*13+f1+i] := sf1[i] / (19 - tract)


  vt[tract*13+f1] := sf1 / 19
  vt[tract*13+f2] := sf2 / 19
  vt[tract*13+f3] := sf3 / 19
  vt[tract*13+f4] := sf4 / 19
 
}    
PRI rnd(low, high)
  return low + ||(?cnt // (high - low + 1))

PRI ga_wrapper(the_value) | the_pitch
    'always set gp before calling ga_wrapper
    the_pitch := gp
    the_pitch := the_pitch / 4
    the_pitch := the_pitch - 12
    the_pitch := the_pitch / 2
    if (the_value > the_pitch)
      ga := the_value - the_pitch
    else
      ga := the_value

PRI set_gp_to_pitch(the_key)|the_pitch
    the_pitch := the_key + 12 '0-23 or 12 see table in FrequencyTable.xls
    the_pitch := the_pitch * 4

    'always set gp before calling ga_wrapper 
    gp := the_pitch 'rnd(60, 120)
    
' ************************************************
' **   ALLOPHONES   ******************************
' ************************************************
 
PRI bEEt_to_silence    
    'setformants(310, 2000, 3100, 3700)'like bEEt
    bEEt
    ga_wrapper(0)
    aa := 0
    fa := 0
    na := 0
    
PRI sOAp
    setformants(530, 950, 2400, 3200)                   'sOAp
    ga_wrapper(30)
    aa := 0

PRI bEEt
    setformants(310, 2000, 3100, 3700)                  'bEEt
    ga_wrapper(30)                                                       'breathy
    aa := 3

PRI hAt
    setformants(730,1700,2500,3400)                     'hAt
    ga_wrapper(30)
    aa := 0
    
PRI hOt
    setformants(750,1050,2400,3200)                     'hOt
    ga_wrapper(30)
    aa := 0

PRI boRRow
    setformants(580, 1200, 1500, 4700)                  'boRRow
    ga_wrapper(30)
    aa := 0

PRI baLL
    setformants(560, 850, 2600, 3600)                   'baLL
    ga_wrapper(30)
    aa := 0

PRI go_release_minimum

  bEEt_to_silence
 
PRI go_trigger_seven | base_volume
  {
  base_volume := 30
  
  setformants(470,1650,2500,3500)
  ff := 165<<3                                    
  v.go(10)
  fa := base_volume/3       'comment this line out to hear 'heaven' instead of 'seven'
  v.go(200)
  aa := base_volume/2
  v.go(50)
  fa := 0
  v.go(50)  
  ga := base_volume
  setformants(700,1750,2500,3500)
  v.go(70)  
  setformants(700,1500,2400,3400)
  v.go(150)  
  setformants(600,1440,2300,3300)
  v.go(50)  
  ga := base_volume/5
  aa := 0
  ff := 240
  v.go(20)
  fa := 10
  v.go(20)
  v.go(80)
  fa := 0
  v.go(50)
  ga := base_volume
  aa := 2
  setformants(500,1440,2300,3300)
  v.go(25)  
  setformants(550,1750,2400,3400)
  v.go(60)
  v.go(50)
  setformants(250,1700,2300,3400)
  nf := 2000/18
  na := 255
  v.go(60)
  ga:= base_volume
  v.go(150)
  ga := 0 '*************
  aa := 0
  v.go(80)
  na := 0
  v.go(200)
} 
PRI Convert_Pot_1_to_85(the_value)
  return the_value /3

PRI Thirtyfifth_value_of_pot(pot_value) : the_decimal_value
  return pot_value/7

PRI Convert_Pot_0_to_12 (the_value)
  return the_value /21

PRI Convert_Pot_0_to_10 (the_value)
  return the_value /25

PRI formants_ee
  set(0)
    ga_wrapper(30)
    aa := 0
    fa := 0

PRI formants_i
  set(1)
    ga_wrapper(30)
    aa := 0
    fa := 0

PRI formants_e
  set(2)
    ga_wrapper(30)
    aa := 0
    fa := 0

PRI formants_a
  set(3)
    ga_wrapper(30)
    aa := 0
    fa := 0

PRI formants_o
  set(4)
    ga_wrapper(30)
    aa := 0
    fa := 0

PRI formants_oh
  set(5)
    ga_wrapper(30)
    aa := 0
    fa := 0

PRI formants_foot
  set(6)
    ga_wrapper(30)
    aa := 0
    fa := 0

PRI formants_boot
  set(7)
    ga_wrapper(30)
    aa := 0
    fa := 0

PRI formants_r
  set(8)
    ga_wrapper(30)
    aa := 0
    fa := 0

PRI formants_l
  set(9)
    ga_wrapper(30)
    aa := 0
    fa := 0

PRI formants_uh
  set(10)
    ga_wrapper(30)
    aa := 0
    fa := 0
  
PRI set(i) | jj
    jj := 19   -7
    f1 := (f1s[i] + jj/2) / jj
    f2 := (f2s[i] + jj/2) / jj
    f3 := (f3s[i] + jj/2) / jj
    f4 := (f4s[i] + jj/2) / jj


PRI set_dat_formants(sf1,sf2,sf3,sf4)|jj
    jj := 19   -7
    f1 := (sf1 + jj/2) / jj  <# 255
    f2 := (sf2 + jj/2) / jj  <# 255
    f3 := (sf3 + jj/2) / jj  <# 255
    f4 := (sf4 + jj/2) / jj  <# 255
{
Allophone Knobs

********BEER
knob0 = 0, 0
knob1 = 0, 0
knob2 = 255, 36
knob3 = 47, 6
knob4 = 165, 23
knob5 = 31, 4
knob6 = 14, 2
knob7 = 105, 15
knob8 = 8, 1
knob9 = 115, 16
knob10 = 118, 16
knob11 = 95, 13
knob12 = 0, 0
knob13 = 3, 0
knob14 = 3, 0
knob15 = 74, 10
knob16 = 10, 1
knob17 = 3, 0
knob18 = 3, 0

}
DAT

        '     ee   i    e    a    o    oh   foot boot r    l    uh
f1s     long  0280,0450,0550,0700,0775,0575,0425,0275,0560,0560,0700
f2s     long  2040,2060,1950,1800,1100,0900,1000,0850,1200,0820,1300
f3s     long  3040,2700,2600,2550,2500,2450,2400,2400,1500,2700,2600
f4s     long  3600,3570,3400,3400,3500,3500,3500,3500,3050,3600,3100
 