# kolortrax
A psychedelic color tracking app 


## Description

Kolor Trax is a Processing sketch that utilizes the webcam of your computer to create a psychedelic, retro view of whatever you feed it. It is essentially a color tracker. The user can select a color to track via mouse click. Colors similar to the selected color will be highlighted. The highlighted areas can then be modified using a microcontroller or other MIDI device, or through TouchOSC. 

## Controls
MIDI channels 1-4 correspond to four pots on the microcontroller, however any MIDI controller can be used. 

Pots or sliders can be used for the following:
MIDI channel 1 controls the pixel size displayed in the sketch. It also controls the overall degrade sound effect in Max.
MIDI Channel 2 controls the red value of the RGB of the pixels being tracked.  It also controls the cutoff frequency of the Low Pass Filter applied to the overall sound in Max.
MIDI Channel 3 controls the green value of the RGB of the pixels being tracked. It also controls the fundamental frequency of the drone effect in Max.
MIDI Channel 4 controls the blue value of the RGB of the pixels being tracked. It also controls the resonance of the Low Pass Filter applied to the overall sound in Max

All four pots are currently controllable via TouchOSC as well. Future changes will incorporate all functionality available via the microcontroller into TouchOSC. 

## Buttons:
The background color is controlled by sound. When external audio reaches a certain threshold, a random-ish color is chosen for the background. If you like a color and want it to sick, there is a button that causes background changing to temporarily cease (MIDI channel 9). External sound also causes the pixel size to momentarily increase.
Another button  (MIDI channel 10) turns Perlin noise, a shader effect, on and off for the highlighted area. This same button also turns the sound component, controlled by Max/MSP, on and off. 
A final button (MIDI channel 3) switches the pixel shape from squares to circles or vice versa. It also controls the auto-filter effect in Max. The speed of this effect can be controlled with a photocell sensor on the microcontroller (MIDI channel 12). 
 
## Scope
In addition to controlling the color and shape of the pixels, a “scope” effect is also available. This is controlled via joystick. Use the joystick to select a square section of the video output. Once you’ve found a section you like, click on the joystick to create a scope that will bypass the color tracking effect and allow you to “see through” the sketch. Do this up to 8 times. If you want to clear all scopes, double click on the joystick and all scopes will disappear. 

## Max Patch / Sound Component
As previously mentioned, there is also an associated Max patch for this sketch. Initially, the patch is silent but can be turned on with a specific button (Midi channel 10). The patch functions by sounding five oscillators. The lowest-pitched oscillator is the fundamental tone and all others are integer multiples of the fundamental, based on the harmonic series. Depending on the number of pixels tracked by the Processing sketch, the harmonics change by scaling up or down. If more pixels are tracked, the harmonics scale up. Fewer means the harmonics scale down. Throughout, the fundamental frequency remains unchanged. 

Many of these controls correspond to sound reactions in the associated Max patch. 
The red pot controls the cutoff frequency for a low-pass filter applied to the final audio output. The blue pot controls the resonance of this filter. The green pot controls the fundamental frequency. Scaling this up or down scales all other oscillators along with it. Finally, the pot which controls pixel size corresponds to a “degrade” effect which causes the audio to degrade into lower quality by lowering its bit depth (analogous to the pixel size change). 

An FM modulation effect to the sound output can be applied via MIDI channel 11. This corresponds to the severity of the shader effect (turned on and off by MIDI channel 10). On the microcontroller, this is achieved via a Force Senstive Resistor. 

## TouchOSC
As mentioned before, all four pots which control pixel size and RGB values can be controlled via TouchOSC. In addition, there is a feature that is only available through TouchOSC: “PsychGen”. This effect is controlled via the bottom middle fader. When this slider passes to the right side, the effect is turned on and its severity is determined by how far the fader slides. 

KolorTrax listens for TouchOSC on UDP port 16000. 
It responds to float messages with the following routes:
* /1/rotary{1-4}
* /1/toggle{1-3}
* /1/fader2
