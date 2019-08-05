clear all;
close all;
fileName = 'data_single.xlsx';
[status,sheets] = xlsfinfo(fileName);
% include PSE val to order by bias
bias = ones(2, 8);
for i=1:length(sheets) % 1 sheet per participant
    data = xlsread(fileName, sheets{i});
     % sort by 3rd row (angle)
    [temp, order] = sort(data(3,:)); 
    data_sorted_by_angle = data(:,order);
    % split matrix where angle is different i.e. a cell with 8 slots for
    % each angle. 
    data_split_by_angle = splitapply(@(m) {m}, data_sorted_by_angle, findgroups(data_sorted_by_angle(3, :)));
    %celldisp(data_split_by_angle);
    for j=1:length(data_split_by_angle)
        curr = data_split_by_angle{j};
        [temp, order] = sort(curr(2,:));
        % sort each slot in the cell by morph value
        data_split_by_angle{j} = curr(:,order);
        %gets percentage answered female for a particular morph value
        sorted_data  = getPercentChooseFemale(data_split_by_angle{j});
        % graph stuff
        stimulus_data = sorted_data(2,:); % morph values -4 to 4
        response_data =  sorted_data(1,:); % % of times person answer female
        [p1, p2] = j_fit(stimulus_data, response_data,'logistic1',2); % two parameter fit
        % add angle male or female bias depending on p2 (PSE val)
        bias(1, j) = sorted_data(3,1);
        bias(2, j) = p2;
    end
    [temp, order] = sort(bias(2,:)); 
    bias = bias(:,order);
    disp(bias)
    % save bias to spreadsheet
    writematrix(bias,'data_single_bias.xlsx', 'Sheet',i);
end

function percentMat = getPercentChooseFemale(data)
    angleRow = 3;
    morphRow = 2;
    responseRow = 1;
    percentCell = {};

    numFemale = 0;
    totalRespOfMorph = 0;
    morphIdx = 1;
    % loop through in the cell
    for i=1:size(data,2)
        currAngle = data(angleRow,i);
        currMorph = data(morphRow,i);
        resp = data(responseRow,i);
        % check if response for a morph is female
        if resp == 1 
            numFemale = numFemale + 1;
        end
        totalRespOfMorph = totalRespOfMorph + 1;
        % if cell of the next index has a different morph or current index
        % is the last, calculate % female response & reset variables for
        % next morph
        if i == size(data,2) || data(morphRow,i+1) ~= currMorph
            percent = numFemale / totalRespOfMorph;
            percentCell{responseRow, morphIdx} = percent;
            percentCell{morphRow, morphIdx} = currMorph;
            percentCell{angleRow, morphIdx} = currAngle;

            numFemale = 0;
            totalRespOfMorph = 0;
            morphIdx = morphIdx + 1;
        end
    end
    percentMat = cell2mat(percentCell);
end

