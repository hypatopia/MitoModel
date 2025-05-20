function saveExcelReport(app, folderName)
    % Ensure the folder exists or create it
    if ~exist(folderName, 'dir')
        mkdir(folderName);
    end

    % Define the file name and path for the Excel report
    fileName = fullfile(folderName, 'Report.xlsx');
    
    % Extract and organize data from your GUI
    % Example: Assuming you have various tables and data to include
    % Modify these parts based on your actual GUI data

    % Create a new Excel file
    % Using MATLAB's write functions to create sheets and write data

    % Optimized Parameters
    optimizedParams = app.ResultsTable.Data;
    parameterTable = cell2table(optimizedParams, 'VariableNames', {'Parameter', 'Optimized Value'});
    writetable(parameterTable, fileName, 'Sheet', 'Optimized Parameters');

    % MCMC Analysis Results
    if size(app.ResultsTable.Data, 2) >= 4
        mcmcData = app.ResultsTable.Data(:, 1:4);
        mcmcTable = cell2table(mcmcData, 'VariableNames', {'Parameter', 'Optimized Value', 'Mean Value', 'Confidence Interval (CI)'});
        writetable(mcmcTable, fileName, 'Sheet', 'MCMC Analysis Results');
    end

    % Bootstrap Confidence Intervals
    if size(app.ResultsTable.Data, 2) == 5
        bootstrapData = app.ResultsTable.Data;
        bootstrapTable = cell2table(bootstrapData, 'VariableNames', {'Parameter', 'Optimized Value', 'Mean Value', 'Confidence Interval (CI)', 'CI by Bootstrap Samples'});
        writetable(bootstrapTable, fileName, 'Sheet', 'Bootstrap Confidence Intervals');
    end

    % GA Information
    if ~isempty(app.GAInfoTable.Data)
        gaData = app.GAInfoTable.Data;
        gaTable = cell2table(gaData, 'VariableNames', {'Generation', 'Best Score'});
        writetable(gaTable, fileName, 'Sheet', 'GA Information');
    end

    % Correlation Matrix
    paramNames = app.results.parameterNames;
    corrMatrix = app.CorrMatrixTable.Data;
    corrMatrixTable = array2table(corrMatrix, 'VariableNames', ['Parameter', paramNames']);
    writetable(corrMatrixTable, fileName, 'Sheet', 'Correlation Matrix');

    % Dynamic Subplots
    % Assuming dynamic subplots are saved as a figure file (image)
    % If you have multiple images, save each image separately and include their paths

    % Include dynamic subplots figure
    dynamicSubplotsImage = fullfile(folderName, 'DynamicSubplots.png');
    saveas(app.DynamicFigure, dynamicSubplotsImage); % Assuming app.DynamicFigure is the handle to the dynamic subplot figure
    % Add a sheet with the image path or include details about dynamic subplots if needed

    % Notify the user
    msgbox('Excel report has been saved successfully.', 'Success');
end
