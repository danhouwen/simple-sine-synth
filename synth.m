function varargout = synth(varargin)
% SYNTH M-file for synth.fig
%      SYNTH, by itself, creates a new SYNTH or raises the existing
%      singleton*.
%
%      H = SYNTH returns the handle to a new SYNTH or the handle to
%      the existing singleton*.
%
%      SYNTH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SYNTH.M with the given input arguments.
%
%      SYNTH('Property','Value',...) creates a new SYNTH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before synth_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to synth_OpeningFcn via varargin.
%
% Created by: Daniel Houwen (danhouwen@gmail.com)
% Last Modified by GUIDE v2.5 20-Aug-2013 22:24:55

% Initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @synth_OpeningFcn, ...
                   'gui_OutputFcn',  @synth_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before synth is made visible.
function synth_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to synth (see VARARGIN)

% choose default command line output for synth
handles.output = hObject;

% set default values / initialize variables
set(handles.octaveMenu,'Value',5);
set(handles.valueMenu,'Value',5);
handles.wavCount = 0;

% grey out non-active text boxes
set(handles.freqText,'BackgroundColor',[0.8,0.8,0.8]);
set(handles.tone1,'BackgroundColor',[0.8 0.8 0.8]);
set(handles.tone2,'BackgroundColor',[0.8 0.8 0.8]);
set(handles.tone3,'BackgroundColor',[0.8 0.8 0.8]);
set(handles.tone4,'BackgroundColor',[0.8 0.8 0.8]);

% generate empty notes
handles.wave1Note = zeros(1,88200);
handles.wave2Note = zeros(1,88200);
handles.wave3Note = zeros(1,88200);
handles.wave4Note = zeros(1,88200);
handles.wave5Note = zeros(1,88200);

% create location for note .wav files
handles.files=dir('wavs/note_*.wav');

% generate startup sine wave
handles.finalNote = generateWave(261.6,0.5,1,0,1);
plot(handles.axes1,handles.finalNote(1:2000))
title('First 2000 Samples of generated sound')

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = synth_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in generateButton.
function generateButton_Callback(hObject, eventdata, handles)
% hObject    handle to generateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set note as 'generated'
set(handles.playButton,'userData',1);

% get note and octave from menus
    note = get(handles.noteMenu,'Value');
    octave = get(handles.octaveMenu,'Value')-1;
    
    % if 'Triad Chord' is selected (bold), use preset chords
    if strcmp(get(handles.chordText,'FontWeight'),'bold')
        % based on chord/single note selection
        switch get(handles.chordMenu,'Value')
            case 1 % single note
                trueFreq=0;
            case 2 % major
                note = [note note+4 note+7]; % create chord
                trueFreq=[0 0 0];
            case 3 % minor
                note = [note note+3 note+7];
                trueFreq=[0 0 0];
            case 4 % augmented
                note = [note note+4 note+8];
                trueFreq=[0 0 0];
            case 5 % diminished
                note = [note note+3 note+6];
                trueFreq=[0 0 0];
            case 6 % suspended second
                note = [note note+2 note+7];
                trueFreq=[0 0 0];
            case 7 % suspended fourth
                note = [note note+5 note+7];
                trueFreq=[0 0 0];
        end
    
        % add minor seventh (10 semitones)
        if get(handles.chordButton,'Value')
            note = [note note(1)+10];
        end
    else % if 'Custom Semitones' is selected, use entered numbers
        tone1 = str2double(get(handles.tone1,'String'));
        tone2 = str2double(get(handles.tone2,'String'));
        tone3 = str2double(get(handles.tone3,'String'));
        tone4 = str2double(get(handles.tone4,'String'));
        note = [note tone1 tone2 tone3 tone4];
    end
    
    % assign note value (in terms of measures)
    switch get(handles.valueMenu,'Value')
        case 1
            noteValue = 16; % Ionga
        case 2
            noteValue = 8; % Double Whole
        case 3
            noteValue = 4; % Whole
        case 4
            noteValue = 2; % Half
        case 5
            noteValue = 1; % Quarter 
        case 6
            noteValue = 0.5; % Eighth
        case 7
            noteValue = 0.25; % Sixteenth
        case 8
            noteValue = 0.125; % Thirty-second
    end
    
    % check for dotted notes
    if get(handles.dotted,'Value')
        noteValue = noteValue + noteValue/2;
    end
    
    % set duration based on tempo or custom duration based on selection
    if strcmp(get(handles.tempoText,'FontWeight'), 'bold') % tempo
        tempo = str2double(get(handles.editTempo,'String'));
        duration = 60/tempo*noteValue; % resultant duration
        set(handles.freqText,'String',duration); 
    else % custom duration
        duration = str2double(get(handles.freqText,'String'));
        tempo = 60/duration*noteValue; % resultant tempo
        set(handles.editTempo,'String',tempo); 
        set(handles.tempoSlider,'Value',tempo);
    end
    
    % get wave shape, width/duty, and volume from selection
    wave = get(handles.waveMenu,'Value'); 
    width = str2double(get(handles.editWidth,'String'));
    volume = str2double(get(handles.editVolume,'String'))/100;
    
    % CHORD LOOP
    % initialize variables
    prevNote = zeros(1,floor(duration*44100));
    trueFreq = zeros(1,length(note));
    % repeat for each note in the chord
    for i=1:length(note)
        switch note(i)
            case 1
                baseFreq = 16.35; % C
            case 2
                baseFreq = 17.325; % C#
            case 3
                baseFreq = 18.355; % D
            case 4
                baseFreq = 19.45; % D#
            case 5
                baseFreq = 20.60; % E
            case 6
                baseFreq = 21.825; % F
            case 7
                baseFreq = 23.125; % F#
            case 8
                baseFreq = 24.50; % G
            case 9
                baseFreq = 25.955; % G#
            case 10
                baseFreq = 27.50; % A
            case 11
                baseFreq = 29.135; % A#
            case 12
                baseFreq = 30.87; % B
            case 13
                baseFreq = 32.70; % C
            case 14
                baseFreq = 34.65; % C#
            case 15
                baseFreq = 36.71; % D
            case 16
                baseFreq = 38.89; % D#
            case 17
                baseFreq = 41.20; % E
            case 18
                baseFreq = 43.65; % F
            case 19
                baseFreq = 46.25; % F#
            case 20
                baseFreq = 49.00; % G
        end
        trueFreq(i)=baseFreq*2^octave; % find true frequency
        % create current note based on selected parameters
        currentNote = generateWave(trueFreq(i),duration,wave,width,volume);
        
        finalNote = prevNote + currentNote; % additive chord synthesis
        prevNote = finalNote; % update previous note for chord synthesis
    end
    
    % save generated note to the selected wave (1-5)
    if get(handles.wave1Button,'Value')
        handles.wave1Note=generateWave(trueFreq(1),2,wave,width,1);   
    elseif get(handles.wave2Button,'Value')
        handles.wave2Note=generateWave(trueFreq(1),2,wave,width,1);
    elseif get(handles.wave3Button,'Value')
        handles.wave3Note=generateWave(trueFreq(1),2,wave,width,1);
    elseif get(handles.wave4Button,'Value')
        handles.wave4Note=generateWave(trueFreq(1),2,wave,width,1);
    elseif get(handles.wave5Button,'Value')
        handles.wave5Note=generateWave(trueFreq(1),2,wave,width,1);
    end
    
    % plot the first 2000 samples of the note (for readability)
    if length(finalNote) > 2000
        plot(handles.axes1,finalNote(1:2000))
    else
        plot(handles.axes1,finalNote)
    end
    axes(handles.axes1)
    title('First 2000 Samples of generated sound')
    
    % update global variables
    handles.finalNote = finalNote;
    guidata(hObject, handles);

    
% --- Executes during object creation, after setting all properties.
function noteMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function octaveMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in waveMenu.
function waveMenu_Callback(hObject, eventdata, handles)

% turn additional menus on/off depending on wave type
waveChoice = get(handles.waveMenu,'Value');
if  waveChoice == 1 % if sine, no additional menu needed
    set(handles.dutyText,'Visible','off');
    set(handles.widthText,'Visible','off');
    set(handles.editWidth,'Visible','off');
elseif waveChoice == 2 % show duty menu for square wave
    set(handles.dutyText,'Visible','on');
    set(handles.widthText,'Visible','off');
    set(handles.editWidth,'Visible','on');
else % show width menu for sawtooth wave
    set(handles.dutyText,'Visible','off');
    set(handles.widthText,'Visible','on');
    set(handles.editWidth,'Visible','on');
end
 

% --- Executes during object creation, after setting all properties.
function waveMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function tempoSlider_Callback(hObject, eventdata, handles)

% if tempo slider is used, show updated values in tempo text and duration
sliderValue = get(handles.tempoSlider,'Value');
set(handles.editTempo,'String',num2str(sliderValue));
set(handles.freqText,'BackgroundColor',[0.8,0.8,0.8]); 
set(handles.editTempo,'BackgroundColor',[1,1,1]); 
set(handles.tempoText,'FontWeight','bold');
set(handles.durationText,'FontWeight','normal');


% --- Executes during object creation, after setting all properties.
function tempoSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on selection change in editTempo.
function editTempo_Callback(hObject, eventdata, handles)
% if tempo text is used, show updated values in tempo slider and duration
sliderValue = str2double(get(handles.editTempo,'String'));
% if blank or incorrect text is given, set to default
if (isempty(sliderValue) || sliderValue < 40 || sliderValue > 240)
    set(handles.tempoSlider,'Value',120);
    set(handles.editTempo,'String','120');
else
    set(handles.tempoSlider,'Value',sliderValue);
end

set(handles.freqText,'BackgroundColor',[0.8,0.8,0.8]);
set(handles.editTempo,'BackgroundColor',[1,1,1]);
set(handles.tempoText,'FontWeight','bold');
set(handles.durationText,'FontWeight','normal');


% --- Executes during object creation, after setting all properties.
function editTempo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function valueMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% normalize signal to prevent clipping
finalNote = handles.finalNote/max(abs(handles.finalNote));
% play note
sound(finalNote,44100);


% --- Executes on change to editWidth.
function editWidth_Callback(hObject, eventdata, handles)

% if an invalid point is entered, set to default
widthValue = str2double(get(handles.editWidth,'String'));
if (isempty(widthValue) || widthValue < 0 || widthValue > 1)
   set(handles.editWidth,'String','0.5');
end


% --- Executes during object creation, after setting all properties.
function editWidth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function volumeSlider_Callback(hObject, eventdata, handles)

% set the volume text to the position of the volume slider
sliderValue = get(handles.volumeSlider,'Value');
set(handles.editVolume,'String',num2str(sliderValue));


% --- Executes during object creation, after setting all properties.
function volumeSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on change to editVolume.
function editVolume_Callback(hObject, eventdata, handles)

% set the position of the slider based on the input volume text
% if invalid volume is given, set to default value
sliderValue = str2num(get(handles.editVolume,'String'));
if (isempty(sliderValue) || sliderValue < 0 || sliderValue > 100)
    set(handles.volumeSlider,'Value',100);
    set(handles.editVolume,'String','100');
else
    set(handles.volumeSlider,'Value',sliderValue);
end


% --- Executes during object creation, after setting all properties.
function editVolume_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in chordMenu.
function chordMenu_Callback(hObject, eventdata, handles)

% if chordMenu is changed, grey out 'Custom Semitones'
set(handles.chordMenu,'BackgroundColor',[1,1,1]);
set(handles.chordText,'FontWeight','bold');
set(handles.tone1,'BackgroundColor',[0.8 0.8 0.8]);
set(handles.tone2,'BackgroundColor',[0.8 0.8 0.8]);
set(handles.tone3,'BackgroundColor',[0.8 0.8 0.8]);
set(handles.tone4,'BackgroundColor',[0.8 0.8 0.8]);
set(handles.toneText,'FontWeight','normal');


% --- Executes during object creation, after setting all properties.
function chordMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chordButton.
function chordButton_Callback(hObject, eventdata, handles)

% if chordButton is changed, grey out 'Custom Semitones'
set(handles.chordMenu,'BackgroundColor',[1,1,1]);
set(handles.chordText,'FontWeight','bold');
set(handles.tone1,'BackgroundColor',[0.8 0.8 0.8]);
set(handles.tone2,'BackgroundColor',[0.8 0.8 0.8]);
set(handles.tone3,'BackgroundColor',[0.8 0.8 0.8]);
set(handles.tone4,'BackgroundColor',[0.8 0.8 0.8]);
set(handles.toneText,'FontWeight','normal');

% --- Executes on change in text to tone1.
function tone1_Callback(hObject, eventdata, handles)

% if semitones are edited, grey out 'Triad Chord' menu
set(handles.chordMenu,'BackgroundColor',[0.8,0.8,0.8]);
set(handles.chordText,'FontWeight','normal');
set(handles.tone1,'BackgroundColor',[1 1 1]);
set(handles.tone2,'BackgroundColor',[1 1 1]);
set(handles.tone3,'BackgroundColor',[1 1 1]);
set(handles.tone4,'BackgroundColor',[1 1 1]);
set(handles.toneText,'FontWeight','bold');

% if invalid tone is entered, set tone to 0
tone = str2double(get(handles.tone1,'String'));
if (isempty(tone) || tone < 0 || tone > 20)
    set(handles.tone1,'String','0');
else % ensure all tones are integers
    set(handles.tone1,'String',num2str(round(tone)));
end


% --- Executes during object creation, after setting all properties.
function tone1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on change in text to tone2.
function tone2_Callback(hObject, eventdata, handles)

% if semitones are edited, grey out 'Triad Chord' menu
set(handles.chordMenu,'BackgroundColor',[0.8,0.8,0.8]);
set(handles.chordText,'FontWeight','normal');
set(handles.tone1,'BackgroundColor',[1 1 1]);
set(handles.tone2,'BackgroundColor',[1 1 1]);
set(handles.tone3,'BackgroundColor',[1 1 1]);
set(handles.tone4,'BackgroundColor',[1 1 1]);
set(handles.toneText,'FontWeight','bold');

% if invalid tone is entered, set tone to 0
tone = str2double(get(handles.tone2,'String'));
if (isempty(tone) || tone < 0 || tone > 20)
    set(handles.tone2,'String','0');
else % ensure all tones are integers
    set(handles.tone2,'String',num2str(round(tone)));
end


% --- Executes during object creation, after setting all properties.
function tone2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on change in text to tone3.
function tone3_Callback(hObject, eventdata, handles)

% if semitones are edited, grey out 'Triad Chord' menu
set(handles.chordMenu,'BackgroundColor',[0.8,0.8,0.8]);
set(handles.chordText,'FontWeight','normal');
set(handles.tone1,'BackgroundColor',[1 1 1]);
set(handles.tone2,'BackgroundColor',[1 1 1]);
set(handles.tone3,'BackgroundColor',[1 1 1]);
set(handles.tone4,'BackgroundColor',[1 1 1]);
set(handles.toneText,'FontWeight','bold');

% if invalid tone is entered, set tone to 0
tone = str2double(get(handles.tone3,'String'));
if (isempty(tone) || tone < 0 || tone > 20)
    set(handles.tone3,'String','0');
else % ensure all tones are integers
    set(handles.tone3,'String',num2str(round(tone)));
end


% --- Executes during object creation, after setting all properties.
function tone3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on change in text to tone4.
function tone4_Callback(hObject, eventdata, handles)

% if semitones are edited, grey out 'Triad Chord' menu
set(handles.chordMenu,'BackgroundColor',[0.8,0.8,0.8]);
set(handles.chordText,'FontWeight','normal');
set(handles.tone1,'BackgroundColor',[1 1 1]);
set(handles.tone2,'BackgroundColor',[1 1 1]);
set(handles.tone3,'BackgroundColor',[1 1 1]);
set(handles.tone4,'BackgroundColor',[1 1 1]);
set(handles.toneText,'FontWeight','bold');

% if invalid tone is entered, set tone to 0
tone = str2double(get(handles.tone4,'String'));
if (isempty(tone) || tone < 0 || tone > 20)
    set(handles.tone4,'String','0');
else % ensure all tones are integers
    set(handles.tone4,'String',num2str(round(tone)));
end


% --- Executes during object creation, after setting all properties.
function tone4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function freqText_Callback(hObject, eventdata, handles)

% if invalid duration is entered, set duration to 1
duration = str2double(get(handles.freqText,'String'));
if (isnan(duration) || duration < 0.01 || duration > 10)
    set(handles.freqText,'String','1');
end

% grey out tempo text and slider if duration is activated
set(handles.editTempo,'BackgroundColor',[0.8,0.8,0.8]);
set(handles.freqText,'BackgroundColor',[1,1,1]);
set(handles.durationText,'FontWeight','bold');
set(handles.tempoText,'FontWeight','normal');


% --- Executes during object creation, after setting all properties.
function freqText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function wave1Slider_Callback(hObject, eventdata, handles)
% update wave1 text if slider is changed
sliderValue = get(handles.wave1Slider,'Value');
set(handles.wave1Edit,'String',num2str(sliderValue));


% --- Executes during object creation, after setting all properties.
function wave1Slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function wave2Slider_Callback(hObject, eventdata, handles)
% update wave2 text if slider is changed
sliderValue = get(handles.wave2Slider,'Value');
set(handles.wave2Edit,'String',num2str(sliderValue));


% --- Executes during object creation, after setting all properties.
function wave2Slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function wave3Slider_Callback(hObject, eventdata, handles)
% update wave3 text if slider is changed
sliderValue = get(handles.wave3Slider,'Value');
set(handles.wave3Edit,'String',num2str(sliderValue));


% --- Executes during object creation, after setting all properties.
function wave3Slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function wave4Slider_Callback(hObject, eventdata, handles)
% update wave4 text if slider is changed
sliderValue = get(handles.wave4Slider,'Value');
set(handles.wave4Edit,'String',num2str(sliderValue));


% --- Executes during object creation, after setting all properties.
function wave4Slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function wave5Slider_Callback(hObject, eventdata, handles)
% update wave5 text if slider is changed
sliderValue = get(handles.wave5Slider,'Value');
set(handles.wave5Edit,'String',num2str(sliderValue));


% --- Executes during object creation, after setting all properties.
function wave5Slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in wave1Button.
function wave1Button_Callback(hObject, eventdata, handles)
% turn all other wave buttons off
set(handles.wave2Button,'Value',0.0)
set(handles.wave3Button,'Value',0.0)
set(handles.wave4Button,'Value',0.0)
set(handles.wave5Button,'Value',0.0)


% --- Executes on button press in wave5Button.
function wave5Button_Callback(hObject, eventdata, handles)
% turn all other wave buttons off
set(handles.wave2Button,'Value',0.0)
set(handles.wave3Button,'Value',0.0)
set(handles.wave4Button,'Value',0.0)
set(handles.wave1Button,'Value',0.0)


% --- Executes on button press in wave4Button.
function wave4Button_Callback(hObject, eventdata, handles)
% turn all other wave buttons off
set(handles.wave2Button,'Value',0.0)
set(handles.wave3Button,'Value',0.0)
set(handles.wave1Button,'Value',0.0)
set(handles.wave5Button,'Value',0.0)


% --- Executes on button press in wave3Button.
function wave3Button_Callback(hObject, eventdata, handles)
% turn all other wave buttons off
set(handles.wave2Button,'Value',0.0)
set(handles.wave1Button,'Value',0.0)
set(handles.wave4Button,'Value',0.0)
set(handles.wave5Button,'Value',0.0)


% --- Executes on button press in wave2Button.
function wave2Button_Callback(hObject, eventdata, handles)
% turn all other wave buttons off
set(handles.wave1Button,'Value',0.0)
set(handles.wave3Button,'Value',0.0)
set(handles.wave4Button,'Value',0.0)
set(handles.wave5Button,'Value',0.0)


% --- Executes on change to wave1 text.
function wave1Edit_Callback(hObject, eventdata, handles)
% set wave1 slider to match text. if invalid input, set to default
sliderValue = str2double(get(handles.wave1Edit,'String'));
if (isempty(sliderValue) || sliderValue < 0 || sliderValue > 120)
    set(handles.wave1Slider,'Value',100);
    set(handles.wave1Edit,'String','100');
else
    set(handles.wave1Slider,'Value',sliderValue);
end


% --- Executes during object creation, after setting all properties.
function wave1Edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on change to wave2 text.
function wave2Edit_Callback(hObject, eventdata, handles)
% set wave2 slider to match text. if invalid input, set to default
sliderValue = str2double(get(handles.wave2Edit,'String'));
if (isempty(sliderValue) || sliderValue < 0 || sliderValue > 120)
    set(handles.wave2Slider,'Value',100);
    set(handles.wave2Edit,'String','100');
else
    set(handles.wave2Slider,'Value',sliderValue);
end


% --- Executes during object creation, after setting all properties.
function wave2Edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on change to wave3 text.
function wave3Edit_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% set wave3 slider to match text. if invalid input, set to default
sliderValue = str2double(get(handles.wave3Edit,'String'));
if (isempty(sliderValue) || sliderValue < 0 || sliderValue > 120)
    set(handles.wave3Slider,'Value',100);
    set(handles.wave3Edit,'String','100');
else
    set(handles.wave3Slider,'Value',sliderValue);
end


% --- Executes during object creation, after setting all properties.
function wave3Edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on change to wave4 text.
function wave4Edit_Callback(hObject, eventdata, handles)
% set wave4 slider to match text. if invalid input, set to default
sliderValue = str2double(get(handles.wave4Edit,'String'));
if (isempty(sliderValue) || sliderValue < 0 || sliderValue > 120)
    set(handles.wave4Slider,'Value',100);
    set(handles.wave4Edit,'String','100');
else
    set(handles.wave4Slider,'Value',sliderValue);
end


% --- Executes during object creation, after setting all properties.
function wave4Edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on change to wave5 text.
function wave5Edit_Callback(hObject, eventdata, handles)
% set wave5 slider to match text. if invalid input, set to default
sliderValue = str2double(get(handles.wave5Edit,'String'));
if (isempty(sliderValue) || sliderValue < 0 || sliderValue > 120)
    set(handles.wave5Slider,'Value',100);
    set(handles.wave5Edit,'String','100');
else
    set(handles.wave5Slider,'Value',sliderValue);
end


% --- Executes during object creation, after setting all properties.
function wave5Edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% compile all the waves into one signal through additive synthesis
function fullNote = additiveSynthesis(handles)
wav1 = get(handles.wave1Slider,'Value')*handles.wave1Note/100;
wav2 = get(handles.wave2Slider,'Value')*handles.wave2Note/100;
wav3 = get(handles.wave3Slider,'Value')*handles.wave3Note/100;
wav4 = get(handles.wave4Slider,'Value')*handles.wave4Note/100;
wav5 = get(handles.wave5Slider,'Value')*handles.wave5Note/100;

fullNote = wav1+wav2+wav3+wav4+wav5;


% --- Executes on button press in allButton.
function allButton_Callback(hObject, eventdata, handles)
% compile all waves into one signal and play
fullNote = additiveSynthesis(handles);
soundsc(fullNote,44100);


function fileName = wavCounter(hObject,eventdata,handles)
% create local variable for faster execution
wavCount = handles.wavCount;

% if wavCount has not been established, find current note count
if (wavCount==0) 
    if(exist('wavs','dir')~=7) % does the directory exist?
        mkdir('wavs') % create directory named 'wavs'
    else % directory already exists
        if(~isempty(handles.files)) % are there files in the directory?
            prevCount = 0; % establish previous count for comp.
            for x=1:length(handles.files) % cycle through files
                % extract the note count from filename
                wavCount = str2double(handles.files(x).name(6:8));
                if (prevCount < wavCount) % compare current and previous
                    prevCount = wavCount;
                end
            end
        end
    end
end
wavCount = wavCount + 1; % increment global wavCount
  
% create file name by string concatenation
if (wavCount<10)
    fileName = ['wavs/note_00',num2str(wavCount),'.wav'];
elseif (wavCount<100)
    fileName = ['wavs/note_0',num2str(wavCount),'.wav'];
else
    fileName = ['wavs/note_',num2str(wavCount),'.wav'];
end

% update global variable
handles.wavCount = wavCount;
guidata(hObject,handles);


% --- Executes on button press in saveWaveButton.
function saveWaveButton_Callback(hObject, eventdata, handles)
% perform additive synthesis to find complete signal
fullNote = additiveSynthesis(handles); 
% create file name based on current wav# in folder
fileName = wavCounter(hObject,eventdata,handles);

% normalize the note to prevent clipping
saveNote = 0.9999*fullNote/max(abs(fullNote));

% save file as .wav and alert user
wavwrite(saveNote,44100,fileName);
msgbox(['File "', fileName(6:17), '" has been created.']);



function noteMenu_Callback(hObject, eventdata, handles)
% empty function, no action to be taken during change in noteMenu

function octaveMenu_Callback(hObject, eventdata, handles)
% empty function, no action to be taken during change in octaveMenu

function valueMenu_Callback(hObject, eventdata, handles)
% empty function, no action to be taken during change in valueMenu


% --- Executes on button press in waveButton.
function waveButton_Callback(hObject, eventdata, handles)
% play the wave that is currently selected
if get(handles.wave1Button,'Value')
        sound(handles.wave1Note*get(handles.wave1Slider,'Value')/100,44100);   
    elseif get(handles.wave2Button,'Value')
        sound(handles.wave2Note*get(handles.wave2Slider,'Value')/100,44100);   
    elseif get(handles.wave3Button,'Value')
        sound(handles.wave3Note*get(handles.wave3Slider,'Value')/100,44100);   
    elseif get(handles.wave4Button,'Value')
        sound(handles.wave4Note*get(handles.wave4Slider,'Value')/100,44100);   
    elseif get(handles.wave5Button,'Value')
        sound(handles.wave5Note*get(handles.wave5Slider,'Value')/100,44100);   
end


% --- Executes on button press in plotWaveButton.
function plotWaveButton_Callback(hObject, eventdata, handles)
% plot the output of all waves after additive synthesis
fullNote = additiveSynthesis(handles);
plot(handles.axes1,fullNote(1:2000))
title('First 2000 Samples of the addition of all waves')

% --- Executes on button press in saveNoteButton.
function saveNoteButton_Callback(hObject, eventdata, handles)
% generate file name based on the current wav# in the folder
fileName = wavCounter(hObject,eventdata,handles);
finalNote = handles.finalNote; % import global variable

% normalize the note to prevent clipping
finalNote = 0.9999*finalNote/max(abs(finalNote));

% save file as .wav and alert user
wavwrite(finalNote,44100,fileName);
msgbox(['File "', fileName(6:17), '" has been created.']);


% --- Executes on button press in dotted.
function dotted_Callback(hObject, eventdata, handles)
% empty function, no action to be taken during change in dotted
