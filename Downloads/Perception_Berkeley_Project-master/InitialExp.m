clear all; close all; clc;
%% Load Screen
Name = input('What is your name? ', 's');
Age = input('What is your age? ', 's');
Handedness = input('What is your handedness? ', 's');
Height = input('What is your hieght?', 's');
Gender= input('What is your gender? ', 's');

Screen('Preference', 'SkipSyncTests', 1);
[window, rect] = Screen('OpenWindow', 0); % opening the screen
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % allowing transparency in the photos

HideCursor();
window_w = rect(3); % window width
window_h = rect(4);% window height

x_center = window_w/2;% window x center
y_center = window_h/2;% window y center

cd('Stimuli') %going to the directory for the faces

%% reading the transparency mask

Screen('FillRect',window,[128 128 128],rect); % make the whole screen black instead of making a mask


%% loading the face stimuli
tid = zeros(1,9); %matrix to store the textures

for i = 1:9
    tmp_bmp = imread([num2str(i) '.bmp']);
     for j = 1:400
         for k = 1:400
             for l = 1:3
        while tmp_bmp(j,k,l) == 0
            tmp_bmp(j,:,:) =  tmp_bmp(j,:,:) + 128;
        end
             end
         end
         
     end
    
    tid(i) = Screen('MakeTexture', window, tmp_bmp);
    Screen('DrawText', window, 'Loading...', x_center, y_center-25); % Write text to confirm loading of images
    Screen('DrawText', window, [int2str(int16(i*100/9)) '%'], x_center, y_center+25); % Write text to confirm percentage complete
    Screen('Flip', window); % Display text
end



w_img = size(tmp_bmp, 2) * 0.35; % width of pictures
h_img = size(tmp_bmp, 1) * 0.35 ; % height of pictures

face_number  = 1:9; % making an array of numbers nine

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculating the Circle Locations

num_pts = 8;

radius = window_h/2 - 200;

% Get a sequence of angles equally spaced around a circle using the
% function "linspace"

%1728 size random vector with 
% 

theta = linspace(360/num_pts, 360, num_pts);

pos_vec = sort(repmat(1:8, 1, 9));
face_vec = repmat(1:9, 1, 8);
all_faces = vertcat(pos_vec, face_vec);
all_faces = repmat(all_faces, 1, 24);
all_faces = all_faces(:, randperm(size(all_faces, 2)));

responses = zeros(1, 1728);
morph_signals = zeros(1, 1728);
angles = zeros(1, 1728);

for i = 1:128
    
    face_pos = theta(all_faces(1, i));
    face = all_faces(2, i);
    angles(1, i) = face_pos;
    morph_signals(1, i) = (face - 5)*12.5;
    
    x_circle = window_w/2 + (cosd(face_pos)*radius);
    y_circle = window_h/2 + (sind(face_pos)*radius);
    
    xy_rect = [x_circle - w_img/2; y_circle - h_img/2; x_circle + w_img/2; y_circle + h_img]; % put all of the coordinates together and center the pictures
    
    %TODO Display Faces
    Screen('Flip', window);
    Screen('TextSize',window,100)
    Screen('DrawTextures', window, tid(face), [], xy_rect);% display the faces
    Screen('DrawText',window,'+',x_center-25,y_center-25,[255 0 0]);
    Screen('Flip', window);
    WaitSecs(1/20);
    
    
    
    
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
    while keyIsDown == 1
        if KbName(keycode) == 's'
            responses(1, i) = 0;
        elseif KbName(keycode) == 'k'
            responses(1, i) = 1;
        end
    end
end

Screen('CloseAll');

cd ..
