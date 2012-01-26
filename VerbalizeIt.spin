CON
     _CLKMODE = XTAL1 + PLL16X
     _XINFREQ = 5_000_000

        voices = 3              'voices can be 1..4, but we dont have all 4 cogs available
        buffer_size = $1000     '$1000 spatializer buffer size

        me_high = 1
        me_low  = 0
        
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

        'verbal_state queue
        long Verbal_Space[100]'stack space allotment
        long verbal_state[voices] 'can be me_high, me_low
        
PUB start(the_pot_pointer) | i, r
    stop_signal := 1
   
    repeat i from 0 to voices -1
      'each voice is not on a new cog, but each subsequent vocal tract is 
      input[i] := v[i].start(the_pot_pointer) 'start cogs 4,5,6 of 8

    'knobs :=  %000_011_100_101   'start spatializer
    knobs :=  %000_011_100_110   'start spatializer
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
│            │  101  │ -39dB  │   -9dB     │     -9dB     │* -3dB per 1024 depth units * │                         │ 
│            │  110  │ -42dB  │   -6dB     │     -6dB     │X -3dB per 512 depth units X  │                         │ 
│            │  111  │ -45dB  │   -3dB     │     -3dB      │ -3dB per 256 depth units   │                          │ 
│            └───────┴────────┴────────────┴───────────────┴────────────────────────────┘                          │ 
    }
    
    's.start starts a new cog
    s.start(@input, @buffer, buffer_size, 11, -1, 10, -1)'start cog 7 of 8

    'initialize voices
    repeat i from 0 to voices -1
      key_index[i] := 100
      angle[i] := 18 * 1771  '65535..32768..0 ~ L..mid..R
      depth[i] := 0'?r & $FFF 'random depth
      v[i].go_null  

    'cognew(Monitor_Verbal_Status, @Verbal_Space)'start cog 8 of 8
    
PUB stop
   stop_signal := 100     

PUB Monitor_Verbal_Status | index
  'verbal_state[voices]
  
  repeat 'forever!
    wait_this_fraction_of_a_second(1000)
    
    repeat index from 0 to voices-1
      'if any voices are "done" update the verbal_state status     
      if(v[index].done)
        verbal_state[index] := me_low    
        
    repeat index from 0 to voices-1
      'if any voices are "started" and the voice is done, start the voice
      if(verbal_state[index] == me_high)
          verbal_state[index] := me_low        
          play_this_one(index, key_index[index])
          
   
PUB stop_if_available(the_key) | i, the_result

  the_result := FALSE
  
  repeat i from 0 to voices -1
    if key_index[i] == the_key  'check if this key is already in use on one of the 4 voices 
        
           the_result := TRUE
           v[i].go_release(the_key)  

  return the_result

PUB go_sustain(the_key) | i, r, voice_number

    repeat i from 0 to voices -1 
      if key_index[i] == the_key
        v[i].go_sustain(the_key)
  
PUB go_if_available(the_key) | i, r, voice_number
  {
    a key was pressed.  this checks if one of the voices is available.  if all voices are in use, nothing will happen
  }

  'here I seem to be stealing from voices in sustain

  'key_index[i] := the_key
  'verbal_state[i] := me_high
  'return TRUE
  
  repeat i from 0 to voices -1
    if key_index[i] == the_key  'check if this key is already in use on one of the 4 voices 
       'check if it is done or not
        if v[i].done '
            key_index[i] := the_key
            play_this_one(i,the_key)
            'verbal_state[i] := me_high
            return TRUE
        else
            return FALSE 'this key is in use                    

  repeat i from 0 to voices -1   
      if v[i].done
       
          key_index[i] := the_key
          play_this_one(i,the_key)
          'verbal_state[i] := me_high
          return TRUE
            
  return FALSE 'a key was not triggered       


PRI play_this_one(da_index, da_key)

  angle[da_index] := (37 - da_key) * 1771  '65535..32768..0 ~ L..mid..R
  depth[da_index] := 0'32768'?r & $FFF 'random depth
  v[da_index].go_trigger(da_key)

PRI wait_this_fraction_of_a_second(the_decimal)'1/the_decimal, e.g. 1/2, 1/4th, 1/10
  waitcnt(clkfreq / the_decimal + cnt)'if the_decimal=4, then we wait 1/4 sec
              