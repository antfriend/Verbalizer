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
    
    return v.sample_ptr

PUB go_trigger(the_key) | the_pot

    the_pot := byte[the_pot_list_address][1]
    case the_pot
      1 : go_blah(the_key)
      2 : go_ahh(the_key)
      3 : go_ahh(the_key)
      4 : go_ahh(the_key)
      other : go_blah(the_key)

PUB go_sustain(the_key) | the_pot  

  set_gp_to_pitch(the_key)
 
    the_pot := byte[the_pot_list_address][0]
    case the_pot
      1 : sOAp
      2 : bEEt
      3 : hAt
      4 : hOt
      5 : boRRow
      6 : baLL

      other : go_sustain_ah(the_key)

    v.go(40)
    
  repeat 6 'fill the buffer
    v.go(1)'(rnd(200, 1000))

PUB go_release | the_pot  

    the_pot := byte[the_pot_list_address][0]
    case the_pot
      1 : go_release_minimum
      2 : go_release_minimum

      other : go_release_minimum
   
PRI go_blah(the_key) 
    'randomize some values ********************************

    setformants(400, 850, 2800, 3750)
    v.go(1)
    set_gp_to_pitch(the_key) 
    'always set gp before calling ga_wrapper
    
    vp := 2 'rnd(4, 48)  
    vr := 92 'rnd(4, 52)
  'v.go(100)
  setformants(100, 200, 2800, 3750)
  'v.go(rnd(100, 1000))
  v.go(50) ' 1.4 milliseconds
  
  setformants(400, 850, 2800, 3750)
  aa := 10
  ga_wrapper(20)
  v.go(40)

  v.go(80)

  setformants(730, 1050, 2500, 3480)
  aa := 20
  ga_wrapper(30)
  na := 100       'added
  nf := 200      'added
  v.go(100)
  
  repeat 2 'fill the buffer
    v.go(1)'(rnd(200, 1000))

PRI go_ahh(the_key)

  set_gp_to_pitch(the_key)
    'always set gp before calling ga_wrapper
    
    vp := 2 'rnd(4, 48)  
    vr := 92 'rnd(4, 52)
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
  v.go(50)
  repeat 6
    v.go(25)'(rnd(200, 1000))
  'gone

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

PRI go_sustain_Vowel(the_case, the_key)
  set_gp_to_pitch(the_key)
       
  sOAp
  v.go(40)
    
  repeat 7 'fill the buffer
    v.go(1)'(rnd(200, 1000))
    
         
PRI go_sustain_ah(the_key)

    set_gp_to_pitch(the_key)
    'always set gp before calling ga_wrapper
    
    vp := 1 'rnd(4, 48)  
    vr := 80 'rnd(4, 52) 52 ─ 4 Hz
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
    
PRI go_release_minimum
  {
  setformants(730, 1050, 2500, 3480)'(400, 850, 2800, 3750)
  ga_wrapper(20)
  v.go(150)
  
  setformants(100, 200, 2800, 3750)
  'v.go(rnd(100, 1000))
  v.go(2) ' 1.4 milliseconds

  v.go(80)

  
  aa := 0
  'setformants(100, 100, 100, 100)
  
  fa := 0
  na := 0
  }
  ga_wrapper(0)
  aa := 0
  fa := 0
  na := 0
  v.go(100)'50
  
  repeat 6
    v.go(1)'50


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
  
PRI bEEt
    setformants(310, 2000, 3100, 3700)                  'bEEt
    v.go(1)                                                       'breathy
    aa := 3
    ga_wrapper(30)

PRI hAt
    setformants(730,1700,2500,3400)                     'hAt

PRI hOt
    setformants(750,1050,2400,3200)                     'hOt
    'ga := (the_volume * 0.9)

PRI sOAp
    setformants(530, 950, 2400, 3200)                   'sOAp

PRI boRRow
    setformants(580, 1200, 1500, 4700)                  'boRRow

PRI baLL
    setformants(560, 850, 2600, 3600)                   'baLL

PRI taper_to_silence    
    aa := 0                                             'taper to silence
    ga := 0
    fa := 0
