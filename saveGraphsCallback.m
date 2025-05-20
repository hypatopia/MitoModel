function saveGraphsCallback(app)
    % Define the base path for saving graphs
    resultsFolder = fullfile(pwd, 'Results');
    saveFolder = fullfile(resultsFolder, 'Saved Graphs');
    
    % Create the 'Saved Graphs' folder if it doesn't exist
    if ~exist(saveFolder, 'dir')
        mkdir(saveFolder);
    end
    
    % Define the list of axes to save (adjust based on your app's axes)
    axesList = {app.O2_plot, app.OCR_plot, app.Cytc_plot, app.H_N_plot, app.H_P_plot};
    
    % Define file extensions for the graphs (you can modify this as needed)
    fileExtensions = {'.png', '.jpg', '.tif', '.pdf'};
    
    % Loop through each plot and save it in each of the specified formats
    for i = 1:length(axesList)
        for j = 1:length(fileExtensions)
            % Construct the file name for each plot and format
            currentFileName = sprintf('plot%d%s', i, fileExtensions{j});
            currentFilePath = fullfile(saveFolder, currentFileName);
            
            % Save the current plot using exportgraphics
            exportgraphics(axesList{i}, currentFilePath);
        end
    end
    
    % Optionally, notify the user that the graphs have been saved
    msgbox('Graphs have been successfully saved in the "Saved Graphs" folder.', 'Save Graphs');
end
