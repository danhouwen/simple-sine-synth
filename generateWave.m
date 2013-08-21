function x = generateWave(note,duration,wave,width,volume)
    % this function generates wave 'x', with a frequency of 'note', 
    % an amplitude 'volume', a width or duty value of 'width',
    % length of 'duration' seconds, and having shape 'wave'.
    % 1 - sine, 2 - square, 3 - sawtooth/triangle
    
    Fs = 44100; % default sampling frequency
    t = linspace(0,duration,duration*Fs); % generate time window
    switch wave % generate signal based on wave shape
        case 1
            x=volume*sin(2*pi*note*t); % sine
        case 2
            x=0.5*volume*square(2*pi*note*t,width*100); % square
        case 3
            x=volume*sawtooth(2*pi*note*t,width); % sawtooth
    end
    