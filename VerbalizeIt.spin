CON
     _CLKMODE = XTAL1 + PLL16X
     _XINFREQ = 5_000_000

        voices = 4              'voices can be 1..4
        buffer_size = 4096     '$1000 spatializer buffer size (16 to 4096 longs) default=$1000

        LEFT_STEREO_PIN = 11 'lpos_pin
        RIGHT_STEREO_PIN = 10 'rpos_pin
        
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
        long pot_pointer
        
PUB start(the_pot_pointer) | i, r
    stop_signal := 1
    pot_pointer := the_pot_pointer
    repeat i from 0 to voices -1
      'each voice is not on a new cog, but each subsequent vocal tract is 
      input[i] := v[i].start(pot_pointer) 'starts cogs 4,5,6,7 of 8

    'knobs :=  %000_011_100_101   'start spatializer
    Set_Knobs_Value 
    
    's.start starts a new cog
    s.start(@input, @buffer, buffer_size, LEFT_STEREO_PIN, -1, RIGHT_STEREO_PIN, -1)'starts cog 8 of 8

    'initialize voices
    repeat i from 0 to voices -1
      key_index[i] := 100
      angle[i] := 32768  '65535..32768..0 ~ L..mid..R
      depth[i] := 100'?r & $FFF 'random depth
      Set_Knobs_Value
      v[i].go_null  
      'Set_Knobs_Value
      
PRI Set_Knobs_Value | da_knobs

    'knobs :=  %NNN_XXX_PPP_DDD
    'knobs :=  %000_011_100_110
    
    da_knobs := byte[pot_pointer][12]
    
    case da_knobs
      0..4 :
        knobs :=  %000_000_000_000
      5..9 :
        knobs :=  %001_011_001_001
      10..29 :
        knobs :=  %001_011_010_010
      30..59 :
        knobs :=  %001_011_010_011
      60..99 :
        knobs :=  %001_011_100_100
      100..160 :
        knobs :=  %001_010_101_101
      161..249 :
        knobs :=  %001_011_110_110
      250..257 :
        knobs :=  %001_100_111_111
        

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

    
PUB stop
   stop_signal := 100     

PUB go_test(the_key)
  v[0].go_test(the_key)
  return TRUE
  
PUB release_test(the_key)
  v[0].go_null
    
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
        if v[i].done
          v[i].go_sustain(the_key)
          'Set_Knobs_Value
  
PUB go_if_available(the_key) | i, r, voice_number
  {
    a key was pressed.  this checks if one of the voices is available.  if all voices are in use, nothing will happen
  }
 
  repeat i from 0 to voices -1
    if key_index[i] == the_key  'check if this key is already in use on one of the 4 voices 
       'check if it is done or not
        if v[i].done '
            key_index[i] := the_key
            play_this_one(i,the_key)
            return TRUE
        else
            return FALSE 'this key is in use                    

  repeat i from 0 to voices -1   
      if v[i].done
       
          key_index[i] := the_key
          play_this_one(i,the_key)
          return TRUE
            
  return FALSE 'a key was not triggered       


PRI play_this_one(da_index, da_key)

  angle[da_index] := (37 - da_key) * 1771  '65535..32768..0 ~ L..mid..R
  depth[da_index] := 1'32768'?r & $FFF 'random depth
  Set_Knobs_Value
  v[da_index].go_trigger(da_key)

PRI wait_this_fraction_of_a_second(the_decimal)'1/the_decimal, e.g. 1/2, 1/4th, 1/10
  waitcnt(clkfreq / the_decimal + cnt)'if the_decimal=4, then we wait 1/4 sec
              