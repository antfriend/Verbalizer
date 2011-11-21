
OBJ
  freq  :       "FREQOUTMULTI"

PUB Play_Tone(tone_one, tone_two, for_duration) | cog_id1, cog_id2'duration of 1 = 1/10 second
  cog_id1 := freq.start(10, 11, -1, -1, -1, -1, 218, 438, 0, 0, 0, 0)
  cog_id2 := freq.start(10, 11, -1, -1, -1, -1, tone_one, tone_two, 0, 0, 0, 0)
  for_duration := 2000000 *  for_duration
  waitcnt(for_duration+cnt)
  freq.stop(cog_id1)
  freq.stop(cog_id2) 

PUB positive_result
    Play_Tone(880, 440, 3)
    Play_Tone(2200, 2200, 4)
    Play_Tone(8800, 4400, 5)

PUB negative_result
    Play_Tone(200, 400, 9)
    waitcnt(10000000+cnt)
    Play_Tone(200, 400, 9)
        