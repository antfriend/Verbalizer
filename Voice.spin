{{'**************************************************
  One of Four Voices, Used in the VerbalizeIt module
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

PUB go_test(the_key)
    set_gp_to_pitch(the_key)
    go_blah(the_key)
    v.go(100)
    bEEt_to_silence
    v.go(10)
    
PUB go_trigger(the_key) | the_pot
{' ******************************
 ' *       key pressed          *
}' ******************************
    set_gp_to_pitch(the_key)
    'always set gp before calling ga_wrapper
    
    vp := Convert_Pot_1_to_85(byte[the_pot_list_address][3])  '1 'rnd(4, 48)  
    vr := Convert_Pot_1_to_85(byte[the_pot_list_address][4]) '80 'rnd(4, 52) 52 ─ 4 Hz

    the_pot := byte[the_pot_list_address][0]
    Select_Allophone(the_pot, the_key)
    v.go(byte[the_pot_list_address][1]*2)
    
    repeat 6 'fill the buffer
      v.go(1)
    
PUB go_sustain(the_key) | the_pot  
{' ******************************
 ' *        key held            *
}' ******************************
  'set_gp_to_pitch(the_key)
  
    vp := Convert_Pot_1_to_85(byte[the_pot_list_address][8])  '1 'rnd(4, 48)  
    vr := Convert_Pot_1_to_85(byte[the_pot_list_address][9]) '80 'rnd(4, 52) 52 ─ 4 Hz
     
    the_pot := byte[the_pot_list_address][5]
    Select_Allophone(the_pot, the_key)
    v.go(byte[the_pot_list_address][6]*2)
    
  repeat 6 'fill the buffer
    v.go(1)

PUB go_release(the_key) | the_pot 
{' ******************************
 ' *       key released         *
}' ******************************
    'the_key := 1

    vp := Convert_Pot_1_to_85(byte[the_pot_list_address][15])  '1 'rnd(4, 48)  
    vr := Convert_Pot_1_to_85(byte[the_pot_list_address][16]) '80 'rnd(4, 52) 52 ─ 4 Hz
      
    the_pot := byte[the_pot_list_address][10]
    Select_Allophone(the_pot, the_key)
    v.go(byte[the_pot_list_address][11]*2)'50
    
    'now quickly go to silence
    bEEt_to_silence
    v.go(10)'50
     
    repeat 6
      v.go(1)

PUB go_null
  sOAp
  bEEt_to_silence
  v.go(1)
  
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
       9 : go_blah(the_key)
      10 : go_sustain_ah(the_key)

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
    
    'vp := 1 'rnd(4, 48)  
    'vr := 80 'rnd(4, 52) 52 ─ 4 Hz
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
    

PUB done
    return v.empty
          
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
 
PRI go_trigger_seven

{
  set_formants(470,1650,2500,3500)
  ff := 165<<3                                    
  go(10)
  set(fa, hivol[tract]/3)       'comment this line out to hear 'heaven' instead of 'seven'
  go(200)
  set(aa, hivol[tract]/2)
  go(50)
  set(fa, 0)
  go(50)  
  set(ga, hivol[tract])
  set_formants(700,1750,2500,3500)
  go(70)  
  set_formants(700,1500,2400,3400)
  go(150)  
  set_formants(600,1440,2300,3300)
  go(50)  
  set(ga, lowvol[tract])
  set(aa, 0)
  set(ff, 240 + tract<<2)
  go(20)
  set(fa, hivol[tract]/4)
  go(20)
  go(80)
  set(fa, 0)
  go(50)
  set(ga, hivol[tract])
  set(aa, hivol[tract]>>2)
  set_formants(500,1440,2300,3300)
  go(25)  
  set_formants(550,1750,2400,3400)
  go(60)
  go(50)
  set_formants(250,1700,2300,3400)
  set(nf, 2000/(19-tract))
  set(na, $FF)
  go(60)
  set(ga, hivol[tract])
  go(150)
  set(ga, 0)
  set(aa, 0)
  go(80)
  set(na, 0)
  go(200)
 }
 
PRI Convert_Pot_1_to_85(the_value)

    return the_value /3

PRI Convert_Pot_0_to_10 (the_value)

    return the_value /25

PRI Thirtyfifth_value_of_pot(pot_value) : the_decimal_value

  return pot_value/7
 