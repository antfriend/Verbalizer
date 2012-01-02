CON
     _CLKMODE = XTAL1 + PLL16X
     _XINFREQ = 5_000_000

        voices = 4              'voices can be 1..4
        buffer_size = $1000     'spatializer buffer size

OBJ
        v [voices] : "Voice"
        s          : "StereoSpatializer"

VAR
        'spatializer parameters
        word input[voices], angle[voices], depth[voices], knobs

        'spatial delay buffer
        long buffer[buffer_size]
        byte stop_signal
        long key_index[voices]
        long status[voices]
     
PUB start | i, r
    stop_signal := 1
    repeat i from 0 to voices -1 
      input[i] := v[i].start'(da_gp)   'to spatializer inputs

    knobs :=  %000_011_100_101   'start spatializer
    {                                                                                                              │ 
│            ┌───────┬────────┬────────────┬───────────────┬────────────────────────────┐                          │ 
│            │ knobs │  %NNN  │    %XXX    │     %PPP      │            %DDD            │                          │ 
│            ├───────┼────────┼────────────┼───────────────┼────────────────────────────┤                          │ 
│            │ value │ dither │ cross echo │ parallel echo │      depth decay rate      │                          │ 
│            ├───────┼────────┼────────────┼───────────────┼────────────────────────────┤                          │ 
│            │  000 │ *-24dB*  │   -24dB    │     -24dB     │ -3dB per 32768 depth units│                          │ 
│            │  001  │ -27dB  │   -21dB    │     -21dB     │ -3dB per 16384 depth units │                          │ 
│            │  010  │ -30dB  │   -18dB    │     -18dB     │ -3dB per 8192 depth units  │                          │ 
│            │  011  │ -33dB │   *-15dB*    │     -15dB     │ -3dB per 4096 depth units │                          │ 
│            │  100  │ -36dB  │   -12dB   │     *-12dB*     │ -3dB per 2048 depth units │                          │ 
│            │  101  │ -39dB  │   -9dB     │     -9dB     │ *-3dB per 1024 depth units*  │                         │ 
│            │  110  │ -42dB  │   -6dB     │     -6dB      │ -3dB per 512 depth units   │                          │ 
│            │  111  │ -45dB  │   -3dB     │     -3dB      │ -3dB per 256 depth units   │                          │ 
│            └───────┴────────┴────────────┴───────────────┴────────────────────────────┘                          │ 
    }
    s.start(@input, @buffer, buffer_size, 11, -1, 10, -1)

    'initialize voices
    repeat i from 0 to voices -1
      key_index[i] := 100
      v[i].gone  

PUB stop
   stop_signal := 100     

PUB stop_if_available(the_key) | i, the_result

  the_result := FALSE
  
  repeat i from 0 to voices -1
    if key_index[i] == the_key  'check if this key is already in use on one of the 4 voices 
       'check if it is done or not
        'if v[i].done
        
           the_result := TRUE
           v[i].gone  
           'return TRUE

  return the_result
  
PUB go_if_available(the_key) | i, r, voice_number, the_pitch
  {
    a key was pressed.  this checks if one of the voices is available.  if all voices are in use, nothing will happen
  }
 
  repeat i from 0 to voices -1
    if key_index[i] == the_key  'check if this key is already in use on one of the 4 voices 
       'check if it is done or not
        if v[i].done
            angle[i] := (37 - the_key) * 1771  '65535..32768..0 ~ L..mid..R
            depth[i] := 32768'?r & $FFF 'random depth
            v[i].go(the_key)
            key_index[i] := the_key
            return TRUE

    else   
        if v[i].done
            angle[i] := (37 - the_key) * 1771  '65535..32768..0 ~ L..mid..R
            depth[i] := 32768'?r & $FFF 'random depth
            v[i].go(the_key)
            key_index[i] := the_key
            return TRUE
            
  return FALSE 'a key was not triggered       
              