clear all 
% load('MDM2data_transformed.mat');

stimulus_data = sorted_data(:,2); % this should correspond to the column...
% with the negative and positive integers (no decimals);
response_data =  sorted_data(:,3);% should correspond to accuracy which should be 0 & 1

% curve fit for condition 1
[a_cond1 b_cond1] = j_fit(stimulus_data, response_data,'logistic1',2); % two parameter fit
