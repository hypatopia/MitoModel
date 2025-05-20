% Define the file names
fileNames = {
    'GA_MultipleRuns_Results_Sandeep16_1.mat', ...
    'GA_MultipleRuns_Results_Sandeep16_2.mat', ...
    'GA_MultipleRuns_Results_Sandeep16_3.mat', ...
    'GA_MultipleRuns_Results_Sandeep16_4.mat',...
    'GA_MultipleRuns_Results_Sandeep16_5.mat'
};

% fileNames = {
%     'GA_MultipleRuns_Results_Sandeep21_AVG_1.mat', ...
%     'GA_MultipleRuns_Results_Sandeep21_AVG_2.mat'
% };

% Initialize empty arrays/cells for each field
allOptimizedParams = [];
allFinalErrors = [];
allGaInfo = [];

% Loop through each file and load the data
for i = 1:length(fileNames)
    % Load the .mat file
    fileData = load(fileNames{i});
    
    % Check if the necessary fields exist
    if isfield(fileData, 'optimizedParamsArray') && ...
       isfield(fileData, 'finalErrorsArray') && ...
       isfield(fileData, 'gaInfoArray')
        
        % Concatenate data from each field
        allOptimizedParams = [allOptimizedParams; fileData.optimizedParamsArray];
        allFinalErrors = [allFinalErrors; fileData.finalErrorsArray];
        allGaInfo = [allGaInfo; fileData.gaInfoArray];
    else
        error('Missing expected fields in file: %s', fileNames{i});
    end
end

% Convert concatenated data to tables
optimizedParamsTable = cell2table(allOptimizedParams, 'VariableNames', {'OptimizedParams'});
finalErrorsTable = array2table(allFinalErrors, 'VariableNames', {'FinalErrors'});
gaInfoTable = cell2table(allGaInfo, 'VariableNames', {'GaInfo'});

% Combine all tables into one (side by side)
combinedTable = [optimizedParamsTable, finalErrorsTable, gaInfoTable];

% Define the output CSV file name
csvFileName = 'GA_MultipleRuns_Results_Combined.csv';

% Write the combined table to a CSV file
writetable(combinedTable, csvFileName);

disp(['Combined data saved to ', csvFileName]);
