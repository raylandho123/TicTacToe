clear all; close all; clc;
%% Load Screen
Info = {'Number','Initials','Gender [1=Male,2=Female,3=Other]','Age','Ethnicity', 'Hand'}; % making questionare
dlg_title = 'Subject Information'; % making questionare
num_lines = 1; % making questionare
subject_info = inputdlg(Info,dlg_title,num_lines); % storing the values in subject_info

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

pixelsPerMM = window_w/width;

cd('Color_stimuli') %going to the directory for the faces

%% reading the transparency mask

Screen('FillRect',window,[127 127 127],rect); % make the whole screen gray 


%% loading the face stimuli
tid = zeros(1,9); %matrix to store the textures

% making the textures for each picture in a for loop and add loading 
for i = 1:9
    tmp = imread([num2str(i) '.png']);
    tid(i) = Screen('MakeTexture', window, tmp);
    Screen('DrawText', window, 'Loading...', x_center, y_center-25); % Write text to confirm loading of images
    Screen('DrawText', window, [int2str(int16(i*100/9)) '%'], x_center, y_center+25); % Write text to confirm percentage complete
    Screen('Flip', window); % Display text
    
end

DrawFormattedText(window, 'Welcome To Our Experiment.\nToday you will be partaking in our experiment investigating Spatial Heterogeneity.\n Please focus on the red cross that will appear in the middle of the screen.\n One face will randomly shown in a random position around the red cross.\n Press "q" if you think that the face is male and "p" if you think it is female.\n Press any key to begin the experiment.\n', 'center', 'center', [0 0 0]);
Screen('Flip', window);
KbWait;

w_img = pixelsPerMM * 20; % width of pictures
h_img = pixelsPerMM * 20; % height of pictures

face_number  = 1:9; % making an array of numbers nine

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculating the Circle Locations
num_pts = 8; % number of point in the circle

radius = pixelsPerMM * 30; % radius of the circle

% Get a sequence of angles equally spaced around a circle using the
% function "linspace"
% 

theta = linspace(360/num_pts, 360, num_pts);

% makes a vector that is 2 by 1728 first row having all the position of the
% faces and the second having all the faces, we first made a vector of 2 by
% 72 by making a face match each position, then shuffled using randperm
pos_vec = sort(repmat(1:8, 1, 9));
color_vec = repmat(1:9, 1, 8);
all_colors = vertcat(pos_vec, color_vec);
all_colors = repmat(all_colors, 1, 24);
all_colors = all_colors(:, randperm(size(all_colors, 2)));

%Blank arrays for each trial's responses, morph_signals, and angles to send
%to data analysis
responses = zeros(1728, 1);
morph_signals = zeros(1728, 1);
angles = zeros(1728, 1);
accuracy = zeros(1728, 1);

for i = 1:12
    
    % Takes first row element of all_faces and passes to theta to get the
    % angle
    color_pos = theta(all_colors(1, i));
    %Gets face number from all_faces matrix
    color = all_colors(2, i);
    %Writes face_pos to angles for data collection
    angles(i, 1) = color_pos;
    %Writes morph signals into -4 to 4 for data
    %collection
    morph_signals(i, 1) = color;
    
    %Set up circle to show the pictures
    x_circle = window_w/2 + (cosd(color_pos)*radius);
    y_circle = window_h/2 + (sind(color_pos)*radius);
    
    xy_rect = [x_circle - w_img/2; y_circle - h_img/2; x_circle + w_img/2; y_circle + h_img/2]; % put all of the coordinates together and center the pictures
    
    %Actually displays faces
    Screen('Flip', window); 
    Screen('TextSize',window,75) %Set text size
    Screen('DrawTextures', window, tid(color), [], xy_rect);% display the faces
    DrawFormattedText(window, '+', 'center', 'center', [255 0 0]); %display fixation cross
    Screen('Flip', window); %show image
    WaitSecs(0.2); %show for 50 milliseconds
    Screen('Flip',window); %take image away

    %Checks for key presses and stores them in variable response
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
        if color < 0
            accuracy(i, 1) = 1;
        else
            accuracy(i, 1) = 0;
        end
    end 
    if  strcmp('p',response)
        responses(i, 1) = 2;
        if color > 0
            accuracy(i, 1) = 1;
        else
            accuracy(i, 1) = 0;
        end
    end
    
    while keyIsDown == 1
       [keyIsDown,seconds,keycode] = KbCheck(-1);
    end
   
    WaitSecs(0.3);
    
    result{i,1} = color;
    result{i,2} = color_pos;
    result{i,3} = response(i, 1);
    result{i,4} = accuracy(i, 1);
    
    result{1,5} = subj;
    result{1,6} = nameID;
    result{1,7} = age;
    result{1,8} = gender;
    result{1,9} = hand;
    result{1,10} = ethnicity;
   
end

%close screen and end experiment
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