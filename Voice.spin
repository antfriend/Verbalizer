'a voice

VAR
        'vocal tract paramters
        byte aa,ga,gp,vp,vr,f1,f2,f3,f4,na,nf,fa,ff
        
OBJ
        v       : "VocalTract"

PUB start

    v.start(@aa, -1, -1, -1) 'start tract, no pin outputs
    return v.sample_ptr

PUB ga_wrapper(the_value) | the_pitch
    'always set gp before calling ga_wrapper
    the_pitch := gp
    the_pitch := the_pitch / 4
    the_pitch := the_pitch - 12
    the_pitch := the_pitch / 2
    if (the_value > the_pitch)
      ga := the_value - the_pitch
    else
      ga := the_value

PUB go(the_key) | the_pitch
    go_blah(the_key)
    'go_minimum(the_key)
    
PUB go_blah(the_key) | the_pitch  'say "blah"
    'randomize some values ********************************

    setformants(400, 850, 2800, 3750)
    v.go(1)
    'gp := rnd(60, 120)          'random glottal pitch
    the_pitch := the_key + 12 '0-23 or 12 see table in FrequencyTable.xls
    the_pitch := the_pitch * 4

    'always set gp before calling ga_wrapper 
    gp := the_pitch 'rnd(60, 120)
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
  v.go(50)
  
  repeat 2 'fill the buffer
    v.go(1)'(rnd(200, 1000))
  'gone

PUB go_sustain(the_key)|the_pitch

    'randomize some values ********************************
    'gp := rnd(60, 120)          'random glottal pitch
    the_pitch := the_key + 12 '0-23 or 12 see table in FrequencyTable.xls
    the_pitch := the_pitch * 4

    'always set gp before calling ga_wrapper 
    gp := the_pitch 'rnd(60, 120)
    'always set gp before calling ga_wrapper
    
    vp := 20 'rnd(4, 48)  
    vr := 20 'rnd(4, 52)
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
  v.go(40)
  repeat 6 'fill the buffer
    v.go(1)'(rnd(200, 1000))
  'gone

    
PUB go_minimum(the_key) | the_pitch  'say "blah"
    'randomize some values ********************************
    'gp := rnd(60, 120)          'random glottal pitch
    the_pitch := the_key + 12 '0-23 or 12 see table in FrequencyTable.xls
    the_pitch := the_pitch * 4

    'always set gp before calling ga_wrapper 
    gp := the_pitch 'rnd(60, 120)
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

PUB gone
  {
  aa := 0
  fa := 0
  na := 0
  ga_wrapper(0)
  v.go(10)
  

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
  v.go(40)'50
  
  repeat 6
    v.go(1)'50


PUB done
    return v.empty
          
PRI setformants(s1, s2, s3, s4)
  f1 := s1 * 100 / 1953        
  f2 := s2 * 100 / 1953
  f3 := s3 * 100 / 1953
  f4 := s4 * 100 / 1953
    
PRI rnd(low, high)
  return low + ||(?cnt // (high - low + 1))
    