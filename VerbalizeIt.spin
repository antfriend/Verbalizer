CON
     _CLKMODE = XTAL1 + PLL16X
     _XINFREQ = 5_000_000

        voices = 3              'voices can be 1..4
        buffer_size = $1000     'spatializer buffer size

OBJ
        v [voices] : "Blah"
        s          : "StereoSpatializer"

VAR
        'spatializer parameters
        word input[4], angle[4], depth[4], knobs

        'spatial delay buffer
        long buffer[buffer_size]
        byte stop_signal
        
PUB start | i, r
    stop_signal := 1
    repeat i from 0 to voices -1 
      input[i] := v[i].start'(da_gp)   'to spatializer inputs

    knobs :=  %000_011_100_101   'start spatializer
    s.start(@input, @buffer, buffer_size, 11, -1, 10, -1)

    'i := 0
    'v[i].go
    {
    if v[i].done
          angle[i] := ?r 'random angle
          depth[i] := ?r & $FFF 'random depth
          
          'v[i].go
   }
PUB stop
   stop_signal := 100     

PUB stop_this_voice(voice_number)
  'if v[voice_number].done
    'then there's nothing else to do
  'else
     'v[voice_number].gone

PUB go_available(the_key) | i, r, voice_number, the_pitch

  the_pitch := the_key + 12 '0-23 or 12 see table in FrequencyTable.xls
  the_pitch := the_pitch * 4

  'need to either limit use to one or something
                    
  repeat i from 0 to voices -1
      if v[i].done
          angle[i] := (37 - the_key) * 1771  '65535..32768..0 ~ L..mid..R
          depth[i] := 32768'?r & $FFF 'random depth
          v[i].go(the_pitch)
          voice_number := i
          return voice_number
          
              