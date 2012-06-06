{{
Readme.spin
 *******************************************************************
 *********************** THE*VERBALIZER ****************************
 ***********************   by Dan Ray   ****************************
 *******************************************************************
 a one-of-a-kind musical instrument fashioned after the Mini-Moog
 and based on the vocal tract object by propeller chip creator,
 Chip Gracey
 
  Verbalizer.spin
        |
        Parallax Serial Terminal.spin
        VerbalizeIt.spin
        |       |
        |       Voice[4].spin
        |       | |
        |       | VocalTract.spin          TLC545C_Driver_Test.spin
        |       StereoSpatializer.spin     |              
        TLC545C.spin-----------------------^       
        settings.spin
                |
                Basic_I2C_Driver

                
***CONTROLS*********************************************************                
  the on/off switch is centrally located to the right of the head of
  the silver viking
  this switch also controls the amount of echo/reverb
  
  the three position toggle switch determines THE MODE, one of three,
  affecting all other controls
  || //  up - Words
  ||//   mid - Trigger Sustain Release
  ||/    dwn - Formants


***CONTROL MODE: Words**********************************************
  this is the easiest mode
  knob one sets duration of the word
  only one word set - planning to make each of the three knob areas
  control three different words on the respective areas of the keyboard
  

***CONTROL MODE: Trigger Sustain Release****************************

  this is the most powerful mode with the greatest variety of
  vocalizations
  the three knob areas control the three phases of a keystroke, left
  to right, trigger, sustain, and release
        the big knob with numerals sets the phoneme for the keyphase
        the little bottom knob sets the duration of the phase
        the red knobs set the vibrato pitch and modulation
        the remaining big knob sets the culminating volume - and is
        the primary way to remove the static crackle sound that occurs
        when there is a numerical overflow.  See Chip Gracey's notes
        in VocalTract.spin for more on numerical overflow.


***CONTROL MODE: Formants*******************************************
  this is the most difficult mode 
  ~ powering on while in this mode will cause the verbalizer to attempt
  to connect to a serial terminal on the usb port ~ power on in a different
  mode if not connecting to a serial terminal ~
  the knobs correspond to the 13 formants of speech, listed and
  illustrated in VocalTract.spin and printed and displayed on the
  verbalizer body - it is easy to make noise in this mode, but hard to
  make good verbalizations however, in this mode, you should be able to make
  any sound or part of a word that humans can create and many that we cant
  the plan is to add the ability to save formant mode creations as additional
  phonemes available for the trigger, sustain, and release mode
  
   











}}