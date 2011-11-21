{{
        talk!
}}

Con
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  Longer = 300
  Shorter = 80
  
VAR
  'vocal tract parameters
  byte aa,ga,gp,vp,vr,f1,f2,f3,f4,na,nf,fa,ff
  byte the_volume '0 to 255
  long nasal_freq_mod_pointer
  long f1_freq_mod_pointer
  long f2_freq_mod_pointer
  long f3_freq_mod_pointer
  long f4_freq_mod_pointer
   
OBJ
        v       : "VocalTract"

PUB start
  v.start(@aa,10,11,-1) 'start tract, output pins 10,11
{

}

PUB volume(this_volume)'0 to 255
      the_volume := this_volume
   ' aa := (the_volume * 0.1)
    'ga := (the_volume * 0.4)
          
PUB stop
  v.stop
  v.empty

PUB set_nasal_freq_mod_pointer(the_pointer)
      'this method should get called as part of an initialization routine in the calling object
     nasal_freq_mod_pointer := the_pointer
     
PUB set_f1_freq_mod_pointer(the_pointer)
    f1_freq_mod_pointer := the_pointer

PUB set_f2_freq_mod_pointer(the_pointer)
    f2_freq_mod_pointer := the_pointer

PUB set_f3_freq_mod_pointer(the_pointer)
    f3_freq_mod_pointer := the_pointer

PUB set_f4_freq_mod_pointer(the_pointer)
    f4_freq_mod_pointer := the_pointer
  
PUB bEEt
    setformants(310, 2000, 3100, 3700)                  'bEEt
    v.go(1)
                                                        'breathy
    aa := 3
    ga := 30
    
    v.go(Shorter)
    v.go(Longer)

PUB hAt
    setformants(730,1700,2500,3400)                     'hAt
    v.go(Shorter)
    v.go(Longer)

PUB hOt
    setformants(750,1050,2400,3200)                     'hOt
    ga := (the_volume * 0.9)
    v.go(Shorter)
    v.go(Longer)

PUB sOAp
    setformants(530, 950, 2400, 3200)                   'sOAp
    v.go(Shorter)
    v.go(Longer)

PUB boRRow
    setformants(580, 1200, 1500, 4700)                  'boRRow
    v.go(Shorter)
    v.go(Longer)

PUB baLL
    setformants(560, 850, 2600, 3600)                   'baLL
    v.go(Shorter)
    v.go(Longer)

PUB taper_to_silence    
    aa := 0                                             'taper to silence
    ga := 0
    fa := 0
    v.go(Shorter)

PUB pause
    v.go(Longer)                                           'pause

PUB randomize_values
    'randomize some values ********************************
    gp := rnd(60, 120)          'random glottal pitch
    vp := rnd(4, 48)            'random vibrato pitch
    vr := rnd(4, 30)            'random vibrato rate
  
PUB M
  setformants(170, 1100, 2600, 3200) 'M
  nf := 2900 * 100 /1953             'nasal
  na := 255
  v.go(1)

  aa := 10
  ga := 30
    
  v.go(150)

PUB M_adjustable | f1_mod, f2_mod, f3_mod, f4_mod, nf_mod

  f1_mod := LONG[f1_freq_mod_pointer]
  f2_mod := LONG[f2_freq_mod_pointer]
  f3_mod := LONG[f3_freq_mod_pointer]
  f4_mod := LONG[f4_freq_mod_pointer]
  nf_mod := LONG[nasal_freq_mod_pointer] 'read the value of the shared variable
  
 'f1_freq_mod_pointer
  setformants(f1_mod, f2_mod, f3_mod, f4_mod) 'M
  'setformants(170, 1100, 2600, 3200) 'M 
  nf := nf_mod             'nasal
  'nf := 2900 * 100 /1953             'nasal
  na := 255
  v.go(1)

  aa := 10
  ga := 30
    
  v.go(150)

PUB Say_This(m_aa, m_ga, m_gp, m_vp, m_vr, m_f1, m_f2, m_f3, m_f4, m_na, m_nf, m_fa, m_ff)  
    aa := m_aa

    v.go(100)
         
PUB yaeeoo

    randomize_values
    bEEt
    hAt
    hOt
    sOAp
    boRRow
    baLL
    taper_to_silence
    pause

PUB affirmative_sound
    randomize_values
    M
    hAt
    taper_to_silence
    'pause

PUB inquisitive_sound
    randomize_values
    M
    'bEEt
    'hAt
    hOt
    sOAp
    taper_to_silence
    'pause

PUB hello
    randomize_values
    'hhhhhhh
    ff := 2900 * 100 /1953             'voiceless fricative
    fa := 40
    v.go(1)
    fa := 0
    'eeeee
    bEEt
    
    baLL
    sOAp
    taper_to_silence
        
PUB blah

  randomize_values
  
  setformants(100, 200, 2800, 3750)
  v.go(rnd(100, 1000))

  setformants(400, 850, 2800, 3750)
  aa := 10
  ga := 20
  v.go(20)

  v.go(80)

  setformants(730, 1050, 2500, 3480)
  aa := 20
  ga := 30
  v.go(50)

  v.go(rnd(200, 1000))

  taper_to_silence
    
      
PRI setformants(s1, s2, s3, s4)
  f1 := s1 * 100 / 1953        
  f2 := s2 * 100 / 1953
  f3 := s3 * 100 / 1953
  f4 := s4 * 100 / 1953
    
PRI rnd(low, high)
  return low + ||(?cnt // (high - low + 1))
      