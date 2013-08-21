********************************
SIMPLE SINE SYNTH - README
********************************
- Created by Daniel Houwen - danhouwen@gmail.com
********************************
SSSynth is a simple synthesizer program that combines signal processing concepts with music theory, and exhibits the
relationship between the two fields. Users can generate sine, square, and sawtooth waveforms for any frequency in the
Western chromatic scale. Chords may be generated from a set of popular chord types, or created manually by entering 
individual semitones. The length of the note may be controlled by either entering a duration in seconds or setting the 
tempo and note length. Up to five generated signals may be saved locally on the program and combined through additive
synthesis. The generated signals may be plotted in the time-domain (frequency-domain capabilities are planned). The
generated signals may also be saved as .wav files, to be used in external programs. 

Version 0.1 - 8/20/13

********************************
Running SSSynth
********************************

SSSynth can be started in two ways (64-bit Windows required):

1) Using MATLAB: 
- Add "generateWave.m", "synth.fig", and "synth.m" to the Current Folder on Matlab.
- Type "synth" into the Command Window.

2) Using the MATLAB Compiler Runtime:
- Go to the following site: http://www.mathworks.com/products/compiler/mcr/
- Download and install the 64-bit MCR for R2013a.
- Run the program "synth.exe".


********************************
Description of Functions
********************************

Note - Choose base note, from A through G, based on the chromatic scale.

Octave - Choose the octave , from 0-8, based on scientific pitch notation. This will transpose the root note to 
the octave chosen.

Waveform - Choose the waveform, between Sine, Square, and Sawtooth waves.
	Sub-Menu: Duty - Set the duty cycle of the square wave. Duty cycle is the ratio of the high period to 
		  the total period of the wave.
		  Width - Set the point on the period of the wave where the maximum occurs. If set to 0.5, the 
		  result will be a triangle wave. A value of 1 will result in a true sawtooth wave, and a value
		  of 0 will result in a reverse sawtooth wave.

Note Value - Choose the note value between Thirty-Second and Longa. Longa is equivalent to four whole notes, and 
every decreasing note value is half the length of the one before it. One whole note is equal to 4 beats in 4/4 time 
in Western musical notation, therefore one quarter note is equal to one beat.
	Sub-Menu: Dotted - A dotted note increases the duration of the original note by half of the original note's
		  duration. For example, a dotted half note is equal to three beats, or three quarter notes.

Tempo - Choose the tempo between 40bpm and 240bpm. 60bpm with Note Value = "Quarter" would result in a note duration 
of 1 second.

Duration - Choose the length of the note in seconds.

Triad Chord - Choose a triad chord to be generated instead of a single note. Triad chords consist of three notes, the lowest of which, called the root, being the "Note" selected. The second note, called the third, is either three semitones (minor chord) or four semitones (major chord) above the root. The third note, called the fifth, is either six (diminished), seven (perfect), or eight (augmented) semitones above the root. 
	Sub-Menu: Seventh - Adds a fourth note to the chord: a major seventh. This is 11 semitones above the root.

Custom Semitones - Choose semitones manually. A semitone is 1/12th of an octave, or the difference between an A
and an A# or an E and an F. For example, the semitones of a major chord would be 0 (root), 4 (third), and 7 (fifth).

Wave 1 through Wave 5 - Select the radio button to make each wave slot active. When "Generate Note" button is pressed
the note will be saved to the selected wave. The associated slider and text box allow the volume of the waves to
be adjusted when combining multiple waves.

Generate Note - Press to generate a signal based on chosen parameters. It will plot the signal, and save it to the
selected wave.

Play Note - After note has been generated, press to play the note on the speakers. 

Save Note - After note has been generated, press to save the note as "Note_###.wav". The first time a note is saved
a folder named "wavs" is created as the save location.

Play All Waves - After notes have been generated and saved to waves 1-5, press to combine the signals through
additive synthesis and play the note through the speakers.

Play Selected Waves - If a note has been generated and saved to a wave slot, it can be played by selecting the wave
and pressing this button.

Plot Waves - After notes have been generated and saved to waves 1-5, press to combine the signals through
additive synthesis and plot the signal on the screen.

Save Waves - After notes have been generated and saved to waves 1-5, press to combine the signals through
additive synthesis and save the signal as "Note_###.wav" in folder "wavs".

