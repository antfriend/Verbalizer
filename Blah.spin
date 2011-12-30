'Blah

VAR
        'vocal tract paramters
        byte aa,ga,gp,vp,vr,f1,f2,f3,f4,na,nf,fa,ff
OBJ
        v       : "VocalTract"

PUB start

    v.start(@aa, -1, -1, -1) 'start tract, no pin outputs
    return v.sample_ptr

PUB go(da_gp)  'say "blah"
    'randomize some values ********************************
    'gp := rnd(60, 120)          'random glottal pitch
    gp := da_gp 'rnd(60, 120)
    vp := 4 'rnd(4, 48)            'random vibrato pitch
    vr := 12 'rnd(4, 30)            'random vibrato rate

  setformants(100, 200, 2800, 3750)
  'v.go(rnd(100, 1000))
  v.go(1)
  
  setformants(400, 850, 2800, 3750)
  aa := 10
  ga := 20
  v.go(20)

  v.go(80)

  setformants(730, 1050, 2500, 3480)
  aa := 20
  ga := 30
  v.go(50)

  v.go(400)'(rnd(200, 1000))
  gone

PUB gone

  aa := 0
  ga := 0
  v.go(50)'50


PUB done
    return v.empty
          
PRI setformants(s1, s2, s3, s4)
  f1 := s1 * 100 / 1953        
  f2 := s2 * 100 / 1953
  f3 := s3 * 100 / 1953
  f4 := s4 * 100 / 1953
    
PRI rnd(low, high)
  return low + ||(?cnt // (high - low + 1))
    