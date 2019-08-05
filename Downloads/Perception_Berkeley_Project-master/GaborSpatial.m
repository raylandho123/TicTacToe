clear all; close all; clc;
%% Load Screen
Info = {'Number','Initials','Gender [1=Male,2=Female,3=Other]','Age','Ethnicity', 'Handedness'}; % making questionare
dlg_title = 'Subject Information'; % making questionare
num_lines = 1; % making questionare
subject_info = inputdlg(Info,dlg_title,num_lines);% storing the values in subject_info

subj = subject_info(1);
nameID = subject_info(2);
age = subject_info(4);
gender = subject_info(3);
hand = subject_info(6);
ethnicity = subject_info(5);

Screen('Preference', 'SkipSyncTests', 1);% Skip screen tests
[window, rect] = Screen('OpenWindow', 0); % opening the screen
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % allowing transparency in the photos
[width, height] = Screen('DisplaySize',0);

HideCursor(); % hiding the cursor
window_w = rect(3); % window width
window_h = rect(4);% window height

x_center = window_w/2;% window x center
y_center = window_h/2;% window y center


Screen('FillRect',window,[127 127 127],rect); % make the whole screen gray 

rect1 = [0 0 720 450];

black = 0;
white = 255;
red = [255,0,0];
grey = 127;
size_img_angle = 6;
length_size_img = tan((size_img_angle/ 2) * (pi / 180)) * 57;
widthOfGrid = ((1920 / (20*2.54)) * length_size_img * 2);
% This script is part of the main script. Don't run it independently.    
% Contrast increment range for given white and gray values:
inc=abs(white-grey); 
% Gabor parameters:
sigma = 30;  % Standard deviation in pixels, here I set it to 50 as default
phase=0;     % in radians(0-2*pi),here I set it to 0 as default
sf=2.5;      % sf: spatial frequency in cycles per degree
halfWidthOfGrid = widthOfGrid/2;
widthArray=(-halfWidthOfGrid):halfWidthOfGrid;  % widthArray is used in creating the meshgrid.
[x, y] = meshgrid(widthArray, widthArray);

for ang=1:360                % ang: orientation of gabor patch in degrees
    tiltInRadians = ang*pi/180; % The tilt of the grating in radians.
    spatialFrequency = sf/36.6011; % How many periods/cycles are there in a pixel? PS.1 degree = 36.6011 pixels according to the formula
    radiansPerPixel = spatialFrequency*(2*pi); % = (periods per pixel) * (2 pi radians per period)
    % Compute ramp
    a=sin(tiltInRadians);
    b=cos(tiltInRadians);
    ramp = (b*x + a*y);
    % gaussian
    gaussian=exp(-((x/sigma).^2)-((y/sigma).^2));
    % grating
    grating = sin(radiansPerPixel*ramp-phase);
    % gabor
    gabor = grating.*gaussian;
    stimuli(ang)=Screen('MakeTexture', window, grey+inc*gabor);
end

DrawFormattedText(window, 'Welcome To Our Experiment.\nToday you will be partaking in our experiment investigating Spatial Heterogeneity.\n Please focus on the red cross that will appear in the middle of the screen.\n One face will randomly shown in a random position around the red cross.\n Press "q" if you think that the gabor patch is left-leaning and "p" if you think it is rihgt-leaning.\n Press any key to begin the experiment.\n You can find an example of a left-leaning gabor patch to your left and right leaning gabor patch to you right', 'center', 'center', [0 0 0]);
Screen('Flip', window);
KbWait;

pixelsPerMM = window_w/width;
w_img = pixelsPerMM * 20; % width of pictures
h_img = pixelsPerMM * 20; % height of pictures

radius = pixelsPerMM * 30;

num_angles = 9;
num_places = 8;
num_repeated_trials = 24;

circle_theta = linspace(360/num_places, 360, num_places);
gabor_theta = linspace(180/num_angles, 180, num_angles);

ang_vec = sort(repmat(gabor_theta, num_places));
place_vec = repmat(circle_theta, num_angles);
all_gabor = vertcat(ang_vec, place_vec);
all_gabor = repmat(all_gabor, 1, num_repeated_trials);
all_gabor = all_gabor(:, randperm(size(all_gabor, 2)));

responses = zeros(1728, 1);
morph_signals = zeros(1728, 1);
angles = zeros(1728, 1);
accuracy = zeros(1728, 1);

for i = 1:12
    x_circle = window_w/2 + (cosd(all_gabor(2,i))*radius);
    y_circle = window_h/2 + (sind(all_gabor(2,i))*radius);
    
    xy_rect = [x_circle - w_img/2; y_circle - h_img/2; x_circle + w_img/2; y_circle + h_img/2]; % put all of the coordinates together and center the pictures
    
     
    Screen('Flip', window); 
    Screen('TextSize',window,75) %Set text size
    Screen('DrawTextures', window, stimuli(all_gabor(1,i)), [], xy_rect);% display the faces
    DrawFormattedText(window, '+', 'center', 'center', [255 0 0]); %display fixation cross
    Screen('Flip', window); %show image
    WaitSecs(0.2); %show for 50 milliseconds
    Screen('Flip',window); %take image away
    
     while 1
        [keyIsDown,seconds,keyCode] = KbCheck;
        if keyCode(KbName('q'))
            response = 'q';
            break
        end
        if keyCode(KbName('p'))
            response = 'p';
            break
        end
    end
    
    if strcmp('q',response)
        responses(i, 1) = 1;
        if i < 0
            accuracy(i, 1) = 1;
        else
            accuracy(i, 1) = 0;
        end
    end 
    if  strcmp('p',response)
        responses(i, 1) = 2;
        if i > 0
            accuracy(i, 1) = 1;
        else
            accuracy(i, 1) = 0;
        end
    end
    
    while keyIsDown == 1
       [keyIsDown,seconds,keycode] = KbCheck(-1);
    end
   
    WaitSecs(0.3);
    
    result{i,1} = all_gabor(2,i);
    result{i,2} = all_gabor(1,i);
    result{i,3} = response;
    result{i,4} = accuracy;
    
    result{1,5} = subj;
    result{1,6} = nameID;
    result{1,7} = age;
    result{1,8} = gender;
    result{1,9} = hand;
    result{1,10} = ethnicity;
    
end 

data = horzcat(responses, morph_signals, angles,accuracy);
xlswrite('data_single.xlsx', data);

ALL=[result{:, 1}; result{:, 2}; result{:, 3}; result{:, 4}];

%close screen and end experiment
cur = pwd();
if ~isfolder([cur '/Participant_Data/'])
    mkdir([cur '/Participant_Data/'])
end

cd([cur '/Participant_Data/']);

data_filename = [char(subj) '_' char(nameID) '_Single.mat'];

save(data_filename,'result', 'ALL'); 

Screen('CloseAll');

cd ..
cd ..